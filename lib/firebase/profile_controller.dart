import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pekan_innovasi/main.dart'; // Impor LocationService dari main.dart

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController namaController;
  late TextEditingController alamatController;
  late TextEditingController teleponController;

  String? _email;
  bool _isLoading = false;

  ProfileController() {
    _initializeControllers();
  }

  String? get email => _email;
  bool get isLoading => _isLoading;

  void _initializeControllers() {
    namaController = TextEditingController();
    alamatController = TextEditingController();
    teleponController = TextEditingController();
  }

  Future<void> _updateLocationOnce() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('ProfileController: No user logged in');
      return;
    }

    final locationService = LocationService();
    final data = await locationService.getCurrentLocation();
    if (data == null) {
      print('ProfileController: Failed to get current location');
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'location': {
          'latitude': data.latitude,
          'longitude': data.longitude,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
      print('ProfileController: Location updated for user ${user.uid} at ${DateTime.now()}');
    } catch (e) {
      print('ProfileController: Error updating location - $e');
    }
  }

  Future<void> loadProfileData(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('ProfileController: No user logged in');
      return;
    }

    _email = user.email;

    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        if (context.mounted) {
          namaController.text = data['namaLengkap'] ?? '';
          alamatController.text = data['alamat'] ?? '';
          teleponController.text = data['telepon'] ?? '';
          print('ProfileController: Profile data loaded for user ${user.uid}');
        }
      } else {
        await _firestore.collection('users').doc(user.uid).set({
          'namaLengkap': '',
          'alamat': '',
          'telepon': '',
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'location': null,
        });
        print('ProfileController: Created new profile for user ${user.uid}');
      }
    } catch (e) {
      print('ProfileController: Error loading profile data - $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 100,
              left: 10,
              right: 10,
            ),
          ),
        );
      }
    }
  }

  Future<void> updateProfileData(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null || _isLoading) {
      print('ProfileController: No user logged in or update in progress');
      return;
    }

    _isLoading = true;
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'namaLengkap': namaController.text.trim(),
        'alamat': alamatController.text.trim(),
        'telepon': teleponController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('namaLengkap', namaController.text);
      await prefs.setString('alamat', alamatController.text);
      await prefs.setString('telepon', teleponController.text);

      await _updateLocationOnce();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil berhasil diperbarui'),
            backgroundColor: const Color.fromARGB(255, 72, 72, 72),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 100,
              left: 10,
              right: 10,
            ),
          ),
        );
        print('ProfileController: Profile updated for user ${user.uid}');
      }
    } catch (e) {
      print('ProfileController: Error updating profile - $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 100,
              left: 10,
              right: 10,
            ),
          ),
        );
      }
    } finally {
      _isLoading = false;
    }
  }

  void dispose() {
    namaController.dispose();
    alamatController.dispose();
    teleponController.dispose();
  }
}