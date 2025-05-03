import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'map_page.dart';

// Model untuk data relasi, sesuai dengan yang diharapkan MapPage
class RelationData {
  final String name;
  final String phone;
  final String profileImage;
  final String relation;
  final String status;
  final double latitude;
  final double longitude;
  final bool isInDisasterRadius;
  final String alamat;
  final String email;
  final Timestamp createdAt;
  final Timestamp lastUpdated;
  final Timestamp locationTimestamp;
  final String targetUid;

  RelationData({
    required this.name,
    required this.phone,
    required this.profileImage,
    required this.relation,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.isInDisasterRadius,
    required this.alamat,
    required this.email,
    required this.createdAt,
    required this.lastUpdated,
    required this.locationTimestamp,
    required this.targetUid,
  });
}

class Relation extends StatelessWidget {
  const Relation({super.key});

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Data default untuk pengguna ("saya")
  static const String userName = 'Saya';
  static const String userProfileImage = 'https://randomuser.me/api/portraits/men/1.jpg';

  // Fungsi untuk mendapatkan lokasi pengguna
  Future<LatLng> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Periksa apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Layanan lokasi dinonaktifkan.';
    }

    // Periksa izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Izin lokasi ditolak.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Izin lokasi ditolak secara permanen.';
    }

    // Dapatkan posisi pengguna
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey.shade900,
            Colors.blueGrey.shade200,
          ],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<LatLng>(
        future: _getUserLocation(),
        builder: (context, locationSnapshot) {
          if (locationSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (locationSnapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat lokasi: ${locationSnapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!locationSnapshot.hasData) {
            return const Center(
              child: Text(
                'Lokasi tidak tersedia.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final userLocation = locationSnapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .collection('relasi')
                .where('status', isEqualTo: 'accepted')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Gagal memuat relasi: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada relasi yang terhubung.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final relations = snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                Map<String, dynamic>? locationData = data['location'];
                return RelationData(
                  name: data['namaLengkap'] ?? 'Nama tidak tersedia',
                  phone: data['telepon'] ?? 'Tidak tersedia',
                  profileImage: 'https://randomuser.me/api/portraits/men/${doc.id.hashCode % 100}.jpg',
                  relation: 'Relasi',
                  status: 'Terhubung',
                  latitude: locationData != null && locationData['latitude'] != null
                      ? (locationData['latitude'] as num).toDouble()
                      : 0.0,
                  longitude: locationData != null && locationData['longitude'] != null
                      ? (locationData['longitude'] as num).toDouble()
                      : 0.0,
                  isInDisasterRadius: false, // Placeholder untuk logika radius bencana
                  alamat: data['alamat'] ?? 'Alamat tidak tersedia',
                  email: data['email'] ?? 'Email tidak tersedia',
                  createdAt: data['createdAt'] ?? Timestamp.now(),
                  lastUpdated: data['lastUpdated'] ?? Timestamp.now(),
                  locationTimestamp: locationData != null && locationData['timestamp'] != null
                      ? locationData['timestamp']
                      : Timestamp.now(),
                  targetUid: data['targetUid'] ?? '',
                );
              }).toList();

              return ListView.builder(
                itemCount: relations.length,
                itemBuilder: (context, index) {
                  final relation = relations[index];
                  return Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blueGrey.shade800, Colors.black87],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: relation.isInDisasterRadius
                              ? Colors.redAccent.withOpacity(0.4)
                              : Colors.tealAccent.withOpacity(0.2),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: relation.profileImage,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  relation.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.tealAccent.shade100,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${relation.relation} | ${relation.phone}',
                                  style: _labelStyle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  relation.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: relation.isInDisasterRadius
                                        ? Colors.redAccent
                                        : Colors.greenAccent,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Alamat: ${relation.alamat}',
                                  style: _labelStyle,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.location_on, color: Colors.tealAccent),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapPage(
                                        userLocation: userLocation,
                                        userName: userName,
                                        userProfileImage: userProfileImage,
                                        relations: relations,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.phone, color: Colors.tealAccent),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Menghubungi ${relation.phone}'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}