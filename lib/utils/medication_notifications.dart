library;

import 'dart:io' show Platform;
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:dawatime/home_page.dart' show Medications;
import 'package:dawatime/l10n/app_localizations.dart';
import 'package:dawatime/main.dart'
    show flutterLocalNotificationsPlugin, navigatorKey;

Future<void> scheduleMedicationNotification(
  BuildContext? context,
  String docId,
  Medications medication, {
  bool forceNextDay = false,
  String? userId,
}) async {
  if (kDebugMode) {
    print(
      'DEBUG: scheduleMedicationNotification called for ${medication.name} (docId: $docId)',
    );
  }
  if (kIsWeb) return;

  await requestExactAlarmPermission();
  if (medication.notifyTime == null || medication.notifyTime!.isEmpty) return;
  final timeParts = medication.notifyTime!.split(':');
  if (timeParts.length != 2) return;
  final hour = int.tryParse(timeParts[0]);
  final minute = int.tryParse(timeParts[1]);
  if (hour == null || minute == null) return;

  await cancelMedicationReminders(docId);

  final now = DateTime.now();
  final daysOfWeek = medication.daysOfWeek ?? [];

  if (daysOfWeek.isNotEmpty) {
    final todayScheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (kDebugMode) {
      print('DEBUG: Checking follow-up scheduling for ${medication.name}');
      print('DEBUG: lastTaken: \'${medication.lastTaken}\'');
      print('DEBUG: todayScheduledTime: $todayScheduledTime');
    }
    final twoHoursAfter = todayScheduledTime.add(const Duration(hours: 2));
    final isTodayScheduled = daysOfWeek.contains(now.weekday);
    final isWithinWindow =
        isTodayScheduled &&
        now.isAfter(todayScheduledTime) &&
        now.isBefore(twoHoursAfter);

    if (isWithinWindow &&
        medication.lastTaken != null &&
        medication.lastTaken!.isAfter(todayScheduledTime)) {
      if (kDebugMode) {
        print(
          'Not scheduling follow-ups for ${medication.name} because already marked as taken.',
        );
      }
      return;
    }

    if (isTodayScheduled && now.isAfter(twoHoursAfter)) {
      if (kDebugMode) {
        print(
          'Skipping old notification for ${medication.name} on ${now.weekday}',
        );
      }
    } else if (isWithinWindow) {
      if (kDebugMode) {
        print(
          'Within 2-hour window for ${medication.name}. Scheduling follow-ups...',
        );
      }
      for (int j = 0; j <= 4; j++) {
        final followUpTime = todayScheduledTime.add(Duration(minutes: 30 * j));
        if (followUpTime.isAfter(now)) {
          final scheduledTZ = tz.TZDateTime.from(followUpTime, tz.local);
          final notificationId = ('${docId}_${now.weekday}_$j').hashCode;
          final notificationMessage = AppLocalizations.of(
            context ?? navigatorKey.currentContext!,
          )!.reminderTakeMedication(medication.name);

          if (kDebugMode) {
            print(
              'Scheduling notification #$notificationId for ${medication.name} at $followUpTime (in ${followUpTime.difference(now).inMinutes} minutes)',
            );
          }

          await flutterLocalNotificationsPlugin.zonedSchedule(
            notificationId,
            medication.name,
            notificationMessage,
            scheduledTZ,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'medication_channel_$docId',
                'Medication Reminders for ${medication.name}',
                channelDescription: 'Reminds you to take ${medication.name}',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                showWhen: true,
                ongoing: false,
                autoCancel: true,
                icon: 'dawatime_notify',
                sound: RawResourceAndroidNotificationSound(
                  'notification_sound',
                ),
                color: const Color(0xFF8AC249),
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentSound: true,
                presentBadge: true,
                sound: "notification_sound.wav",
                interruptionLevel: InterruptionLevel.timeSensitive,
              ),
            ),
            payload: docId,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );

          if (kDebugMode) {
            print('✓ Notification scheduled successfully');
          }
        } else {
          if (kDebugMode) {
            print('Skipping notification at $followUpTime (already passed)');
          }
        }
      }
      if (kDebugMode) {
        print(
          'Finished scheduling all follow-up notifications for ${medication.name}',
        );
      }
      return;
    }

    DateTime? nextOccurrence;
    int? nextWeekday;

    for (final weekday in daysOfWeek) {
      int daysUntil = (weekday - now.weekday) % 7;
      if (daysUntil <= 0) daysUntil += 7;
      final candidateDate = now.add(Duration(days: daysUntil));
      final candidateTime = DateTime(
        candidateDate.year,
        candidateDate.month,
        candidateDate.day,
        hour,
        minute,
      );
      if (candidateTime.isAfter(now)) {
        if (nextOccurrence == null || candidateTime.isBefore(nextOccurrence)) {
          nextOccurrence = candidateTime;
          nextWeekday = weekday;
        }
      }
    }
    if (nextOccurrence != null && nextWeekday != null) {
      for (int j = 0; j <= 4; j++) {
        final followUpTime = nextOccurrence.add(Duration(minutes: 30 * j));
        final scheduledTZ = tz.TZDateTime.from(followUpTime, tz.local);
        final notificationId = ('${docId}_${nextWeekday}_$j').hashCode;
        final notificationMessage =
            j == 0
                ? AppLocalizations.of(
                  context ?? navigatorKey.currentContext!,
                )!.timeToTakeMedication(medication.name)
                : AppLocalizations.of(
                  context ?? navigatorKey.currentContext!,
                )!.reminderTakeMedication(medication.name);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          medication.name,
          notificationMessage,
          scheduledTZ,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'medication_channel_$docId',
              'Medication Reminders for ${medication.name}',
              channelDescription: 'Reminds you to take ${medication.name}',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              showWhen: true,
              ongoing: false,
              autoCancel: true,
              icon: 'dawatime_notify',
              sound: RawResourceAndroidNotificationSound('notification_sound'),
              color: const Color(0xFF8AC249),
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
              presentBadge: true,
              sound: "notification_sound.wav",
              interruptionLevel: InterruptionLevel.timeSensitive,
            ),
          ),
          payload: docId,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
    return;
  }
  if (medication.daysOfWeek != null && medication.daysOfWeek!.isNotEmpty) {
    return;
  }
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

  var scheduledTime = baseDate;
  final twoHoursAfterBase = baseDate.add(const Duration(hours: 2));
  final isWithinWindowOfToday =
      now.isAfter(baseDate) && now.isBefore(twoHoursAfterBase);

  if (isWithinWindowOfToday &&
      medication.lastTaken != null &&
      medication.lastTaken!.isAfter(baseDate)) {
    if (kDebugMode) {
      print(
        'Not scheduling everyXDays follow-ups for ${medication.name} because already marked as taken.',
      );
      print('DEBUG: lastTaken: \'${medication.lastTaken}\'');
      if (kDebugMode) {
        print(
          'DEBUG: Skipping everyXDays scheduling for ${medication.name} (docId: $docId) because lastTaken (${medication.lastTaken}) > baseDate ($baseDate)',
        );
      }
      return;
    }
  } else if (isWithinWindowOfToday) {
    if (kDebugMode) {
      print('DEBUG: Not skipping everyXDays: lastTaken is null or <= baseDate');
      print(
        'DEBUG: lastTaken: \'${medication.lastTaken?.toString() ?? 'null'}\'',
      );
      print('DEBUG: baseDate: $baseDate');
    }

    try {
      final baseScheduledTime = scheduledTime;
      final twoHoursAfter = scheduledTime.add(const Duration(hours: 2));
      final isWithinWindow =
          now.isAfter(scheduledTime) && now.isBefore(twoHoursAfter);

      if (now.isAfter(twoHoursAfter)) {
        if (kDebugMode) {
          print(
            'Skipping old notification for ${medication.name} at $scheduledTime',
          );
        }
        return;
      }

      if (scheduledTime.isAfter(now)) {
        for (int i = 0; i <= 4; i++) {
          final followUpTime = scheduledTime.add(Duration(minutes: 30 * i));
          final notificationMessage =
              i == 0
                  ? AppLocalizations.of(
                    context ?? navigatorKey.currentContext!,
                  )!.timeToTakeMedication(medication.name)
                  : AppLocalizations.of(
                    context ?? navigatorKey.currentContext!,
                  )!.reminderTakeMedication(medication.name);

          final scheduledTZ = tz.TZDateTime.from(followUpTime, tz.local);
          final notificationId = ('${docId}_$i').hashCode;

          await flutterLocalNotificationsPlugin.zonedSchedule(
            notificationId,
            medication.name,
            notificationMessage,
            scheduledTZ,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'medication_channel_$docId',
                'Medication Reminders for ${medication.name}',
                channelDescription: 'Reminds you to take ${medication.name}',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                showWhen: true,
                ongoing: false,
                autoCancel: true,
                icon: 'dawatime_notify',
                sound: RawResourceAndroidNotificationSound(
                  'notification_sound',
                ),
                color: const Color(0xFF8AC249),
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentSound: true,
                presentBadge: true,
                sound: "notification_sound.wav",
                interruptionLevel: InterruptionLevel.timeSensitive,
              ),
            ),
            payload: docId,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      } else if (isWithinWindow) {
        for (int i = 0; i <= 4; i++) {
          final followUpTime = baseScheduledTime.add(Duration(minutes: 30 * i));
          if (followUpTime.isAfter(now)) {
            final notificationMessage = AppLocalizations.of(
              context ?? navigatorKey.currentContext!,
            )!.reminderTakeMedication(medication.name);

            final scheduledTZ = tz.TZDateTime.from(followUpTime, tz.local);
            final notificationId = ('${docId}_$i').hashCode;

            await flutterLocalNotificationsPlugin.zonedSchedule(
              notificationId,
              medication.name,
              notificationMessage,
              scheduledTZ,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  'medication_channel_$docId',
                  'Medication Reminders for ${medication.name}',
                  channelDescription: 'Reminds you to take ${medication.name}',
                  importance: Importance.max,
                  priority: Priority.high,
                  playSound: true,
                  showWhen: true,
                  ongoing: false,
                  autoCancel: true,
                  icon: 'dawatime_notify',
                  sound: RawResourceAndroidNotificationSound(
                    'notification_sound',
                  ),
                  color: const Color(0xFF8AC249),
                ),
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentSound: true,
                  presentBadge: true,
                  sound: "notification_sound.wav",
                  interruptionLevel: InterruptionLevel.timeSensitive,
                ),
              ),
              payload: docId,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );
          }
        }
      }
    } catch (e) {
      if (context != null) {
        try {
          if (e is PlatformException &&
              e.code == 'exact_alarms_not_permitted') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF8AC249),
                content: Text(
                  AppLocalizations.of(context)!.allowSettings,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)!.openSettings,
                  onPressed: openExactAlarmSettings,
                ),
                persist: false,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF8AC249),
                content: Text(
                  '${AppLocalizations.of(context)!.scheduleMedicationFailure} $e',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                persist: false,
              ),
            );
          }
        } catch (scaffoldError) {
          if (kDebugMode) {
            print('Could not show SnackBar (widget disposed): $scaffoldError');
          }
        }
      }
    }
    return;
  }

  while (scheduledTime.isBefore(now) ||
      (scheduledTime.isAfter(now) &&
          scheduledTime.difference(now).inHours < 2 &&
          medication.lastTaken != null &&
          medication.lastTaken!.isAfter(scheduledTime))) {
    scheduledTime = scheduledTime.add(Duration(days: medication.frequency));
  }

  if (kDebugMode) {
    print(
      'Scheduling ${medication.name} for $scheduledTime (in ${scheduledTime.difference(now).inHours} hours)',
    );
  }

  for (int i = 0; i <= 4; i++) {
    final followUpTime = scheduledTime.add(Duration(minutes: 30 * i));
    final notificationMessage =
        i == 0
            ? AppLocalizations.of(
              context ?? navigatorKey.currentContext!,
            )!.timeToTakeMedication(medication.name)
            : AppLocalizations.of(
              context ?? navigatorKey.currentContext!,
            )!.reminderTakeMedication(medication.name);

    final scheduledTZ = tz.TZDateTime.from(followUpTime, tz.local);
    final notificationId = ('${docId}_$i').hashCode;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      medication.name,
      notificationMessage,
      scheduledTZ,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel_$docId',
          'Medication Reminders for ${medication.name}',
          channelDescription: 'Reminds you to take ${medication.name}',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          showWhen: true,
          ongoing: false,
          autoCancel: true,
          icon: 'dawatime_notify',
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          color: const Color(0xFF8AC249),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
          sound: "notification_sound.wav",
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: docId,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    if (kDebugMode) {
      print(
        '✓ Scheduled notification #$notificationId for ${medication.name} at $followUpTime',
      );
    }
  }
}

Future<void> cancelMedicationReminders(String docId) async {
  for (int i = 0; i <= 8; i++) {
    final notificationId = ('${docId}_$i').hashCode;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }
  for (int weekday = 1; weekday <= 7; weekday++) {
    for (int j = 0; j <= 4; j++) {
      final notificationId = ('${docId}_${weekday}_$j').hashCode;
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }
}

Future<void> scheduleWeeklyRefillNotification(
  Medications medication,
  String docId,
) async {
  if (kIsWeb) return;

  try {
    await cancelRefillNotifications(docId);

    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    final scheduledTime = DateTime(
      nextWeek.year,
      nextWeek.month,
      nextWeek.day,
      10,
      0,
    );

    final scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);
    final notificationId = ('refill_weekly_$docId').hashCode;

    final context = navigatorKey.currentContext;
    final loc = context != null ? AppLocalizations.of(context) : null;

    final title =
        loc != null
            ? '${loc.refillReminder}: ${medication.name}'
            : 'Refill Reminder: ${medication.name}';

    final body =
        loc != null
            ? loc.refillReminderBody(
              medication.amount.toInt().toString(),
              medication.name,
              medication.typeOfMedication,
            )
            : 'You have ${medication.amount.toInt()} ${medication.typeOfMedication} left. Time to refill!';

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledTZ,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'refill_channel',
          'Refill Reminders',
          channelDescription: 'Weekly reminders to refill your medications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          showWhen: true,
          ongoing: false,
          autoCancel: true,
          icon: 'dawatime_notify',
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          color: const Color(0xFFFF9800),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
          sound: "notification_sound.wav",
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: 'refill_$docId',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error scheduling weekly refill notification: $e');
    }
  }
}

Future<void> cancelRefillNotifications(String docId) async {
  if (kIsWeb) return;

  try {
    final notificationId = ('refill_weekly_$docId').hashCode;
    await flutterLocalNotificationsPlugin.cancel(notificationId);

    if (kDebugMode) {
      print('✓ Cancelled refill notification for $docId (ID: $notificationId)');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error canceling refill notifications for $docId: $e');
    }
  }
}

Future<void> cancelAllRefillNotifications() async {
  if (kIsWeb) return;

  try {
    await flutterLocalNotificationsPlugin.cancelAll();

    if (kDebugMode) {
      print('✓ Cancelled all pending notifications for cleanup');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error canceling all notifications: $e');
    }
  }
}

Future<void> openExactAlarmSettings() async {
  final intent = AndroidIntent(
    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
  );
  await intent.launch();
}

Future<void> requestExactAlarmPermission() async {
  if (kIsWeb) return;
  if (!Platform.isAndroid) return;

  try {
    final status = await Permission.scheduleExactAlarm.status;

    if (status.isGranted) {
      return;
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      if (kDebugMode) {
        print('Exact alarm permission not granted');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error checking exact alarm permission: $e');
    }
  }
}
