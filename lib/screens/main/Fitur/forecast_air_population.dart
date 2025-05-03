import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../api/openweatherapi.dart';

class ForecastAirPopulation extends StatefulWidget {
  const ForecastAirPopulation({super.key});

  @override
  State<ForecastAirPopulation> createState() => _ForecastAirPopulationState();
}

class _ForecastAirPopulationState extends State<ForecastAirPopulation> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _pollutionData;
  bool _isLoading = true;
  String _errorMessage = '';
  String _location = '';

  @override
  void initState() {
    super.initState();
    _init();  
  }

  Future<void> _init() async {
    await _determineLocation();
    _fetchPollutionData();
  }

  Future<void> _determineLocation() async {
    try {
      // 1. Cek dan minta permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Izin lokasi ditolak. Tidak bisa menampilkan lokasi.';
          _isLoading = false;
        });
        return;
      }
      // 2. Ambil posisi
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _location = '${pos.latitude.toStringAsFixed(4)}, '
                    '${pos.longitude.toStringAsFixed(4)}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mendapatkan lokasi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPollutionData() async {
    try {
      final data = await _weatherService.fetchWeatherAndPollutionData();
      setState(() {
        _pollutionData = data['pollution'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data polusi udara.';
        _isLoading = false;
      });
    }
  }

  Widget _buildPollutionIndex(int aqi) {
    String status;
    Color color;
    switch (aqi) {
      case 1:
        status = 'BAIK';
        color = Colors.green;
        break;
      case 2:
        status = 'SEDANG';
        color = Colors.yellow;
        break;
      case 3:
        status = 'TIDAK SEHAT';
        color = Colors.orange;
        break;
      case 4:
        status = 'SANGAT TIDAK SEHAT';
        color = Colors.red;
        break;
      case 5:
        status = 'BERBAHAYA';
        color = Colors.purple;
        break;
      default:
        status = 'TIDAK DIKETAHUI';
        color = Colors.grey;
    }
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(
          'Kualitas Udara: $status (AQI: $aqi)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPollutantCard(String title, double value, String unit) {
    return Card(
      color: Colors.white24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('${value.toStringAsFixed(2)} $unit', style: const TextStyle(fontSize: 16, color: Colors.white)),
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
            : Center(
                child: _errorMessage.isNotEmpty
                    ? Text(
                        _errorMessage,
                        style: const TextStyle(fontSize: 16, color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tampilkan lokasi user
                            if (_location.isNotEmpty) ...[
                              Text(
                                'Lokasi: $_location',
                                style: const TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kualitas udara di lingkunganmu di lokasi tersebut:',
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                            ],
                            const Text(
                              'Perkiraan Kualitas Udara',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            if (_pollutionData?['list'] != null && _pollutionData!['list'].isNotEmpty) ...[
                              _buildPollutionIndex(_pollutionData!['list'][0]['main']['aqi']),
                              const SizedBox(height: 16),
                              const Text(
                                'Konsentrasi Polutan:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              _buildPollutantCard(
                                'Karbon Monoksida (CO)',
                                _pollutionData!['list'][0]['components']['co'],
                                'μg/m³',
                              ),
                              _buildPollutantCard(
                                'Nitrogen Monoksida (NO)',
                                _pollutionData!['list'][0]['components']['no'],
                                'μg/m³',
                              ),
                              _buildPollutantCard(
                                'Nitrogen Dioksida (NO₂)',
                                _pollutionData!['list'][0]['components']['no2'],
                                'μg/m³',
                              ),
                              _buildPollutantCard(
                                'Ozon (O₃)',
                                _pollutionData!['list'][0]['components']['o3'],
                                'μg/m³',
                              ),
                              _buildPollutantCard(
                                'Sulfur Dioksida (SO₂)',
                                _pollutionData!['list'][0]['components']['so2'],
                                'μg/m³',
                              ),
                              _buildPollutantCard(
                                'Partikel PM2.5',
                                _pollutionData!['list'][0]['components']['pm2_5'],
                                'μg/m³',
                              ),
                              _buildPollutantCard(
                                'Partikel PM10',
                                _pollutionData!['list'][0]['components']['pm10'],
                                'μg/m³',
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'AQI (Air Quality Index) adalah indikator kualitas udara yang digunakan untuk mengkomunikasikan seberapa tercemar udara saat ini.',
                                style: TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                            ] else
                              const Text(
                                'Data polusi udara tidak tersedia',
                                style: TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                          ],
                        ),
                      ),
              ),
      ),
    );
  }
}
