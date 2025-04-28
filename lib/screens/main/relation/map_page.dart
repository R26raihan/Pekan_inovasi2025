import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dummy.dart';
import 'custom_app_bar.dart';

// Model untuk menyimpan data rute dan instruksi
class RouteInfo {
  final List<LatLng> points;
  final List<String> instructions;
  final String relationName;

  RouteInfo({
    required this.points,
    required this.instructions,
    required this.relationName,
  });
}

class MapPage extends StatefulWidget {
  final LatLng userLocation;
  final String userName;
  final String userProfileImage;
  final List<RelationData> relations;

  const MapPage({
    super.key,
    required this.userLocation,
    required this.userName,
    required this.userProfileImage,
    required this.relations,
  });

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late Future<List<RouteInfo>> _routesFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDarkTheme = false; // State untuk tema peta

  @override
  void initState() {
    super.initState();
    // Ambil rute otomatis untuk kerabat dalam radius bencana
    final disasterRelations = widget.relations.where((r) => r.isInDisasterRadius).toList();
    _routesFuture = Future.wait(disasterRelations.map((r) =>
        _getRoute(widget.userLocation, LatLng(r.latitude, r.longitude), r.name)));
  }

  // Mengambil rute dan instruksi dari OSRM API
  Future<RouteInfo> _getRoute(LatLng start, LatLng end, String name) async {
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/' +
          '${start.longitude},${start.latitude};${end.longitude},${end.latitude}' +
          '?overview=full&geometries=geojson&steps=true',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;
      final points = coords.map((pt) => LatLng(pt[1] as double, pt[0] as double)).toList();
      final steps = data['routes'][0]['legs'][0]['steps'] as List;
      final instructions = steps.map((step) {
        final maneuver = step['maneuver'];
        final type = maneuver['type'];
        final modifier = maneuver['modifier'] ?? '';
        final street = step['name'];
        return '${type}${modifier.isNotEmpty ? ' ' + modifier : ''} on ${street.isNotEmpty ? street : 'road'}';
      }).toList();

      return RouteInfo(points: points, instructions: instructions, relationName: name);
    } else {
      throw Exception('Gagal mendapatkan rute dari OSRM');
    }
  }

  // Fungsi untuk memilih URL tile berdasarkan tema
  String _getTileUrl() {
    if (_isDarkTheme) {
      return 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
    } else {
      return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade800,
          ),
          child: SafeArea(
            child: FutureBuilder<List<RouteInfo>>(
              future: _routesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat navigasi: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  final routes = snapshot.data!;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: routes.expand((routeInfo) {
                      return [
                        ListTile(
                          title: Text(
                            'Rute ke ${routeInfo.relationName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.tealAccent,
                            ),
                          ),
                        ),
                        ...routeInfo.instructions.map((instr) => ListTile(
                              leading: const Icon(Icons.directions, color: Colors.white),
                              title: Text(
                                instr,
                                style: const TextStyle(color: Colors.white),
                              ),
                            )),
                        const Divider(color: Colors.white54),
                      ];
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ),
      ),
      appBar: CustomAppBar(
        title: 'Lokasi Relation',
        onNotificationPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifikasi diklik')),
          );
        },
        onRefreshPressed: () {
          setState(() {
            initState();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Memperbarui lokasi')),
          );
        },
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.userLocation,
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: _getTileUrl(),
                subdomains: _isDarkTheme ? ['a', 'b', 'c', 'd'] : ['a', 'b', 'c'],
              ),
              // Tampilkan rute
              FutureBuilder<List<RouteInfo>>(
                future: _routesFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final routes = snapshot.data!;
                    return PolylineLayer(
                      polylines: routes
                          .map((r) => Polyline(
                                points: r.points,
                                strokeWidth: 4.0,
                                color: Colors.tealAccent,
                              ))
                          .toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              MarkerLayer(
                markers: [
                  // Marker pengguna
                  Marker(
                    point: widget.userLocation,
                    width: 80,
                    height: 80,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blueAccent, width: 2),
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: widget.userProfileImage,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder: (c, u) => const CircularProgressIndicator(),
                              errorWidget: (c, u, e) => const Icon(Icons.error, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade800,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Marker kerabat
                  ...widget.relations.map((r) => Marker(
                        point: LatLng(r.latitude, r.longitude),
                        width: 80,
                        height: 80,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: r.isInDisasterRadius ? Colors.redAccent : Colors.greenAccent,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: r.profileImage,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  placeholder: (c, u) => const CircularProgressIndicator(),
                                  errorWidget: (c, u, e) => const Icon(Icons.error, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade800,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  r.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ],
          ),
          // Tombol untuk membuka sidebar
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              backgroundColor: Colors.tealAccent,
              child: const Icon(Icons.directions, color: Colors.blueGrey),
            ),
          ),
          // Tombol untuk mengubah tema peta
          Positioned(
            bottom: 16,
            right: 80,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isDarkTheme = !_isDarkTheme;
                });
              },
              backgroundColor: Colors.tealAccent,
              child: Icon(
                _isDarkTheme ? Icons.wb_sunny : Icons.nights_stay,
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}