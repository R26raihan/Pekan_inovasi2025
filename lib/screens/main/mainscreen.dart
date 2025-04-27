import 'package:flutter/material.dart';
import 'package:pekan_innovasi/widgets/appbar/appbar.dart';
import 'package:pekan_innovasi/widgets/navigator/navigator.dart';
import 'package:pekan_innovasi/screens/screens/main/home/home.dart';
import 'package:pekan_innovasi/screens/screens/main/dashboard/dashboard.dart';
import 'package:pekan_innovasi/screens/screens/main/map/map.dart';
import 'package:pekan_innovasi/screens/screens/main/article/article.dart';
import 'package:pekan_innovasi/screens/screens/main/profile/profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const DashboardScreen(),
    const MapScreen(),
    const ArticleScreen(),
    const ProfileScreen(),
  ];

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: const MainAppBar(),
      body: _screens[_currentIndex], 
      bottomNavigationBar: MainNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
