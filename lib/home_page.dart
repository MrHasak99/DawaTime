import 'dart:async';
import 'dart:io' show Platform;
import 'package:android_intent_plus/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dawatime/add_medications.dart';
import 'package:dawatime/login_page.dart';
import 'package:dawatime/main.dart';
import 'package:dawatime/settings.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dawatime/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

class Medications {
  final String name;
  final String typeOfMedication;
  final double dosage;
  final int frequency;
  final double amount;
  final String? notifyTime;
  final DateTime? startDate;
  final List<int>? daysOfWeek;
  final DateTime? lastTaken;
  final double? refillThreshold;
  final bool? refillNotified;

  const Medications({
    required this.name,
    required this.typeOfMedication,
    required this.dosage,
    required this.frequency,
    required this.amount,
    this.notifyTime,
    this.startDate,
    this.daysOfWeek,
    this.lastTaken,
    this.refillThreshold,
    this.refillNotified,
  });

  factory Medications.fromMap(Map<String, dynamic> data) {
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
          data['startDate'] != null
              ? DateTime.tryParse(data['startDate'])
              : null,
      daysOfWeek: daysOfWeek,
      lastTaken:
          data['lastTaken'] != null
              ? DateTime.tryParse(data['lastTaken'])
              : null,
      refillThreshold:
          data['refillThreshold'] != null
              ? (data['refillThreshold'] as num).toDouble()
              : null,
      refillNotified: data['refillNotified'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'typeOfMedication': typeOfMedication,
      'dosage': dosage,
      'frequency': frequency,
      'amount': amount,
      'notifyTime': notifyTime,
      'startDate': startDate?.toIso8601String(),
      'daysOfWeek': daysOfWeek,
      'lastTaken': lastTaken?.toIso8601String(),
      'refillThreshold': refillThreshold,
      'refillNotified': refillNotified,
    };
  }
}

class HomePage extends StatefulWidget {
  final String? uid;
  const HomePage({super.key, this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Medications? _recentlyDeletedMedication;
  Map<String, dynamic>? _recentlyDeletedData;
  String? _recentlyDeletedDocId;

  Timer? _medicationCheckTimer;
  final Set<String> _shownAlerts = {};

  bool _showIntroGuide = false;
  int _introStep = 0;

  List<Map<String, String>> get _introSteps {
    final loc = AppLocalizations.of(context)!;
    return [
      {'title': loc.welcomeToDawaTime, 'body': loc.welcomeBody},
      {'title': loc.addMedicationTitle, 'body': loc.addMedicationBody},
      {'title': loc.editDeleteTitle, 'body': loc.editDeleteBody},
      {'title': loc.notifications, 'body': loc.notificationsBody},
      {'title': loc.profileAndSettings, 'body': loc.profileAndSettingsBody},
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @pragma('vm:entry-point')
  Future<void> notificationTapBackground(NotificationResponse response) async {
    if (response.payload == null) return;

    await Firebase.initializeApp();

    final docId = response.payload!;
    final doc =
        await FirebaseFirestore.instance
            .collection('medications')
            .doc(docId)
            .get();
    if (doc.exists) {
      final medication = medicationFromDoc(doc);
      await scheduleMedicationNotification(
        null,
        docId,
        medication,
        forceNextDay: true,
      );
    }
  }

  late VoidCallback _localeListener;

  @override
  void initState() {
    super.initState();
    _checkIntroGuide();

    if (!kIsWeb) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _checkPermissionsIfNeeded(user.uid);
        _scheduleAfterPermissionCheck(user.uid);
      }

      _medicationCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _checkAndShowDueMedications();
      });

      selectNotificationStream.stream.listen((
        NotificationResponse response,
      ) async {
        if (response.payload != null && widget.uid != null) {
          final docId = response.payload!;
          final doc =
              await FirebaseFirestore.instance
                  .collection(widget.uid!)
                  .doc(docId)
                  .get();
          if (doc.exists) {
            final medication = medicationFromDoc(doc);

            if (navigatorKey.currentContext != null) {
              showDialog(
                context: navigatorKey.currentContext!,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: const Color(0xFF8AC249),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!.timeToTakeMedication(medication.name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            AppLocalizations.of(context)!.ok,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
              );
            }
            await scheduleMedicationNotification(
              context,
              docId,
              medication,
              forceNextDay: true,
              userId: widget.uid,
            );
          }
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showIntroGuide && mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder:
              (context) => AlertDialog(
                backgroundColor: const Color(0xFF8AC249),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Text(
                  AppLocalizations.of(context)!.welcomeToDawaTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.getStarted,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${AppLocalizations.of(context)!.addMedicationBody2}\n'
                        '${AppLocalizations.of(context)!.setReminders}\n'
                        '${AppLocalizations.of(context)!.viewDetails}\n'
                        '${AppLocalizations.of(context)!.swipe}\n'
                        '${AppLocalizations.of(context)!.checkReminders}\n'
                        '${AppLocalizations.of(context)!.manageProfile}.\n',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.medicationNotifications,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('seenIntroGuide', true);
                      setState(() {
                        _showIntroGuide = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.close,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
        );
      }
    });
    _localeListener = () {
      if (mounted) setState(() {});
    };
    localeNotifier.addListener(_localeListener);
  }

  @override
  void dispose() {
    _medicationCheckTimer?.cancel();
    localeNotifier.removeListener(_localeListener);
    super.dispose();
  }

  Future<void> _checkPermissionsIfNeeded(String userId) async {
    if (kIsWeb) return;

    if (!Platform.isAndroid) return;
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection(userId).limit(1).get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      final status = await Permission.scheduleExactAlarm.status;
      if (!status.isGranted && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF8AC249),
                content: Text(
                  AppLocalizations.of(context)!.allowSettings,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)!.openSettings,
                  onPressed: openExactAlarmSettings,
                  textColor: Colors.white,
                ),
                duration: const Duration(seconds: 8),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking permissions: $e');
      }
    }
  }

  Future<void> _scheduleAfterPermissionCheck(String userId) async {
    if (kIsWeb) return;

    if (Platform.isIOS) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    rescheduleAllMedications(userId);
    _autoRescheduleOverdueMedications(userId);
    _checkRefillReminders(userId);
  }

  Future<void> _autoRescheduleOverdueMedications(String userId) async {
    try {
      final now = DateTime.now();
      final meds =
          await FirebaseFirestore.instance.collection(userId).limit(12).get();

      for (var doc in meds.docs) {
        final medication = medicationFromDoc(doc);
        if (medication.notifyTime == null || medication.notifyTime!.isEmpty) {
          continue;
        }

        final timeParts = medication.notifyTime!.split(':');
        if (timeParts.length != 2) continue;
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour == null || minute == null) continue;

        bool shouldAutoReschedule = false;
        DateTime? lastScheduledTime;

        if (medication.daysOfWeek != null &&
            medication.daysOfWeek!.isNotEmpty) {
          if (medication.daysOfWeek!.contains(now.weekday)) {
            lastScheduledTime = DateTime(
              now.year,
              now.month,
              now.day,
              hour,
              minute,
            );
          }
        } else {
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
          while (scheduledTime.isBefore(
            now.subtract(Duration(days: medication.frequency)),
          )) {
            scheduledTime = scheduledTime.add(
              Duration(days: medication.frequency),
            );
          }

          if (scheduledTime.year == now.year &&
              scheduledTime.month == now.month &&
              scheduledTime.day == now.day) {
            lastScheduledTime = scheduledTime;
          }
        }

        if (lastScheduledTime != null) {
          final minutesSince = now.difference(lastScheduledTime).inMinutes;

          final notTakenToday =
              medication.lastTaken == null ||
              medication.lastTaken!.isBefore(
                DateTime(now.year, now.month, now.day),
              );

          if (minutesSince >= 0 && minutesSince <= 120 && notTakenToday) {
            await scheduleMedicationNotification(
              null,
              doc.id,
              medication,
              userId: userId,
            );
          } else if (minutesSince > 120 && notTakenToday) {
            shouldAutoReschedule = true;
          }
        }

        if (shouldAutoReschedule) {
          if (medication.daysOfWeek == null || medication.daysOfWeek!.isEmpty) {
            final nextScheduled = lastScheduledTime!.add(
              Duration(days: medication.frequency),
            );
            final updatedMedication = Medications(
              name: medication.name,
              typeOfMedication: medication.typeOfMedication,
              dosage: medication.dosage,
              frequency: medication.frequency,
              amount: medication.amount,
              notifyTime: medication.notifyTime,
              startDate: nextScheduled,
              daysOfWeek: medication.daysOfWeek,
              lastTaken: medication.lastTaken,
            );
            await FirebaseFirestore.instance
                .collection(userId)
                .doc(doc.id)
                .update(updatedMedication.toMap());
          }
          await scheduleMedicationNotification(
            null,
            doc.id,
            medication,
            userId: userId,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error auto-rescheduling overdue medications: $e');
      }
    }
  }

  Future<void> _checkRefillReminders(String userId) async {
    if (kIsWeb) return;

    try {
      final meds =
          await FirebaseFirestore.instance.collection(userId).limit(12).get();
      final List<Map<String, dynamic>> lowStockMeds = [];

      for (var doc in meds.docs) {
        final medication = medicationFromDoc(doc);

        if (medication.refillThreshold == null ||
            medication.refillThreshold! <= 0) {
          await cancelRefillNotifications(doc.id);
          continue;
        }

        if (medication.amount <= medication.refillThreshold!) {
          lowStockMeds.add({'medication': medication, 'docId': doc.id});

          if (medication.refillNotified != true) {
            await FirebaseFirestore.instance
                .collection(userId)
                .doc(doc.id)
                .update({'refillNotified': true});
          }
          await scheduleWeeklyRefillNotification(medication, doc.id);
        } else {
          await cancelRefillNotifications(doc.id);
          if (medication.refillNotified == true) {
            await FirebaseFirestore.instance
                .collection(userId)
                .doc(doc.id)
                .update({'refillNotified': false});
          }
        }
      }

      if (lowStockMeds.isNotEmpty) {
        await _showRefillNotifications(lowStockMeds);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking refill reminders: $e');
      }
    }
  }

  Future<void> _showRefillNotifications(
    List<Map<String, dynamic>> lowStockMeds,
  ) async {
    try {
      final context = navigatorKey.currentContext;
      final loc = context != null ? AppLocalizations.of(context) : null;

      if (lowStockMeds.length == 1) {
        final medication = lowStockMeds[0]['medication'] as Medications;
        final docId = lowStockMeds[0]['docId'] as String;

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

        await flutterLocalNotificationsPlugin.show(
          docId.hashCode + 1000,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'refill_channel',
              'Refill Reminders',
              channelDescription: 'Reminds you to refill your medications',
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
            ),
          ),
          payload: 'refill_$docId',
        );
      } else {
        final title =
            loc != null
                ? '${loc.refillReminder} (${lowStockMeds.length})'
                : 'Refill Reminder (${lowStockMeds.length})';

        final body =
            loc != null
                ? '${lowStockMeds.length} ${loc.needRefillShort}'
                : '${lowStockMeds.length} medications need refilling';

        await flutterLocalNotificationsPlugin.show(
          'refill_multiple'.hashCode,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'refill_channel',
              'Refill Reminders',
              channelDescription: 'Reminds you to refill your medications',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              icon: 'dawatime_notify',
              sound: RawResourceAndroidNotificationSound('notification_sound'),
              color: const Color(0xFFFF9800),
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
              presentBadge: true,
              sound: "notification_sound.wav",
            ),
          ),
          payload: 'refill_multiple',
        );
      }

      if (context != null && mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: const Color(0xFFFF9800),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Row(
                  children: [
                    Icon(Icons.warning_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lowStockMeds.length == 1
                            ? (loc != null
                                ? '${loc.refillReminder}: ${(lowStockMeds[0]['medication'] as Medications).name}'
                                : 'Refill Reminder: ${(lowStockMeds[0]['medication'] as Medications).name}')
                            : (loc != null
                                ? '${loc.lowStock} (${lowStockMeds.length})'
                                : 'Low Stock (${lowStockMeds.length})'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child:
                      lowStockMeds.length == 1
                          ? Text(
                            loc != null
                                ? loc.refillReminderBody(
                                  (lowStockMeds[0]['medication'] as Medications)
                                      .amount
                                      .toInt()
                                      .toString(),
                                  (lowStockMeds[0]['medication'] as Medications)
                                      .name,
                                  (lowStockMeds[0]['medication'] as Medications)
                                      .typeOfMedication,
                                )
                                : 'You have ${(lowStockMeds[0]['medication'] as Medications).amount.toInt()} ${(lowStockMeds[0]['medication'] as Medications).typeOfMedication} left. Time to refill!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )
                          : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc != null
                                    ? loc.needRefill
                                    : 'The following medications need refilling:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              ...lowStockMeds.map((item) {
                                final med = item['medication'] as Medications;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.medication,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${med.name}: ${med.amount.toInt()} ${med.typeOfMedication}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      loc?.ok ?? 'OK',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error showing refill notification: $e');
      }
    }
  }

  void _checkAndShowDueMedications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final now = DateTime.now();
      final meds =
          await FirebaseFirestore.instance.collection(user.uid).limit(12).get();

      for (var doc in meds.docs) {
        final medication = medicationFromDoc(doc);
        if (medication.notifyTime == null || medication.notifyTime!.isEmpty) {
          continue;
        }

        final timeParts = medication.notifyTime!.split(':');
        if (timeParts.length != 2) continue;
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour == null || minute == null) continue;

        bool shouldShowToday = false;

        if (medication.daysOfWeek != null &&
            medication.daysOfWeek!.isNotEmpty) {
          int todayWeekday = now.weekday;
          shouldShowToday = medication.daysOfWeek!.contains(todayWeekday);
        } else {
          var scheduledTime = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );
          while (scheduledTime.isBefore(now)) {
            scheduledTime = scheduledTime.add(
              Duration(days: medication.frequency),
            );
          }
          shouldShowToday = scheduledTime.day == now.day;
        }

        if (shouldShowToday) {
          final scheduledTime = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );
          if ((now.difference(scheduledTime).inSeconds).abs() <= 1 &&
              !_shownAlerts.contains(doc.id)) {
            _shownAlerts.add(doc.id);

            if (navigatorKey.currentContext != null) {
              showDialog(
                context: navigatorKey.currentContext!,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: const Color(0xFF8AC249),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      title: Text(
                        AppLocalizations.of(
                          context,
                        )!.timeToTakeMedication(medication.name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            AppLocalizations.of(context)!.ok,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
              );
            }
          }

          if (now.isBefore(
            scheduledTime.subtract(const Duration(seconds: 3)),
          )) {
            _shownAlerts.remove(doc.id);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking medications (user may not be authenticated): $e');
      }
    }
  }

  Future<void> _checkIntroGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final seenGuide = prefs.getBool('seenIntroGuide') ?? false;
    if (!seenGuide && mounted) {
      setState(() {
        _showIntroGuide = true;
        _introStep = 0;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInteractiveGuide();
      });
    }
  }

  void _showInteractiveGuide() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                backgroundColor: const Color(0xFF8AC249),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Text(
                  _introSteps[_introStep]['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  _introSteps[_introStep]['body']!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                actions: [
                  if (_introStep > 0)
                    TextButton(
                      onPressed:
                          () => setState(() {
                            _introStep--;
                          }),
                      child: Text(
                        loc.back,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  if (_introStep < _introSteps.length - 1)
                    TextButton(
                      onPressed:
                          () => setState(() {
                            _introStep++;
                          }),
                      child: Text(
                        loc.next,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  if (_introStep == _introSteps.length - 1)
                    TextButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('seenIntroGuide', true);
                        setState(() {
                          _showIntroGuide = false;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        loc.close,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                ],
              ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (_recentlyDeletedMedication != null &&
        _recentlyDeletedData != null &&
        _recentlyDeletedDocId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final deletedMedication = _recentlyDeletedMedication;
        final deletedData = _recentlyDeletedData;
        final deletedDocId = _recentlyDeletedDocId;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF8AC249),
            content: Text(
              AppLocalizations.of(
                context,
              )!.medicationDeleted(deletedMedication!.name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.undo,
              textColor: Colors.red,
              onPressed: () async {
                try {
                  await firestore
                      .collection(widget.uid!)
                      .doc(deletedDocId!)
                      .set(deletedData!);
                  await scheduleMedicationNotification(
                    context,
                    deletedDocId,
                    deletedMedication,
                    userId: widget.uid,
                  );
                  if (deletedMedication.refillThreshold != null &&
                      deletedMedication.refillThreshold! > 0 &&
                      deletedMedication.amount <=
                          deletedMedication.refillThreshold!) {
                    await scheduleWeeklyRefillNotification(
                      deletedMedication,
                      deletedDocId,
                    );
                  }
                  if (mounted) setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF8AC249),
                      content: Text(
                        '${AppLocalizations.of(context)!.couldNotUpdateMedication} $e',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
        setState(() {
          _recentlyDeletedMedication = null;
          _recentlyDeletedData = null;
          _recentlyDeletedDocId = null;
        });
      });
    }

    if (user == null) {
      Future.microtask(() {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF8AC249)),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF8AC249),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
              builder: (context, snapshot) {
                String name = AppLocalizations.of(context)!.friend;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  name = data['name'] ?? AppLocalizations.of(context)!.friend;
                }
                return Text(
                  "${AppLocalizations.of(context)!.welcomeBack} $name!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: Colors.white),
                tooltip: AppLocalizations.of(context)!.viewProfile,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection(user.uid)
                .limit(12)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8AC249)),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.medication,
                    color: Color(0xFF8AC249),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noMedicationsFound,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }
          final docs = snapshot.data!.docs;

          docs.sort((a, b) {
            final medA = medicationFromDoc(a);
            final medB = medicationFromDoc(b);
            return medA.name.toLowerCase().compareTo(medB.name.toLowerCase());
          });

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8AC249).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF8AC249).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFF8AC249),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.openAppRegularlyForNotifications,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (scaffoldContext) {
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final medication = medicationFromDoc(docs[index]);
                          final isRTL =
                              Directionality.of(context) == TextDirection.rtl;
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 24,
                              left: 8,
                              right: 8,
                            ),
                            child: Dismissible(
                              key: Key(docs[index].id),
                              direction: DismissDirection.horizontal,
                              background:
                                  isRTL
                                      ? Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.lightBlue,
                                          size: 32,
                                        ),
                                      )
                                      : Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.lightBlue,
                                          size: 32,
                                        ),
                                      ),
                              secondaryBackground:
                                  isRTL
                                      ? Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 32,
                                        ),
                                      )
                                      : Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 32,
                                        ),
                                      ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  return await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          backgroundColor: Color(0xFF8AC249),
                                          title: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.deleteMedication,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.areYouSureDeleteMedication(
                                              medication.name,
                                            ),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.cancel,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                              ),
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.deleteMedication,
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                } else if (direction ==
                                    DismissDirection.startToEnd) {
                                  FrequencyType editFrequencyType =
                                      (medication.daysOfWeek != null &&
                                              medication.daysOfWeek!.isNotEmpty)
                                          ? FrequencyType.daysOfWeek
                                          : FrequencyType.everyXDays;

                                  final nameController = TextEditingController(
                                    text: medication.name,
                                  );
                                  final typeOfMedicationController =
                                      TextEditingController(
                                        text: medication.typeOfMedication,
                                      );
                                  final dosageController =
                                      TextEditingController(
                                        text: medication.dosage.toString(),
                                      );
                                  final frequencyController =
                                      TextEditingController(
                                        text: medication.frequency.toString(),
                                      );
                                  final amountController =
                                      TextEditingController(
                                        text: medication.amount.toString(),
                                      );
                                  final refillThresholdController =
                                      TextEditingController(
                                        text:
                                            medication.refillThreshold
                                                ?.toString() ??
                                            '',
                                      );
                                  TimeOfDay? selectedTime;
                                  if (medication.notifyTime != null &&
                                      medication.notifyTime!.isNotEmpty) {
                                    final parts = medication.notifyTime!.split(
                                      ":",
                                    );
                                    if (parts.length == 2) {
                                      selectedTime = TimeOfDay(
                                        hour: int.tryParse(parts[0]) ?? 0,
                                        minute: int.tryParse(parts[1]) ?? 0,
                                      );
                                    }
                                  }

                                  DateTime? selectedStartDate =
                                      medication.startDate;
                                  List<int> selectedDaysOfWeek =
                                      medication.daysOfWeek != null
                                          ? List<int>.from(
                                            medication.daysOfWeek!,
                                          )
                                          : [];
                                  bool nameError = false;
                                  bool typeError = false;
                                  bool dosageError = false;
                                  bool amountError = false;
                                  bool frequencyError = false;
                                  bool timeError = false;
                                  bool startDateError = false;
                                  bool daysOfWeekError = false;

                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder:
                                            (context, setState) => AlertDialog(
                                              backgroundColor: Color(
                                                0xFF8AC249,
                                              ),
                                              title: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.editMedication,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller:
                                                          nameController,
                                                      cursorColor: Colors.white,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                      textDirection:
                                                          Localizations.localeOf(
                                                                    context,
                                                                  ).languageCode ==
                                                                  'ar'
                                                              ? TextDirection
                                                                  .rtl
                                                              : TextDirection
                                                                  .ltr,
                                                      onChanged: (value) {
                                                        if (nameError &&
                                                            value.isNotEmpty) {
                                                          setState(
                                                            () =>
                                                                nameError =
                                                                    false,
                                                          );
                                                        }
                                                      },
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.name,
                                                        labelStyle: Theme.of(
                                                              context,
                                                            )
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.copyWith(
                                                              color:
                                                                  nameError
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                        errorText:
                                                            nameError
                                                                ? AppLocalizations.of(
                                                                  context,
                                                                )!.pleaseFillAllFields
                                                                : null,
                                                        errorStyle: TextStyle(
                                                          color:
                                                              Colors.red[100],
                                                        ),
                                                        focusedBorder:
                                                            const UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                            ),
                                                        enabledBorder:
                                                            const UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                            ),
                                                      ),
                                                    ),
                                                    TextField(
                                                      controller:
                                                          typeOfMedicationController,
                                                      cursorColor: Colors.white,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                      textDirection:
                                                          Localizations.localeOf(
                                                                    context,
                                                                  ).languageCode ==
                                                                  'ar'
                                                              ? TextDirection
                                                                  .rtl
                                                              : TextDirection
                                                                  .ltr,
                                                      onChanged: (value) {
                                                        if (typeError &&
                                                            value.isNotEmpty) {
                                                          setState(
                                                            () =>
                                                                typeError =
                                                                    false,
                                                          );
                                                        }
                                                      },
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.unitOfMeasurement,
                                                        labelStyle: Theme.of(
                                                              context,
                                                            )
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.copyWith(
                                                              color:
                                                                  typeError
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                        errorText:
                                                            typeError
                                                                ? AppLocalizations.of(
                                                                  context,
                                                                )!.pleaseFillAllFields
                                                                : null,
                                                        errorStyle: TextStyle(
                                                          color:
                                                              Colors.red[100],
                                                        ),
                                                        focusedBorder:
                                                            const UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                            ),
                                                        enabledBorder:
                                                            const UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                            ),
                                                      ),
                                                    ),
                                                    TextField(
                                                      controller:
                                                          dosageController,
                                                      cursorColor: Colors.white,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (value) {
                                                        if (dosageError &&
                                                            value.isNotEmpty &&
                                                            convertArabicNumerals(
                                                                  value,
                                                                ) !=
                                                                '0') {
                                                          setState(
                                                            () =>
                                                                dosageError =
                                                                    false,
                                                          );
                                                        }
                                                      },
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.dosage,
                                                        labelStyle: Theme.of(
                                                              context,
                                                            )
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.copyWith(
                                                              color:
                                                                  dosageError
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                        errorText:
                                                            dosageError
                                                                ? AppLocalizations.of(
                                                                  context,
                                                                )!.dosageFrequencyGreaterThanZero
                                                                : null,
                                                        errorStyle: TextStyle(
                                                          color:
                                                              Colors.red[100],
                                                        ),
                                                        focusedBorder:
                                                            const UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                            ),
                                                        enabledBorder:
                                                            const UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                            ),
                                                      ),
                                                    ),
                                                    TextField(
                                                      controller:
                                                          amountController,
                                                      cursorColor: Colors.white,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (value) {
                                                        if (amountError &&
                                                            value.isNotEmpty) {
                                                          setState(
                                                            () =>
                                                                amountError =
                                                                    false,
                                                          );
                                                        }
                                                      },
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.currentAmount,
                                                        labelStyle: Theme.of(
                                                              context,
                                                            )
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.copyWith(
                                                              color:
                                                                  amountError
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                        errorText:
                                                            amountError
                                                                ? AppLocalizations.of(
                                                                  context,
                                                                )!.pleaseFillAllFields
                                                                : null,
                                                        errorStyle: TextStyle(
                                                          color:
                                                              Colors.red[100],
                                                        ),
                                                        focusedBorder:
                                                            const UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                            ),
                                                        enabledBorder:
                                                            const UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                            ),
                                                      ),
                                                    ),
                                                    TextField(
                                                      controller:
                                                          refillThresholdController,
                                                      cursorColor: Colors.white,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.refillThreshold,
                                                        labelStyle: Theme.of(
                                                              context,
                                                            )
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                        focusedBorder:
                                                            const UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                            ),
                                                        enabledBorder:
                                                            const UnderlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                            ),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      title: Text(
                                                        selectedTime == null
                                                            ? AppLocalizations.of(
                                                              context,
                                                            )!.pickNotificationTime
                                                            : "${AppLocalizations.of(context)!.notifyAt}: ${selectedTime!.format(context)}",
                                                        style: TextStyle(
                                                          color:
                                                              timeError
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      trailing: Icon(
                                                        Icons.access_time,
                                                        color:
                                                            timeError
                                                                ? Colors.red
                                                                : Colors.white,
                                                      ),
                                                      onTap: () async {
                                                        final isDark =
                                                            Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark;
                                                        final primaryColor =
                                                            const Color(
                                                              0xFF8AC249,
                                                            );
                                                        final surfaceColor =
                                                            isDark
                                                                ? const Color(
                                                                  0xFF222222,
                                                                )
                                                                : Colors.white;
                                                        final onSurfaceColor =
                                                            isDark
                                                                ? Colors.white
                                                                : primaryColor;
                                                        final hourMinuteBg =
                                                            isDark
                                                                ? primaryColor
                                                                    .withValues(
                                                                      alpha:
                                                                          0.15,
                                                                    )
                                                                : primaryColor
                                                                    .withValues(
                                                                      alpha:
                                                                          0.08,
                                                                    );

                                                        final picked = await showTimePicker(
                                                          context: context,
                                                          initialTime:
                                                              selectedTime ??
                                                              TimeOfDay.now(),
                                                          builder: (
                                                            context,
                                                            child,
                                                          ) {
                                                            return Theme(
                                                              data: Theme.of(
                                                                context,
                                                              ).copyWith(
                                                                timePickerTheme: TimePickerThemeData(
                                                                  backgroundColor:
                                                                      surfaceColor,
                                                                  hourMinuteTextColor:
                                                                      primaryColor,
                                                                  hourMinuteColor:
                                                                      hourMinuteBg,
                                                                  dayPeriodTextColor:
                                                                      primaryColor,
                                                                  dayPeriodColor:
                                                                      hourMinuteBg,
                                                                  dialHandColor:
                                                                      primaryColor,
                                                                  dialBackgroundColor:
                                                                      hourMinuteBg,
                                                                  entryModeIconColor:
                                                                      primaryColor,
                                                                  helpTextStyle: TextStyle(
                                                                    color:
                                                                        primaryColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  hourMinuteTextStyle: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        28,
                                                                    color:
                                                                        primaryColor,
                                                                  ),
                                                                  dayPeriodTextStyle: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16,
                                                                    color:
                                                                        primaryColor,
                                                                  ),
                                                                  dialTextStyle: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20,
                                                                    color:
                                                                        primaryColor,
                                                                  ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          24,
                                                                        ),
                                                                  ),
                                                                ),
                                                                textButtonTheme: TextButtonThemeData(
                                                                  style: TextButton.styleFrom(
                                                                    foregroundColor:
                                                                        primaryColor,
                                                                    textStyle: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                colorScheme: ColorScheme(
                                                                  brightness:
                                                                      isDark
                                                                          ? Brightness
                                                                              .dark
                                                                          : Brightness
                                                                              .light,
                                                                  primary:
                                                                      primaryColor,
                                                                  onPrimary:
                                                                      Colors
                                                                          .white,
                                                                  secondary:
                                                                      primaryColor,
                                                                  onSecondary:
                                                                      Colors
                                                                          .white,
                                                                  error:
                                                                      Colors
                                                                          .red,
                                                                  onError:
                                                                      Colors
                                                                          .white,
                                                                  surface:
                                                                      surfaceColor,
                                                                  onSurface:
                                                                      onSurfaceColor,
                                                                ),
                                                              ),
                                                              child: child!,
                                                            );
                                                          },
                                                        );
                                                        if (picked != null) {
                                                          setState(() {
                                                            selectedTime =
                                                                picked;
                                                            timeError = false;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                    ListTile(
                                                      title: Text(
                                                        selectedStartDate ==
                                                                null
                                                            ? AppLocalizations.of(
                                                              context,
                                                            )!.pickScheduleStartDate
                                                            : "${AppLocalizations.of(context)!.startDate}: ${selectedStartDate!.day.toString().padLeft(2, '0')}-${selectedStartDate!.month.toString().padLeft(2, '0')}-${selectedStartDate!.year}",
                                                        style: TextStyle(
                                                          color:
                                                              startDateError
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      trailing: Icon(
                                                        Icons.calendar_today,
                                                        color:
                                                            startDateError
                                                                ? Colors.red
                                                                : Colors.white,
                                                      ),
                                                      onTap: () async {
                                                        final isDark =
                                                            Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark;
                                                        final primaryColor =
                                                            const Color(
                                                              0xFF8AC249,
                                                            );
                                                        final surfaceColor =
                                                            isDark
                                                                ? const Color(
                                                                  0xFF222222,
                                                                )
                                                                : Colors.white;
                                                        final onSurfaceColor =
                                                            isDark
                                                                ? Colors.white
                                                                : primaryColor;

                                                        final now =
                                                            DateTime.now();
                                                        final safeInitialDate =
                                                            (selectedStartDate !=
                                                                        null &&
                                                                    selectedStartDate!
                                                                        .isAfter(
                                                                          now,
                                                                        ))
                                                                ? selectedStartDate!
                                                                : now;

                                                        final picked = await showDatePicker(
                                                          context: context,
                                                          initialDate:
                                                              safeInitialDate,
                                                          firstDate: now,
                                                          lastDate: DateTime(
                                                            now.year + 10,
                                                          ),
                                                          builder: (
                                                            context,
                                                            child,
                                                          ) {
                                                            return Theme(
                                                              data: Theme.of(
                                                                context,
                                                              ).copyWith(
                                                                colorScheme: ColorScheme(
                                                                  brightness:
                                                                      isDark
                                                                          ? Brightness
                                                                              .dark
                                                                          : Brightness
                                                                              .light,
                                                                  primary:
                                                                      primaryColor,
                                                                  onPrimary:
                                                                      Colors
                                                                          .white,
                                                                  secondary:
                                                                      primaryColor,
                                                                  onSecondary:
                                                                      Colors
                                                                          .white,
                                                                  error:
                                                                      Colors
                                                                          .red,
                                                                  onError:
                                                                      Colors
                                                                          .white,
                                                                  surface:
                                                                      surfaceColor,
                                                                  onSurface:
                                                                      onSurfaceColor,
                                                                ),
                                                                textButtonTheme: TextButtonThemeData(
                                                                  style: TextButton.styleFrom(
                                                                    foregroundColor:
                                                                        primaryColor,
                                                                    textStyle: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                dialogTheme:
                                                                    DialogThemeData(
                                                                      backgroundColor:
                                                                          surfaceColor,
                                                                    ),
                                                              ),
                                                              child: child!,
                                                            );
                                                          },
                                                        );
                                                        if (picked != null) {
                                                          setState(() {
                                                            selectedStartDate =
                                                                picked;
                                                            startDateError =
                                                                false;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                    SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: RadioGroup<
                                                        FrequencyType
                                                      >(
                                                        groupValue:
                                                            editFrequencyType,
                                                        onChanged: (val) {
                                                          setState(() {
                                                            editFrequencyType =
                                                                val!;
                                                          });
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Radio<
                                                              FrequencyType
                                                            >(
                                                              value:
                                                                  FrequencyType
                                                                      .everyXDays,
                                                              activeColor:
                                                                  Colors.white,
                                                              fillColor:
                                                                  WidgetStateProperty.all(
                                                                    Colors
                                                                        .white,
                                                                  ),
                                                            ),
                                                            Text(
                                                              AppLocalizations.of(
                                                                context,
                                                              )!.everyXDays,
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Radio<
                                                              FrequencyType
                                                            >(
                                                              value:
                                                                  FrequencyType
                                                                      .daysOfWeek,
                                                              activeColor:
                                                                  Colors.white,
                                                              fillColor:
                                                                  WidgetStateProperty.all(
                                                                    Colors
                                                                        .white,
                                                                  ),
                                                            ),
                                                            Text(
                                                              AppLocalizations.of(
                                                                context,
                                                              )!.selectDaysOfWeek,
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    editFrequencyType ==
                                                            FrequencyType
                                                                .daysOfWeek
                                                        ? Column(
                                                          children: [
                                                            Text(
                                                              AppLocalizations.of(
                                                                context,
                                                              )!.selectDaysOfWeek,
                                                              style: TextStyle(
                                                                color:
                                                                    daysOfWeekError
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            _buildEditWeekdayPicker(
                                                              selectedDaysOfWeek,
                                                              (
                                                                dayNum,
                                                                selected,
                                                              ) {
                                                                setState(() {
                                                                  if (selected) {
                                                                    selectedDaysOfWeek
                                                                        .add(
                                                                          dayNum,
                                                                        );
                                                                    selectedDaysOfWeek.sort((
                                                                      a,
                                                                      b,
                                                                    ) {
                                                                      if (a ==
                                                                              7 &&
                                                                          b !=
                                                                              7) {
                                                                        return -1;
                                                                      }
                                                                      if (a !=
                                                                              7 &&
                                                                          b ==
                                                                              7) {
                                                                        return 1;
                                                                      }
                                                                      return a
                                                                          .compareTo(
                                                                            b,
                                                                          );
                                                                    });
                                                                  } else {
                                                                    selectedDaysOfWeek
                                                                        .remove(
                                                                          dayNum,
                                                                        );
                                                                  }
                                                                  if (daysOfWeekError &&
                                                                      selectedDaysOfWeek
                                                                          .isNotEmpty) {
                                                                    daysOfWeekError =
                                                                        false;
                                                                  }
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        )
                                                        : TextField(
                                                          controller:
                                                              frequencyController,
                                                          cursorColor:
                                                              Colors.white,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                          onChanged: (value) {
                                                            if (frequencyError &&
                                                                value
                                                                    .isNotEmpty &&
                                                                convertArabicNumerals(
                                                                      value,
                                                                    ) !=
                                                                    '0') {
                                                              setState(
                                                                () =>
                                                                    frequencyError =
                                                                        false,
                                                              );
                                                            }
                                                          },
                                                          decoration: InputDecoration(
                                                            labelText:
                                                                AppLocalizations.of(
                                                                  context,
                                                                )!.frequency,
                                                            labelStyle: TextStyle(
                                                              color:
                                                                  frequencyError
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            errorText:
                                                                frequencyError
                                                                    ? AppLocalizations.of(
                                                                      context,
                                                                    )!.dosageFrequencyGreaterThanZero
                                                                    : null,
                                                            errorStyle: TextStyle(
                                                              color:
                                                                  Colors
                                                                      .red[100],
                                                            ),
                                                            focusedBorder:
                                                                const UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                ),
                                                            enabledBorder:
                                                                const UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                ),
                                                          ),
                                                        ),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.cancel,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final isEveryXDays =
                                                        editFrequencyType ==
                                                        FrequencyType
                                                            .everyXDays;
                                                    final isDaysOfWeek =
                                                        editFrequencyType ==
                                                        FrequencyType
                                                            .daysOfWeek;

                                                    setState(() {
                                                      nameError = false;
                                                      typeError = false;
                                                      dosageError = false;
                                                      amountError = false;
                                                      frequencyError = false;
                                                      timeError = false;
                                                      startDateError = false;
                                                      daysOfWeekError = false;
                                                    });

                                                    bool hasErrors = false;

                                                    if (nameController
                                                        .text
                                                        .isEmpty) {
                                                      setState(
                                                        () => nameError = true,
                                                      );
                                                      hasErrors = true;
                                                    }
                                                    if (typeOfMedicationController
                                                        .text
                                                        .isEmpty) {
                                                      setState(
                                                        () => typeError = true,
                                                      );
                                                      hasErrors = true;
                                                    }
                                                    if (dosageController
                                                        .text
                                                        .isEmpty) {
                                                      setState(
                                                        () =>
                                                            dosageError = true,
                                                      );
                                                      hasErrors = true;
                                                    }
                                                    if (amountController
                                                        .text
                                                        .isEmpty) {
                                                      setState(
                                                        () =>
                                                            amountError = true,
                                                      );
                                                      hasErrors = true;
                                                    }
                                                    if (selectedTime == null) {
                                                      setState(
                                                        () => timeError = true,
                                                      );
                                                      hasErrors = true;
                                                    }
                                                    if (selectedStartDate ==
                                                        null) {
                                                      setState(
                                                        () =>
                                                            startDateError =
                                                                true,
                                                      );
                                                      hasErrors = true;
                                                    }
                                                    if (isEveryXDays &&
                                                        frequencyController
                                                            .text
                                                            .isEmpty) {
                                                      setState(
                                                        () =>
                                                            frequencyError =
                                                                true,
                                                      );
                                                      hasErrors = true;
                                                    }
                                                    if (isDaysOfWeek &&
                                                        selectedDaysOfWeek
                                                            .isEmpty) {
                                                      setState(
                                                        () =>
                                                            daysOfWeekError =
                                                                true,
                                                      );
                                                      hasErrors = true;
                                                    }

                                                    if (hasErrors) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          backgroundColor:
                                                              Colors.red,
                                                          content: Text(
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.pleaseFillAllFields,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Inter',
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }

                                                    if (isEveryXDays &&
                                                        (convertArabicNumerals(
                                                              frequencyController
                                                                  .text,
                                                            ).isEmpty ||
                                                            convertArabicNumerals(
                                                                  frequencyController
                                                                      .text,
                                                                ) ==
                                                                '0')) {
                                                      setState(
                                                        () =>
                                                            frequencyError =
                                                                true,
                                                      );
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          backgroundColor:
                                                              Colors.red,
                                                          content: Text(
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.dosageFrequencyGreaterThanZero,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Inter',
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    if (nameController
                                                            .text
                                                            .isNotEmpty &&
                                                        typeOfMedicationController
                                                            .text
                                                            .isNotEmpty &&
                                                        dosageController
                                                            .text
                                                            .isNotEmpty &&
                                                        frequencyController
                                                            .text
                                                            .isNotEmpty &&
                                                        amountController
                                                            .text
                                                            .isNotEmpty) {
                                                      if (dosageController
                                                                  .text ==
                                                              '0' ||
                                                          frequencyController
                                                                  .text ==
                                                              '0') {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            backgroundColor:
                                                                Colors.red,
                                                            content: Text(
                                                              AppLocalizations.of(
                                                                context,
                                                              )!.dosageFrequencyGreaterThanZero,
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Inter',
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                      if (selectedStartDate ==
                                                          null) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            backgroundColor:
                                                                Color(
                                                                  0xFF8AC249,
                                                                ),
                                                            content: Text(
                                                              AppLocalizations.of(
                                                                context,
                                                              )!.pleasePickScheduleStartDate,
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Inter',
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                      try {
                                                        final oldData =
                                                            docs[index].data()
                                                                as Map<
                                                                  String,
                                                                  dynamic
                                                                >;
                                                        await firestore.collection(widget.uid!).doc(docs[index].id).update({
                                                          'name':
                                                              nameController
                                                                  .text,
                                                          'typeOfMedication':
                                                              typeOfMedicationController
                                                                  .text,
                                                          'dosage':
                                                              double.tryParse(
                                                                convertArabicNumerals(
                                                                  dosageController
                                                                      .text,
                                                                ),
                                                              ) ??
                                                              0,
                                                          'frequency':
                                                              editFrequencyType ==
                                                                      FrequencyType
                                                                          .everyXDays
                                                                  ? (int.tryParse(
                                                                        convertArabicNumerals(
                                                                          frequencyController
                                                                              .text,
                                                                        ),
                                                                      ) ??
                                                                      1)
                                                                  : 1,
                                                          'amount':
                                                              double.tryParse(
                                                                convertArabicNumerals(
                                                                  amountController
                                                                      .text,
                                                                ),
                                                              ) ??
                                                              0,
                                                          'refillThreshold':
                                                              refillThresholdController
                                                                      .text
                                                                      .isNotEmpty
                                                                  ? double.tryParse(
                                                                    convertArabicNumerals(
                                                                      refillThresholdController
                                                                          .text,
                                                                    ),
                                                                  )
                                                                  : null,
                                                          'refillNotified':
                                                              false,
                                                          'notifyTime':
                                                              selectedTime !=
                                                                      null
                                                                  ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                                                  : '',
                                                          'startDate':
                                                              selectedStartDate!
                                                                  .toIso8601String(),
                                                          'daysOfWeek':
                                                              editFrequencyType ==
                                                                      FrequencyType
                                                                          .daysOfWeek
                                                                  ? selectedDaysOfWeek
                                                                  : null,
                                                        });
                                                        final updatedDoc =
                                                            await firestore
                                                                .collection(
                                                                  widget.uid!,
                                                                )
                                                                .doc(
                                                                  docs[index]
                                                                      .id,
                                                                )
                                                                .get();
                                                        final updatedMedication =
                                                            medicationFromDoc(
                                                              updatedDoc,
                                                            );

                                                        await scheduleMedicationNotification(
                                                          context,
                                                          docs[index].id,
                                                          updatedMedication,
                                                          userId: widget.uid,
                                                        );

                                                        if (updatedMedication
                                                                    .refillThreshold !=
                                                                null &&
                                                            updatedMedication
                                                                    .refillThreshold! >
                                                                0) {
                                                          if (updatedMedication
                                                                  .amount <=
                                                              updatedMedication
                                                                  .refillThreshold!) {
                                                            await scheduleWeeklyRefillNotification(
                                                              updatedMedication,
                                                              docs[index].id,
                                                            );
                                                          } else {
                                                            await cancelRefillNotifications(
                                                              docs[index].id,
                                                            );
                                                          }
                                                        }

                                                        if (!context.mounted) {
                                                          return;
                                                        }
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        );
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xFF8AC249,
                                                                ),
                                                            content: Text(
                                                              AppLocalizations.of(
                                                                context,
                                                              )!.medicationUpdated(
                                                                medication.name,
                                                              ),
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Inter',
                                                              ),
                                                            ),
                                                            action: SnackBarAction(
                                                              label:
                                                                  AppLocalizations.of(
                                                                    context,
                                                                  )!.undo,
                                                              textColor:
                                                                  Colors.red,
                                                              onPressed: () async {
                                                                await firestore
                                                                    .collection(
                                                                      widget
                                                                          .uid!,
                                                                    )
                                                                    .doc(
                                                                      docs[index]
                                                                          .id,
                                                                    )
                                                                    .set(
                                                                      oldData,
                                                                    );
                                                                await scheduleMedicationNotification(
                                                                  context,
                                                                  docs[index]
                                                                      .id,
                                                                  medicationFromDoc(
                                                                    await firestore
                                                                        .collection(
                                                                          widget
                                                                              .uid!,
                                                                        )
                                                                        .doc(
                                                                          docs[index]
                                                                              .id,
                                                                        )
                                                                        .get(),
                                                                  ),
                                                                );
                                                                if (mounted) {
                                                                  setState(
                                                                    () {},
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xFF8AC249,
                                                                ),
                                                            content: Text(
                                                              '${AppLocalizations.of(context)!.addMedicationFailed} $e',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Inter',
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    } else {
                                                      if (!mounted) return;
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          backgroundColor:
                                                              const Color(
                                                                0xFF8AC249,
                                                              ),
                                                          content: Text(
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.pleaseFillAllFields,
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'Inter',
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.white,
                                                      ),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.saveMedication,
                                                    style: const TextStyle(
                                                      color: Color(0xFF8AC249),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                  );
                                  if (result == true && mounted) {
                                    setState(() {});
                                  }
                                  return false;
                                }
                                return false;
                              },
                              onDismissed: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  final deletedDocId = docs[index].id;
                                  final deletedData =
                                      docs[index].data()
                                          as Map<String, dynamic>;
                                  final deletedMedication = medicationFromDoc(
                                    docs[index],
                                  );
                                  try {
                                    await firestore
                                        .collection(widget.uid!)
                                        .doc(deletedDocId)
                                        .delete();
                                    await flutterLocalNotificationsPlugin
                                        .cancel(deletedDocId.hashCode);
                                    await cancelMedicationReminders(
                                      deletedDocId,
                                    );
                                    await cancelRefillNotifications(
                                      deletedDocId,
                                    );

                                    setState(() {
                                      _recentlyDeletedMedication =
                                          deletedMedication;
                                      _recentlyDeletedData = deletedData;
                                      _recentlyDeletedDocId = deletedDocId;
                                    });
                                  } catch (e) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          ScaffoldMessenger.of(
                                            scaffoldContext,
                                          ).showSnackBar(
                                            SnackBar(
                                              backgroundColor: const Color(
                                                0xFF8AC249,
                                              ),
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.couldNotUpdateMedication,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Inter',
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  }
                                }
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color:
                                    medication.amount <= 0
                                        ? Colors.red
                                        : (medication.refillThreshold != null &&
                                            medication.refillThreshold! > 0 &&
                                            medication.amount <=
                                                medication.refillThreshold!)
                                        ? const Color(0xFFFF9800)
                                        : Color(0xFF8AC249),
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ListTile(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              insetPadding:
                                                  const EdgeInsets.all(16),
                                              child: MedicationDetailsCard(
                                                medication: medication,
                                              ),
                                            ),
                                      );
                                    },
                                    title: Text(
                                      medication.name,
                                      textDirection:
                                          Localizations.localeOf(
                                                    context,
                                                  ).languageCode ==
                                                  'ar'
                                              ? TextDirection.rtl
                                              : TextDirection.ltr,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (medication.daysOfWeek != null &&
                                            medication.daysOfWeek!.isNotEmpty)
                                          Text(
                                            "${medication.dosage} ${medication.typeOfMedication} ${AppLocalizations.of(context)!.every}: ${_getDaysOfWeekString(context, medication.daysOfWeek!)}",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          )
                                        else
                                          Text(
                                            "${medication.dosage} ${medication.typeOfMedication} ${AppLocalizations.of(context)!.every} ${medication.frequency} ${AppLocalizations.of(context)!.day}",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        if (medication.amount > 0)
                                          Text(
                                            "${AppLocalizations.of(context)!.currentAmount}: ${(medication.amount).toStringAsFixed(2)}",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          )
                                        else
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.outOfStock,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        if (getNextReminder(medication) != null)
                                          Text(
                                            "${AppLocalizations.of(context)!.nextReminder}: ${getNextReminder(medication)!}",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      tooltip: AppLocalizations.of(
                                        context,
                                      )!.takeMedication(medication.name),
                                      icon: const Icon(
                                        Icons.medication_rounded,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      onPressed: () async {
                                        if (medication.amount > 0) {
                                          final confirm = await showDialog<
                                            bool
                                          >(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  backgroundColor: Color(
                                                    0xFF8AC249,
                                                  ),
                                                  title: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.takeMedication(
                                                      medication.name,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.didYouTakeYourMedication(
                                                      medication.name,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.no,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.white,
                                                          ),
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.yes,
                                                        style: TextStyle(
                                                          color: Color(
                                                            0xFF8AC249,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                          if (confirm == true) {
                                            final previousAmount =
                                                medication.amount;
                                            try {
                                              await firestore
                                                  .collection(widget.uid!)
                                                  .doc(docs[index].id)
                                                  .update({
                                                    'amount':
                                                        medication.amount -
                                                                    medication
                                                                        .dosage <
                                                                0
                                                            ? 0
                                                            : medication
                                                                    .amount -
                                                                medication
                                                                    .dosage,
                                                    'lastTaken':
                                                        DateTime.now()
                                                            .toIso8601String(),
                                                  });
                                              await cancelMedicationReminders(
                                                docs[index].id,
                                              );

                                              final updatedDoc =
                                                  await firestore
                                                      .collection(widget.uid!)
                                                      .doc(docs[index].id)
                                                      .get();
                                              final updatedMedication =
                                                  medicationFromDoc(updatedDoc);

                                              await scheduleMedicationNotification(
                                                context,
                                                docs[index].id,
                                                updatedMedication,
                                              );

                                              if (updatedMedication
                                                          .refillThreshold !=
                                                      null &&
                                                  updatedMedication
                                                          .refillThreshold! >
                                                      0) {
                                                if (updatedMedication.amount <=
                                                    updatedMedication
                                                        .refillThreshold!) {
                                                  await scheduleWeeklyRefillNotification(
                                                    updatedMedication,
                                                    docs[index].id,
                                                  );
                                                } else {
                                                  await cancelRefillNotifications(
                                                    docs[index].id,
                                                  );
                                                }
                                              }

                                              if (updatedMedication.amount <=
                                                  0) {
                                                showDialog(
                                                  context: context,
                                                  builder: (
                                                    BuildContext context,
                                                  ) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF8AC249,
                                                          ),
                                                      title: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.youreOutOfMedication(
                                                          medication.name,
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.pleaseRefillYourMedication(
                                                          medication.name,
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                          },
                                                          child: Text(
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.ok,
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else if (updatedMedication
                                                          .refillThreshold !=
                                                      null &&
                                                  updatedMedication
                                                          .refillThreshold! >
                                                      0 &&
                                                  previousAmount >
                                                      updatedMedication
                                                          .refillThreshold! &&
                                                  updatedMedication.amount <=
                                                      updatedMedication
                                                          .refillThreshold!) {
                                                showDialog(
                                                  context: context,
                                                  builder: (
                                                    BuildContext context,
                                                  ) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFFFF9800,
                                                          ),
                                                      title: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .warning_rounded,
                                                            color: Colors.white,
                                                            size: 28,
                                                          ),
                                                          SizedBox(width: 12),
                                                          Expanded(
                                                            child: Text(
                                                              '${AppLocalizations.of(context)!.lowStock}: ${medication.name}',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      content: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.refillReminderBody(
                                                          updatedMedication
                                                              .amount
                                                              .toInt()
                                                              .toString(),
                                                          updatedMedication
                                                              .name,
                                                          updatedMedication
                                                              .typeOfMedication,
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                          },
                                                          child: Text(
                                                            AppLocalizations.of(
                                                              context,
                                                            )!.ok,
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: const Color(
                                                    0xFF8AC249,
                                                  ),
                                                  content: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.markedAsTaken(
                                                      medication.name,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Inter',
                                                    ),
                                                  ),
                                                  action: SnackBarAction(
                                                    label:
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.undo,
                                                    textColor: Colors.red,
                                                    onPressed: () async {
                                                      await firestore
                                                          .collection(
                                                            widget.uid!,
                                                          )
                                                          .doc(docs[index].id)
                                                          .update({
                                                            'amount':
                                                                previousAmount,
                                                            'lastTaken': null,
                                                          });
                                                      final restoredDoc =
                                                          await firestore
                                                              .collection(
                                                                widget.uid!,
                                                              )
                                                              .doc(
                                                                docs[index].id,
                                                              )
                                                              .get();
                                                      final restoredMedication =
                                                          medicationFromDoc(
                                                            restoredDoc,
                                                          );
                                                      await scheduleMedicationNotification(
                                                        context,
                                                        docs[index].id,
                                                        restoredMedication,
                                                      );
                                                      if (mounted) {
                                                        setState(() {});
                                                      }
                                                    },
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: const Color(
                                                    0xFF8AC249,
                                                  ),
                                                  content: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.couldNotUpdateMedication,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Inter',
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.red,
                                                title: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.youreOutOfMedication(
                                                    medication.name,
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.pleaseRefillYourMedication(
                                                    medication.name,
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                    child: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.ok,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8AC249).withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          tooltip: AppLocalizations.of(context)!.addMedication,
          shape: const CircleBorder(),
          backgroundColor:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2C2C2C)
                  : Colors.white,
          elevation: 0,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMedications(uid: widget.uid!),
              ),
            );
            if (!mounted) return;
          },
          child: const Icon(
            Icons.add_rounded,
            color: Color(0xFF8AC249),
            size: 36,
          ),
        ),
      ),
    );
  }

  Widget _buildEditWeekdayPicker(
    List<int> selectedDaysOfWeek,
    Function(int, bool) onSelectionChanged,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final daysAr = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    final days = isArabic ? daysAr : daysEn;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(7, (i) {
        final dayNum = i == 0 ? 7 : i;
        final isSelected = selectedDaysOfWeek.contains(dayNum);
        return FilterChip(
          label: Text(
            days[i],
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF8AC249),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          selected: isSelected,
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFF8AC249).withValues(alpha: 0.8),
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color:
                  isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          elevation: isSelected ? 3 : 1,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.comfortable,
          onSelected: (selected) {
            onSelectionChanged(dayNum, selected);
          },
        );
      }),
    );
  }
}

class MedicationDetailsCard extends StatelessWidget {
  final Medications medication;
  const MedicationDetailsCard({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final daysAr = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    final hasDaysOfWeek =
        medication.daysOfWeek != null && medication.daysOfWeek!.isNotEmpty;
    final days =
        hasDaysOfWeek
            ? medication.daysOfWeek!
                .map(
                  (d) =>
                      isArabic
                          ? daysAr[d == 7 ? 0 : d]
                          : daysEn[d == 7 ? 0 : d],
                )
                .join(isArabic ? '، ' : ', ')
            : null;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF8AC249), width: 2),
      ),
      color:
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF222222)
              : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                medication.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 26,
                  color: const Color(0xFF8AC249),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(
              icon: Icons.category,
              label: AppLocalizations.of(context)!.unitOfMeasurement,
              value: medication.typeOfMedication,
              valueStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF8AC249),
                fontSize: 18,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 18),
            _DetailRow(
              icon: Icons.medical_services,
              label: AppLocalizations.of(context)!.dosage,
              value: "${medication.dosage}",
              valueStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF8AC249),
                fontSize: 18,
                fontFamily: 'Inter',
              ),
            ),
            if (medication.daysOfWeek == null ||
                medication.daysOfWeek!.isEmpty) ...[
              const SizedBox(height: 18),
              _DetailRow(
                icon: Icons.repeat,
                label: AppLocalizations.of(context)!.frequency,
                value:
                    "${AppLocalizations.of(context)!.every} ${medication.frequency} ${AppLocalizations.of(context)!.day}",
                valueStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8AC249),
                  fontSize: 18,
                  fontFamily: 'Inter',
                ),
              ),
            ],
            if (hasDaysOfWeek && days != null && days.isNotEmpty) ...[
              const SizedBox(height: 18),
              _DetailRow(
                icon: Icons.calendar_today,
                label: AppLocalizations.of(context)!.selectDaysOfWeek,
                value: days,
                valueStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8AC249),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ],
            const SizedBox(height: 18),
            _DetailRow(
              icon: Icons.inventory_2,
              label: AppLocalizations.of(context)!.currentAmount,
              value: "${medication.amount}",
              valueStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF8AC249),
                fontSize: 18,
                fontFamily: 'Inter',
              ),
            ),
            if (medication.refillThreshold != null &&
                medication.refillThreshold! > 0) ...[
              const SizedBox(height: 18),
              _DetailRow(
                icon: Icons.warning_amber_rounded,
                label: AppLocalizations.of(context)!.refillThresholdDisplay,
                value: "${medication.refillThreshold}",
                valueStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8AC249),
                  fontSize: 18,
                  fontFamily: 'Inter',
                ),
              ),
            ],
            const SizedBox(height: 18),
            if (getNextReminder(medication) != null)
              _DetailRow(
                icon: Icons.notifications_active,
                label: AppLocalizations.of(context)!.nextReminder,
                value: getNextReminder(medication)!,
                valueStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8AC249),
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF8AC249)),
        const SizedBox(width: 12),
        Text(
          "$label: ",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style:
                valueStyle ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

Medications medicationFromDoc(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return Medications.fromMap(data);
}

Future<void> scheduleMedicationNotification(
  BuildContext? context,
  String docId,
  Medications medication, {
  bool forceNextDay = false,
  String? userId,
}) async {
  if (kIsWeb) return;

  await requestExactAlarmPermission();
  if (medication.notifyTime == null || medication.notifyTime!.isEmpty) return;
  final timeParts = medication.notifyTime!.split(':');
  if (timeParts.length != 2) return;
  final hour = int.tryParse(timeParts[0]);
  final minute = int.tryParse(timeParts[1]);
  if (hour == null || minute == null) return;

  for (int i = 0; i <= 4; i++) {
    await flutterLocalNotificationsPlugin.cancel(docId.hashCode + i);
  }

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
    final twoHoursAfter = todayScheduledTime.add(const Duration(hours: 2));
    final isTodayScheduled = daysOfWeek.contains(now.weekday);
    final isWithinWindow =
        isTodayScheduled &&
        now.isAfter(todayScheduledTime) &&
        now.isBefore(twoHoursAfter);

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

  if (!isWithinWindowOfToday) {
    while (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: medication.frequency));
    }
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
              sound: RawResourceAndroidNotificationSound('notification_sound'),
              color: const Color(0xFF8AC249),
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
              presentBadge: true,
              sound: "notification_sound.wav",
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
      if (e is PlatformException && e.code == 'exact_alarms_not_permitted') {
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
          ),
        );
      }
    }
  }
}

Future<void> cancelMedicationReminders(String docId) async {
  for (int i = 0; i <= 8; i++) {
    final notificationId = ('${docId}_$i').hashCode;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
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
  } catch (e) {
    if (kDebugMode) {
      print('Error canceling refill notifications: $e');
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

Future<void> initializeNotifications() async {
  await flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('dawatime_notify'),
    ),
  );
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
      final date = now.add(Duration(days: i));
      if (medication.daysOfWeek!.contains(date.weekday)) {
        final scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );
        if (scheduledTime.isAfter(now)) {
          final isArabic =
              contextToUse != null
                  ? Localizations.localeOf(contextToUse).languageCode == 'ar'
                  : WidgetsBinding
                          .instance
                          .platformDispatcher
                          .locale
                          .languageCode ==
                      'ar';
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
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
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
          : WidgetsBinding.instance.platformDispatcher.locale.languageCode ==
              'ar';
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
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
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

Future<void> rescheduleAllMedications(String uid) async {
  if (kIsWeb) return;

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
      print(
        'Error rescheduling medications (user may not be authenticated): $e',
      );
    }
  }
}

String convertArabicNumerals(String input) {
  const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (int i = 0; i < arabicNums.length; i++) {
    input = input.replaceAll(arabicNums[i], i.toString());
  }
  return input;
}

String _getDaysOfWeekString(BuildContext context, List<int> daysOfWeek) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final daysAr = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];
  final days = isArabic ? daysAr : daysEn;
  final separator = isArabic ? '، ' : ', ';
  return daysOfWeek.map((d) => days[d == 7 ? 0 : d]).join(separator);
}
