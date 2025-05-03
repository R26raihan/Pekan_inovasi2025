import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pekan_innovasi/routing/routes.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Fade animation for logo and text
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );

    // Background color transition from dark to light
    _backgroundColorAnimation = ColorTween(
      begin: Colors.blueGrey.shade900, // Dark color
      end: Colors.blueGrey.shade200,   // Light color
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation
    _controller.forward();

    // Navigate based on auth status after animation
    _navigateBasedOnAuthStatus();
  }

  Future<void> _navigateBasedOnAuthStatus() async {
    // Tunggu animasi selesai (4 detik total, termasuk delay tambahan)
    await Future.delayed(const Duration(seconds: 4), () {});
    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('SplashScreen: Pengguna sudah login, navigasi ke /main');
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        print('SplashScreen: Pengguna belum login, navigasi ke /login');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundColorAnimation.value,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    'images/logo.png',
                    height: 180,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                // Text with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'PANTAU LINDUNGI',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Sistem Cerdas Informasi Bencana',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                // Progress bar
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    value: _controller.value,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 100),
                // Version info with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Powered by Pekan Innovation',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Versi 1.0.0',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}