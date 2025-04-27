import 'package:flutter/material.dart';
import '../widgets/appbar/appbar.dart';
import '../widgets/navigator/navigator.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int)? onTap;
  final bool showAppBar;
  final bool showNavBar;

  const BaseScaffold({
    super.key,
    required this.body,
    this.currentIndex = 0,
    this.onTap,
    this.showAppBar = true,
    this.showNavBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? const MainAppBar() : null,
      body: body,
      bottomNavigationBar: showNavBar
          ? MainNavBar(
              currentIndex: currentIndex,
              onTap: onTap ?? (index) {},
            )
          : null,
    );
  }
}
