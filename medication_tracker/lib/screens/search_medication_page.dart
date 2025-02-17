import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import '../services/firestore_service.dart';
import '../models/medication.dart';
import 'addmed_page.dart';

class MedicationDetailPage extends StatefulWidget {
  final Map<String, String> medication;

  const MedicationDetailPage({super.key, required this.medication});

  @override
  _MedicationDetailPageState createState() => _MedicationDetailPageState();
}

class _MedicationDetailPageState extends State<MedicationDetailPage> {
  bool _isDosageExpanded = false;
  bool _isWarningsExpanded = false;

  @override
  Widget build(BuildContext context) {
    String dosage = widget.medication['dosage'] ?? 'Not available';
    String warnings = widget.medication['warnings'] ?? 'Not available';

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.medication['name'] ?? 'Medication Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInfoSection('Medication', widget.medication['name']),
            buildInfoSection(
                'Active Ingredient', widget.medication['active_ingredient']),
            buildInfoSection('Purpose', widget.medication['purpose']),
            buildInfoSection('Indications & Usage',
                widget.medication['indications_and_usage']),
            buildExpandableSection('Warnings', warnings, _isWarningsExpanded,
                () {
              setState(() {
                _isWarningsExpanded = !_isWarningsExpanded;
              });
            }),
            buildInfoSection('Do Not Use', widget.medication['do_not_use']),
            buildInfoSection('Ask Doctor', widget.medication['ask_doctor']),
            buildInfoSection('Stop Use', widget.medication['stop_use']),
            buildExpandableSection('Dosage', dosage, _isDosageExpanded, () {
              setState(() {
                _isDosageExpanded = !_isDosageExpanded;
              });
            }),
            ElevatedButton(
              onPressed: () {
                final medication = Medication(
                  userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                  name: widget.medication['name'] ?? '',
                  purpose: widget.medication['purpose'] ?? '',
                  dosage: widget.medication['dosage'] ?? '',
                  frequency: 'Daily', // Default value
                  timing: '', // No default timing
                  foodInstruction: 'Does not matter',
                  remarks: '',
                  endingDate: '',
                  quantity: 0,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddMedPage(prefilledMedication: medication),
                  ),
                );
              },
              child: const Text('Add to My Medications'),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper function for displaying regular text sections
  Widget buildInfoSection(String title, String? value) {
    if (value == null || value.isEmpty || value == 'Not available') {
      return const SizedBox(); // Hide empty sections
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }

  /// expandable section
  Widget buildExpandableSection(
      String title, String value, bool isExpanded, VoidCallback onToggle) {
    bool isLongText = value.length > 100;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            isExpanded || !isLongText ? value : '${value.substring(0, 100)}...',
            style: const TextStyle(fontSize: 16),
          ),
          if (isLongText)
            TextButton(
              onPressed: onToggle,
              child: Text(isExpanded ? 'Show Less' : 'Show More'),
            ),
          const Divider(),
        ],
      ),
    );
  }
}
