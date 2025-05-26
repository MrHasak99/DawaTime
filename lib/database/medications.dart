class Medications {
  final String name;
  final String typeOfMedication;
  final double dosage;
  final String frequency;
  final double amount;
  final String? notifyTime;

  Medications({
    required this.name,
    required this.typeOfMedication,
    required this.dosage,
    required this.frequency,
    required this.amount,
    this.notifyTime,
  });

  factory Medications.fromMap(Map<String, dynamic> data) {
    return Medications(
      name: data['name'] ?? '',
      typeOfMedication: data['typeOfMedication'] ?? '',
      dosage: (data['dosage'] ?? 0).toDouble(),
      frequency: data['frequency'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      notifyTime: data['notifyTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'typeOfMedication': typeOfMedication,
      'dosage': dosage,
      'frequency': frequency,
      'amount': amount,
      'notifyTime': notifyTime,
    };
  }

  static List<Medications> medications = [];
}
