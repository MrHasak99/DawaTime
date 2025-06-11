import 'package:android_intent_plus/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medication_app_full/add_medications.dart';
import 'package:medication_app_full/login_page.dart';
import 'package:medication_app_full/main.dart';
import 'package:medication_app_full/settings.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class Medications {
  final String name;
  final String typeOfMedication;
  final double dosage;
  final int frequency;
  final double amount;
  final String? notifyTime;

  Medications({
    required this.name,
    required this.typeOfMedication,
    required this.dosage,
    required this.frequency,
    required this.amount,
    this.notifyTime,
  });

  factory Medications.fromMap(Map<String, dynamic> data) {
    return Medications(
      name: data['name'] ?? '',
      typeOfMedication: data['typeOfMedication'] ?? '',
      dosage: (data['dosage'] ?? 0).toDouble(),
      frequency: (data['frequency'] ?? 1),
      amount: (data['amount'] ?? 0).toDouble(),
      notifyTime: data['notifyTime']?.toString(),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleUserMedications();
  }

  Future<void> _scheduleUserMedications() async {
    if (widget.uid == null) return;
    final meds = await firestore.collection(widget.uid!).get();
    for (var doc in meds.docs) {
      final medication = medicationFromDoc(doc);
      await scheduleMedicationNotification(context, doc.id, medication);
    }
  }

  @pragma('vm:entry-point')
  void notificationTapBackground(NotificationResponse response) {}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Future.microtask(() {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.lightGreen),
        ),
      );
    }

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
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            tooltip: 'View Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active),
              label: const Text('Test Notification (Immediate)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await flutterLocalNotificationsPlugin.show(
                  0,
                  'Test Notification',
                  'This is a test notification',
                  const NotificationDetails(
                    android: AndroidNotificationDetails(
                      'medication_channel',
                      'Medication Reminders',
                      channelDescription: 'Reminds you to take your medication',
                      importance: Importance.max,
                      priority: Priority.high,
                      icon: '@mipmap/ic_launcher',
                    ),
                    iOS: DarwinNotificationDetails(presentSound: true),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('Future Test Notification (30 seconds)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final scheduledTime = tz.TZDateTime.now(
                  tz.local,
                ).add(const Duration(seconds: 30));
                await flutterLocalNotificationsPlugin.zonedSchedule(
                  999,
                  'Test Scheduled',
                  'This is a test scheduled notification',
                  scheduledTime,
                  const NotificationDetails(
                    android: AndroidNotificationDetails(
                      'test_channel',
                      'Test Channel',
                      channelDescription: 'Test notifications',
                      importance: Importance.max,
                      priority: Priority.high,
                    ),
                  ),
                  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                  uiLocalNotificationDateInterpretation:
                      UILocalNotificationDateInterpretation.absoluteTime,
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection(user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.lightGreen),
                  );
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

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final medication = medicationFromDoc(docs[index]);
                    return Dismissible(
                      key: Key(docs[index].id),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.lightBlue,
                          size: 32,
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                  backgroundColor: Colors.lightGreen,
                                  title: const Text(
                                    'Delete Medication',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete ${medication.name}?',
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
                                        'Cancel',
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
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        } else if (direction == DismissDirection.startToEnd) {
                          final nameController = TextEditingController(
                            text: medication.name,
                          );
                          final typeController = TextEditingController(
                            text: medication.typeOfMedication,
                          );
                          final dosageController = TextEditingController(
                            text: medication.dosage.toString(),
                          );
                          final frequencyController = TextEditingController(
                            text: medication.frequency.toString(),
                          );
                          final amountController = TextEditingController(
                            text: medication.amount.toString(),
                          );
                          TimeOfDay? localNotifyTime;
                          if (medication.notifyTime != null &&
                              medication.notifyTime!.isNotEmpty) {
                            final parts = medication.notifyTime!.split(":");
                            if (parts.length == 2) {
                              localNotifyTime = TimeOfDay(
                                hour: int.tryParse(parts[0]) ?? 0,
                                minute: int.tryParse(parts[1]) ?? 0,
                              );
                            }
                          }

                          final result = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder:
                                    (context, setState) => AlertDialog(
                                      backgroundColor: Colors.lightGreen,
                                      title: const Text(
                                        'Edit Medication',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: nameController,
                                              cursorColor: Colors.white,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              decoration: const InputDecoration(
                                                labelText: 'Name',
                                                labelStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                            TextField(
                                              controller: typeController,
                                              cursorColor: Colors.white,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'Unit of Measurement',
                                                labelStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                            TextField(
                                              controller: dosageController,
                                              cursorColor: Colors.white,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: 'Dosage',
                                                labelStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                              ),
                                            ),

                                            TextField(
                                              controller: frequencyController,
                                              cursorColor: Colors.white,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'Frequency (every x days)',
                                                labelStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                            TextField(
                                              controller: amountController,
                                              cursorColor: Colors.white,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: 'Current Amount',
                                                labelStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                            ListTile(
                                              title: Text(
                                                localNotifyTime == null
                                                    ? "Pick Notification Time"
                                                    : "Notify at: ${localNotifyTime!.format(context)}",
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              trailing: const Icon(
                                                Icons.access_time,
                                                color: Colors.black,
                                              ),
                                              onTap: () async {
                                                final picked = await showTimePicker(
                                                  context: context,
                                                  initialTime:
                                                      localNotifyTime ??
                                                      TimeOfDay.now(),
                                                  builder: (context, child) {
                                                    return Theme(
                                                      data: Theme.of(
                                                        context,
                                                      ).copyWith(
                                                        timePickerTheme: TimePickerThemeData(
                                                          backgroundColor:
                                                              Colors.lightGreen,
                                                          hourMinuteTextColor:
                                                              Colors.black,
                                                          hourMinuteColor:
                                                              Colors.white,
                                                          dayPeriodTextColor:
                                                              Colors.black,
                                                          dayPeriodColor:
                                                              Colors.white,
                                                          dialHandColor:
                                                              Colors.lightGreen,
                                                          dialBackgroundColor:
                                                              Colors.white,
                                                          entryModeIconColor:
                                                              Colors.white,
                                                          helpTextStyle:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                          hourMinuteTextStyle:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 28,
                                                              ),
                                                          dayPeriodTextStyle:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                          dialTextStyle:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                              ),
                                                        ),
                                                        textButtonTheme: TextButtonThemeData(
                                                          style: TextButton.styleFrom(
                                                            foregroundColor:
                                                                Colors.white,
                                                            textStyle:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      child: child!,
                                                    );
                                                  },
                                                );
                                                if (picked != null) {
                                                  setState(() {
                                                    localNotifyTime = picked;
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (nameController
                                                    .text
                                                    .isNotEmpty &&
                                                typeController
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
                                              if (dosageController.text ==
                                                      '0' ||
                                                  frequencyController.text ==
                                                      '0') {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Dosage and Frequency must be greater than 0",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              try {
                                                await firestore
                                                    .collection(widget.uid!)
                                                    .doc(docs[index].id)
                                                    .update({
                                                      'name':
                                                          nameController.text,
                                                      'typeOfMedication':
                                                          typeController.text,
                                                      'dosage':
                                                          double.tryParse(
                                                            dosageController
                                                                .text,
                                                          ) ??
                                                          0,

                                                      'frequency':
                                                          int.tryParse(
                                                            frequencyController
                                                                .text,
                                                          ) ??
                                                          0,
                                                      'amount':
                                                          double.tryParse(
                                                            amountController
                                                                .text,
                                                          ) ??
                                                          0,
                                                      'notifyTime':
                                                          localNotifyTime !=
                                                                  null
                                                              ? '${localNotifyTime!.hour.toString().padLeft(2, '0')}:${localNotifyTime!.minute.toString().padLeft(2, '0')}'
                                                              : '',
                                                    });
                                                final updatedDoc =
                                                    await firestore
                                                        .collection(widget.uid!)
                                                        .doc(docs[index].id)
                                                        .get();
                                                final updatedMedication =
                                                    medicationFromDoc(
                                                      updatedDoc,
                                                    );

                                                await scheduleMedicationNotification(
                                                  context,
                                                  docs[index].id,
                                                  updatedMedication,
                                                );
                                                if (!context.mounted) return;
                                                Navigator.pop(context, true);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Medication updated!',
                                                    ),
                                                  ),
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Failed to add medication: $e',
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
                                                  content: Text(
                                                    "Please fill all fields",
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            'Save',
                                            style: TextStyle(
                                              color: Colors.lightGreen,
                                              fontWeight: FontWeight.bold,
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
                              docs[index].data() as Map<String, dynamic>;

                          try {
                            await firestore
                                .collection(widget.uid!)
                                .doc(docs[index].id)
                                .delete();
                            await flutterLocalNotificationsPlugin.cancel(
                              docs[index].id.hashCode,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${medication.name} deleted!'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to delete medication: $e',
                                ),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  textColor: Colors.lightGreen,
                                  onPressed: () async {
                                    await firestore
                                        .collection(widget.uid!)
                                        .doc(deletedDocId)
                                        .set(deletedData);
                                    await scheduleMedicationNotification(
                                      context,
                                      deletedDocId,
                                      medicationFromDoc(
                                        await firestore
                                            .collection(widget.uid!)
                                            .doc(deletedDocId)
                                            .get(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Card(
                        color:
                            medication.amount <= 0
                                ? Colors.red
                                : Colors.lightGreen,
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(16),
                                    child: MedicationDetailsCard(
                                      medication: medication,
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
                                "${medication.dosage} ${medication.typeOfMedication} every ${medication.frequency} ${medication.frequency == 1 ? 'day' : 'days'}",
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
                                    final parts = medication.notifyTime!.split(
                                      ':',
                                    );
                                    if (parts.length == 2) {
                                      final hour = int.tryParse(parts[0]) ?? 0;
                                      final minute =
                                          int.tryParse(parts[1]) ?? 0;
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
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
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
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
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
                                  try {
                                    await firestore
                                        .collection(widget.uid!)
                                        .doc(docs[index].id)
                                        .update({
                                          'amount':
                                              medication.amount -
                                                          medication.dosage <
                                                      0
                                                  ? 0
                                                  : medication.amount -
                                                      medication.dosage,
                                        });
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to update medication: $e',
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
      ),
      bottomNavigationBar: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final info = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Version: ${info.version} (${info.buildNumber})',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}

class MedicationDetailsCard extends StatelessWidget {
  final Medications medication;
  const MedicationDetailsCard({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                medication.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightGreen,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(
              icon: Icons.category,
              label: "Unit Of Measurement",
              value: medication.typeOfMedication,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.medical_services,
              label: "Dosage",
              value: "${medication.dosage}",
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.repeat,
              label: "Frequency",
              value:
                  "Every ${medication.frequency} ${medication.frequency == 1 ? 'day' : 'days'}",
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.inventory_2,
              label: "Current Amount",
              value: "${medication.amount}",
            ),
            const SizedBox(height: 12),
            if (medication.notifyTime != null &&
                medication.notifyTime!.isNotEmpty)
              Builder(
                builder: (context) {
                  final parts = medication.notifyTime!.split(':');
                  if (parts.length == 2) {
                    final hour = int.tryParse(parts[0]) ?? 0;
                    final minute = int.tryParse(parts[1]) ?? 0;
                    final timeOfDay = TimeOfDay(hour: hour, minute: minute);
                    return _DetailRow(
                      icon: Icons.alarm,
                      label: "Notify at",
                      value: timeOfDay.format(context),
                      valueStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreen,
                        fontSize: 18,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
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
        Icon(icon, color: Colors.lightGreen),
        const SizedBox(width: 12),
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Expanded(
          child: Text(
            value,
            style:
                valueStyle ??
                const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
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
  BuildContext context,
  String docId,
  Medications medication,
) async {
  if (medication.notifyTime == null || medication.notifyTime!.isEmpty) return;
  final timeParts = medication.notifyTime!.split(':');
  if (timeParts.length != 2) return;
  final hour = int.tryParse(timeParts[0]);
  final minute = int.tryParse(timeParts[1]);
  if (hour == null || minute == null) return;
  final now = DateTime.now();
  var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
  if (scheduledTime.isBefore(now)) {
    scheduledTime = scheduledTime.add(const Duration(days: 1));
  }

  print(
    'Scheduling notification for ${medication.name} at $scheduledTime (docId: $docId)',
  );

  try {
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
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
      ),
      payload: docId,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    print(
      'Scheduled notification for ${medication.name} at $scheduledTime (docId: $docId)',
    );
  } catch (e) {
    print('Failed to schedule notification for ${medication.name}: $e');
    if (e is PlatformException && e.code == 'exact_alarms_not_permitted') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please allow "Schedule exact alarms" in system settings.',
          ),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: openExactAlarmSettings,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule notification: $e')),
      );
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
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

Future<void> initializeNotifications() async {
  await flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
}
