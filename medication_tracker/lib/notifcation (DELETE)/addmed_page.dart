// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../services/firestore_service.dart';
// import '../models/medication.dart';

// class AddMedPage extends StatefulWidget {
//   final Medication? prefilledMedication;

//   const AddMedPage({super.key, this.prefilledMedication});

//   @override
//   _AddMedPageState createState() => _AddMedPageState();
// }

// class _AddMedPageState extends State<AddMedPage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController purposeController = TextEditingController();
//   final TextEditingController dosageController = TextEditingController();
//   final TextEditingController remarksController = TextEditingController();
//   final TextEditingController endingDateController = TextEditingController();
//   final TextEditingController quantityController = TextEditingController();
//   TimeOfDay? selectedTime;

//   String frequency = 'Daily';
//   String foodInstruction = 'Does not matter';

//   final FirestoreService firestoreService = FirestoreService();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     if (widget.prefilledMedication != null) {
//       nameController.text = widget.prefilledMedication!.name;
//       purposeController.text = widget.prefilledMedication!.purpose;
//       dosageController.text = widget.prefilledMedication!.dosage;
//       remarksController.text = widget.prefilledMedication!.remarks;
//       endingDateController.text = widget.prefilledMedication!.endingDate;
//       quantityController.text = widget.prefilledMedication!.quantity.toString();
//       frequency = widget.prefilledMedication!.frequency;
//       foodInstruction = widget.prefilledMedication!.foodInstruction;
//       selectedTime = _parseTime(widget.prefilledMedication!.timing);
//     }
//   }

//   TimeOfDay _parseTime(String timing) {
//     final parts = timing.split(':');
//     if (parts.length == 2) {
//       final hour = int.tryParse(parts[0]) ?? 0;
//       final minute = int.tryParse(parts[1]) ?? 0;
//       return TimeOfDay(hour: hour, minute: minute);
//     }
//     return TimeOfDay.now();
//   }

//   void _selectTime() async {
//     final TimeOfDay? picked = await showTimePicker(
//         context: context, initialTime: selectedTime ?? TimeOfDay.now());
//     if (picked != null) {
//       setState(() {
//         selectedTime = picked;
//       });
//     }
//   }

//   void _addMedication() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No user logged in!")),
//       );
//       return;
//     }

//     final medication = Medication(
//       userId: user.uid,
//       name: nameController.text.trim(),
//       purpose: purposeController.text.trim(),
//       dosage: dosageController.text.trim(),
//       frequency: frequency,
//       timing: "${selectedTime!.hour}:${selectedTime!.minute}",
//       foodInstruction: foodInstruction,
//       remarks: remarksController.text.trim(),
//       endingDate: endingDateController.text.trim(),
//       quantity: int.parse(quantityController.text.trim()),
//     );

//     try {
//       await firestoreService.addMedication(medication);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Medication added successfully!')),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Medication')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextFormField(
//                   controller: nameController,
//                   decoration:
//                       const InputDecoration(labelText: 'Medication Name'),
//                   validator: (value) => value == null || value.isEmpty
//                       ? 'Name is required'
//                       : null,
//                 ),
//                 TextFormField(
//                   controller: purposeController,
//                   decoration: const InputDecoration(labelText: 'Purpose'),
//                 ),
//                 TextFormField(
//                   controller: dosageController,
//                   decoration: const InputDecoration(labelText: 'Dosage'),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text('Frequency'),
//                 DropdownButtonFormField<String>(
//                   value: frequency,
//                   onChanged: (newValue) =>
//                       setState(() => frequency = newValue!),
//                   items: ['Daily', 'Weekly', 'Monthly']
//                       .map((value) =>
//                           DropdownMenuItem(value: value, child: Text(value)))
//                       .toList(),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text('Timing'),
//                 GestureDetector(
//                   onTap: _selectTime,
//                   child: AbsorbPointer(
//                     child: TextFormField(
//                       decoration: const InputDecoration(
//                         labelText: 'Select Time',
//                         suffixIcon: Icon(Icons.access_time),
//                       ),
//                       controller: TextEditingController(
//                         text: selectedTime != null
//                             ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
//                             : '',
//                       ),
//                       validator: (value) => value == null || value.isEmpty
//                           ? 'Timing is required'
//                           : null,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text('Before or After Food'),
//                 DropdownButtonFormField<String>(
//                   value: foodInstruction,
//                   onChanged: (newValue) =>
//                       setState(() => foodInstruction = newValue!),
//                   items: ['Before', 'After', 'Does not matter']
//                       .map((value) =>
//                           DropdownMenuItem(value: value, child: Text(value)))
//                       .toList(),
//                 ),
//                 TextFormField(
//                   controller: endingDateController,
//                   decoration: const InputDecoration(labelText: 'Ending Date'),
//                 ),
//                 TextFormField(
//                   controller: quantityController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: 'Quantity'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Quantity is required';
//                     }
//                     final int? parsedValue = int.tryParse(value);
//                     if (parsedValue == null || parsedValue <= 0) {
//                       return 'Enter a valid quantity';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: remarksController,
//                   decoration: const InputDecoration(labelText: 'Remarks'),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _addMedication,
//                   child: const Text('Add Medication'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
