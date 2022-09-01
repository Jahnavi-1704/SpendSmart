import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> createExpenseNotification(String userName, String tracking) async {

  if(tracking == "yearly")
  {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: UniqueKey().hashCode,
        channelKey: 'basic_channel',
        title: '$userName, current year has ended',
        body: 'Select which goals you would like to contribute your savings towards.',
        notificationLayout: NotificationLayout.Default,
        payload: {
          'type': 'expense',
        },
      ),
      schedule: NotificationCalendar(
          month: 1,
          day: 1,
          second: 0,
          millisecond: 0,
          repeats: true
      ),
    );
  }
  else if(tracking == "monthly")
  {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: UniqueKey().hashCode,
        channelKey: 'basic_channel',
        title: '$userName, current month has ended',
        body: 'Select which goals you would like to contribute your savings towards.',
        notificationLayout: NotificationLayout.Default,
        payload: {
          'type': 'expense',
        },
      ),
      schedule: NotificationCalendar(
          day: 1,
          second: 0,
          millisecond: 0,
          repeats: true
      ),
    );
  }
  else if(tracking == "daily")
  {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: UniqueKey().hashCode,
        channelKey: 'basic_channel',
        title: '$userName, current day has ended',
        body: 'Select which goals you would like to contribute your savings towards.',
        notificationLayout: NotificationLayout.Default,
        payload: {
          'type': 'expense',
        },
      ),
      schedule: NotificationCalendar(
          hour: 8,
          second: 0,
          millisecond: 0,
          repeats: true
      ),
    );
  }


}

Future<void> createGoalNotification(String userName, DateTime scheduledDate, String goalName) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: UniqueKey().hashCode,
      channelKey: 'basic_channel',
      title: '$userName, your $goalName goal has ended',
      body: 'Congrats on achieving your goal, Keep going!',
      notificationLayout: NotificationLayout.Default,
      payload: {
        'type': 'goal',
      },
    ),
    schedule: NotificationCalendar.fromDate(date: scheduledDate),
  );
}

Future<List<NotificationModel>> retrieveNotifications() async {
  return  AwesomeNotifications().listScheduledNotifications();

  // do something with list

}

Future<void> cancelAllNotifications() async {
  await AwesomeNotifications().cancelAll();
}

Future<void> cancelNotification(int id) async {
  await AwesomeNotifications().cancel(id);
}

// flutter_local_notifications

// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
//
// class NotificationService {
//   static final NotificationService _notificationService =
//   NotificationService._internal();
//
//   factory NotificationService() {
//     return _notificationService;
//   }
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   NotificationService._internal();
//
//   // function to initialize notifications
//   Future<void> initNotification() async {
//
//     // Android initialization
//     final AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     // ios initialization
//     final IOSInitializationSettings initializationSettingsIOS =
//     IOSInitializationSettings(
//       requestAlertPermission: false,
//       requestBadgePermission: false,
//       requestSoundPermission: false,
//     );
//
//     final InitializationSettings initializationSettings =
//     InitializationSettings(
//         android: initializationSettingsAndroid,
//         iOS: initializationSettingsIOS);
//     // the initialization settings are initialized after they are setted
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }
//
//   // function to create scheduled notifications
//   Future<void> createNotification(int id, String title, String body, DateTime scheduledDate) async {
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(scheduledDate, tz.local), //schedule the notification to show after 2 seconds.
//       const NotificationDetails(
//
//         // Android details
//         android: AndroidNotificationDetails('main_channel', 'Main Channel',
//             channelDescription: "ashwin",
//             importance: Importance.max,
//             priority: Priority.max),
//         // iOS details
//         iOS: IOSNotificationDetails(
//           sound: 'default.wav',
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       ),
//
//       // Type of time interpretation
//       uiLocalNotificationDateInterpretation:
//       UILocalNotificationDateInterpretation.absoluteTime,
//       androidAllowWhileIdle: true, // To show notification even when the app is closed
//     );
//   }
//
//   Future<void> retrieveNotification() async {
//     var list = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
//     print(list.length);
//     // print(list[0].title);
//     // print(list[0].id);
//     // print(list[0].body);
//   }
//
//   Future<void> cancelAllNotifications() async {
//     await flutterLocalNotificationsPlugin.cancelAll();
//   }
//
//   Future<void> cancelNotification(String title) async {
//     // first retrieve all pending notifications
//     var list = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
//     int id = 0;
//
//     // search through the list for index whose title matches passed in argument
//     for(var notification in list) {
//       if(notification.title == title) {
//         // get it's id
//         id = notification.id;
//       }
//     }
//
//     // cancel that particular notification
//     await flutterLocalNotificationsPlugin.cancel(id);
//   }
//
// }
