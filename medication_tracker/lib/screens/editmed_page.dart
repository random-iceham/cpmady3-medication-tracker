import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/medication.dart';

class EditMedPage extends StatefulWidget {
  final Medication medication;

  const EditMedPage({super.key, required this.medication});

  @override
  _EditMedPageState createState() => _EditMedPageState();
}

class _EditMedPageState extends State<EditMedPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController timingController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController endingDateController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  String frequency = 'Daily';
  String foodInstruction = 'Does not matter';

  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.medication.name;
    purposeController.text = widget.medication.purpose;
    dosageController.text = widget.medication.dosage;
    timingController.text = widget.medication.timing;
    remarksController.text = widget.medication.remarks;
    endingDateController.text = widget.medication.endingDate;
    quantityController.text = widget.medication.quantity.toString();
    frequency = widget.medication.frequency;
    foodInstruction = widget.medication.foodInstruction;
  }

  void _editMedication() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user logged in!")),
      );
      return;
    }

    final updatedMedication = Medication(
      id: widget.medication.id,
      userId: user.uid,
      name: nameController.text.trim(),
      purpose: purposeController.text.trim(),
      dosage: dosageController.text.trim(),
      frequency: frequency,
      timing: timingController.text.trim(),
      foodInstruction: foodInstruction,
      remarks: remarksController.text.trim(),
      endingDate: endingDateController.text.trim(),
      quantity: int.tryParse(quantityController.text.trim()) ?? 0,
    );

    await firestoreService.updateMedication(updatedMedication);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medication updated successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Medication Name')),
              TextField(
                  controller: purposeController,
                  decoration: const InputDecoration(labelText: 'Purpose')),
              TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(labelText: 'Dosage')),
              const SizedBox(height: 10),
              const Text('Frequency'),
              DropdownButton<String>(
                value: frequency,
                onChanged: (newValue) => setState(() => frequency = newValue!),
                items: ['Daily', 'Weekly', 'Monthly', 'Custom']
                    .map((value) =>
                        DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
              ),
              TextField(
                  controller: timingController,
                  decoration: const InputDecoration(labelText: 'Timing')),
              const SizedBox(height: 10),
              const Text('Before or After Food'),
              DropdownButton<String>(
                value: foodInstruction,
                onChanged: (newValue) =>
                    setState(() => foodInstruction = newValue!),
                items: ['Before', 'After', 'Does not matter']
                    .map((value) =>
                        DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
              ),
              TextField(
                  controller: remarksController,
                  decoration: const InputDecoration(labelText: 'Remarks')),
              TextField(
                  controller: endingDateController,
                  decoration: const InputDecoration(labelText: 'Ending Date')),
              TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity')),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _editMedication,
                  child: const Text('Update Medication')),
            ],
          ),
        ),
      ),
    );
  }
}
