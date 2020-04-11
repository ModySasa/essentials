import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  ///Example of tableConstruction:
  /// _id INTEGER PRIMARY KEY AUTOINCREMENT , lat REAL, lng REAL, time INTEGER , city TEXT , country TEXT

  static Future<void> insert({String dbName, String table, Map<String, dynamic> data, String tableConstruction}) async {
    sql.Database sqlDB = await database(dbName: dbName, table: table, tableConstruction: tableConstruction);
    Future<void> returnVal;
    if (await checkTableExists(dbName: dbName, table: table, tableConstruction: tableConstruction)) {
      returnVal = sqlDB.insert(
        table,
        data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );
    } else {
      await sqlDB.execute('CREATE TABLE $table ($tableConstruction)').then((_) {
        returnVal = sqlDB.insert(
          table,
          data,
          conflictAlgorithm: sql.ConflictAlgorithm.replace,
        );
      });
    }
    return returnVal;
  }

  static Future<List<Map<String, dynamic>>> read({String dbName, String table, String tableConstruction}) async {
    sql.Database sqlDB = await database(dbName: dbName, table: table, tableConstruction: tableConstruction);
    Future<List<Map<String, dynamic>>> returnVal;
    if (await checkTableExists(dbName: dbName, table: table, tableConstruction: tableConstruction)) {
      returnVal = sqlDB.query(
        table,
      );
    } else {
      await sqlDB.execute('CREATE TABLE $table ($tableConstruction)').then((_) {
        returnVal = sqlDB.query(
          table,
        );
      });
    }
    return returnVal;
  }

  static Future<void> clearTable({String dbName, String table, String tableConstruction}) async {
    sql.Database sqlDB = await database(dbName: dbName, table: table, tableConstruction: tableConstruction);
    return await sqlDB.execute(
      "DROP TABLE IF EXISTS $table",
    );
  }

  static Future<bool> checkTableExists({String dbName, String table, String tableConstruction}) async {
    sql.Database sqlDb = await database(dbName: dbName, table: table, tableConstruction: tableConstruction);
    bool exist = false;
    await sqlDb.query(table).catchError((error, stackTrace) {
      exist = false;
    }).then((count) {
      if (count != null) {
        exist = true;
      } else {
        exist = false;
      }
    });
    return exist;
  }

  static Future<Database> database({String dbName, String table, String tableConstruction}) async {
    final dpPath = await sql.getDatabasesPath();
    return await sql.openDatabase(
      path.join(
        dpPath,
        '$dbName.db',
      ),
      onCreate: (db, version) {
        db.execute('CREATE TABLE $table ($tableConstruction)');
      },
      version: 1,
    );
  }
}
