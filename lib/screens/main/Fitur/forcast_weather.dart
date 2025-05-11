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
  List<List<dynamic>>? _forecastData;
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
      // Kelompokkan data perkiraan berdasarkan tanggal
      final groupedData = <String, List<dynamic>>{};
      for (var item in data) {
        final date = DateTime.parse(item['dt_txt'] as String)
            .toString()
            .split(' ')[0];
        groupedData.putIfAbsent(date, () => []).add(item);
      }
      // Batasi hanya 5 hari pertama
      final limitedData = groupedData.values.toList().take(5).toList();
      setState(() {
        _forecastData = limitedData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat perkiraan cuaca: $e';
        _isLoading = false;
      });
      debugPrint('Error loading forecast: $e');
    }
  }

  Widget _buildDailyForecastCard(List<dynamic> dailyForecast) {
    if (dailyForecast.isEmpty) return const SizedBox.shrink();

    final rep = dailyForecast[dailyForecast.length ~/ 2];
    final dt = DateTime.parse(rep['dt_txt'] as String);
    final day = DateFormat.EEEE('id').format(dt);
    final date = DateFormat('d MMM', 'id').format(dt);
    final minTemp = dailyForecast
        .map((e) => e['main']['temp_min'] as num)
        .reduce((a, b) => a < b ? a : b)
        .toStringAsFixed(1);
    final maxTemp = dailyForecast
        .map((e) => e['main']['temp_max'] as num)
        .reduce((a, b) => a > b ? a : b)
        .toStringAsFixed(1);
    final icon = rep['weather'][0]['icon'] as String;

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(day,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center),
            Text(date,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Image.network(
              'http://openweathermap.org/img/wn/$icon@2x.png',
              width: 60,
              height: 60,
            ),
            const SizedBox(height: 8),
            Text('$minTemp°C - $maxTemp°C',
                style:
                    const TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedForecastCard(dynamic item) {
    final dt = DateTime.parse(item['dt_txt'] as String);
    final time = DateFormat('HH:mm', 'id').format(dt);
    final temp = item['main']['temp'] as num;
    final desc = item['weather'][0]['description'] as String;
    final icon = item['weather'][0]['icon'] as String;
    final humidity = (item['main']['humidity'] as num?)?.toInt();
    final wind = item['wind']['speed'] as num;
    final pressure = (item['main']['pressure'] as num?)?.toInt();
    final rain = item.containsKey('rain') && item['rain'].containsKey('3h')
        ? item['rain']['3h'] as num
        : 0.0;

    return Card(
      color: Colors.white12,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.network(
                    'http://openweathermap.org/img/wn/$icon@2x.png',
                    width: 40,
                    height: 40),
                Text('${temp.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                        fontSize: 18, color: Colors.white)),
              ],
            ),
            Text(desc.capitalizeFirst,
                style: const TextStyle(
                    fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.opacity,
                      color: Colors.tealAccent, size: 16),
                  const SizedBox(width: 4),
                  Text('${humidity ?? '-'}%',
                      style: const TextStyle(color: Colors.white)),
                ]),
                Row(children: [
                  const Icon(Icons.air,
                      color: Colors.tealAccent, size: 16),
                  const SizedBox(width: 4),
                  Text('${wind.toStringAsFixed(1)} m/s',
                      style: const TextStyle(color: Colors.white)),
                ]),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.compress,
                      color: Colors.tealAccent, size: 16),
                  const SizedBox(width: 4),
                  Text('${pressure ?? '-'} hPa',
                      style: const TextStyle(color: Colors.white)),
                ]),
                if (rain > 0)
                  Row(children: [
                    const Icon(Icons.water_drop,
                        color: Colors.tealAccent, size: 16),
                    const SizedBox(width: 4),
                    Text('${rain.toStringAsFixed(1)} mm',
                        style:
                            const TextStyle(color: Colors.white)),
                  ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loading & Error handling
    if (_isLoading) {
      return const Center(
          child:
              CircularProgressIndicator(color: Colors.tealAccent));
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error,
                style: const TextStyle(
                    fontSize: 16, color: Colors.redAccent)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _loadForecast,
                child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    // Flatten data for detailed list
    final flatForecast =
        _forecastData!.expand((day) => day).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey.shade900,
            Colors.blueGrey.shade800
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Perkiraan Cuaca 5 Hari',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Berikut adalah perkiraan cuaca untuk 5 hari mendatang dengan rangkuman suhu harian.',
                style:
                    TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),

            // Daily summary horizontal list
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _forecastData!.length,
                itemBuilder: (ctx, i) =>
                    _buildDailyForecastCard(_forecastData![i]),
              ),
            ),

            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Detail Perkiraan Per Jam',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),

            // Detailed hourly list (flattened)
            Expanded(
              child: ListView.builder(
                itemCount: flatForecast.length,
                itemBuilder: (ctx, index) =>
                    _buildDetailedForecastCard(
                        flatForecast[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String get capitalizeFirst =>
      isEmpty ? '' : this[0].toUpperCase() + substring(1);
}
