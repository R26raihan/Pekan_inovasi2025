import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Konfigurasi Firebase
final firebaseOptions = FirebaseOptions(
  apiKey: dotenv.env['FIREBASE_API_KEY']!,
  appId: dotenv.env['FIREBASE_APP_ID']!,
  projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
  messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
);

// Service untuk lokasi
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final loc.Location _location = loc.Location();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) {
      print('LocationService: Already initialized');
      return true;
    }

    try {
      // Periksa layanan lokasi
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        print('LocationService: Requesting location service');
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          print('LocationService: Location service disabled by user');
          return false;
        }
      }

      // Periksa izin lokasi
      loc.PermissionStatus permission = await _location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        print('LocationService: Requesting location permission');
        permission = await _location.requestPermission();
        if (permission != loc.PermissionStatus.granted && permission != loc.PermissionStatus.grantedLimited) {
          print('LocationService: Location permission denied');
          return false;
        }
      }

      // Konfigurasi pengaturan lokasi
      await _location.changeSettings(
        interval: 1000 * 60 * 5, // 5 menit
        distanceFilter: 50, // 50 meter
        accuracy: loc.LocationAccuracy.high,
      );

      _isInitialized = true;
      print('LocationService: Initialized successfully');
      return true;
    } catch (e) {
      print('LocationService: Error initializing - $e');
      return false;
    }
  }

  Stream<loc.LocationData> get locationStream => _location.onLocationChanged;

  Future<loc.LocationData?> getCurrentLocation() async {
    try {
      if (await initialize()) {
        final location = await _location.getLocation();
        print('LocationService: Current location - Lat: ${location.latitude}, Lng: ${location.longitude}');
        return location;
      }
      print('LocationService: Initialization failed, cannot get location');
      return null;
    } catch (e) {
      print('LocationService: Error getting current location - $e');
      return null;
    }
  }
}

// Inisialisasi background service
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  try {
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
        autoStartOnBoot: true,
        notificationChannelId: 'location_channel',
        initialNotificationTitle: 'Pelacakan Lokasi Aktif',
        initialNotificationContent: 'Memantau lokasi Anda di latar belakang',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
    print('BackgroundService: Configuration completed');
    await service.startService();
    print('BackgroundService: Service started');
  } catch (e) {
    print('BackgroundService: Error configuring or starting service - $e');
  }
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (service is AndroidServiceInstance) {
    try {
      await service.setAsForegroundService();
      service.setForegroundNotificationInfo(
        title: "Pelacakan Lokasi Aktif",
        content: "Memantau lokasi Anda di latar belakang",
      );
      print('BackgroundService: Set as foreground service');
    } catch (e) {
      print('BackgroundService: Error setting as foreground - $e');
      service.stopSelf();
      return;
    }
  }

  try {
    await Firebase.initializeApp(options: firebaseOptions);
    print('BackgroundService: Firebase initialized');
  } catch (e) {
    print('BackgroundService: Firebase initialization failed - $e');
    service.stopSelf();
    return;
  }

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService().then((_) {
        print('BackgroundService: Set as foreground via event');
      }).catchError((e) {
        print('BackgroundService: Error in setAsForeground event - $e');
      });
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      print('BackgroundService: Set as background');
    });
    service.on('stopService').listen((event) {
      service.stopSelf();
      print('BackgroundService: Service stopped via event');
    });
  }

  final locationService = LocationService();
  if (!await locationService.initialize()) {
    print('BackgroundService: Failed to initialize location service');
    service.stopSelf();
    return;
  }

  if (!await locationService._location.serviceEnabled()) {
    print('BackgroundService: Location service not enabled');
    service.stopSelf();
    return;
  }

  print('BackgroundService: Listening to location changes...');
  locationService.locationStream.listen((loc.LocationData data) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('BackgroundService: No user logged in');
        return;
      }

      await user.getIdToken(true);
      print('BackgroundService: Auth token refreshed for user ${user.uid}');

      print('BackgroundService: Location changed - Lat: ${data.latitude}, Lng: ${data.longitude} at ${DateTime.now()}');
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'location': {
          'latitude': data.latitude,
          'longitude': data.longitude,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
      print('BackgroundService: Location updated in Firestore for user ${user.uid}');

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Lokasi Diperbarui",
          content: "Lat: ${data.latitude?.toStringAsFixed(4)}, Lng: ${data.longitude?.toStringAsFixed(4)}",
        );
        print('BackgroundService: Foreground notification updated');
      }
    } catch (e) {
      print('BackgroundService: Error updating location - $e');
      await Future.delayed(Duration(minutes: 2));
    }
  }, onError: (e) {
    print('BackgroundService: Location stream error - $e');
    service.stopSelf();
  });
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  print('BackgroundService: iOS background handler triggered');
  return true;
}