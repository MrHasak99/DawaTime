import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medication_app_full/database/medications.dart';

class MedicationDetails extends StatefulWidget {
  final String uid;
  final String docId;
  final Medications medications;
  const MedicationDetails({
    super.key,
    required this.uid,
    required this.docId,
    required this.medications,
  });

  @override
  State<MedicationDetails> createState() => _MedicationDetailsState();
}

class _MedicationDetailsState extends State<MedicationDetails> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Medications? _medication;

  @override
  void initState() {
    super.initState();
    _medication = widget.medications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        leading: BackButton(color: Colors.white),
        title: Text(
          widget.medications.name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            tooltip: 'Edit Medication',
            onPressed: () async {
              final nameController = TextEditingController(
                text: widget.medications.name,
              );
              final typeController = TextEditingController(
                text: widget.medications.typeOfMedication,
              );
              final dosageController = TextEditingController(
                text: widget.medications.dosage.toString(),
              );
              final List<String> periodOptions = [
                'day',
                'week',
                'month',
                'year',
              ];
              final frequencyParts = widget.medications.frequency.split(' ');
              final frequencyNumberController = TextEditingController(
                text: frequencyParts.isNotEmpty ? frequencyParts[0] : '',
              );
              String frequencyPeriod =
                  (frequencyParts.length > 1 &&
                          periodOptions.contains(frequencyParts[1]))
                      ? frequencyParts[1]
                      : 'day';
              final amountController = TextEditingController(
                text: widget.medications.amount.toString(),
              );
              TimeOfDay? localNotifyTime;
              if (widget.medications.notifyTime != null &&
                  widget.medications.notifyTime!.isNotEmpty) {
                final parts = widget.medications.notifyTime?.split(":");
                if (parts?.length == 2) {
                  localNotifyTime = TimeOfDay(
                    hour: int.tryParse(parts![0]) ?? 0,
                    minute: int.tryParse(parts[1]) ?? 0,
                  );
                }
              }

              final result = await showDialog<bool>(
                context: context,
                builder: (context) {
                  String localFrequencyPeriod = frequencyPeriod;
                  return StatefulBuilder(
                    builder:
                        (context, setState) => AlertDialog(
                          backgroundColor: Colors.lightGreen,
                          title: Text(
                            'Edit Medication',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextField(
                                  controller: nameController,
                                  textCapitalization: TextCapitalization.words,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
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
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
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
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
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
                                        controller: frequencyNumberController,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Times',
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
                                                (period) => DropdownMenuItem(
                                                  value: period,
                                                  child: Text(
                                                    period,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
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
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.access_time,
                                    color: Colors.black,
                                  ),
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime:
                                          localNotifyTime ?? TimeOfDay.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            timePickerTheme:
                                                TimePickerThemeData(
                                                  backgroundColor:
                                                      Colors.lightGreen,
                                                  hourMinuteTextColor:
                                                      Colors.black,
                                                  hourMinuteColor: Colors.white,
                                                  dayPeriodTextColor:
                                                      Colors.black,
                                                  dayPeriodColor: Colors.white,
                                                  dialHandColor:
                                                      Colors.lightGreen,
                                                  dialBackgroundColor:
                                                      Colors.white,
                                                  entryModeIconColor:
                                                      Colors.white,
                                                  helpTextStyle:
                                                      const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                  hourMinuteTextStyle:
                                                      const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 28,
                                                      ),
                                                  dayPeriodTextStyle:
                                                      const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                  dialTextStyle:
                                                      const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    textStyle: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
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
                                      .collection(widget.uid)
                                      .doc(widget.docId)
                                      .update({
                                        'name': nameController.text,
                                        'typeOfMedication': typeController.text,
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
                                  if (!mounted) return;
                                  final doc =
                                      await firestore
                                          .collection(widget.uid)
                                          .doc(widget.docId)
                                          .get();
                                  setState(() {
                                    _medication = Medications.fromMap(
                                      doc.data()!,
                                    );
                                  });
                                  Navigator.pop(context, true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Medication updated!'),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to update: $e'),
                                    ),
                                  );
                                }
                              },
                              child: Text(
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
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Medication',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: Colors.lightGreen,
                      title: Text(
                        'Delete Medication',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to delete this medication?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: Text(
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
              if (confirm == true) {
                try {
                  await firestore
                      .collection(widget.uid)
                      .doc(widget.docId)
                      .delete();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Medication deleted")));
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to delete: $e")),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child:
            _medication == null
                ? CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name: ${_medication!.name}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Type: ${_medication!.typeOfMedication}",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Dosage: ${_medication!.dosage}",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Frequency: ${_medication!.frequency.replaceFirst(' ', ' times per ')}",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Current Amount: ${_medication!.amount}",
                          style: TextStyle(fontSize: 16),
                        ),
                        if (_medication!.notifyTime != null &&
                            _medication!.notifyTime!.isNotEmpty)
                          Builder(
                            builder: (context) {
                              final parts = _medication!.notifyTime!.split(':');
                              if (parts.length == 2) {
                                final hour = int.tryParse(parts[0]) ?? 0;
                                final minute = int.tryParse(parts[1]) ?? 0;
                                final timeOfDay = TimeOfDay(
                                  hour: hour,
                                  minute: minute,
                                );
                                return Text(
                                  "Notify at: ${timeOfDay.format(context)}",
                                  style: TextStyle(fontSize: 16),
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}
