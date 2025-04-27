import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController for fade-in effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Fade animation for smooth entrance
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Adjust padding based on keyboard visibility
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double verticalPadding = keyboardHeight > 0 ? 20.0 : 40.0;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height, // Ensure full screen height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey.shade900, // Dark color from SplashScreen
              Colors.blueGrey.shade200, // Light color from SplashScreen
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: verticalPadding,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'images/logo.png',
                      height: 150, // Enlarged logo
                      color: Colors.white,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Daftar Akun Baru',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.95),
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade800.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            keyboardType: TextInputType.name,
                            style: TextStyle(color: Colors.white.withOpacity(0.9)),
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap',
                              hintText: 'Masukkan nama lengkap Anda',
                              labelStyle:
                                  TextStyle(color: Colors.white.withOpacity(0.7)),
                              hintStyle:
                                  TextStyle(color: Colors.white.withOpacity(0.5)),
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.blueGrey.shade200),
                              filled: true,
                              fillColor: Colors.blueGrey.shade700.withOpacity(0.4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Colors.white.withOpacity(0.9)),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Masukkan email Anda',
                              labelStyle:
                                  TextStyle(color: Colors.white.withOpacity(0.7)),
                              hintStyle:
                                  TextStyle(color: Colors.white.withOpacity(0.5)),
                              prefixIcon:
                                  Icon(Icons.email, color: Colors.blueGrey.shade200),
                              filled: true,
                              fillColor: Colors.blueGrey.shade700.withOpacity(0.4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            obscureText: true,
                            style: TextStyle(color: Colors.white.withOpacity(0.9)),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Masukkan password Anda',
                              labelStyle:
                                  TextStyle(color: Colors.white.withOpacity(0.7)),
                              hintStyle:
                                  TextStyle(color: Colors.white.withOpacity(0.5)),
                              prefixIcon:
                                  Icon(Icons.lock, color: Colors.blueGrey.shade200),
                              filled: true,
                              fillColor: Colors.blueGrey.shade700.withOpacity(0.4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            obscureText: true,
                            style: TextStyle(color: Colors.white.withOpacity(0.9)),
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Password',
                              hintText: 'Masukkan password kembali',
                              labelStyle:
                                  TextStyle(color: Colors.white.withOpacity(0.7)),
                              hintStyle:
                                  TextStyle(color: Colors.white.withOpacity(0.5)),
                              prefixIcon:
                                  Icon(Icons.lock, color: Colors.blueGrey.shade200),
                              filled: true,
                              fillColor: Colors.blueGrey.shade700.withOpacity(0.4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Logic untuk registrasi
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'DAFTAR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun?',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Masuk disini',
                            style: TextStyle(
                              color: Colors.blueGrey.shade100,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}