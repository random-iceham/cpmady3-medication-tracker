import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/medication.dart';

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  _SchedulesPageState createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  final FirestoreService firestoreService = FirestoreService();
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  List<Medication> medications = [];
  String searchQuery = "";
  bool showAllDoseDetails = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> resetTakenStatus() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      // Get all medications for the user
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("medications")
          .get();

      // Loop through each document and update `takenStatus` to false
      for (var doc in snapshot.docs) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("medications")
            .doc(doc.id)
            .update({'takenStatus': false});
      }
      print("All medications have been reset.");
    } catch (e) {
      print("Error resetting medications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Schedule'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await resetTakenStatus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("All medications have been reset!")),
                );
              },
              child: Text("Reset"),
            ),
            Text("red -> not taken"),
            Text("green -> taken"),
            Text("white -> pending action"),
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

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No upcoming medications.'));
                }

                // Filter medications based on search query
                final filteredMedications = snapshot.data!
                    .where((medication) => medication.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                    .toList();

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredMedications.length,
                  itemBuilder: (context, index) {
                    final med = filteredMedications[index];
                    final timeParts = med.timing.split(':');
                    final medTime = TimeOfDay(
                      hour: int.parse(timeParts[0]),
                      minute: int.parse(timeParts[1]),
                    );

                    // Check if the current time is within 5 minutes of the medication time
                    final currentTime = TimeOfDay.now();
                    final timeDifference =
                        _getTimeDifference(currentTime, medTime);
                    bool isInTimeFrame = timeDifference <= 5;

                    // conditional colouring
                    Color rowColor = Colors.white;
                    if (med.takenStatus) {
                      rowColor = Colors.green;
                    } else if (!isInTimeFrame) {
                      rowColor = Colors.red;
                    }

                    return ListTile(
                      title: Text(med.name),
                      subtitle: Text(
                        '${medTime.format(context)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(showAllDoseDetails
                                ? Icons.expand_less
                                : Icons.expand_more),
                            onPressed: () {
                              setState(() {
                                showAllDoseDetails = !showAllDoseDetails;
                              });
                            },
                          ),
                          if (isInTimeFrame && !med.takenStatus)
                            IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: () async {
                                await firestoreService.updateTakenStatus(
                                    userId, med.id, true);
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                      tileColor: rowColor,
                      isThreeLine: true,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(med.name),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Time: ${medTime.format(context)}'),
                                if (showAllDoseDetails) ...[
                                  const SizedBox(height: 8),
                                  _buildExpandableText(
                                    label: 'Quantity',
                                    text: med.quantity.toString(),
                                  ),
                                  _buildExpandableText(
                                    label: 'Remarks',
                                    text: med.remarks,
                                  ),
                                ],
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
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

  void _filterMedications(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  // Expand text widget
  Widget _buildExpandableText({
    required String label,
    required String text,
  }) {
    final int maxChars = 50; // Limit before "See More"

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${text.length > maxChars ? text.substring(0, maxChars) + '...' : text}',
          ),
          if (text.length > maxChars)
            GestureDetector(
              onTap: () {
                setState(() {
                  showAllDoseDetails = !showAllDoseDetails;
                });
              },
              child: Text(
                showAllDoseDetails ? 'See Less' : 'See More',
                style: const TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  int _getTimeDifference(TimeOfDay current, TimeOfDay scheduled) {
    final currentTimeInMinutes = current.hour * 60 + current.minute;
    final scheduledTimeInMinutes = scheduled.hour * 60 + scheduled.minute;
    return (currentTimeInMinutes - scheduledTimeInMinutes).abs();
  }
}
