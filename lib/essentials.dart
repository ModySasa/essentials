library essentials;

import 'dart:io';
import 'dart:ui';

import 'package:background_fetch/background_fetch.dart';
import 'package:dio/dio.dart';
import 'package:essentials/values_and_localization/localized.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({@required this.id, @required this.title, @required this.body, @required this.payload});
}

void customPrint({
  @required List<dynamic> values,
  bool printSingle = false,
  String customMessage,
  String tag = 'My Custom Log,val is : ',
}) {
  String printedVal = tag;
  if (customMessage != null) printedVal += customMessage;
  values.forEach((singleVal) {
    if (printSingle) print('$tag$singleVal');
    printedVal += ' $singleVal';
  });
  if (!printSingle) print(printedVal);
}

SharedPreferences prefs;
bool notifyMe;
bool firstTime;
FirebaseApp app;
FirebaseDatabase database;
String fireBaseToken;
String userPhone;
String userFirebaseKey = '+2$userPhone';
String userPass;
String appName;
String packageName;
String version;
String buildNumber;
String currentAppLink;
int fireBaseVersion;

const String FIREBASE_VERSION_KEY = 'versionNumber';
const String FIREBASE_LINK_KEY = 'appURL';

const String FIREBASE_TOKEN_KEY = 'userFireBaseToken';
const String REMEMBER_ME_KEY = 'REMEMBER_ME';
const String NOTIFY_ME_KEY = 'NOTIFY_ME';
const String FIRST_TIME_KEY = 'FIRST_TIME';
const String USER_LANG_KEY = "userLang";
const String USER_PASS_KEY = 'userPass';
const String USER_PHONE_KEY = 'userPhone';

Future setSharedPref({
  @required Map<String, dynamic> shared,
}) async {
  return SharedPreferences.getInstance().then((sharedPref) {
    prefs = sharedPref;
    shared.forEach((key, value) {
      if (sharedPref.containsKey(key)) {
        value = sharedPref.get(key);
      }
    });
    if (prefs.containsKey(USER_LANG_KEY)) {
      Localized.userLangCode = prefs.getString(USER_LANG_KEY);
    } else {
      Localized.userLangCode = "en";
    }
    if (prefs.containsKey(USER_PHONE_KEY)) {
      userPhone = prefs.getString(USER_PHONE_KEY);
    }
    if (prefs.containsKey(USER_PASS_KEY)) {
      userPass = prefs.getString(USER_PASS_KEY);
    }
    if (prefs.containsKey(FIREBASE_TOKEN_KEY)) {
      fireBaseToken = prefs.getString(FIREBASE_TOKEN_KEY);
    }
    if (prefs.containsKey(NOTIFY_ME_KEY)) {
      notifyMe = prefs.getBool(NOTIFY_ME_KEY);
    } else {
      notifyMe = true;
    }
  });
}

Future<void> showNotification({
  @required String title,
  @required String body,
  @required String channelId,
  @required int key,
  bool autoCancel = false,
  bool ongoing = false,
  StyleInformation style,
  Color color = Colors.black,
  Color ledColor = Colors.green,
}) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    channelId,
    channelId,
    'your channel description',
    importance: Importance.Max,
    priority: Priority.High,
    ticker: 'ticker',
    autoCancel: autoCancel,
    ongoing: ongoing,
    styleInformation: style != null ? style : DefaultStyleInformation(false, false),
    color: color,
    enableLights: true,
    ledColor: ledColor,
    ledOffMs: 500,
    ledOnMs: 1000,
  );
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  customPrint(values: [notifyMe]);
  if (notifyMe) await FlutterLocalNotificationsPlugin().show(key, title, body, platformChannelSpecifics, payload: 'item x');
}

Future setUpApp({
  @required Map<String, dynamic> shared,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await setSharedPref(
    shared: shared,
  );

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  appName = packageInfo.appName;
  packageName = packageInfo.packageName;
  version = packageInfo.version;
  buildNumber = packageInfo.buildNumber;

  var initializationSettingsAndroid = AndroidInitializationSettings('ic_logo_bringero');
  var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: (int id, String title, String body, String payload) async {
    didReceiveLocalNotificationSubject.add(ReceivedNotification(id: id, title: title, body: body, payload: payload));
  });
  var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String payload) async {
    /*if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }*/
    selectNotificationSubject.add(payload);
  });
  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(
  String taskId, {
  @required Map<String, dynamic> shared,
}) async {
  await setSharedPref(shared: shared).then((_) {
    switch (taskId) {
      default:
        print(taskId);
    }
    BackgroundFetch.finish(taskId);
  });
}

Future<dynamic> backGroundHandler(Map<String, dynamic> message) async {
  customPrint(values: ['on background']);
  showNot(message);
}

Future showNot(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    await showNotification(title: message['data']['title'], body: message['data']['body'], channelId: message['data']['channelId'], key: 10);
  } else {
    await showNotification(title: message['title'], body: message['body'], channelId: 'FireBaseApp', key: 101);
  }
}

void iOSPermission() {
  _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
  _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
    print("Settings registered: $settings");
  });
}

void firebaseCloudMessagingListeners() {
  if (Platform.isIOS) iOSPermission();
  _firebaseMessaging.getToken().then((token) {
    if (fireBaseToken == null) {
      prefs.setString(FIREBASE_TOKEN_KEY, token);
      fireBaseToken = token;
    } else if (fireBaseToken.isEmpty) {
      prefs.setString(FIREBASE_TOKEN_KEY, token);
      fireBaseToken = token;
    }
  });

  _firebaseMessaging.configure(
    onBackgroundMessage: backGroundHandler,
    onMessage: (Map<String, dynamic> message) async {
      customPrint(values: [message], customMessage: "on message");
      await showNot(message);
    },
    onResume: (Map<String, dynamic> message) async {
      customPrint(values: [message], customMessage: "on resume");
      await showNot(message);
    },
    onLaunch: (Map<String, dynamic> message) async {
      customPrint(values: [message], customMessage: "on launch");
      await showNot(message);
    },
  );
}

Future<void> initPlatformState(
  doSomeThing, {
  @required Map<String, dynamic> shared,
  bool mounted,
}) async {
  // Configure BackgroundFetch.
  BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        forceAlarmManager: true,
        requiredNetworkType: NetworkType.ANY,
      ), (String taskId) async {
    if (prefs == null) {
      await setSharedPref(shared: shared).then((_) {
        doSomeThing(taskId);
      });
    } else {
      doSomeThing(taskId);
    }
    BackgroundFetch.finish(taskId);
  }).catchError((e) {
    print('[BackgroundFetch] configure ERROR: $e');
  });
  //TODO schedule background tasks here
  if (!mounted) return;
}

Future onClickInstallApk(String saveLocation, String myPackageName) async {
  if (saveLocation.isEmpty) {
    print('make sure the apk file is set');
    return;
  }

  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
  ].request();

  if (statuses[Permission.storage] == PermissionStatus.granted) {
    InstallPlugin.installApk(saveLocation, myPackageName).then((result) {
      customPrint(values: ['install apk $result']);
    }).catchError((error) {
      customPrint(values: ['install apk error: $error']);
    });
  } else {
    customPrint(values: ['Permission request fail!']);
  }
}

Future<bool> needUpdate() async {
  customPrint(values: [buildNumber]);
  customPrint(values: [fireBaseVersion]);
  if (fireBaseVersion != null)
    return fireBaseVersion > int.parse(buildNumber);
  else
    return false;
}

Future checkAndDownload(String myPackageName) async {
  needUpdate().then((inNeed) async {
    if (inNeed) {
      await downloadAPKFile(myPackageName).then((_) {});
    }
  });
}

Future downloadAPKFile(
  String myPackageName,
) async {
  Dio dio = new Dio();
  int i = 0;
  await dio.download(currentAppLink, await UrlToFilename.file(), onReceiveProgress: (currentProgress, maxProgress) async {
    if (maxProgress != -1) {
      if (currentProgress > i) i = currentProgress;
      customPrint(values: ['Donwloading progress ${(i * 100 / maxProgress).toStringAsFixed(0)} %']);
      await Future.delayed(Duration(milliseconds: 500), () async {
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'download_apk',
          'download_apk',
          'donwloading apk files',
          channelShowBadge: false,
          ongoing: i < 99,
          importance: Importance.Low,
          priority: Priority.High,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: maxProgress,
          progress: i,
        );
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin
            .show(122, 'Downloading', 'Donwloading progress ${(i * 100 / maxProgress).toStringAsFixed(0)} %', platformChannelSpecifics, payload: 'item x');
      });
    }
  }).whenComplete(() async {
    onClickInstallApk(await UrlToFilename.file(), myPackageName);
  });
}

class UrlToFilename {
  static Future<String> file() => getExternalStorageDirectory().then((dir) => Directory(dir.path + "/data/")).then((dir) async {
        customPrint(values: [dir.path]);
        if (!await dir.exists()) {
          dir.create();
        }
        return "${dir.path}/${currentAppLink.split('/').last}";
      });
}

Future<void> _showProgressNotification(progress, maxProgress) async {
  for (var i = 0; i <= maxProgress; i++) {
    await Future.delayed(Duration(seconds: 1), () async {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails('download_apk', 'download_apk', 'donwloading apk files',
          channelShowBadge: false,
          importance: Importance.Low,
          priority: Priority.High,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: maxProgress,
          progress: i);
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(0, 'progress notification title', 'progress notification body', platformChannelSpecifics, payload: 'item x');
    });
  }
}
