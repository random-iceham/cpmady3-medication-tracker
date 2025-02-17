// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'services/firebase_options.dart';
// import 'services/notifcations_func.dart';
// import 'package:provider/provider.dart'; // import provider

// import 'screens/home_page.dart';
// import 'screens/login_page.dart';
// import 'screens/addmed_page.dart';
// import 'screens/viewmed_page.dart';
// import 'screens/search_page.dart';
// import 'screens/schedule_page.dart';
// import 'screens/info_page.dart';
// import 'screens/viewuser_page.dart';
// import 'screens/location_page.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider<NotificationService>(
//       create: (_) =>
//           NotificationService(), // Initialize NotificationService globally
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Medication Tracker',
//         routes: {
//           '/login': (context) => const LoginPage(),
//           '/home': (context) => const HomePage(),
//           '/view_meds': (context) => const ViewMedsPage(),
//           '/search': (context) => const SearchPage(),
//           '/add_meds': (context) => const AddMedPage(),
//           '/schedules': (context) => const SchedulePage(),
//           '/info': (context) => const InfoPage(),
//           '/userpage': (context) => const ViewUserPage(),
//           '/locations': (context) => LocationPage(),
//         },
//         home: const LoginPage(),
//       ),
//     );
//   }
// }
