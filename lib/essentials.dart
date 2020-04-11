library essentials;

import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:essentials/values_and_localization/localized.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

const String FIREBASE_TOKEN_KEY = 'userFireBaseToken';
const String REMEMBER_ME_KEY = 'REMEMBER_ME';
const String NOTIFY_ME_KEY = 'NOTIFY_ME';
const String FIRST_TIME_KEY = 'FIRST_TIME';
const String USER_LANG_KEY = "userLang";
const String USER_PASS_KEY = 'userPass';
const String USER_PHONE_KEY = 'userPhone';

Future setSharedPref({
  @required List<String> keys,
  @required List<dynamic> values,
}) async {
  return SharedPreferences.getInstance().then((sharedPref) {
    prefs = sharedPref;
    keys.forEach((shared) {
      if (sharedPref.containsKey(shared)) {
        int index = keys.indexOf(shared);
        values[index] = sharedPref.get(shared);
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
  @required List<String> keys,
  @required List<dynamic> values,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await setSharedPref(
    values: values,
    keys: keys,
  );
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
  @required List<String> keys,
  @required List<dynamic> values,
}) async {
  await setSharedPref(values: values, keys: keys).then((_) {
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
  @required List<String> keys,
  @required List<dynamic> values,
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
      await setSharedPref(values: values, keys: keys).then((_) {
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
