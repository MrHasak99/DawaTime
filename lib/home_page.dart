import 'dart:async';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dawatime/add_medications.dart';
import 'package:dawatime/login_page.dart';
import 'package:dawatime/main.dart';
import 'package:dawatime/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dawatime/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:dawatime/utils/medication_notifications.dart';
import 'package:dawatime/utils/string_utils.dart';
import 'package:dawatime/utils/medication_helpers.dart';

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
  Timer? _autoRefreshTimer;
  final Set<String> _shownAlerts = {};
  final ScrollController _scrollController = ScrollController();

  int _introStep = 0;

  bool? _useNewStructure;

  CollectionReference _getMedicationsCollection(String userId) {
    if (_useNewStructure == false) {
      return firestore.collection(userId);
    }
    return firestore.collection('Users').doc(userId).collection('medications');
  }

  Future<void> _checkMigrationStatus(String userId) async {
    if (_useNewStructure != null) return;

    try {
      final newLocation = firestore
          .collection('Users')
          .doc(userId)
          .collection('medications');
      final newSnapshot = await newLocation.limit(1).get();
      final hasNewData = newSnapshot.docs.isNotEmpty;

      final oldLocation = firestore.collection(userId);
      final oldSnapshot = await oldLocation.limit(1).get();
      final hasOldData = oldSnapshot.docs.isNotEmpty;

      if (hasNewData && hasOldData) {
        try {
          final allOldDocs = await oldLocation.get();
          for (var doc in allOldDocs.docs) {
            await doc.reference.delete();
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️  Error cleaning up old location: $e');
          }
        }

        setState(() => _useNewStructure = true);
      } else if (hasNewData) {
        setState(() => _useNewStructure = true);
      } else if (hasOldData) {
        setState(() => _useNewStructure = false);
      } else {
        setState(() => _useNewStructure = true);
      }
    } catch (e) {
      setState(() => _useNewStructure = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _useNewStructure = null;
          _checkMigrationStatus(userId);
        }
      });
    }
  }

  List<Map<String, String>> get _introSteps {
    final loc = AppLocalizations.of(context)!;
    return [
      {'title': loc.welcomeToDawaTime, 'body': loc.welcomeBody},
      {'title': loc.addMedicationTitle, 'body': loc.addMedicationBody},
      {'title': loc.editDeleteTitle, 'body': loc.editDeleteBody},
      {'title': loc.notifications, 'body': loc.notificationsBody},
      {'title': loc.stockRefillTitle, 'body': loc.stockRefillBody},
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
        _checkMigrationStatus(user.uid);
        _checkPermissionsIfNeeded(user.uid);
        _scheduleAfterPermissionCheck(user.uid);
      }

      _medicationCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _checkAndShowDueMedications();
      });

      _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) setState(() {});
      });

      selectNotificationStream.stream.listen((
        NotificationResponse response,
      ) async {
        if (response.payload != null && widget.uid != null) {
          final payload = response.payload!;

          if (payload == 'refill_multiple' || payload.startsWith('refill_')) {
            await _checkAndShowDueMedications();
            return;
          }

          final docId = payload;
          final doc =
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(widget.uid!)
                  .collection('medications')
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

    _localeListener = () {
      if (mounted) setState(() {});
    };
    localeNotifier.addListener(_localeListener);
  }

  @override
  void dispose() {
    _medicationCheckTimer?.cancel();
    _autoRefreshTimer?.cancel();
    _scrollController.dispose();
    localeNotifier.removeListener(_localeListener);
    super.dispose();
  }

  Future<void> _checkPermissionsIfNeeded(String userId) async {
    if (kIsWeb) return;

    if (!Platform.isAndroid) return;
    try {
      final snapshot = await _getMedicationsCollection(userId).limit(1).get();
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

    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error clearing notifications: $e');
      }
    }

    rescheduleAllMedications(userId);
    _autoRescheduleOverdueMedications(userId);
    _checkRefillReminders(userId);
  }

  Future<void> _autoRescheduleOverdueMedications(String userId) async {
    try {
      final now = DateTime.now();
      final meds = await _getMedicationsCollection(userId).limit(12).get();

      for (var doc in meds.docs) {
        final medication = medicationFromDoc(doc);
        if (medication.notifyTime == null || medication.notifyTime!.isEmpty) {
          continue;
        }

        final timeParts = medication.notifyTime!.split(':');
        if (timeParts.length != 2) continue;
        final int? hour = int.tryParse(timeParts[0]);
        final int? minute = int.tryParse(timeParts[1]);
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
            await _getMedicationsCollection(
              userId,
            ).doc(doc.id).update(updatedMedication.toMap());
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
      final meds = await _getMedicationsCollection(userId).limit(12).get();
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
            await _getMedicationsCollection(
              userId,
            ).doc(doc.id).update({'refillNotified': true});
          }
          await scheduleWeeklyRefillNotification(medication, doc.id);
        } else {
          await cancelRefillNotifications(doc.id);
          if (medication.refillNotified == true) {
            await _getMedicationsCollection(
              userId,
            ).doc(doc.id).update({'refillNotified': false});
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

  Future<void> _checkAndShowDueMedications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final now = DateTime.now();
      final meds =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .collection('medications')
              .limit(12)
              .get();

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
          bool shouldShowAlert = false;
          String alertKey = '';

          for (int i = 0; i <= 4; i++) {
            final followUpTime = scheduledTime.add(Duration(minutes: 30 * i));
            alertKey = '${doc.id}_$i';

            if ((now.difference(followUpTime).inSeconds).abs() <= 1 &&
                !_shownAlerts.contains(alertKey)) {
              shouldShowAlert = true;
              break;
            }
          }

          if (shouldShowAlert) {
            _shownAlerts.add(alertKey);

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
            for (int i = 0; i <= 4; i++) {
              _shownAlerts.remove('${doc.id}_$i');
            }
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
    if (widget.uid == null) {
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

    if (_recentlyDeletedMedication != null &&
        _recentlyDeletedData != null &&
        _recentlyDeletedDocId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
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
            persist: false,
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.undo,
              textColor: Colors.red,
              onPressed: () async {
                try {
                  await _getMedicationsCollection(
                    widget.uid!,
                  ).doc(deletedDocId!).set(deletedData!);
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
                  if (mounted) {
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
                        persist: false,
                      ),
                    );
                  }
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
        stream: _getMedicationsCollection(user.uid).limit(12).snapshots(),
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
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final medication = medicationFromDoc(docs[index]);
                          final docId = docs[index].id;
                          final docData =
                              docs[index].data() as Map<String, dynamic>?;
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
                                                          persist: false,
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
                                                          persist: false,
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
                                                            persist: false,
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
                                                            persist: false,
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
                                                                >?;
                                                        if (oldData == null) {
                                                          if (mounted) {
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
                                                                  )!.couldNotUpdateMedication,
                                                                  style: const TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                                ),
                                                                persist: false,
                                                              ),
                                                            );
                                                          }
                                                          return;
                                                        }
                                                        await _getMedicationsCollection(
                                                          widget.uid!,
                                                        ).doc(docId).update({
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
                                                            await _getMedicationsCollection(
                                                              widget.uid!,
                                                            ).doc(docId).get();
                                                        final updatedMedication =
                                                            medicationFromDoc(
                                                              updatedDoc,
                                                            );

                                                        await scheduleMedicationNotification(
                                                          context,
                                                          docId,
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
                                                              docId,
                                                            );
                                                          } else {
                                                            await cancelRefillNotifications(
                                                              docId,
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
                                                            persist: false,
                                                            action: SnackBarAction(
                                                              label:
                                                                  AppLocalizations.of(
                                                                    context,
                                                                  )!.undo,
                                                              textColor:
                                                                  Colors.red,
                                                              onPressed: () async {
                                                                await _getMedicationsCollection(
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
                                                                    await _getMedicationsCollection(
                                                                          widget
                                                                              .uid!,
                                                                        )
                                                                        .doc(
                                                                          docs[index]
                                                                              .id,
                                                                        )
                                                                        .get(),
                                                                  ),
                                                                  userId:
                                                                      widget
                                                                          .uid,
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
                                                            persist: false,
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
                                                          persist: false,
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
                                  if (docData == null) {
                                    if (mounted) {
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
                                            ),
                                          ),
                                          persist: false,
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                  try {
                                    await _getMedicationsCollection(
                                      widget.uid!,
                                    ).doc(docId).delete();
                                    await flutterLocalNotificationsPlugin
                                        .cancel(docId.hashCode);
                                    await cancelMedicationReminders(docId);
                                    await cancelRefillNotifications(docId);

                                    setState(() {
                                      _recentlyDeletedMedication = medication;
                                      _recentlyDeletedData = docData;
                                      _recentlyDeletedDocId = docId;
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
                                              persist: false,
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
                                            final docId = docs[index].id;
                                            try {
                                              await _getMedicationsCollection(
                                                widget.uid!,
                                              ).doc(docId).update({
                                                'amount':
                                                    medication.amount -
                                                                medication
                                                                    .dosage <
                                                            0
                                                        ? 0
                                                        : medication.amount -
                                                            medication.dosage,
                                                'lastTaken':
                                                    DateTime.now()
                                                        .toIso8601String(),
                                              });
                                              await cancelMedicationReminders(
                                                docId,
                                              );
                                              final updatedDoc =
                                                  await _getMedicationsCollection(
                                                    widget.uid!,
                                                  ).doc(docId).get();
                                              final updatedMedication =
                                                  medicationFromDoc(updatedDoc);
                                              await scheduleMedicationNotification(
                                                context,
                                                docId,
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
                                                  persist: false,
                                                  action: SnackBarAction(
                                                    label:
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.undo,
                                                    textColor: Colors.red,
                                                    onPressed: () async {
                                                      await _getMedicationsCollection(
                                                        widget.uid!,
                                                      ).doc(docId).update({
                                                        'amount':
                                                            previousAmount,
                                                        'lastTaken': null,
                                                      });
                                                      final restoredDoc =
                                                          await _getMedicationsCollection(
                                                            widget.uid!,
                                                          ).doc(docId).get();
                                                      final restoredMedication =
                                                          medicationFromDoc(
                                                            restoredDoc,
                                                          );
                                                      final now =
                                                          DateTime.now();
                                                      final notifyTime =
                                                          restoredMedication
                                                              .notifyTime;
                                                      bool scheduled = false;
                                                      if (notifyTime != null &&
                                                          notifyTime
                                                              .isNotEmpty) {
                                                        final timeParts =
                                                            notifyTime.split(
                                                              ':',
                                                            );
                                                        if (timeParts.length ==
                                                            2) {
                                                          final hour =
                                                              int.tryParse(
                                                                timeParts[0],
                                                              );
                                                          final minute =
                                                              int.tryParse(
                                                                timeParts[1],
                                                              );
                                                          if (hour != null &&
                                                              minute != null) {
                                                            final todayScheduledTime =
                                                                DateTime(
                                                                  now.year,
                                                                  now.month,
                                                                  now.day,
                                                                  hour,
                                                                  minute,
                                                                );
                                                            final twoHoursAfter =
                                                                todayScheduledTime
                                                                    .add(
                                                                      const Duration(
                                                                        hours:
                                                                            2,
                                                                      ),
                                                                    );
                                                            if (now.isAfter(
                                                                  todayScheduledTime,
                                                                ) &&
                                                                now.isBefore(
                                                                  twoHoursAfter,
                                                                )) {
                                                              await scheduleMedicationNotification(
                                                                context,
                                                                docId,
                                                                restoredMedication,
                                                              );
                                                              scheduled = true;
                                                            }
                                                          }
                                                        }
                                                      }
                                                      if (!scheduled) {
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
                                                              )!.reminderWindowPassed,
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
                                                            persist: false,
                                                          ),
                                                        );
                                                      }
                                                      if (mounted) {
                                                        setState(() {});
                                                      }
                                                    },
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor:
                                                        const Color(0xFF8AC249),
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
                                                    persist: false,
                                                  ),
                                                );
                                              }
                                            }
                                          }
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
  final TextStyle valueStyle;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF8AC249), size: 22),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF8AC249),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: valueStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

Future<void> initializeNotifications() async {
  await flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('dawatime_notify'),
    ),
  );
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
