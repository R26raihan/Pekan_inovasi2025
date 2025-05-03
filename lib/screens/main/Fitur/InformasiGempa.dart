import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pekan_innovasi/screens/main/BMKG/BMKG_api.dart';  // Import your BMKG API file

class Informasigempa extends StatefulWidget {
  const Informasigempa({super.key});

  @override
  State<Informasigempa> createState() => _InformasigempaState();
}

class _InformasigempaState extends State<Informasigempa> {
  List<AutoGempaItem>? _earthquakes;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadEarthquakeData();
  }

  Future<void> _loadEarthquakeData() async {
    try {
      final data = await fetchGempaTerkiniData();
      setState(() {
        _earthquakes = data.gempa;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data gempa.';
        _isLoading = false;
      });
    }
  }

  Widget _buildEarthquakeCard(AutoGempaItem item) {
    final dateTime = DateTime.parse(item.dateTime);
    final date = DateFormat('d MMM yyyy').format(dateTime);
    final time = DateFormat('HH:mm:ss').format(dateTime);

    return Card(
      color: Colors.white24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              '$date, $time',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Magnitude: ${item.magnitude}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Lokasi: ${item.wilayah}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Kedalaman: ${item.kedalaman} km',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Dirasakan: ${item.dirasakan}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade900,
      child: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
            : (_error.isNotEmpty
                ? Center(
                    child: Text(_error,
                        style: const TextStyle(fontSize: 16, color: Colors.redAccent)),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Informasi Gempa Terkini',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Berikut adalah informasi gempa terkini yang tercatat oleh BMKG.',
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_earthquakes != null && _earthquakes!.isNotEmpty)
                          ListView.builder(
                            itemCount: _earthquakes!.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (ctx, i) => _buildEarthquakeCard(_earthquakes![i]),
                          ),
                      ],
                    ),
                  )),
      ),
    );
  }
}
