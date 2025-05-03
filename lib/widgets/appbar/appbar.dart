import 'package:flutter/material.dart';


class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24), // border radius bawah
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent, // transparan agar container yang terlihat
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'images/logo.png',
              height: 30,
              color: Colors.white, // tetap putih
              colorBlendMode: BlendMode.srcIn,
            ),
            const SizedBox(width: 12),
            Text(
              'Pantau Lindungi',
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: Colors.tealAccent,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
