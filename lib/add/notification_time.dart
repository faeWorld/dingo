// notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _scheduleNotification(DateTime date, int remindMeInDays,
    String userTitle, String userBody) async {
  // Convert DateTime to TZDateTime
  final tz.TZDateTime scheduledDate =
      tz.TZDateTime.from(date.add(Duration(days: remindMeInDays)), tz.local);

  // Notification details
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'activity_reminder_channel', // Channel ID
    'Activity Reminders', // Channel name
    channelDescription:
        'Notifications for scheduled activities and reminders', // Channel description
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Schedule the notification
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0, // Notification ID
    userTitle, // Use user-defined title
    userBody, // Use user-defined body
    scheduledDate, // Scheduled date/time
    platformChannelSpecifics, // Notification details
    androidAllowWhileIdle: true, // Allow notifications while idle
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime, // Interpretation
    matchDateTimeComponents:
        DateTimeComponents.dateAndTime, // Match date and time components
  );
}
