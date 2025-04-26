import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _isMapDark = false;
  LatLng? _userLocation;
  bool _isLoading = true;
  bool _showSidebar = false;
  String? _selectedWeatherLayer;
  late AnimationController _sidebarAnimationController;
  final String _openWeatherApiKey = '4e39df06cb5091186927ce444e1ab4ad';

  final List<Map<String, dynamic>> _weatherLayers = [
    {'name': 'Clouds', 'value': 'clouds_new'},
    {'name': 'Precipitation', 'value': 'precipitation_new'},
    {'name': 'Pressure', 'value': 'pressure_new'},
    {'name': 'Temperature', 'value': 'temp_new'},
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _sidebarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _sidebarAnimationController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userLocation = LatLng(-6.2088, 106.8456);
        _isLoading = false;
      });
    }
  }

  void _toggleSidebar() {
    setState(() {
      _showSidebar = !_showSidebar;
      _showSidebar ? _sidebarAnimationController.forward() : _sidebarAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildFloatingButtons(),
          _buildAnimatedSidebar(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation!,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: _isMapDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
              ),
              if (_selectedWeatherLayer != null)
                TileLayer(
                  urlTemplate: 'https://tile.openweathermap.org/map/$_selectedWeatherLayer/{z}/{x}/{y}.png?appid=$_openWeatherApiKey',
                  userAgentPackageName: 'com.example.app',
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isMapDark
                            ? Colors.blueGrey.shade200.withOpacity(0.9)
                            : Colors.blueGrey.shade900.withOpacity(0.9),
                        border: Border.all(
                          color: _isMapDark ? Colors.blueGrey.shade900 : Colors.blueGrey.shade200,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  Widget _buildFloatingButtons() {
    return SafeArea(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              mini: true,
              backgroundColor: Colors.blueGrey.shade800,
              onPressed: _toggleSidebar,
              child: Icon(
                _showSidebar ? Icons.arrow_back_ios : Icons.menu,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              mini: true,
              backgroundColor: Colors.blueGrey.shade800,
              onPressed: () {
                setState(() {
                  _isMapDark = !_isMapDark;
                });
              },
              child: Icon(
                _isMapDark ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSidebar() {
    return AnimatedBuilder(
      animation: _sidebarAnimationController,
      builder: (context, child) {
        double slide = 250 * _sidebarAnimationController.value;
        return Stack(
          children: [
            Positioned(
              left: -250 + slide,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                // Deteksi gestur swipe horizontal
                onHorizontalDragUpdate: (details) {
                  // Jika swipe ke kiri (delta.dx negatif) dan sidebar terbuka
                  if (details.delta.dx < 0 && _showSidebar) {
                    _toggleSidebar(); // Tutup sidebar
                  }
                },
                child: _buildSidebarContent(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebarContent() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade800.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSidebarHeader(),
            const Divider(color: Colors.white24),
            _buildWeatherLayers(),
            const Divider(color: Colors.white24),
            _buildClearLayerButton(),
            const Spacer(),
            _buildComingSoon(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Map Controls',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildWeatherLayers() {
    return Expanded(
      child: ListView.builder(
        itemCount: _weatherLayers.length,
        itemBuilder: (context, index) {
          final layer = _weatherLayers[index];
          return ListTile(
            title: Text(
              layer['name'],
              style: const TextStyle(color: Colors.white),
            ),
            leading: Radio<String>(
              value: layer['value'],
              groupValue: _selectedWeatherLayer,
              onChanged: (value) {
                setState(() {
                  _selectedWeatherLayer = value;
                });
              },
              fillColor: MaterialStateProperty.all(const Color.fromARGB(255, 64, 255, 131)),
            ),
            onTap: () {
              setState(() {
                _selectedWeatherLayer = (_selectedWeatherLayer == layer['value']) ? null : layer['value'];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildClearLayerButton() {
    return ListTile(
      title: const Text('Clear Weather', style: TextStyle(color: Colors.white)),
      leading: const Icon(Icons.clear_all, color: Colors.white),
      onTap: () {
        setState(() {
          _selectedWeatherLayer = null;
        });
      },
    );
  }

  Widget _buildComingSoon() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Icon(Icons.update, color: Colors.white54),
          SizedBox(width: 8),
          Text('More features', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}