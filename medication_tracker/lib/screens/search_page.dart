import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../screens/search_medication_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _medications = [];
  bool _isLoading = false;
  String? _error;

  Future<void> fetchMedication(String drugName) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _medications.clear();
    });

    final url = Uri.parse(
        'https://api.fda.gov/drug/label.json?search=$drugName&limit=10');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          setState(() {
            _medications = data['results'].map<Map<String, String>>((med) {
              return {
                'name': drugName,
                'purpose': (med['purpose'] is List && med['purpose'].isNotEmpty)
                    ? med['purpose'][0].toString()
                    : 'Not available',
                'dosage': (med['dosage_and_administration'] is List &&
                        med['dosage_and_administration'].isNotEmpty)
                    ? med['dosage_and_administration'][0].toString()
                    : 'Not available',
                'active_ingredient': (med['active_ingredient'] is List &&
                        med['active_ingredient'].isNotEmpty)
                    ? med['active_ingredient'][0].toString()
                    : 'Not available',
                'indications_and_usage':
                    (med['indications_and_usage'] is List &&
                            med['indications_and_usage'].isNotEmpty)
                        ? med['indications_and_usage'][0].toString()
                        : 'Not available',
                'warnings':
                    (med['warnings'] is List && med['warnings'].isNotEmpty)
                        ? med['warnings'][0].toString()
                        : 'Not available',
                'do_not_use':
                    (med['do_not_use'] is List && med['do_not_use'].isNotEmpty)
                        ? med['do_not_use'][0].toString()
                        : 'Not available',
                'ask_doctor':
                    (med['ask_doctor'] is List && med['ask_doctor'].isNotEmpty)
                        ? med['ask_doctor'][0].toString()
                        : 'Not available',
                'stop_use':
                    (med['stop_use'] is List && med['stop_use'].isNotEmpty)
                        ? med['stop_use'][0].toString()
                        : 'Not available',
              };
            }).toList();
          });
        } else {
          setState(() {
            _error = 'No data found for "$drugName". Try another medication.';
          });
        }
      } else {
        setState(() {
          _error = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Enter medication name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  fetchMedication(_searchController.text);
                }
              },
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_medications.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    final med = _medications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(med['name']!,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Purpose: ${med['purpose']}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MedicationDetailPage(medication: med),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
