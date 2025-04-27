import 'package:flutter/material.dart';
import 'package:pekan_innovasi/widgets/appbar/appbar.dart';
import 'package:pekan_innovasi/widgets/navigator/navigator.dart';
import 'package:pekan_innovasi/screens/main/home/home.dart';
import 'package:pekan_innovasi/screens/main/dashboard/dashboard.dart';
import 'package:pekan_innovasi/screens/main/map/map.dart';
import 'package:pekan_innovasi/screens/main/article/article.dart';
import 'package:pekan_innovasi/screens/main/profile/profile.dart';
import 'package:pekan_innovasi/screens/main/Fitur/InformasiGempa.dart';
import 'package:pekan_innovasi/screens/main/Fitur/KorbanBencana.dart';
import 'package:pekan_innovasi/screens/main/Fitur/RoadRisk.dart';
import 'package:pekan_innovasi/screens/main/Fitur/forcast_weather.dart';
import 'package:pekan_innovasi/screens/main/Fitur/forecast_air_population.dart';
import 'package:pekan_innovasi/screens/main/Fitur/kerabat.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Daftar screen yang bisa diakses melalui navbar
  final List<Widget> _navbarScreens = [
    HomeScreen(onNavigate: (index) {}), // Diisi nanti di initState
    const DashboardScreen(),
    const MapScreen(),
    const ArticleScreen(),
    const ProfileScreen(),
  ];

  // Daftar screen untuk fitur-fitur dari FiturCard
  final List<Widget> _featureScreens = [
    const Informasigempa(),
    const Korbanbencana(),
    const Roadrisk(),
    const ForecastWeather(),
    const ForecastAirPopulation(),
    const Kerabat(),
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi HomeScreen dengan callback navigasi yang benar
    _navbarScreens[0] = HomeScreen(onNavigate: _navigateToFeatureScreen);
  }

  // Fungsi untuk navigasi dari FiturCard
  void _navigateToFeatureScreen(int featureIndex) {
    // Index fitur dimulai setelah index terakhir navbar
    int targetIndex = _navbarScreens.length + featureIndex;
    
    // Pastikan index tidak melebihi total screen yang ada
    if (targetIndex < _navbarScreens.length + _featureScreens.length) {
      setState(() {
        _currentIndex = targetIndex;
      });
    }
  }

  // Fungsi untuk navigasi melalui navbar
  void _onNavTap(int index) {
    // Hanya izinkan navigasi ke screen navbar (0 sampai 4)
    if (index < _navbarScreens.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: const MainAppBar(),
      body: _buildCurrentScreen(),
      bottomNavigationBar: MainNavBar(
        currentIndex: _currentIndex < _navbarScreens.length 
            ? _currentIndex 
            : 0, // Jika di screen fitur, set ke 0 (Home)
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildCurrentScreen() {
    // Jika index mengarah ke screen navbar
    if (_currentIndex < _navbarScreens.length) {
      return _navbarScreens[_currentIndex];
    } 
    // Jika index mengarah ke screen fitur
    else {
      int featureIndex = _currentIndex - _navbarScreens.length;
      if (featureIndex < _featureScreens.length) {
        return _featureScreens[featureIndex];
      }
    }
    // Fallback ke HomeScreen jika index tidak valid
    return _navbarScreens[0];
  }
}