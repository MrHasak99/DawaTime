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
                        cursorColor: Color(0xFF8AC249),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: typeOfMedicationController,
                        cursorColor: Color(0xFF8AC249),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          labelText: "Unit of Measurement",
                          labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: dosageController,
                              cursorColor: Color(0xFF8AC249),
                              keyboardType: TextInputType.number,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: "Dosage",
                                labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                              cursorColor: Color(0xFF8AC249),
                              keyboardType: TextInputType.number,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: "Frequency",
                                labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
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
                        cursorColor: Color(0xFF8AC249),
                        keyboardType: TextInputType.number,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          labelText: "Current Amount",
                          labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(
                          _selectedTime == null
                              ? "Pick Notification Time"
                              : "Notify at: ${_selectedTime!.format(context)}",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(Icons.access_time),
                        onTap: () async {
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime ?? TimeOfDay.now(),
                            builder: (context, child) {
                              final primaryColor = const Color(0xFF8AC249);
                              final surfaceColor =
                                  isDark
                                      ? const Color(0xFF222222)
                                      : Colors.white;
                              final onSurfaceColor =
                                  isDark ? Colors.white : primaryColor;
                              final hourMinuteBg =
                                  isDark
                                      ? primaryColor.withValues(alpha: 0.15)
                                      : primaryColor.withValues(alpha: 0.08);

                              return Theme(
                                data: Theme.of(context).copyWith(
                                  timePickerTheme: TimePickerThemeData(
                                    backgroundColor: surfaceColor,
                                    hourMinuteTextColor: primaryColor,
                                    hourMinuteColor: hourMinuteBg,
                                    dayPeriodTextColor: primaryColor,
                                    dayPeriodColor: hourMinuteBg,
                                    dialHandColor: primaryColor,
                                    dialBackgroundColor: hourMinuteBg,
                                    entryModeIconColor: primaryColor,
                                    helpTextStyle: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    hourMinuteTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: primaryColor,
                                    ),
                                    dayPeriodTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: primaryColor,
                                    ),
                                    dialTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: primaryColor,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: primaryColor,
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  colorScheme: ColorScheme(
                                    brightness:
                                        isDark
                                            ? Brightness.dark
                                            : Brightness.light,
                                    primary: primaryColor,
                                    onPrimary: Colors.white,
                                    secondary: primaryColor,
                                    onSecondary: Colors.white,
                                    error: Colors.red,
                                    onError: Colors.white,

                                    surface: surfaceColor,
                                    onSurface: onSurfaceColor,
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
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          "Dosage and Frequency must be greater than 0",
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
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
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          'Failed to add medication: $e',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        "Please fill all fields",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
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
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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
