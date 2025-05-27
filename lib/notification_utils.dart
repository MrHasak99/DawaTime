import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medication_app_full/database/medications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Medications medicationFromDoc(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return Medications(
    name: data['name'] ?? '',
    typeOfMedication: data['typeOfMedication'] ?? '',
    dosage: double.tryParse(data['dosage'].toString()) ?? 0,
    frequency: data['frequency'] ?? '',
    amount: double.tryParse(data['amount'].toString()) ?? 0,
    notifyTime: data['notifyTime'],
  );
}

Future<void> scheduleMedicationNotification(
  String docId,
  Medications medication,
) async {
  await flutterLocalNotificationsPlugin.cancel(docId.hashCode);
  if (medication.notifyTime == null || medication.notifyTime!.isEmpty) {
    return;
  }

  final timeParts = medication.notifyTime!.split(':');
  if (timeParts.length != 2) return;

  final hour = int.tryParse(timeParts[0]) ?? 0;
  final minute = int.tryParse(timeParts[1]) ?? 0;

  final now = DateTime.now();
  var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

  if (scheduledTime.isBefore(now)) {
    scheduledTime = scheduledTime.add(const Duration(days: 1));
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    docId.hashCode,
    'Medication Reminder',
    'Time to take ${medication.name}!',
    tz.TZDateTime.from(scheduledTime, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'medication_channel',
        'Medication Reminders',
        channelDescription: 'Reminds you to take your medication',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(presentSound: true),
    ),
    payload: 'Time to take ${medication.name}!',
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}