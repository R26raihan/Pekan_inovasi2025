import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // For intl initialization
import 'background_service.dart'; // Import background service
import 'routing/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🔧 Load environment variables from .env
    await dotenv.load();

    
    await initializeDateFormatting('id', null);
    print('Main: Intl initialized for id locale');

    // 🔧 Firebase configuration using dotenv
    final firebaseOptions = FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
    );

    // 🔧 Initialize Firebase
    await Firebase.initializeApp(options: firebaseOptions);
    print('Main: Firebase initialized');

    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    print('Main: Firestore persistence enabled');

    // 🔧 Initialize background service
    await initializeBackgroundService();
    print('Main: Background service initialized');

    // 🔧 Run the main app
    runApp(const MyApp());
  } catch (e) {
    print('Main: Application initialization failed - $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Gagal memulai aplikasi: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pekan Inovasi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      builder: (context, child) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            print('MyApp: Auth state - User: ${snapshot.data?.uid ?? "none"}');
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: child!,
            );
          },
        );
      },
    );
  }
}
