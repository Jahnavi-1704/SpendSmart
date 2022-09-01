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