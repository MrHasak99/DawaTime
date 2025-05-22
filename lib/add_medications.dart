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
  TextEditingController frequencyController = TextEditingController();
  TextEditingController amountController = TextEditingController();

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
            TextField(
              controller: frequencyController,
              decoration: InputDecoration(labelText: "Frequency"),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: "Current Amount"),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    typeOfMedicationController.text.isNotEmpty &&
                    dosageController.text.isNotEmpty &&
                    frequencyController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection(widget.uid)
                        .add({
                          'name': nameController.text,
                          'typeOfMedication': typeOfMedicationController.text,
                          'dosage': double.tryParse(dosageController.text) ?? 0,
                          'frequency': frequencyController.text,
                          'amount': double.tryParse(amountController.text) ?? 0,
                        });
                    if (!mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    if (!mounted) return;
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
    );
  }
}
