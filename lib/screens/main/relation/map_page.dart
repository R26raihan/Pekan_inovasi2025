import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'relation.dart';
import 'custom_app_bar.dart';


class RouteInfo {
  final List<LatLng> points;
  final List<String> instructions;
  final List<String> relationNames;

  RouteInfo({
    required this.points,
    required this.instructions,
    required this.relationNames,
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
  late Future<RouteInfo> _routeFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    // Ambil rute untuk semua relasi termasuk pengguna sebagai satu perjalanan
    final allLocations = [widget.userLocation, ...widget.relations.map((r) => LatLng(r.latitude, r.longitude))];
    final allNames = <String>[widget.userName, ...widget.relations.map((r) => r.name)];
    _routeFuture = _getRoute(allLocations, allNames);
  }

  // Mengambil rute dan instruksi dari OSRM API untuk multi-titik
  Future<RouteInfo> _getRoute(List<LatLng> locations, List<String> names) async {
    // Buat string koordinat untuk OSRM route API dengan beberapa titik
    final coordinates = locations.map((loc) => '${loc.longitude},${loc.latitude}').join(';');
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/$coordinates' +
          '?overview=full&geometries=geojson&steps=true',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final coords = (data['routes'][0]['geometry']['coordinates'] as List).cast<List<dynamic>>();
      final points = coords.map((pt) => LatLng(pt[1] as double, pt[0] as double)).toList();
      
      final legs = (data['routes'][0]['legs'] as List).cast<Map<String, dynamic>>();
      final steps = legs.expand((leg) => (leg['steps'] as List).cast<Map<String, dynamic>>()).toList();
      
      final instructions = steps.map((step) {
        final maneuver = step['maneuver'] as Map<String, dynamic>;
        final type = maneuver['type'] as String;
        final modifier = (maneuver['modifier'] as String?) ?? '';
        final street = (step['name'] as String?) ?? 'road';
        return '${type}${modifier.isNotEmpty ? ' $modifier' : ''} on $street';
      }).toList();

      return RouteInfo(
        points: points,
        instructions: instructions,
        relationNames: names,
      );
    } else {
      throw Exception('Gagal mendapatkan rute dari OSRM: ${response.statusCode}');
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
            child: FutureBuilder<RouteInfo>(
              future: _routeFuture,
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
                  final routeInfo = snapshot.data!;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Rute Keseluruhan:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.tealAccent,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...routeInfo.relationNames.asMap().entries.map((entry) {
                        final index = entry.key;
                        final name = entry.value;
                        return ListTile(
                          title: Text(
                            name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: index < routeInfo.relationNames.length - 1
                              ? const Icon(Icons.arrow_forward, color: Colors.tealAccent)
                              : null,
                        );
                      }),
                      const Divider(color: Colors.white54),
                      if (routeInfo.instructions.isNotEmpty) ...[
                        const ListTile(
                          title: Text(
                            'Petunjuk Arah:',
                            style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...routeInfo.instructions.map((instr) => ListTile(
                              leading: const Icon(Icons.directions, color: Colors.white),
                              title: Text(
                                instr,
                                style: const TextStyle(color: Colors.white),
                              ),
                            )),
                      ],
                      const Divider(color: Colors.white54),
                      ...widget.relations.map((relation) => ExpansionTile(
                            title: Text(
                              relation.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.tealAccent,
                              ),
                            ),
                            subtitle: Text(
                              relation.alamat,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            children: [
                              ListTile(
                                title: Text(
                                  'Email: ${relation.email}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Telepon: ${relation.phone}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Dibuat: ${relation.createdAt.toDate().toString()}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Terakhir Diperbarui: ${relation.lastUpdated.toDate().toString()}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Timestamp Lokasi: ${relation.locationTimestamp.toDate().toString()}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          )),
                    ],
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
            final allLocations = [widget.userLocation, ...widget.relations.map((r) => LatLng(r.latitude, r.longitude))];
            final allNames = <String>[widget.userName, ...widget.relations.map((r) => r.name)];
            _routeFuture = _getRoute(allLocations, allNames);
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
              FutureBuilder<RouteInfo>(
                future: _routeFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final routeInfo = snapshot.data!;
                    return PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routeInfo.points,
                          strokeWidth: 4.0,
                          color: Colors.tealAccent,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              MarkerLayer(
                markers: [
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