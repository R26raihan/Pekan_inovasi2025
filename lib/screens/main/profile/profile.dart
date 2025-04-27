import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey.shade900,
            Colors.blueGrey.shade200,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: Colors.blueGrey.shade800.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Foto profil
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/profile.jpg'), // Ganti sesuai fotomu
                      backgroundColor: Colors.grey.shade700,
                    ),
                    const SizedBox(height: 16),
                    // Nama
                    const Text(
                      'Nama User',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Gmail
                    const Text(
                      'namauser@gmail.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Info Detail
                    _buildInfoRow(Icons.person, 'Username', 'namauser'),
                    const Divider(color: Colors.white24, height: 32),
                    _buildInfoRow(Icons.email, 'Email', 'namauser@gmail.com'),
                    const Divider(color: Colors.white24, height: 32),
                    _buildInfoRow(Icons.home, 'Alamat', 'Jl. Contoh Alamat No. 123'),
                    const Divider(color: Colors.white24, height: 32),
                    _buildInfoRow(Icons.phone, 'Telepon', '+62 812 3456 7890'),
                    const Divider(color: Colors.white24, height: 32),
                    _buildInfoRow(Icons.info_outline, 'Tentang Saya', 'Pengguna setia aplikasi ini.'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.tealAccent, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
