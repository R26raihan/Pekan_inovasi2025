import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahkan ini untuk SystemChrome
import 'screens/screens/splash_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Status bar transparan
    statusBarIconBrightness: Brightness.light, // Ikon status bar terang
    systemNavigationBarColor: Colors.transparent, // Navigation bar transparan
    systemNavigationBarIconBrightness: Brightness.light, // Ikon navigation bar terang
  ));
  runApp(const MyApp());
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
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}