// dummy.dart
class RelationData {
  final String name;
  final String phone;
  final String relation;
  final String profileImage;
  final String status; // Menambahkan status
  final bool isInDisasterRadius; // Menambahkan status apakah dekat dalam radius bencana
  final double latitude; // Menambahkan latitude
  final double longitude; // Menambahkan longitude

  RelationData({
    required this.name,
    required this.phone,
    required this.relation,
    required this.profileImage,
    required this.status,
    required this.isInDisasterRadius,
    required this.latitude,
    required this.longitude,
  });
}

List<RelationData> dummyRelations = [
  RelationData(
    name: "Zee",
    phone: "+62 812 3456 7890",
    relation: "Teman",
    profileImage: "https://randomuser.me/api/portraits/women/40.jpg",
    status: "Aman", // Menambahkan status
    isInDisasterRadius: false, // Tidak dekat dalam radius bencana
    latitude: -6.200000, // Koordinat latitude
    longitude: 106.816666, // Koordinat longitude
  ),
  RelationData(
    name: "Apipah",
    phone: "+62 821 9876 5432",
    relation: "Keluarga",
    profileImage: "https://randomuser.me/api/portraits/women/2.jpg",
    status: "Dekat dalam radius bencana", // Menambahkan status
    isInDisasterRadius: true, // Dekat dalam radius bencana
    latitude: -6.250000, // Koordinat latitude
    longitude: 106.850000, // Koordinat longitude
  ),
  RelationData(
    name: "Reza",
    phone: "+62 838 1234 5678",
    relation: "Teman",
    profileImage: "https://randomuser.me/api/portraits/men/3.jpg",
    status: "Aman", // Menambahkan status
    isInDisasterRadius: false, // Tidak dekat dalam radius bencana
    latitude: -6.300000, // Koordinat latitude
    longitude: 106.820000, // Koordinat longitude
  ),
  RelationData(
    name: "Rini",
    phone: "+62 857 6789 1234",
    relation: "Teman",
    profileImage: "https://randomuser.me/api/portraits/women/4.jpg",
    status: "Aman", // Menambahkan status
    isInDisasterRadius: false, // Tidak dekat dalam radius bencana
    latitude: -6.150000, // Koordinat latitude
    longitude: 106.780000, // Koordinat longitude
  ),
  RelationData(
    name: "Intan",
    phone: "+62 857 6789 1234",
    relation: "Teman",
    profileImage: "https://randomuser.me/api/portraits/women/10.jpg",
    status: "Dekat dalam radius bencana", // Menambahkan status
    isInDisasterRadius: true, // Dekat dalam radius bencana
    latitude: -6.270000, // Koordinat latitude
    longitude: 106.830000, // Koordinat longitude
  ),
];
