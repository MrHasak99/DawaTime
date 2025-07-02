import 'dart:async';
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
import 'package:background_fetch/background_fetch.dart';

final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

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

  Medications? _recentlyDeletedMedication;
  Map<String, dynamic>? _recentlyDeletedData;
  String? _recentlyDeletedDocId;

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

  @override
  void initState() {
    super.initState();
    initBackgroundFetch();
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
          await scheduleMedicationNotification(
            context,
            docId,
            medication,
            forceNextDay: true,
          );
        }
      }
    });
  }

  void initBackgroundFetch() async {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ),
      (String taskId) async {
        await Firebase.initializeApp();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final now = DateTime.now();
          if (now.hour == 0 && now.minute < 20) {
            await rescheduleAllMedications(user.uid);
          }
        }
        BackgroundFetch.finish(taskId);
      },
      (String taskId) async {
        BackgroundFetch.finish(taskId);
      },
    );
    BackgroundFetch.start();
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
            content: Text('${deletedMedication!.name} deleted!'),
            action: SnackBarAction(
              label: 'Undo',
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
                  );
                  if (mounted) setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Undo failed: $e')));
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF8AC249),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Center(
              child: Text(
                "DawaTime",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(user.uid).snapshots(),
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
                  Icon(Icons.medication, color: Color(0xFF8AC249), size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    "No Medications Found",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }
          final docs = snapshot.data!.docs;

          return Builder(
            builder: (scaffoldContext) {
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
                                backgroundColor: Color(0xFF8AC249),
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
                                    backgroundColor: Color(0xFF8AC249),
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
                                              labelText: 'Unit of Measurement',
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
                                            keyboardType: TextInputType.number,
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
                                            keyboardType: TextInputType.number,
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
                                            keyboardType: TextInputType.number,
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
                                                fontSize: 14,
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
                                                            Colors.white,
                                                        hourMinuteTextColor:
                                                            Color(0xFF8AC249),
                                                        hourMinuteColor: Colors
                                                            .lightGreen
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        dayPeriodTextColor:
                                                            Color(0xFF8AC249),
                                                        dayPeriodColor: Colors
                                                            .lightGreen
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        dialHandColor: Color(
                                                          0xFF8AC249,
                                                        ),
                                                        dialBackgroundColor:
                                                            Color(
                                                              0xFF8AC249,
                                                            ).withValues(
                                                              alpha: 0.08,
                                                            ),
                                                        entryModeIconColor:
                                                            Color(0xFF8AC249),
                                                        helpTextStyle:
                                                            const TextStyle(
                                                              color:
                                                                  Colors
                                                                      .lightGreen,
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
                                                              color:
                                                                  Colors
                                                                      .lightGreen,
                                                            ),
                                                        dayPeriodTextStyle:
                                                            const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                              color:
                                                                  Colors
                                                                      .lightGreen,
                                                            ),
                                                        dialTextStyle:
                                                            const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  Colors
                                                                      .lightGreen,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                24,
                                                              ),
                                                        ),
                                                      ),
                                                      textButtonTheme:
                                                          TextButtonThemeData(
                                                            style: TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Color(
                                                                    0xFF8AC249,
                                                                  ),
                                                              textStyle:
                                                                  const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                            ),
                                                          ),
                                                      colorScheme:
                                                          ColorScheme.light(
                                                            primary:
                                                                Colors
                                                                    .lightGreen,
                                                            onPrimary:
                                                                Colors.white,
                                                            surface:
                                                                Colors.white,
                                                            onSurface:
                                                                Colors
                                                                    .lightGreen,
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
                                        onPressed: () async {
                                          if (nameController.text.isNotEmpty &&
                                              typeController.text.isNotEmpty &&
                                              dosageController
                                                  .text
                                                  .isNotEmpty &&
                                              frequencyController
                                                  .text
                                                  .isNotEmpty &&
                                              amountController
                                                  .text
                                                  .isNotEmpty) {
                                            if (dosageController.text == '0' ||
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
                                              final oldData =
                                                  docs[index].data()
                                                      as Map<String, dynamic>;
                                              await firestore
                                                  .collection(widget.uid!)
                                                  .doc(docs[index].id)
                                                  .update({
                                                    'name': nameController.text,
                                                    'typeOfMedication':
                                                        typeController.text,
                                                    'dosage':
                                                        double.tryParse(
                                                          dosageController.text,
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
                                                          amountController.text,
                                                        ) ??
                                                        0,
                                                    'notifyTime':
                                                        localNotifyTime != null
                                                            ? '${localNotifyTime!.hour.toString().padLeft(2, '0')}:${localNotifyTime!.minute.toString().padLeft(2, '0')}'
                                                            : '',
                                                  });
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
                                              if (!context.mounted) {
                                                return;
                                              }
                                              Navigator.pop(context, true);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                    'Medication updated!',
                                                  ),
                                                  action: SnackBarAction(
                                                    label: 'Undo',
                                                    textColor: Colors.red,
                                                    onPressed: () async {
                                                      await firestore
                                                          .collection(
                                                            widget.uid!,
                                                          )
                                                          .doc(docs[index].id)
                                                          .set(oldData);
                                                      await scheduleMedicationNotification(
                                                        context,
                                                        docs[index].id,
                                                        medicationFromDoc(
                                                          await firestore
                                                              .collection(
                                                                widget.uid!,
                                                              )
                                                              .doc(
                                                                docs[index].id,
                                                              )
                                                              .get(),
                                                        ),
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
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                        child: const Text(
                                          'Save',
                                          style: TextStyle(
                                            color: Color(0xFF8AC249),
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
                        final deletedMedication = medicationFromDoc(
                          docs[index],
                        );
                        try {
                          await firestore
                              .collection(widget.uid!)
                              .doc(deletedDocId)
                              .delete();
                          await flutterLocalNotificationsPlugin.cancel(
                            deletedDocId.hashCode,
                          );

                          setState(() {
                            _recentlyDeletedMedication = deletedMedication;
                            _recentlyDeletedData = deletedData;
                            _recentlyDeletedDocId = deletedDocId;
                          });
                        } catch (e) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to delete medication: $e',
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
                              : Color(0xFF8AC249),
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
                            fontSize: 20,
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
                                fontSize: 16,
                              ),
                            ),
                            if (medication.amount > 0)
                              Text(
                                "${(medication.amount).toStringAsFixed(2)} left",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
                            if (getNextReminder(medication) != null)
                              Text(
                                "Next reminder: ${getNextReminder(medication)!}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
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
                                      backgroundColor: Color(0xFF8AC249),
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
                                              () =>
                                                  Navigator.pop(context, false),
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
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text(
                                            "Yes",
                                            style: TextStyle(
                                              color: Color(0xFF8AC249),
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
                                  await cancelMedicationReminders(
                                    docs[index].id,
                                  );

                                  final updatedDoc =
                                      await firestore
                                          .collection(widget.uid!)
                                          .doc(docs[index].id)
                                          .get();
                                  final updatedMedication = medicationFromDoc(
                                    updatedDoc,
                                  );

                                  await scheduleMedicationNotification(
                                    context,
                                    docs[index].id,
                                    updatedMedication,
                                  );
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
                                    backgroundColor: Color(0xFF8AC249),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Medication",
        shape: const CircleBorder(),
        backgroundColor: Color(0xFF8AC249),
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
                  color: Color(0xFF8AC249),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(
              icon: Icons.category,
              label: "Unit Of Measurement",
              value: medication.typeOfMedication,
              valueStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF8AC249),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(
              icon: Icons.medical_services,
              label: "Dosage",
              value: "${medication.dosage}",
              valueStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF8AC249),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(
              icon: Icons.repeat,
              label: "Frequency",
              value:
                  "Every ${medication.frequency} ${medication.frequency == 1 ? 'day' : 'days'}",
              valueStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF8AC249),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(
              icon: Icons.inventory_2,
              label: "Current Amount",
              value: "${medication.amount}",
              valueStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF8AC249),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            if (getNextReminder(medication) != null)
              _DetailRow(
                icon: Icons.notifications_active,
                label: "Next Reminder",
                value: getNextReminder(medication)!,
                valueStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8AC249),
                  fontSize: 11,
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
  BuildContext? context,
  String docId,
  Medications medication, {
  bool forceNextDay = false,
}) async {
  await requestExactAlarmPermission();
  if (medication.notifyTime == null || medication.notifyTime!.isEmpty) return;
  final timeParts = medication.notifyTime!.split(':');
  if (timeParts.length != 2) return;
  final hour = int.tryParse(timeParts[0]);
  final minute = int.tryParse(timeParts[1]);
  if (hour == null || minute == null) return;
  final now = DateTime.now();
  var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
  while (scheduledTime.isBefore(now)) {
    scheduledTime = scheduledTime.add(Duration(days: medication.frequency));
  }
  // final isDue =
  //     scheduledTime.difference(now).inDays == 0 &&
  //     scheduledTime.isBefore(now.add(const Duration(days: 1)));
  // if (!isDue && !forceNextDay) {
  //   return;
  // }

  for (int i = 0; i < 5 * 9; i++) {
    await flutterLocalNotificationsPlugin.cancel(docId.hashCode + i);
  }

  try {
    for (int day = 0; day < 5; day++) {
      DateTime baseTime = scheduledTime.add(
        Duration(days: medication.frequency * day),
      );
      if (baseTime.isAfter(now)) {
        for (int i = 0; i <= 8; i++) {
          final followUpTime = baseTime.add(Duration(minutes: 15 * i));
          await flutterLocalNotificationsPlugin.zonedSchedule(
            docId.hashCode + day * 9 + i,
            'DawaTime',
            i == 0
                ? 'Time to take ${medication.name}!'
                : 'Reminder: Take your ${medication.name}',
            tz.TZDateTime.from(followUpTime, tz.local),
            NotificationDetails(
              android: AndroidNotificationDetails(
                'medication_channel',
                'Medication Reminders',
                channelDescription: 'Reminds you to take your medication',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                icon: '@mipmap/ic_launcher',
                sound: RawResourceAndroidNotificationSound(
                  'notification_sound',
                ),
              ),
              iOS: DarwinNotificationDetails(
                presentSound: true,
                sound: "notification_sound.wav",
              ),
            ),
            payload:
                i == 0
                    ? 'Time to take ${medication.name}!'
                    : 'Reminder: Take your ${medication.name}',
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
}

Future<void> cancelMedicationReminders(String docId) async {
  for (int i = 0; i <= 8; i++) {
    await flutterLocalNotificationsPlugin.cancel(docId.hashCode + i);
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
  var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
  while (scheduledTime.isBefore(now)) {
    scheduledTime = scheduledTime.add(Duration(days: medication.frequency));
  }
  const months = [
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
  final period = scheduledTime.hour < 12 ? 'AM' : 'PM';
  return '$month $day, $year - $displayHour:$displayMinute $period';
}

Future<void> rescheduleAllMedications(String uid) async {
  final meds = await FirebaseFirestore.instance.collection(uid).get();
  for (var doc in meds.docs) {
    final medication = medicationFromDoc(doc);
    await scheduleMedicationNotification(null, doc.id, medication);
  }
}
