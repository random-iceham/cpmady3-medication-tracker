import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a medication for logged-in user
  Future<void> addMedication(Medication medication) async {
    try {
      await _firestore
          .collection("users")
          .doc(medication.userId)
          .collection("medications")
          .add(medication.toMap()); // Store medication data
    } catch (e) {
      throw Exception("Failed to add medication: $e");
    }
  }

  /// Get all medications for a specific user
  Stream<List<Medication>> getMedications(String userId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("medications")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Medication.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Update the takenStatus of a medication
  Future<void> updateTakenStatus(
      String userId, String medId, bool status) async {
    try {
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("medications")
          .doc(medId)
          .update({'takenStatus': status}); // Update
    } catch (e) {
      throw Exception("Failed to update taken status: $e");
    }
  }

  /// Delete a medication
  Future<void> deleteMedication(String userId, String medId) async {
    try {
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("medications")
          .doc(medId)
          .delete();
    } catch (e) {
      throw Exception("Failed to delete medication: $e");
    }
  }

  // Update an existing medication
  Future<void> updateMedication(Medication medication) async {
    try {
      await _firestore
          .collection("users")
          .doc(medication.userId)
          .collection("medications")
          .doc(medication.id)
          .update(medication.toMap());
    } catch (e) {
      throw Exception("Failed to update medication: $e");
    }
  }

  //reset status for new day
//   Future<void> resetMedicationsForNewDay(String userId) async {
//     final today = DateTime.now();
//     final dateString =
//         "${today.year}-${today.month}-${today.day}"; // Format to date string

//     try {
//       final medicationsSnapshot = await _firestore
//           .collection("users")
//           .doc(userId)
//           .collection("medications")
//           .get();

//       for (var doc in medicationsSnapshot.docs) {
//         final medication = Medication.fromMap(doc.data(), doc.id);
//         if (medication.date != dateString) {
//           // Reset taken status for medications that haven't been taken today
//           await _firestore
//               .collection("users")
//               .doc(userId)
//               .collection("medications")
//               .doc(medication.id)
//               .update({
//             'takenStatus': false,
//             'date': dateString, // Update to today's date
//           });
//         }
//       }
//     } catch (e) {
//       throw Exception("Failed to reset medications for new day: $e");
//     }
//   }

//reset med status
  // Future<void> resetTakenStatus() async {
  //   String userId =
  //       FirebaseAuth.instance.currentUser!.uid; // Get the current user ID

  //   try {
  //     // Get all medications for the user
  //     QuerySnapshot snapshot = await FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(userId)
  //         .collection("medications")
  //         .get();

  //     // Loop through each document and update `takenStatus` to false
  //     for (var doc in snapshot.docs) {
  //       await FirebaseFirestore.instance
  //           .collection("users")
  //           .doc(userId)
  //           .collection("medications")
  //           .doc(doc.id)
  //           .update({'takenStatus': false});
  //     }
  //   } catch (e) {
  //     print("Error resetting medications: $e");
  //   }
  // }
}
