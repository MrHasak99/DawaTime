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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text(
          widget.medications.name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Type of Medication: ${widget.medications.typeOfMedication}"),
            Text("Dosage: ${widget.medications.dosage}"),
            Text("Frequency: ${widget.medications.frequency}"),
            Text("Current Amount: ${widget.medications.amount}"),
            ElevatedButton(
              onPressed: () async {
                try {
                  await firestore
                      .collection(widget.uid)
                      .doc(widget.docId)
                      .delete();
                  if (!mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to delete: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Delete Medication",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
