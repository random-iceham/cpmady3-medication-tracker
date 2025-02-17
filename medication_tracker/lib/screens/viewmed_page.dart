// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/medication.dart';
import 'editmed_page.dart';

class ViewMedsPage extends StatefulWidget {
  const ViewMedsPage({super.key});

  @override
  _ViewMedsPageState createState() => _ViewMedsPageState();
}

class _ViewMedsPageState extends State<ViewMedsPage> {
  final FirestoreService firestoreService = FirestoreService();
  late String userId;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  void _getUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  // Delete medication
  Future<void> _deleteMedication(String medId) async {
    try {
      await firestoreService.deleteMedication(userId, medId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting medication: $e')),
      );
    }
  }

  void _filterMedications(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Medications')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Medications',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _filterMedications,
              ),
            ),
            StreamBuilder<List<Medication>>(
              stream: firestoreService.getMedications(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No medications added.'));
                }

                final medications = snapshot.data!;

                final filteredMedications = medications
                    .where((medication) => medication.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                    .toList();

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredMedications.length,
                  itemBuilder: (context, index) {
                    final medication = filteredMedications[index];

                    return MedicationCard(
                      medication: medication,
                      onDelete: () => _deleteMedication(medication.id),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MedicationCard extends StatefulWidget {
  final Medication medication;
  final VoidCallback onDelete;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onDelete,
  });

  @override
  _MedicationCardState createState() => _MedicationCardState();
}

class _MedicationCardState extends State<MedicationCard> {
  bool _showFullPurpose = false;
  bool _showFullDosage = false;

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$label: $value'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medication = widget.medication;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medication.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (medication.purpose != null && medication.purpose.isNotEmpty)
              _buildExpandableText(
                label: "Purpose",
                text: medication.purpose,
                isExpanded: _showFullPurpose,
                toggleExpand: () {
                  setState(() => _showFullPurpose = !_showFullPurpose);
                },
              ),

            if (medication.dosage != null && medication.dosage.isNotEmpty)
              _buildExpandableText(
                label: "Dosage",
                text: medication.dosage,
                isExpanded: _showFullDosage,
                toggleExpand: () {
                  setState(() => _showFullDosage = !_showFullDosage);
                },
              ),

            _buildInfoRow('Frequency', medication.frequency),
            _buildInfoRow('Timing', medication.timing),
            _buildInfoRow('Before/After Food', medication.foodInstruction),
            _buildInfoRow('Remarks', medication.remarks),
            _buildInfoRow('Ending Date', medication.endingDate),
            _buildInfoRow('Quantity', medication.quantity.toString()),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditMedPage(medication: widget.medication),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Expand text
  Widget _buildExpandableText({
    required String label,
    required String text,
    required bool isExpanded,
    required VoidCallback toggleExpand,
  }) {
    final int maxChars = 50; // Limit before "See More"

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${isExpanded || text.length <= maxChars ? text : text.substring(0, maxChars) + '...'}',
          ),
          if (text.length > maxChars)
            GestureDetector(
              onTap: toggleExpand,
              child: Text(
                isExpanded ? 'See Less' : 'See More',
                style: const TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
