import 'package:flutter/material.dart';
import '../../../api/openweatherapi.dart';
import 'package:intl/intl.dart';

class ForecastWeather extends StatefulWidget {
  const ForecastWeather({super.key});

  @override
  State<ForecastWeather> createState() => _ForecastWeatherState();
}

class _ForecastWeatherState extends State<ForecastWeather> {
  final WeatherService _weatherService = WeatherService();
  List<dynamic>? _forecast;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    try {
      final data = await _weatherService.fetchWeatherForecastData();
      setState(() {
        _forecast = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat perkiraan cuaca.';
        _isLoading = false;
      });
    }
  }

  Widget _buildCard(dynamic item) {
    final dt = DateTime.parse(item['dt_txt'] as String);
    final day = DateFormat.EEEE('id').format(dt); // Senin, Selasa, dst
    final date = DateFormat('d MMM').format(dt);   // 5 Mei, dst
    final temp = item['main']['temp'] as num;
    final desc = item['weather'][0]['description'] as String;
    final icon = item['weather'][0]['icon'] as String;
    final humidity = item['main']['humidity'] as int;
    final wind = item['wind']['speed'] as num;

    return Card(
      color: Colors.white24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text('$day, $date',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Image.network('http://openweathermap.org/img/wn/$icon@2x.png',
                width: 50, height: 50),
            Text(desc.capitalizeFirst!,
                style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 8),
            Text('${temp.toStringAsFixed(1)}°C',
                style: const TextStyle(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.opacity, color: Colors.tealAccent, size: 16),
                const SizedBox(width: 4),
                Text('$humidity%', style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 16),
                Icon(Icons.air, color: Colors.tealAccent, size: 16),
                const SizedBox(width: 4),
                Text('${wind.toStringAsFixed(1)} m/s',
                    style: const TextStyle(color: Colors.white)),
              ],
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error,
                            style: const TextStyle(fontSize: 16, color: Colors.redAccent)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadForecast,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add a header section for weather overview
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Perkiraan Cuaca 5 Hari',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      // Intro text or weather summary
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Berikut adalah perkiraan cuaca untuk 5 hari mendatang. Anda bisa melihat suhu, kelembaban, dan kecepatan angin untuk tiap hari.',
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Horizontal List of weather forecast cards
                      SizedBox(
                        height: 240,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _forecast!.length,
                          itemBuilder: (ctx, i) => _buildCard(_forecast![i]),
                        ),
                      ),
                    ],
                  )),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String get capitalizeFirst =>
      isEmpty ? '' : this[0].toUpperCase() + substring(1);
}
