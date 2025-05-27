import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medication_app_full/add_medications.dart';
import 'package:medication_app_full/database/medications.dart';
import 'package:medication_app_full/login_page.dart';
import 'package:medication_app_full/medication_details.dart';
import 'package:medication_app_full/user_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomePage extends StatefulWidget {
  final String? uid;
  const HomePage({super.key, this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

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

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification: (id, title, body, payload) async {
            if (_scaffoldContext.mounted) {
              showDialog(
                context: _scaffoldContext,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: Colors.lightGreen,
                      title: Text(
                        title ?? "Medication Reminder",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        body ?? "It's time to take your medication!",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "OK",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
              );
            }
          },
        );
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (_scaffoldContext.mounted) {
          showDialog(
            context: _scaffoldContext,
            builder:
                (context) => AlertDialog(
                  backgroundColor: Colors.lightGreen,
                  title: const Text(
                    "Medication Reminder",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    response.payload != null && response.payload!.isNotEmpty
                        ? response.payload!
                        : "It's time to take your medication!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
          );
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    tz.initializeTimeZones();
  }

  @pragma('vm:entry-point')
  void notificationTapBackground(NotificationResponse response) {}

  Future<void> _scheduleMedicationNotification(Medications medication) async {
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
      medication.hashCode,
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

  late BuildContext _scaffoldContext;

  @override
  Widget build(BuildContext context) {
    _scaffoldContext = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Center(
          child: Text(
            "9i7ati",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            tooltip: 'View Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection(widget.uid!).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Medications Found",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          final docs = snapshot.data!.docs;
          for (final doc in docs) {
            final medication = medicationFromDoc(doc);
            _scheduleMedicationNotification(medication);
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final medication = medicationFromDoc(docs[index]);
              return Card(
                color: medication.amount <= 0 ? Colors.red : Colors.lightGreen,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MedicationDetails(
                              uid: widget.uid!,
                              docId: docs[index].id,
                              medications: medication,
                            ),
                      ),
                    );
                  },
                  title: Text(
                    medication.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${medication.dosage} ${medication.typeOfMedication} every ${medication.frequency}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (medication.amount > 0)
                        Text(
                          "${(medication.amount).toStringAsFixed(2)} left",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        const Text(
                          "Out of stock",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (medication.notifyTime != null &&
                          medication.notifyTime!.isNotEmpty)
                        Builder(
                          builder: (context) {
                            final parts = medication.notifyTime!.split(':');
                            if (parts.length == 2) {
                              final hour = int.tryParse(parts[0]) ?? 0;
                              final minute = int.tryParse(parts[1]) ?? 0;
                              final timeOfDay = TimeOfDay(
                                hour: hour,
                                minute: minute,
                              );
                              return Text(
                                "Notify at: ${timeOfDay.format(context)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                            return SizedBox.shrink();
                          },
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: "Take Medication",
                    icon: const Icon(
                      Icons.medication_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () async {
                      if (medication.amount > 0) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: Colors.lightGreen,
                                title: Text(
                                  "Take ${medication.name}?",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  "Did you take your medication?",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text(
                                      "No",
                                      style: TextStyle(
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
                                        () => Navigator.pop(context, true),
                                    child: const Text(
                                      "Yes",
                                      style: TextStyle(
                                        color: Colors.lightGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          firestore
                              .collection(widget.uid!)
                              .doc(docs[index].id)
                              .update({
                                'amount':
                                    medication.amount - medication.dosage < 0
                                        ? 0
                                        : medication.amount - medication.dosage,
                              });
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.lightGreen,
                              title: Text(
                                "You're out of ${medication.name}!",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                "Please refill your ${medication.name}.",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    "OK",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Medication",
        shape: const CircleBorder(),
        backgroundColor: Colors.lightGreen,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMedications(uid: widget.uid!),
            ),
          );
          if (!mounted) return;
        },
        child: const Icon(Icons.add_circle_rounded, color: Colors.white),
      ),
    );
  }
}
