import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onRefreshPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onNotificationPressed,
    this.onRefreshPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'images/logo.png',
              height: 30,
              color: Colors.white,
              colorBlendMode: BlendMode.srcIn,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white.withOpacity(0.95),
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_rounded,
              color: Colors.tealAccent,
            ),
            onPressed: onNotificationPressed,
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.tealAccent,
            ),
            onPressed: onRefreshPressed,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}