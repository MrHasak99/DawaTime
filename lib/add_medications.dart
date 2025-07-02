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
            leading: BackButton(color: Colors.white),
            title: const Text("Add New Medication"),
            centerTitle: true,
          ),
        ),
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
                              color: Color(0xFF8AC249),
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
                              color: Color(0xFF8AC249),
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
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
                                    hourMinuteTextColor: Color(0xFF8AC249),
                                    hourMinuteColor: Color(
                                      0xFF8AC249,
                                    ).withValues(alpha: 0.1),
                                    dayPeriodTextColor: Color(0xFF8AC249),
                                    dayPeriodColor: Color(
                                      0xFF8AC249,
                                    ).withValues(alpha: 0.1),
                                    dialHandColor: Color(0xFF8AC249),
                                    dialBackgroundColor: Color(
                                      0xFF8AC249,
                                    ).withValues(alpha: 0.08),
                                    entryModeIconColor: Color(0xFF8AC249),
                                    helpTextStyle: const TextStyle(
                                      color: Color(0xFF8AC249),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    hourMinuteTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: Color(0xFF8AC249),
                                    ),
                                    dayPeriodTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF8AC249),
                                    ),
                                    dialTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color(0xFF8AC249),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFF8AC249),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  colorScheme: ColorScheme.light(
                                    primary: Color(0xFF8AC249),
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Color(0xFF8AC249),
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
                                      SnackBar(
                                        backgroundColor: const Color(
                                          0xFF8AC249,
                                        ),
                                        content: Text(
                                          "Dosage and Frequency must be greater than 0",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Nunito',
                                          ),
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
                                        backgroundColor: const Color(
                                          0xFF8AC249,
                                        ),
                                        content: Text(
                                          'Failed to add medication: $e',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Nunito',
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Color(0xFF8AC249),
                                      content: Text(
                                        "Please fill all fields",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF8AC249),
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
