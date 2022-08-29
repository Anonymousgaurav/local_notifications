import 'package:flutter/material.dart';
import 'package:local_notifications/firebase/NotificationPlugin.dart';
import 'package:local_notifications/presentation/screens/NotificationScreen.dart';

class LocalNotificationScreen extends StatefulWidget {
  @override
  _LocalNotificationScreenState createState() =>
      _LocalNotificationScreenState();
}

class _LocalNotificationScreenState extends State<LocalNotificationScreen> {
  int count = 0;

  @override
  void initState() {
    super.initState();

    notificationPlugin
        .setListenerForLowerVersions(onNotificationInLowerVersions);
    notificationPlugin.setOnNotificationClick(onSelectNotification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Notifications'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () async {
            await notificationPlugin.showNotification();
            // await notificationPlugin.scheduleNotification();
            // await notificationPlugin.showNotificationWithAttachment();
            // await notificationPlugin.repeatNotification();
            // await notificationPlugin.showDailyAtTime();
            // await notificationPlugin.showWeeklyAtDayTime();
            //  count = await notificationPlugin.getPendingNotificationCount();
            //  print('Count $count');
            //  await notificationPlugin.cancelNotification();
            //  count = await notificationPlugin.getPendingNotificationCount();
            //  print('Count $count');
          },
          child: Text('Send Notification'),
        ),
      ),
    );
  }

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
    print('Notification Received ${receivedNotification.id}');
  }

  onSelectNotification(String? payload) {
    if (payload != null) {
      return Navigator.push(context, MaterialPageRoute(builder: (coontext) {
        return NotificationScreen(
          payload: payload,
        );
      }));
    }
  }
}
