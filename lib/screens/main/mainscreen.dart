import 'package:flutter/material.dart';
import 'package:pekan_innovasi/widgets/appbar/appbar.dart';
import 'package:pekan_innovasi/widgets/navigator/navigator.dart';
import 'package:pekan_innovasi/screens/main/home/home.dart';
import 'package:pekan_innovasi/screens/main/dashboard/dashboard.dart';
import 'package:pekan_innovasi/screens/main/map/map.dart';
import 'package:pekan_innovasi/screens/main/relation/relation.dart';
import 'package:pekan_innovasi/screens/main/profile/profile.dart';
import 'package:pekan_innovasi/screens/main/Fitur/InformasiGempa.dart';
import 'package:pekan_innovasi/screens/main/Fitur/KorbanBencana.dart';
import 'package:pekan_innovasi/screens/main/Fitur/RoadRisk.dart';
import 'package:pekan_innovasi/screens/main/Fitur/forcast_weather.dart';
import 'package:pekan_innovasi/screens/main/Fitur/forecast_air_population.dart';
import 'package:pekan_innovasi/screens/main/Fitur/kerabat.dart';
import 'package:pekan_innovasi/routing/routes.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _navbarScreens = [];
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
    // inisialisasi list navbar screens sekaligus setup callback home
    _navbarScreens.addAll([
      HomeScreen(onNavigate: _navigateToFeatureScreen),
      const DashboardScreen(),
      const MapScreen(),
      const Relation(),
      const ProfileScreen(),
    ]);
  }

  void _navigateToFeatureScreen(int featureIndex) {
    final targetIndex = _navbarScreens.length + featureIndex;
    if (targetIndex < _navbarScreens.length + _featureScreens.length) {
      setState(() => _currentIndex = targetIndex);
    }
  }

  void _onNavTap(int index) {
    if (index < _navbarScreens.length) {
      setState(() => _currentIndex = index);
    }
  }

  Widget _buildCurrentScreen() {
    if (_currentIndex < _navbarScreens.length) {
      return _navbarScreens[_currentIndex];
    } else {
      final featureIndex = _currentIndex - _navbarScreens.length;
      if (featureIndex < _featureScreens.length) {
        return _featureScreens[featureIndex];
      }
    }
    // fallback
    return _navbarScreens[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  extendBodyBehindAppBar: true,
  extendBody: true,
  appBar: const MainAppBar(),
  body: _buildCurrentScreen(),
  bottomNavigationBar: MainNavBar(
    currentIndex: _currentIndex < _navbarScreens.length ? _currentIndex : 0,
    onTap: _onNavTap,
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () {
      Navigator.pushNamed(context, AppRoutes.chatbot);
    },
    backgroundColor: Colors.white, // supaya icon kelihatan
    child: Image.asset(
      'images/BOT.png',
      height: 40, // ukuran icon (bisa diubah)
      width: 40,
    ),
  ),
);
  }
}
