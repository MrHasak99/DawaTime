import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medication_app_full/add_medications.dart';
import 'package:medication_app_full/database/medications.dart';
import 'package:medication_app_full/settings.dart';
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
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection(widget.uid!).snapshots(),
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
                                              cursorColor: Colors.white,
                                              keyboardType:
                                                  TextInputType.number,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              decoration: const InputDecoration(
                                                labelText: 'Times',
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
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            'per',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
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
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                                  timePickerTheme:
                                                      TimePickerThemeData(
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
                                                                  Colors.white,
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
                                                  textButtonTheme:
                                                      TextButtonThemeData(
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
              value: medication.frequency.replaceFirst(' ', ' times per '),
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
