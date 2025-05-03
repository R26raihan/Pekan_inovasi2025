import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:location/location.dart' as loc;
import 'routing/routes.dart';

// Konfigurasi Firebase
const firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyBPJylWPr1EQC-71lsRBXyjMKu3UmZUA4w",
  appId: "1:476405610657:android:cb283b555bb9196c17d8e0",
  projectId: "pekan-inovasi2025",
  messagingSenderId: "476405610657",
);

// Service untuk lokasi
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final loc.Location _location = loc.Location();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          print('Location service disabled');
          return false;
        }
      }

      loc.PermissionStatus permission = await _location.hasPermission();
      if (permission != loc.PermissionStatus.granted) {
        permission = await _location.requestPermission();
        if (permission != loc.PermissionStatus.granted) {
          print('Location permission denied');
          return false;
        }
      }

      await _location.changeSettings(
        interval: 1000 * 60 * 5, // Ubah ke 5 menit untuk pengujian
        distanceFilter: 50, // Ubah ke 50 meter untuk pengujian
        accuracy: loc.LocationAccuracy.high,
      );

      _isInitialized = true;
      print('Location service initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing location service: $e');
      return false;
    }
  }

  Stream<loc.LocationData> get locationStream => _location.onLocationChanged;

  Future<loc.LocationData?> getCurrentLocation() async {
    try {
      if (await initialize()) {
        return await _location.getLocation();
      }
      return null;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }
}

// Inisialisasi background service
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      autoStartOnBoot: true,
      notificationChannelId: 'location_channel',
      initialNotificationTitle: 'Pelacakan Lokasi Aktif',
      initialNotificationContent: 'Memantau lokasi Anda di latar belakang',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  print('Starting background service...');
  service.startService();
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: firebaseOptions);
    print('Firebase initialized in background service');
  } catch (e) {
    print('Firebase initialization failed: $e');
    service.stopSelf();
    return;
  }

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
      print('Set as foreground service');
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      print('Set as background service');
    });
    service.on('stopService').listen((event) {
      service.stopSelf();
      print('Background service stopped');
    });
  }

  final locationService = LocationService();
  if (!await locationService.initialize()) {
    print('Failed to initialize location service');
    service.stopSelf();
    return;
  }

  print('Listening to location changes...');
  locationService.locationStream.listen((loc.LocationData data) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      print('Location changed: Lat: ${data.latitude}, Lng: ${data.longitude} at ${DateTime.now()}');
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'location': {
          'latitude': data.latitude,
          'longitude': data.longitude,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
      print('Location updated in Firestore for user ${user.uid}');

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Lokasi Diperbarui",
          content: "Lat: ${data.latitude?.toStringAsFixed(4)}, Lng: ${data.longitude?.toStringAsFixed(4)}",
        );
      }
    } catch (e) {
      print('Error updating location: $e');
      // Retry after 2 minutes if update fails
      await Future.delayed(Duration(minutes: 2));
    }
  }, onError: (e) {
    print('Location stream error: $e');
  });
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  print('iOS background handler triggered');
  return true;
}

// Main function
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(options: firebaseOptions);
    print('Firebase initialized in main');

    // Enable Firestore offline persistence
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

    // Initialize background service
    await initializeBackgroundService();

    runApp(const MyApp());
  } catch (e) {
    print('Application initialization failed: $e');
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
            // Jika pengguna sudah login, arahkan ke MainScreen setelah splash
            // Jika belum login, arahkan ke LoginScreen setelah splash
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