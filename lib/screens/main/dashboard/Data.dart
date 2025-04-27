import 'dart:convert';
import 'package:http/http.dart' as http;

// Model untuk data jumlah kejadian bencana
class DisasterOccurrence {
  final int id;
  final String disasterType;
  final Map<String, int> yearlyOccurrences;

  DisasterOccurrence({
    required this.id,
    required this.disasterType,
    required this.yearlyOccurrences,
  });

  factory DisasterOccurrence.fromJson(Map<String, dynamic> json) {
    Map<String, int> yearly = {};
    json.forEach((key, value) {
      if (key != '_id' && key != 'JENIS BENCANA') {
        yearly[key] = (value as num).toInt();
      }
    });

    return DisasterOccurrence(
      id: json['_id'] as int,
      disasterType: json['JENIS BENCANA'] as String,
      yearlyOccurrences: yearly,
    );
  }
}

// Model untuk data kerusakan bencana
class DisasterDamage {
  final int id;
  final int no;
  final int proposalYear;
  final String occurrenceYear;
  final String province;
  final String regency;
  final String disasterType;
  final String occurrenceTime;
  final double damageValue;
  final double lossValue;

  DisasterDamage({
    required this.id,
    required this.no,
    required this.proposalYear,
    required this.occurrenceYear,
    required this.province,
    required this.regency,
    required this.disasterType,
    required this.occurrenceTime,
    required this.damageValue,
    required this.lossValue,
  });

  factory DisasterDamage.fromJson(Map<String, dynamic> json) {
    return DisasterDamage(
      id: json['_id'] as int,
      no: (json['No.'] as num).toInt(),
      proposalYear: (json['Tahun Proposal'] as num).toInt(),
      occurrenceYear: json['Tahun Kejadian'] as String,
      province: json['Provinsi'] as String,
      regency: json['Kabupaten'] as String,
      disasterType: json['Jenis Bencana'] as String,
      occurrenceTime: json['Waktu Kejadian'] as String,
      damageValue: (json['Nilai Kerusakan'] as num).toDouble(),
      lossValue: (json['Nilai Kerugian'] as num).toDouble(),
    );
  }
}

// Service untuk mengambil data dari API
class DisasterService {
  static const String _baseUrl = 'https://data.bnpb.go.id/api/3/action/datastore_search';

  // Fungsi untuk mengambil data jumlah kejadian bencana
  Future<List<DisasterOccurrence>> fetchDisasterOccurrences({int limit = 1}) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl?resource_id=9b41007e-c998-456b-8cbc-385b17986e46&limit=$limit'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final records = data['result']['records'] as List;
      return records.map((json) => DisasterOccurrence.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load disaster occurrences');
    }
  }

  // Fungsi untuk mengambil data kerusakan bencana
  Future<List<DisasterDamage>> fetchDisasterDamages({int limit = 50}) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl?resource_id=f2cd9b7a-c56c-49f9-9a55-8ad40da0d763&limit=$limit'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final records = data['result']['records'] as List;
      return records.map((json) => DisasterDamage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load disaster damages');
    }
  }
}