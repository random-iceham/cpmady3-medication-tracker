class Medication {
  final String id;
  final String userId;
  final String name;
  final String purpose;
  final String dosage;
  final String frequency;
  final String timing;
  final String foodInstruction;
  final String remarks;
  final String endingDate;
  final int quantity;
  final bool takenStatus;

  Medication({
    this.id = '',
    required this.userId,
    required this.name,
    required this.purpose,
    required this.dosage,
    required this.frequency,
    required this.timing,
    required this.foodInstruction,
    required this.remarks,
    required this.endingDate,
    required this.quantity,
    this.takenStatus = false,
  });

  // Convert medication data to a map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'purpose': purpose,
      'dosage': dosage,
      'frequency': frequency,
      'timing': timing,
      'foodInstruction': foodInstruction,
      'remarks': remarks,
      'endingDate': endingDate,
      'quantity': quantity,
      'takenStatus': takenStatus, // Add to map
    };
  }

  // Create a Medication instance from a Firestore document snapshot
  factory Medication.fromMap(Map<String, dynamic> map, String id) {
    return Medication(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      purpose: map['purpose'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      timing: map['timing'] ?? '',
      foodInstruction: map['foodInstruction'] ?? '',
      remarks: map['remarks'] ?? '',
      endingDate: map['endingDate'] ?? '',
      quantity: map['quantity'] ?? 0,
      takenStatus: map['takenStatus'] ?? false, // Add takenStatus from map
    );
  }
}
