import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi untuk mendaftar pengguna baru
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      print('AuthService: Memulai registrasi dengan email: $email');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('AuthService: Pengguna berhasil dibuat: ${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('AuthService: Error registering user: ${e.code} - ${e.message}');
      rethrow; // Lempar ulang untuk penanganan spesifik di UI
    } catch (e, stackTrace) {
      print('AuthService: Unexpected error during registration: $e\nStackTrace: $stackTrace');
      rethrow; // Lempar ulang untuk debugging
    }
  }

  // Fungsi untuk login pengguna
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      print('AuthService: Memulai login dengan email: $email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('AuthService: Login berhasil untuk user: ${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('AuthService: Error signing in user: ${e.code} - ${e.message}');
      rethrow; // Lempar ulang untuk penanganan spesifik di UI
    } catch (e, stackTrace) {
      print('AuthService: Unexpected error during sign-in: $e\nStackTrace: $stackTrace');
      rethrow; // Lempar ulang untuk debugging
    }
  }

  // Fungsi untuk logout pengguna
  Future<void> signOut() async {
    try {
      print('AuthService: Memulai proses logout');
      await _auth.signOut();
      print('AuthService: Logout berhasil');
    } catch (e, stackTrace) {
      print('AuthService: Error during sign-out: $e\nStackTrace: $stackTrace');
    }
  }

  // Mendapatkan user yang sedang login
  User? getCurrentUser() {
    final user = _auth.currentUser;
    print('AuthService: Mendapatkan current user: ${user?.uid}');
    return user;
  }
}