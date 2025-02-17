// // ignore_for_file: deprecated_member_use

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:intl/intl.dart'; // For date formatting
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import '../models/medication.dart';

// class NotificationService {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   NotificationService() {
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     const AndroidInitializationSettings androidInitializationSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: androidInitializationSettings);

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);

//     // Initialize timezones
//     tz.initializeTimeZones();
//   }

//   Future<void> scheduleMedicationNotifications(Medication medication) async {
//     DateTime medicationTime =
//         DateFormat('yyyy-MM-dd HH:mm').parse(medication.timing);

//     // Notification times
//     DateTime tenMinutesBefore = medicationTime.subtract(Duration(minutes: 10));
//     DateTime fiveMinutesBefore = medicationTime.subtract(Duration(minutes: 5));
//     DateTime onTime = medicationTime;

//     // Schedule notifications
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0, // ID for the notification
//       'Medication Reminder',
//       'Your medication is in 10 minutes.',
//       _convertToTZ(tenMinutesBefore),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'medication_channel',
//           'Medication Reminders',
//           channelDescription: 'Daily medication reminders',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//       ),
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       androidAllowWhileIdle: true,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       1, // ID for the notification
//       'Medication Reminder',
//       'Your medication is in 5 minutes.',
//       _convertToTZ(fiveMinutesBefore),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'medication_channel',
//           'Medication Reminders',
//           channelDescription: 'Daily medication reminders',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//       ),
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       androidAllowWhileIdle: true,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       2, // ID for the notification
//       'Medication Reminder',
//       'It\'s time to take your medication.',
//       _convertToTZ(onTime),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'medication_channel',
//           'Medication Reminders',
//           channelDescription: 'Daily medication reminders',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//       ),
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       androidAllowWhileIdle: true,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }

//   tz.TZDateTime _convertToTZ(DateTime dateTime) {
//     final tz.TZDateTime tzDateTime = tz.TZDateTime.from(dateTime, tz.local);
//     return tzDateTime;
//   }
// }
