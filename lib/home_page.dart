import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medication_app_full/add_medications.dart';
import 'package:medication_app_full/login_page.dart';
import 'package:medication_app_full/medication_details.dart';
import 'package:medication_app_full/user_page.dart';
import 'package:medication_app_full/notification_utils.dart';

class HomePage extends StatefulWidget {
  final String? uid;
  const HomePage({super.key, this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @pragma('vm:entry-point')
  void notificationTapBackground(NotificationResponse response) {}

  @override
  Widget build(BuildContext context) {
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
                  child: const Icon(Icons.delete, color: Colors.red, size: 32),
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
                                onPressed: () => Navigator.pop(context, false),
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
                                onPressed: () => Navigator.pop(context, true),
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
                    final frequencyParts = medication.frequency.split(' ');
                    final frequencyNumberController = TextEditingController(
                      text: frequencyParts.isNotEmpty ? frequencyParts[0] : '',
                    );
                    final List<String> periodOptions = [
                      'day',
                      'week',
                      'month',
                      'year',
                    ];
                    String localFrequencyPeriod =
                        (frequencyParts.length > 1 &&
                                periodOptions.contains(frequencyParts[1]))
                            ? frequencyParts[1]
                            : 'day';
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
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: 'Name',
                                          labelStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextField(
                                        controller: typeController,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: 'Type of Medication',
                                          labelStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextField(
                                        controller: dosageController,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Dosage',
                                          labelStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 60,
                                            child: TextField(
                                              controller:
                                                  frequencyNumberController,
                                              keyboardType:
                                                  TextInputType.number,
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                              decoration: const InputDecoration(
                                                labelText: 'Times',
                                                labelStyle: TextStyle(
                                                  color: Colors.white,
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
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            'per',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          DropdownButton<String>(
                                            value: localFrequencyPeriod,
                                            dropdownColor: Colors.white,
                                            items:
                                                periodOptions
                                                    .map(
                                                      (
                                                        period,
                                                      ) => DropdownMenuItem(
                                                        value: period,
                                                        child: Text(
                                                          period,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  localFrequencyPeriod = value;
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      TextField(
                                        controller: amountController,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Current Amount',
                                          labelStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
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
                                            color: Colors.white,
                                          ),
                                        ),
                                        trailing: const Icon(
                                          Icons.access_time,
                                          color: Colors.white,
                                        ),
                                        onTap: () async {
                                          final picked = await showTimePicker(
                                            context: context,
                                            initialTime:
                                                localNotifyTime ??
                                                TimeOfDay.now(),
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
                                      try {
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
                                                  '${frequencyNumberController.text} $localFrequencyPeriod',
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
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to update: $e',
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
                    await firestore
                        .collection(widget.uid!)
                        .doc(docs[index].id)
                        .delete();
                    await flutterLocalNotificationsPlugin.cancel(
                      docs[index].id.hashCode,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${medication.name} deleted!')),
                    );
                  }
                },
                child: Card(
                  color:
                      medication.amount <= 0 ? Colors.red : Colors.lightGreen,
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
                                          : medication.amount -
                                              medication.dosage,
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
