import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  TextEditingController frequencyNumberController = TextEditingController();
  String frequencyPeriod = 'day';
  final List<String> periodOptions = ['day', 'week', 'month', 'year'];
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Center(
          child: Text(
            "Add New Medication",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: typeOfMedicationController,
                decoration: InputDecoration(labelText: "Type of Medication"),
              ),
              TextField(
                controller: dosageController,
                decoration: InputDecoration(labelText: "Dosage"),
                keyboardType: TextInputType.number,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: frequencyNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Times'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('per'),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: frequencyPeriod,
                    items:
                        periodOptions
                            .map(
                              (period) => DropdownMenuItem(
                                value: period,
                                child: Text(period),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          frequencyPeriod = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: "Current Amount"),
                keyboardType: TextInputType.number,
              ),
              ListTile(
                title: Text(
                  _selectedTime == null
                      ? "Pick Notification Time"
                      : "Notify at: ${_selectedTime!.format(context)}",
                ),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedTime = picked;
                    });
                  }
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      typeOfMedicationController.text.isNotEmpty &&
                      dosageController.text.isNotEmpty &&
                      frequencyNumberController.text.isNotEmpty &&
                      amountController.text.isNotEmpty) {
                    try {
                      await FirebaseFirestore.instance.collection(widget.uid).add({
                        'name': nameController.text,
                        'typeOfMedication': typeOfMedicationController.text,
                        'dosage': double.tryParse(dosageController.text) ?? 0,
                        'frequency':
                            "${frequencyNumberController.text} $frequencyPeriod",
                        'amount': double.tryParse(amountController.text) ?? 0,
                        'notifyTime': _selectedTime?.format(context),
                      });
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to add medication: $e")),
                      );
                    }
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please fill all fields")),
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
            ],
          ),
        ),
      ),
    );
  }
}
