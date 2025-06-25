import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dawatime/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dawatime/login_page.dart';

class AddMedications extends StatefulWidget {
  final String uid;

  const AddMedications({super.key, required this.uid});

  @override
  State<AddMedications> createState() => _AddMedicationsState();
}

class _AddMedicationsState extends State<AddMedications> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController typeOfMedicationController = TextEditingController();
  TextEditingController dosageController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController frequencyController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.microtask(() {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
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
        leading: BackButton(color: Colors.white),
        title: const Text("Add New Medication"),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(labelText: "Name"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: typeOfMedicationController,
                        decoration: InputDecoration(
                          labelText: "Unit of Measurement",
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: dosageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: "Dosage"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'every',
                            style: TextStyle(
                              color: Colors.lightGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: frequencyController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Frequency",
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'days',
                            style: TextStyle(
                              color: Colors.lightGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Current Amount",
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(
                          _selectedTime == null
                              ? "Pick Notification Time"
                              : "Notify at: ${_selectedTime!.format(context)}",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime ?? TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  timePickerTheme: TimePickerThemeData(
                                    backgroundColor: Colors.white,
                                    hourMinuteTextColor: Colors.lightGreen,
                                    hourMinuteColor: Colors.lightGreen
                                        .withValues(alpha: 0.1),
                                    dayPeriodTextColor: Colors.lightGreen,
                                    dayPeriodColor: Colors.lightGreen
                                        .withValues(alpha: 0.1),
                                    dialHandColor: Colors.lightGreen,
                                    dialBackgroundColor: Colors.lightGreen
                                        .withValues(alpha: 0.08),
                                    entryModeIconColor: Colors.lightGreen,
                                    helpTextStyle: const TextStyle(
                                      color: Colors.lightGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    hourMinuteTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: Colors.lightGreen,
                                    ),
                                    dayPeriodTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.lightGreen,
                                    ),
                                    dialTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.lightGreen,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.lightGreen,
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.lightGreen,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.lightGreen,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedTime = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (nameController.text.isNotEmpty &&
                                    typeOfMedicationController
                                        .text
                                        .isNotEmpty &&
                                    dosageController.text.isNotEmpty &&
                                    frequencyController.text.isNotEmpty &&
                                    amountController.text.isNotEmpty) {
                                  if (dosageController.text == '0' ||
                                      frequencyController.text == '0') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Dosage and Frequency must be greater than 0",
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  try {
                                    final docRef = await firestore
                                        .collection(widget.uid)
                                        .add({
                                          'name': nameController.text,
                                          'typeOfMedication':
                                              typeOfMedicationController.text,
                                          'dosage':
                                              double.tryParse(
                                                dosageController.text,
                                              ) ??
                                              0,
                                          'frequency':
                                              int.tryParse(
                                                frequencyController.text,
                                              ) ??
                                              0,
                                          'amount':
                                              double.tryParse(
                                                amountController.text,
                                              ) ??
                                              0,
                                          'notifyTime':
                                              _selectedTime != null
                                                  ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                                  : '',
                                        });
                                    final newDoc = await docRef.get();
                                    final newMedication = medicationFromDoc(
                                      newDoc,
                                    );

                                    await scheduleMedicationNotification(
                                      context,
                                      docRef.id,
                                      newMedication,
                                    );

                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to add medication: $e',
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please fill all fields"),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightGreen,
                              ),
                              child: Text(
                                "Save Medication",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
