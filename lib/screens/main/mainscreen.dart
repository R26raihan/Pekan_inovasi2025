import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pekan_innovasi/widgets/appbar/appbar.dart';
import 'package:pekan_innovasi/widgets/navigator/navigator.dart';
import 'package:pekan_innovasi/screens/main/home/home.dart';
import 'package:pekan_innovasi/screens/main/dashboard/dashboard.dart';
import 'package:pekan_innovasi/screens/main/map/map.dart';
import 'package:pekan_innovasi/screens/main/relation/relation.dart';
import 'package:pekan_innovasi/screens/main/profile/profile.dart';
import 'package:pekan_innovasi/screens/main/Fitur/InformasiGempa.dart';
import 'package:pekan_innovasi/screens/main/Fitur/relation/Tambahrelasi.dart';
import 'package:pekan_innovasi/screens/main/Fitur/RoadRisk.dart';
import 'package:pekan_innovasi/screens/main/Fitur/forcast_weather.dart';
import 'package:pekan_innovasi/screens/main/Fitur/forecast_air_population.dart';
import 'package:pekan_innovasi/screens/main/Fitur/psikologi/prsikologiscreen.dart';
import 'package:pekan_innovasi/routing/routes.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  DateTime? _lastPressedAt;

  final List<Widget> _navbarScreens = [];
  final List<Widget> _featureScreens = [
    const Informasigempa(),
    const Tambahrelasi(),
    const Roadrisk(),
    const ForecastWeather(),
    const ForecastAirPopulation(),
    const Psikologi(),
  ];

  @override
  void initState() {
    super.initState();
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

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      print('MainScreen: Pengguna logout, navigasi ke /login');
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      print('MainScreen: Error during logout - $e');
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Gagal logout: $e'),
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

  Widget _buildCurrentScreen() {
    if (_currentIndex < _navbarScreens.length) {
      return _navbarScreens[_currentIndex];
    } else {
      final featureIndex = _currentIndex - _navbarScreens.length;
      if (featureIndex < _featureScreens.length) {
        return _featureScreens[featureIndex];
      }
    }
    return _navbarScreens[0];
  }

  Future<bool> _onWillPop() async {
    // Jika berada di feature screen atau screen selain home
    if (_currentIndex >= _navbarScreens.length || _currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }

    // Double tap untuk keluar dari home screen
    final currentTime = DateTime.now();
    final isBackButtonPressedTwice = _lastPressedAt == null ||
        currentTime.difference(_lastPressedAt!) > const Duration(seconds: 2);

    if (isBackButtonPressedTwice) {
      _lastPressedAt = currentTime;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tekan sekali lagi untuk keluar"),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: const MainAppBar(),
          body: _buildCurrentScreen(),
          bottomNavigationBar: MainNavBar(
            currentIndex: _currentIndex < _navbarScreens.length ? _currentIndex : 0,
            onTap: _onNavTap,
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'logout_${DateTime.now().millisecondsSinceEpoch}',
                onPressed: _logout,
                backgroundColor: Colors.red,
                child: const Icon(Icons.logout, color: Colors.white),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'chatbot_${DateTime.now().millisecondsSinceEpoch}',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.chatbot);
                },
                backgroundColor: Colors.white,
                child: Image.asset(
                  'images/BOT.png',
                  height: 40,
                  width: 40,
                ),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          drawer: Drawer(
            backgroundColor: Colors.blueGrey.shade800,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                  ),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}