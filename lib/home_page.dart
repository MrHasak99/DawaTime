import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medication_app_full/add_medications.dart';
import 'package:medication_app_full/database/medications.dart';
import 'package:medication_app_full/login_page.dart';
import 'package:medication_app_full/medication_details.dart';
import 'package:medication_app_full/user_page.dart';

class HomePage extends StatefulWidget {
  final String? uid;
  const HomePage({super.key, this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Medications medicationFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medications(
      name: data['name'] ?? '',
      typeOfMedication: data['typeOfMedication'] ?? '',
      dosage: double.tryParse(data['dosage'].toString()) ?? 0,
      frequency: data['frequency'] ?? '',
      amount: double.tryParse(data['amount'].toString()) ?? 0,
    );
  }

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
              if (!mounted) return;
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
                style: TextStyle(color: Colors.black),
              ),
            );
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final medication = medicationFromDoc(docs[index]);
              return Card(
                color: medication.amount <= 0 ? Colors.red : Colors.lightGreen,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return MedicationDetails(
                            uid: widget.uid!,
                            docId: docs[index].id,
                            medications: medication,
                          );
                        },
                      ),
                    );
                  },
                  title: Text(
                    medication.name,
                    style: const TextStyle(color: Colors.black),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${medication.dosage} ${medication.typeOfMedication} ${medication.frequency}",
                        style: const TextStyle(color: Colors.black),
                      ),
                      if (medication.amount > 0)
                        Text(
                          "${(medication.amount).toStringAsFixed(2)} left",
                          style: const TextStyle(color: Colors.black),
                        )
                      else
                        const Text(
                          "Out of stock",
                          style: TextStyle(color: Colors.black),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.medication_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {
                      if (medication.amount > 0) {
                        firestore
                            .collection(widget.uid!)
                            .doc(docs[index].id)
                            .update({
                              'amount':
                                  medication.amount - medication.dosage < 0
                                      ? 0
                                      : medication.amount - medication.dosage,
                            });
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.lightGreen,
                              title: Text(
                                "You're out of ${medication.name}!",
                                style: const TextStyle(color: Colors.black),
                              ),
                              content: Text(
                                "Please refill your ${medication.name}.",
                                style: const TextStyle(color: Colors.black),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    "OK",
                                    style: TextStyle(color: Colors.black),
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.lightGreen,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMedications(uid: widget.uid!),
            ),
          );
        },
        child: const Icon(Icons.add_circle_rounded, color: Colors.white),
      ),
    );
  }
}
