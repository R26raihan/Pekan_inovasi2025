import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'model.dart'; // Import model Banjir

class FloodCard extends StatelessWidget {
  final Banjir data;
  final bool isLoading;
  final String errorMessage;

  const FloodCard({
    super.key,
    required this.data,
    required this.isLoading,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.tealAccent),
      );
    }
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    final province = data.nprop;
    final city = data.nkab;
    final incident = data.kejadian;
    final date = data.tanggal;

    return GestureDetector(
      onTap: () => _showFloodDetailDialog(context, data),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade800.withOpacity(0.9),
                  Colors.blueGrey.shade900.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ================= Location Row =================
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.tealAccent, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$city, $province',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.tealAccent,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black45,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ================ Info Row ===================
                Row(
                  children: [
                    // Kotak Kejadian (fixed height)
                    Expanded(
                      flex: 1,
                      child: _buildInfoItem(
                        icon: Icons.warning_amber,
                        value: incident,
                        label: 'Kejadian',
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Kotak Tanggal (fixed height)
                    Expanded(
                      flex: 1,
                      child: _buildInfoItem(
                        icon: Icons.calendar_month,
                        value: date,
                        label: 'Tanggal',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ================= Footer ===================
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      'Klik Selengkapnya',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Kotak info dengan tinggi tetap 80px, teks di-wrap dan ellipsis.
  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return SizedBox(
      height: 80, // tinggi tetap
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade700.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label + ikon
            Row(
              children: [
                Icon(icon, color: Colors.tealAccent, size: 20),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Isi: wrap & ellipsis, di-flex agar bisa dipotong
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFloodDetailDialog(BuildContext context, Banjir data) {
    final lat = double.tryParse(data.latitude) ?? 0.0;
    final lon = double.tryParse(data.longitude) ?? 0.0;
    final position = LatLng(lat, lon);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          initialChildSize: 0.75,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade800.withOpacity(0.95),
                  Colors.blueGrey.shade900.withOpacity(0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Text(
                    "${data.nkab}, ${data.nprop}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black45,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: position,
                          initialZoom: 11.5,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: position,
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem("Kejadian", data.kejadian),
                  _buildDetailItem("Tanggal", data.tanggal),
                  _buildDetailItem("Penyebab", data.penyebab),
                  _buildDetailItem("Kronologis", data.kronologis),
                  _buildDetailItem("Keterangan", data.keterangan),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset('images/Logo_BNPB.png', height: 30),
                      const SizedBox(width: 8),
                      const Text(
                        'Sumber: BNPB',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.tealAccent,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black45,
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
