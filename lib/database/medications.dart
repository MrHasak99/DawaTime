class Medications {
  String name;
  String typeOfMedication;
  double dosage;
  String frequency;
  double amount;

  Medications({
    required this.name,
    required this.typeOfMedication,
    required this.dosage,
    required this.frequency,
    required this.amount,
  });

  static List<Medications> medications = [];
}
