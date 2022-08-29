import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show File, Platform;
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

NotificationPlugin notificationPlugin = NotificationPlugin._();

class NotificationPlugin {

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  /// BehaviorSubject is, by default, a broadcast controller, in order
  /// to fulfill the Rx Subject contract. This means the Subject's `stream` can
  /// be listened to multiple times.

  final BehaviorSubject<ReceivedNotification>
      didReceivedLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();

  NotificationPlugin._() {
    init();
  }

  init() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    initializePlatformSpecifics();
  }

  initializePlatformSpecifics() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/app_notf_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        ReceivedNotification receivedNotification = ReceivedNotification(
            id: id, title: title ?? "", body: body ?? "", payload: payload ?? "");
        didReceivedLocalNotificationSubject.add(receivedNotification);
      },
    );

     InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  setListenerForLowerVersions(Function onNotificationInLowerVersions) {
    didReceivedLocalNotificationSubject.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
  }

  Future<void> showNotification() async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      channelDescription: "channel_desc",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
      icon: "app_notf_icon"
    );
    var iosChannelSpecifics = IOSNotificationDetails(subtitle: "This is the subtitle in ios");
    var platformChannelSpecifics = NotificationDetails(android: androidChannelSpecifics,iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      1,
      'This title is for testing purpose in simple notification',
      'This body is for besting purpose in simple notification', //null
      platformChannelSpecifics,
      payload: 'New Payload',

    );
  }

Future<void> scheduleNotification() async {
  var scheduleNotificationDateTime = DateTime.now().add(Duration(seconds: 5));
  var androidChannelSpecifics = AndroidNotificationDetails(
    'CHANNEL_ID 1',
    'CHANNEL_NAME 1',
    icon: 'shop',
    largeIcon: DrawableResourceAndroidBitmap('buy_now'),
    enableLights: true,
    color: const Color.fromARGB(255, 255, 0, 0),
    ledColor: const Color.fromARGB(255, 255, 0, 0),
    ledOnMs: 1000,
    ledOffMs: 500,
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    timeoutAfter: 5000,
    styleInformation: DefaultStyleInformation(true, true),
  );
  var iosChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(android: androidChannelSpecifics,iOS: iosChannelSpecifics);

  await flutterLocalNotificationsPlugin.schedule(
    0,
    'This title is for testing purpose in simple notification',
    'This body is for besting purpose in simple notification',
    scheduleNotificationDateTime,
    platformChannelSpecifics,
    payload: 'Test Payload',
  );
}

//decode your image
Future<void> showNotificationWithAttachment() async {
  var attachmentPicturePath = await _downloadAndSaveFile(
      'https://via.placeholder.com/800x200', 'attachment_img.jpg');
  var iOSPlatformSpecifics = IOSNotificationDetails(
    attachments: [IOSNotificationAttachment(attachmentPicturePath)],
  );
  var bigPictureStyleInformation = BigPictureStyleInformation(
    FilePathAndroidBitmap(attachmentPicturePath),
    contentTitle: '<b>Attached Image</b>',
    htmlFormatContentTitle: true,
    summaryText: 'Flipkart big billion sell is live now !!',
    htmlFormatSummaryText: true,
  );
  var androidChannelSpecifics = AndroidNotificationDetails(
    'CHANNEL ID 2',
    'CHANNEL NAME 2',
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: bigPictureStyleInformation,
  );
  var platformChannelSpecifics = NotificationDetails(android: androidChannelSpecifics,iOS: iOSPlatformSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Title with attachment',
    'Body with Attachment',
    platformChannelSpecifics,
  );
}

_downloadAndSaveFile(String url, String fileName) async {
  var directory = await getApplicationDocumentsDirectory();
  var filePath = '${directory.path}/$fileName';
  var response = await http.get(Uri.parse(url));
  var file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<void> repeatNotification() async {
  var androidChannelSpecifics = AndroidNotificationDetails(
    'CHANNEL_ID 3',
    'CHANNEL_NAME 3',
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: DefaultStyleInformation(true, true),
  );
  var iosChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(android: androidChannelSpecifics,iOS: iosChannelSpecifics);
  await flutterLocalNotificationsPlugin.periodicallyShow(
    1,
    'This title is for testing purpose in simple notification',
    'This body is for besting purpose in simple notification',
    RepeatInterval.everyMinute,
    platformChannelSpecifics,
    payload: 'Test Payload',
  );
}

 Future<void> showDailyAtTime() async {
    var time = Time(21, 3, 0);
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 4',
      'CHANNEL_NAME 4',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidChannelSpecifics,iOS: iosChannelSpecifics);

    await flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      'Test Title at ${time.hour}:${time.minute}.${time.second}',
      'Test Body', //null
      time,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }


  Future<void> showWeeklyAtDayTime() async {
    var time = Time(21, 5, 0);
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 5',
      'CHANNEL_NAME 5',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidChannelSpecifics,iOS: iosChannelSpecifics);

    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      0,
      'Test Title at ${time.hour}:${time.minute}.${time.second}',
      'Test Body', //null
      Day.saturday,
      time,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }

  Future<int> getPendingNotificationCount() async {
    List<PendingNotificationRequest> p =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return p.length;
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  setOnNotificationClick(Function onNotificationClick) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/app_notf_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        ReceivedNotification receivedNotification = ReceivedNotification(
            id: id, title: title ?? "", body: body ?? "", payload: payload ?? "");
        didReceivedLocalNotificationSubject.add(receivedNotification);
      },
    );

    InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload){
      onNotificationClick(payload);
        }
        );
  }


}


class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}
