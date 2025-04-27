import 'package:flutter/material.dart';

class FiturCard extends StatelessWidget {
  final Function(int) onNavigate;

  const FiturCard({super.key, required this.onNavigate});

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade800, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'List Fitur',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent.shade100,
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                // Sesuaikan jumlah kolom grid berdasarkan ukuran layar
                int crossAxisCount = width < 400 ? 2 : width < 600 ? 3 : 4;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: _features.length,
                  itemBuilder: (context, index) {
                    final item = _features[index];
                    return GestureDetector(
                      onTap: () => onNavigate(index),
                      child: _buildFeatureItem(
                        icon: item['icon'] as IconData,
                        label: item['label'] as String,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    double size = 28,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.tealAccent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: size, color: Colors.tealAccent.shade100),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: _labelStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

final List<Map<String, dynamic>> _features = [
  {'icon': Icons.warning, 'label': 'Informasi Gempa'},
  {'icon': Icons.people, 'label': 'Korban Bencana'},
  {'icon': Icons.directions_car, 'label': 'Road Risk'},
  {'icon': Icons.cloud, 'label': 'Prakiraan Cuaca'},
  {'icon': Icons.air, 'label': 'Kualitas Udara'},
  {'icon': Icons.contacts, 'label': 'Kerabat'},
];