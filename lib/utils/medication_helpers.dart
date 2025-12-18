library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawatime/home_page.dart';
import 'package:dawatime/utils/medication_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dawatime/home_page.dart' show Medications;
import 'package:dawatime/l10n/app_localizations.dart';
import 'package:dawatime/main.dart' show navigatorKey;

Medications medicationFromDoc(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  List<int>? daysOfWeek;
  if (data['daysOfWeek'] != null) {
    if (data['daysOfWeek'] is String) {
      daysOfWeek =
          (data['daysOfWeek'] as String)
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>()
              .toList();
    } else if (data['daysOfWeek'] is List) {
      daysOfWeek = List<int>.from(data['daysOfWeek']);
    }
  }
  return Medications(
    name: data['name'] ?? '',
    typeOfMedication: data['typeOfMedication'] ?? '',
    dosage: (data['dosage'] ?? 0).toDouble(),
    frequency: (data['frequency'] ?? 1),
    amount: (data['amount'] ?? 0).toDouble(),
    notifyTime: data['notifyTime']?.toString(),
    startDate:
        data['startDate'] != null ? DateTime.tryParse(data['startDate']) : null,
    daysOfWeek: daysOfWeek,
    lastTaken:
        data['lastTaken'] != null ? DateTime.tryParse(data['lastTaken']) : null,
    refillThreshold:
        data['refillThreshold'] != null
            ? (data['refillThreshold'] as num).toDouble()
            : null,
    refillNotified: data['refillNotified'] as bool?,
  );
}

Future<void> rescheduleAllMedications(String uid) async {
  if (uid.isEmpty) return;
  try {
    final meds =
        await FirebaseFirestore.instance.collection(uid).limit(12).get();
    for (var doc in meds.docs) {
      final medication = medicationFromDoc(doc);
      await scheduleMedicationNotification(
        null,
        doc.id,
        medication,
        userId: uid,
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error rescheduling medications: $e');
    }
  }
}

String? getNextReminder(Medications medication) {
  if (medication.notifyTime == null || medication.notifyTime!.isEmpty) {
    return null;
  }
  final timeParts = medication.notifyTime!.split(':');
  if (timeParts.length != 2) return null;
  int? hour = int.tryParse(timeParts[0]);
  final minute = int.tryParse(timeParts[1]);
  if (hour == null || minute == null) return null;
  final now = DateTime.now();
  DateTime baseDate =
      medication.startDate != null
          ? DateTime(
            medication.startDate!.year,
            medication.startDate!.month,
            medication.startDate!.day,
            hour,
            minute,
          )
          : DateTime(now.year, now.month, now.day, hour, minute);

  final contextToUse = navigatorKey.currentContext;
  bool isWithinReminderWindow = false;
  if (medication.daysOfWeek != null && medication.daysOfWeek!.isNotEmpty) {
    final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (medication.daysOfWeek!.contains(now.weekday)) {
      if (now.isAtSameMomentAs(scheduledTime) || now.isAfter(scheduledTime)) {
        final timeSinceScheduled = now.difference(scheduledTime).inMinutes;
        if (timeSinceScheduled <= 120) {
          if (medication.lastTaken != null) {
            final lastTakenToday =
                medication.lastTaken!.year == now.year &&
                medication.lastTaken!.month == now.month &&
                medication.lastTaken!.day == now.day;
            if (lastTakenToday &&
                medication.lastTaken!.isAfter(scheduledTime)) {
              isWithinReminderWindow = false;
            } else {
              isWithinReminderWindow = true;
            }
          } else {
            isWithinReminderWindow = true;
          }
        }
      }
    }
  } else {
    var scheduledTime = baseDate;
    while (scheduledTime.isBefore(
      now.subtract(Duration(days: medication.frequency)),
    )) {
      scheduledTime = scheduledTime.add(Duration(days: medication.frequency));
    }
    final todayScheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (now.isAtSameMomentAs(todayScheduledTime) ||
        now.isAfter(todayScheduledTime)) {
      final timeSinceScheduled = now.difference(todayScheduledTime).inMinutes;
      if (timeSinceScheduled <= 120) {
        var checkTime = scheduledTime;
        while (checkTime.isBefore(now.add(Duration(days: 1)))) {
          if (checkTime.year == now.year &&
              checkTime.month == now.month &&
              checkTime.day == now.day) {
            if (medication.lastTaken != null) {
              final lastTakenToday =
                  medication.lastTaken!.year == now.year &&
                  medication.lastTaken!.month == now.month &&
                  medication.lastTaken!.day == now.day;
              if (lastTakenToday &&
                  medication.lastTaken!.isAfter(todayScheduledTime)) {
                isWithinReminderWindow = false;
              } else {
                isWithinReminderWindow = true;
              }
            } else {
              isWithinReminderWindow = true;
            }
            break;
          }
          checkTime = checkTime.add(Duration(days: medication.frequency));
        }
      }
    }
  }
  if (isWithinReminderWindow) {
    return contextToUse != null
        ? AppLocalizations.of(
          contextToUse,
        )!.timeToTakeMedicationNow(medication.name)
        : 'Time to take medication now';
  }

  if (medication.daysOfWeek != null && medication.daysOfWeek!.isNotEmpty) {
    final hour = baseDate.hour;
    final minute = baseDate.minute;
    for (int i = 0; i < 7; i++) {
      final checkDay = DateTime(now.year, now.month, now.day + i, hour, minute);
      if (medication.daysOfWeek!.contains(checkDay.weekday) &&
          checkDay.isAfter(now)) {
        final isArabic =
            contextToUse != null
                ? Localizations.localeOf(contextToUse).languageCode == 'ar'
                : false;

        final months =
            isArabic
                ? [
                  'يناير',
                  'فبراير',
                  'مارس',
                  'أبريل',
                  'مايو',
                  'يونيو',
                  'يوليو',
                  'أغسطس',
                  'سبتمبر',
                  'أكتوبر',
                  'نوفمبر',
                  'ديسمبر',
                ]
                : [
                  'January',
                  'February',
                  'March',
                  'April',
                  'May',
                  'June',
                  'July',
                  'August',
                  'September',
                  'October',
                  'November',
                  'December',
                ];

        final month = months[checkDay.month - 1];
        final day = checkDay.day;
        final year = checkDay.year;
        final displayHour =
            checkDay.hour == 0 || checkDay.hour == 12 ? 12 : checkDay.hour % 12;
        final displayMinute = checkDay.minute.toString().padLeft(2, '0');
        final period =
            isArabic
                ? (checkDay.hour < 12 ? 'ص' : 'م')
                : (checkDay.hour < 12 ? 'AM' : 'PM');

        return isArabic
            ? '$day $month $year - $displayHour:$displayMinute $period'
            : '$month $day, $year - $displayHour:$displayMinute $period';
      }
    }
    return null;
  }
  var scheduledTime = baseDate;
  while (scheduledTime.isBefore(now)) {
    scheduledTime = scheduledTime.add(Duration(days: medication.frequency));
  }

  final isArabic =
      contextToUse != null
          ? Localizations.localeOf(contextToUse).languageCode == 'ar'
          : false;
  final months =
      isArabic
          ? [
            'يناير',
            'فبراير',
            'مارس',
            'أبريل',
            'مايو',
            'يونيو',
            'يوليو',
            'أغسطس',
            'سبتمبر',
            'أكتوبر',
            'نوفمبر',
            'ديسمبر',
          ]
          : [
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December',
          ];
  final month = months[scheduledTime.month - 1];
  final day = scheduledTime.day;
  final year = scheduledTime.year;
  final displayHour =
      scheduledTime.hour == 0 || scheduledTime.hour == 12
          ? 12
          : scheduledTime.hour % 12;
  final displayMinute = scheduledTime.minute.toString().padLeft(2, '0');
  final period =
      isArabic
          ? (scheduledTime.hour < 12 ? 'ص' : 'م')
          : (scheduledTime.hour < 12 ? 'AM' : 'PM');

  return isArabic
      ? '$day $month $year - $displayHour:$displayMinute $period'
      : '$month $day, $year - $displayHour:$displayMinute $period';
}
