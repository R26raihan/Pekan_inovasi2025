import 'dart:convert';
import 'package:http/http.dart' as http;

class AutoGempaItem {
  final String tanggal;
  final String jam;
  final String dateTime;
  final String coordinates;
  final String lintang;
  final String bujur;
  final String magnitude;
  final String kedalaman;
  final String wilayah;
  final String potensi;
  final String dirasakan;
  final String shakemap;

  AutoGempaItem({
    required this.tanggal,
    required this.jam,
    required this.dateTime,
    required this.coordinates,
    required this.lintang,
    required this.bujur,
    required this.magnitude,
    required this.kedalaman,
    required this.wilayah,
    required this.potensi,
    required this.dirasakan,
    required this.shakemap,
  });

  factory AutoGempaItem.fromJson(Map<String, dynamic> json) {
    return AutoGempaItem(
      tanggal: json['Tanggal'] as String? ?? '',
      jam: json['Jam'] as String? ?? '',
      dateTime: json['DateTime'] as String? ?? '',
      coordinates: json['Coordinates'] as String? ?? '',
      lintang: json['Lintang'] as String? ?? '',
      bujur: json['Bujur'] as String? ?? '',
      magnitude: json['Magnitude'] as String? ?? '',
      kedalaman: json['Kedalaman'] as String? ?? '',
      wilayah: json['Wilayah'] as String? ?? '',
      potensi: json['Potensi'] as String? ?? '',
      dirasakan: json['Dirasakan'] as String? ?? '',
      shakemap: json['Shakemap'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'Tanggal': tanggal,
        'Jam': jam,
        'DateTime': dateTime,
        'Coordinates': coordinates,
        'Lintang': lintang,
        'Bujur': bujur,
        'Magnitude': magnitude,
        'Kedalaman': kedalaman,
        'Wilayah': wilayah,
        'Potensi': potensi,
        'Dirasakan': dirasakan,
        'Shakemap': shakemap,
      };
}

class AutoGempaResponse {
  final AutoGempaItem gempa;

  AutoGempaResponse({required this.gempa});

  factory AutoGempaResponse.fromJson(Map<String, dynamic> json) {
    return AutoGempaResponse(
      gempa: AutoGempaItem.fromJson(json['gempa'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'gempa': gempa.toJson()};
}

class GempaTerkiniResponse {
  final List<AutoGempaItem> gempa;

  GempaTerkiniResponse({required this.gempa});

  factory GempaTerkiniResponse.fromJson(Map<String, dynamic> json) {
    var gempaList = json['gempa'] as List<dynamic>;
    List<AutoGempaItem> gempaItems = gempaList
        .map((item) => AutoGempaItem.fromJson(item as Map<String, dynamic>))
        .toList();
    return GempaTerkiniResponse(gempa: gempaItems);
  }

  Map<String, dynamic> toJson() => {
        'gempa': gempa.map((item) => item.toJson()).toList(),
      };
}

Future<AutoGempaResponse> fetchAutoGempaData() async {
  final url = Uri.parse('https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json');
  try {
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (!data.containsKey('Infogempa') || !data['Infogempa'].containsKey('gempa')) {
        throw Exception('Struktur data BMKG tidak valid');
      }

      return AutoGempaResponse.fromJson({'gempa': data['Infogempa']['gempa']});
    } else {
      throw Exception('Gagal mengambil data dari BMKG: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Gagal mengambil data dari BMKG: $e');
  }
}

Future<GempaTerkiniResponse> fetchGempaTerkiniData() async {
  final url = Uri.parse('https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json');
  try {
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (!data.containsKey('Infogempa') || !data['Infogempa'].containsKey('gempa')) {
        throw Exception('Struktur data BMKG tidak valid');
      }

      return GempaTerkiniResponse.fromJson({'gempa': data['Infogempa']['gempa']});
    } else {
      throw Exception('Gagal mengambil data dari BMKG: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Gagal mengambil data dari BMKG: $e');
  }
}