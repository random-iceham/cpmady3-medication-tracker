import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/medication.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;
  String userName = '';
  final FirestoreService firestoreService = FirestoreService();
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  void _getUserName() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email ?? '';
      String name = email.split('@')[0];
      setState(() {
        userName = name;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/view_meds');
        break;
      case 1:
        Navigator.pushNamed(context, '/search');
        break;
      case 2:
        Navigator.pushNamed(context, '/add_meds');
        break;
      case 3:
        Navigator.pushNamed(context, '/schedules');
        break;
      case 4:
        Navigator.pushNamed(context, '/info');
        break;
    }
  }

  void _showLowStockDialog(List<Medication> lowStockMeds) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Medications Running Low"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: lowStockMeds.map((med) {
              return ListTile(
                title: Text(med.name),
                subtitle: Text("Remaining: ${med.quantity}"),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Medication Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/userpage');
            },
          ),
          StreamBuilder<List<Medication>>(
            stream: firestoreService.getMedications(userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                );
              }

              final lowStockMeds =
                  snapshot.data!.where((med) => med.quantity <= 5).toList();
              bool hasLowStock = lowStockMeds.isNotEmpty;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      _showLowStockDialog(lowStockMeds);
                    },
                  ),
                  if (hasLowStock)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Hi $userName',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

                final now = TimeOfDay.now();
                final medications = snapshot.data!;
                medications.sort((a, b) => a.timing.compareTo(b.timing));

                // Filter to get the next upcoming medications
                final nextMedications = medications.where((med) {
                  final timeParts = med.timing.split(':');
                  final medTime = TimeOfDay(
                    hour: int.parse(timeParts[0]),
                    minute: int.parse(timeParts[1]),
                  );
                  return medTime.hour > now.hour ||
                      (medTime.hour == now.hour && medTime.minute > now.minute);
                }).toList();

                final nextMed =
                    nextMedications.isNotEmpty ? nextMedications.first : null;

                final upcomingMeds = nextMedications.length > 1
                    ? nextMedications.sublist(1)
                    : [];

                return Column(
                  children: [
                    // Main Upcoming Medication Container
                    if (nextMed != null)
                      Container(
                        color: Colors.cyan[100],
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(nextMed.name,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('at', style: TextStyle(fontSize: 18)),
                            Text('${nextMed.timing}',
                                style: const TextStyle(
                                    fontSize: 40, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Chip(
                                  label: Text(nextMed.frequency),
                                  backgroundColor: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${nextMed.quantity} tablets left'),
                          ],
                        ),
                      ),

                    // Upcoming Medicines
                    const SizedBox(height: 16),
                    const Text('Upcoming medicine',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (upcomingMeds.isNotEmpty)
                      Container(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: upcomingMeds.length,
                          itemBuilder: (context, index) {
                            final med = upcomingMeds[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.cyan[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Chip(
                                    label: Text(
                                      med.name,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${med.timing}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/locations');
              },
              child: const Text('Find your nearest pharmacy!'),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_services, color: Colors.black),
              label: 'View meds'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search, color: Colors.black), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add, color: Colors.black), label: 'Add meds'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, color: Colors.black),
              label: 'Schedules'),
          BottomNavigationBarItem(
              icon: Icon(Icons.info, color: Colors.black), label: 'Info'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        tooltip: 'Sign Out',
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushNamed('/login');
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
