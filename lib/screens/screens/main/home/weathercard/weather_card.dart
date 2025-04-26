import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class WeatherCard extends StatefulWidget {
  final Map<String, dynamic>? data;
  final bool isLoading;
  final String errorMessage;

  const WeatherCard({
    super.key,
    required this.data,
    required this.isLoading,
    required this.errorMessage,
  });

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isMapDark = false; // State untuk tema peta (false = terang, true = gelap)
  final MapController _mapController = MapController();

  // Gaya teks
  static const TextStyle _titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.tealAccent,
  );
  static const TextStyle _subtitleStyle = TextStyle(
    fontSize: 12,
    color: Colors.white70,
    fontStyle: FontStyle.italic,
  );
  static const TextStyle _valueStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static const TextStyle _labelStyle = TextStyle(
    fontSize: 10,
    color: Colors.white70,
  );
  static const TextStyle _clickMoreStyle = TextStyle(
    fontSize: 12,
    color: Colors.white70,
    fontStyle: FontStyle.italic,
  );

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final minHeight = screenHeight * 0.12;

    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.tealAccent),
      );
    }
    if (widget.errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          widget.errorMessage,
          style: _subtitleStyle.copyWith(color: Colors.white),
        ),
      );
    }
    if (widget.data == null) {
      return const Center(
        child: Text('No data available', style: TextStyle(color: Colors.white)),
      );
    }

    final weatherData = widget.data!['weather'];
    final pollutionData = widget.data!['pollution'];
    final weather = weatherData['weather'][0] as Map<String, dynamic>;
    final main = weatherData['main'] as Map<String, dynamic>;
    final coord = weatherData['coord'] as Map<String, dynamic>;
    final lat = (coord['lat'] as num).toDouble();
    final lon = (coord['lon'] as num).toDouble();
    final position = LatLng(lat, lon);
    final temp = (main['temp'] as num).round();
    final humidity = main['humidity'];
    final windSpeed = (weatherData['wind']['speed'] as num).toDouble();
    final aqi = pollutionData['list'][0]['main']['aqi'] as int;
    final cityName = weatherData['name'] ?? 'Unknown Location';

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Card(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(12),
              child: _isExpanded
                  ? _buildExpandedContent(
                      cityName, weather, temp, humidity, windSpeed, aqi, position)
                  : _buildCollapsedContent(weather, aqi),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedContent(Map<String, dynamic> weather, int aqi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildIconData(
              icon: Icons.cloud_circle,
              label: 'AQI',
              value: pollutionIndicator(aqi),
            ),
            _buildIconData(
              icon: getWeatherIcon(weather['main']),
              label: weather['main'],
              value: '',
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Text(
            'Klik Selengkapnya',
            style: _clickMoreStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(
    String city,
    Map<String, dynamic> weather,
    int temp,
    int humidity,
    double windSpeed,
    int aqi,
    LatLng coords,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text(
                city,
                style: _titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.location_on, color: Colors.tealAccent),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          weather['description'],
          style: _subtitleStyle,
        ),
        const Divider(color: Color.fromARGB(255, 255, 255, 255), height: 20),
        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem(Icons.thermostat, '$temp°C', 'Suhu'),
            _buildStatItem(Icons.cloud, 'AQI: $aqi', 'Polusi'),
            _buildStatItem(Icons.water_drop, '$humidity%', 'Hum'),
            _buildStatItem(Icons.air, '${windSpeed.toStringAsFixed(1)} m/s', 'Angin'),
          ],
        ),
        const SizedBox(height: 12),
        // Map dengan toggle tema
        Container(
          height: 200,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color.fromARGB(60, 255, 251, 251)),
          ),
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: coords,
                  initialZoom: 11,
                ),
                children: [
                  TileLayer(
                    urlTemplate: _isMapDark
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                        : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: _isMapDark ? ['a', 'b', 'c', 'd'] : ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.app', // Ganti dengan nama paket aplikasi Anda
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: coords,
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.location_pin,
                          size: 30,
                          color: _isMapDark ? Colors.tealAccent : Colors.red, // Sesuaikan warna pin
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Ikon toggle tema
              Positioned(
                top: 8,
                right: 8,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.blueGrey.shade800.withOpacity(0.8),
                  onPressed: () {
                    setState(() {
                      _isMapDark = !_isMapDark; // Toggle tema
                    });
                  },
                  child: Icon(
                    _isMapDark ? Icons.brightness_7 : Icons.brightness_4,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconData({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.tealAccent, size: 30),
        const SizedBox(height: 4),
        Text(value, style: _valueStyle),
        Text(label, style: _labelStyle),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.tealAccent, size: 24),
        const SizedBox(height: 2),
        Text(value, style: _valueStyle),
        Text(label, style: _labelStyle),
      ],
    );
  }

  // Menentukan indikator polusi berdasarkan nilai AQI
  String pollutionIndicator(int aqi) {
    String status = '';
    if (aqi == 1) {
      status = 'Good';
    } else if (aqi == 2) {
      status = 'Fair';
    } else if (aqi == 3) {
      status = 'Moderate';
    } else if (aqi == 4) {
      status = 'Poor';
    } else if (aqi == 5) {
      status = 'Very Poor';
    }
    return '$status ($aqi)';
  }

  // Mendapatkan ikon cuaca berdasarkan kondisi cuaca
  IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.water_drop;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.help_outline;
    }
  }
}