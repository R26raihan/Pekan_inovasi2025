import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pekan_innovasi/screens/main/home/BNPBCard/model.dart';
import 'package:pekan_innovasi/screens/main/home/BNPBCard/getBNPB.dart';
import 'package:pekan_innovasi/screens/main/BMKG/bmkg_api.dart' as bmkg;

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
  bool _showFloodData = false;
  bool _showGempaTerbaru = false;
  bool _showGempaTerkini = false;
  late AnimationController _sidebarAnimationController;
  final String _openWeatherApiKey = '4e39df06cb5091186927ce444e1ab4ad';
  List<Banjir> _banjirData = [];
  bmkg.AutoGempaResponse? _gempaTerbaruData;
  bmkg.GempaTerkiniResponse? _gempaTerkiniData;

final List<Map<String, dynamic>> _weatherLayers = [
  {'name': 'Clouds', 'value': 'clouds_new'},              // Gratis
  {'name': 'Precipitation', 'value': 'precipitation_new'},// Gratis
  {'name': 'Pressure', 'value': 'pressure_new'},          // Gratis
  {'name': 'Temperature', 'value': 'temp_new'},           // Gratis
  {'name': 'Wind Speed', 'value': 'wind_new'},            // Gratis
  {'name': 'Snow', 'value': 'snow'},                      // Gratis
  {'name': 'Sea Level Pressure', 'value': 'pressure_cntr'}, // Gratis
  {'name': 'Temperature (Contour)', 'value': 'temp'},     // Gratis
  {'name': 'Precipitation (Classic)', 'value': 'precipitation'}, // Gratis
  {'name': 'Clouds (Classic)', 'value': 'clouds'},        // Gratis
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

  Future<void> _fetchAndDisplayBanjir() async {
    try {
      final banjirList = await fetchBanjirData();
      setState(() {
        _banjirData = banjirList;
        _showFloodData = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data banjir: $e')),
      );
      setState(() {
        _showFloodData = false;
      });
    }
  }

  Future<void> _fetchAndDisplayGempaTerbaru() async {
    try {
      final gempaResponse = await bmkg.fetchAutoGempaData();
      setState(() {
        _gempaTerbaruData = gempaResponse;
        _showGempaTerbaru = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data gempa terbaru: $e')),
      );
      setState(() {
        _showGempaTerbaru = false;
      });
    }
  }

  Future<void> _fetchAndDisplayGempaTerkini() async {
    try {
      final gempaResponse = await bmkg.fetchGempaTerkiniData();
      setState(() {
        _gempaTerkiniData = gempaResponse;
        _showGempaTerkini = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data gempa terkini: $e')),
      );
      setState(() {
        _showGempaTerkini = false;
      });
    }
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

  void _showGempaDetailDialog(BuildContext context, bmkg.AutoGempaItem data) {
    final lat = double.tryParse(data.lintang.replaceAll(' LU', '').replaceAll(' LS', '')) ?? 0.0;
    final lon = double.tryParse(data.bujur.replaceAll(' BT', '').replaceAll(' BB', '')) ?? 0.0;
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
                    data.wilayah,
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
                  _buildDetailItem("Tanggal", data.tanggal),
                  _buildDetailItem("Jam", data.jam),
                  _buildDetailItem("Magnitude", data.magnitude),
                  _buildDetailItem("Kedalaman", data.kedalaman),
                  _buildDetailItem("Potensi", data.potensi),
                  _buildDetailItem("Dirasakan", data.dirasakan.isEmpty ? 'Tidak ada data' : data.dirasakan),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset('images/Logo_BMKG.png', height: 30),
                      const SizedBox(width: 8),
                      const Text(
                        'Sumber: BMKG',
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
                  ..._banjirData.map((banjir) {
                    final lat = double.tryParse(banjir.latitude) ?? 0.0;
                    final lon = double.tryParse(banjir.longitude) ?? 0.0;
                    return Marker(
                      point: LatLng(lat, lon),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          _showFloodDetailDialog(context, banjir);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.9),
                            border: Border.all(color: Colors.red.shade900, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.warning, color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  if (_gempaTerbaruData != null && _showGempaTerbaru)
                    Marker(
                      point: LatLng(
                        double.tryParse(_gempaTerbaruData!.gempa.lintang.replaceAll(' LU', '').replaceAll(' LS', '')) ?? 0.0,
                        double.tryParse(_gempaTerbaruData!.gempa.bujur.replaceAll(' BT', '').replaceAll(' BB', '')) ?? 0.0,
                      ),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          _showGempaDetailDialog(context, _gempaTerbaruData!.gempa);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.withOpacity(0.9),
                            border: Border.all(color: Colors.orange.shade900, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.gps_fixed, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  if (_gempaTerkiniData != null && _showGempaTerkini)
                    ..._gempaTerkiniData!.gempa.map((gempa) {
                      final lat = double.tryParse(gempa.lintang.replaceAll(' LU', '').replaceAll(' LS', '')) ?? 0.0;
                      final lon = double.tryParse(gempa.bujur.replaceAll(' BT', '').replaceAll(' BB', '')) ?? 0.0;
                      return Marker(
                        point: LatLng(lat, lon),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            _showGempaDetailDialog(context, gempa);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange.withOpacity(0.9),
                              border: Border.all(color: Colors.orange.shade900, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.gps_fixed, color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx < 0 && _showSidebar) {
                    _toggleSidebar();
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
            ListTile(
              title: const Text(
                'Peta Bencana',
                style: TextStyle(color: Colors.white),
              ),
              leading: Radio<bool>(
                value: true,
                groupValue: _showFloodData,
                onChanged: (value) {
                  setState(() {
                    if (value == true && !_showFloodData) {
                      _fetchAndDisplayBanjir();
                    } else {
                      _banjirData = [];
                      _showFloodData = false;
                    }
                  });
                },
                fillColor: MaterialStateProperty.all(const Color.fromARGB(255, 64, 255, 131)),
              ),
              onTap: () {
                setState(() {
                  if (_showFloodData) {
                    _banjirData = [];
                    _showFloodData = false;
                  } else {
                    _fetchAndDisplayBanjir();
                  }
                });
              },
            ),
            ListTile(
              title: const Text(
                'Gempa Terbaru',
                style: TextStyle(color: Colors.white),
              ),
              leading: Radio<bool>(
                value: true,
                groupValue: _showGempaTerbaru,
                onChanged: (value) {
                  setState(() {
                    if (value == true && !_showGempaTerbaru) {
                      _fetchAndDisplayGempaTerbaru();
                    } else {
                      _gempaTerbaruData = null;
                      _showGempaTerbaru = false;
                    }
                  });
                },
                fillColor: MaterialStateProperty.all(const Color.fromARGB(255, 64, 255, 131)),
              ),
              onTap: () {
                setState(() {
                  if (_showGempaTerbaru) {
                    _gempaTerbaruData = null;
                    _showGempaTerbaru = false;
                  } else {
                    _fetchAndDisplayGempaTerbaru();
                  }
                });
              },
            ),
            ListTile(
              title: const Text(
                'Gempa Terkini',
                style: TextStyle(color: Colors.white),
              ),
              leading: Radio<bool>(
                value: true,
                groupValue: _showGempaTerkini,
                onChanged: (value) {
                  setState(() {
                    if (value == true && !_showGempaTerkini) {
                      _fetchAndDisplayGempaTerkini();
                    } else {
                      _gempaTerkiniData = null;
                      _showGempaTerkini = false;
                    }
                  });
                },
                fillColor: MaterialStateProperty.all(const Color.fromARGB(255, 64, 255, 131)),
              ),
              onTap: () {
                setState(() {
                  if (_showGempaTerkini) {
                    _gempaTerkiniData = null;
                    _showGempaTerkini = false;
                  } else {
                    _fetchAndDisplayGempaTerkini();
                  }
                });
              },
            ),
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
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Scrool Untuk memilih layer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _weatherLayers.length,
            itemBuilder: (context, index) {
              final layer = _weatherLayers[index];
              return ListTile(
                title: Text(
                  layer['name'],
                  style: TextStyle(color: Colors.white),
                ),
                leading: Radio<String>(
                  value: layer['value'],
                  groupValue: _selectedWeatherLayer,
                  onChanged: (value) {
                    setState(() {
                      _selectedWeatherLayer = value;
                    });
                  },
                  fillColor: MaterialStateProperty.all(Colors.tealAccent),
                ),
                onTap: () {
                  setState(() {
                    _selectedWeatherLayer = (_selectedWeatherLayer == layer['value']) ? null : layer['value'];
                  });
                },
              );
            },
          ),
        ),
      ],
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