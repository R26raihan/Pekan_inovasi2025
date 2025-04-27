import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart'; // Import model Banjir

Future<List<Banjir>> fetchBanjirData() async {
  final url = Uri.parse('https://dibi.bnpb.go.id/baru/get_markers?pr=&kb=&th=2025&bl=&jn=&lm=c&tg1=2025-01-23&tg2=2025-01-23');
  print('Attempting to fetch data from: $url');

  try {
    // Lakukan HTTP GET request
    final response = await http.get(url);

    // Periksa status kode response
    if (response.statusCode == 200) {
      // Parsing JSON response
      final List<dynamic> jsonData = jsonDecode(response.body);

      // Konversi JSON ke list objek Banjir
      List<Banjir> banjirList = jsonData.map((json) => Banjir.fromJson(json)).toList();

      print('Data fetched successfully: ${banjirList.length} items');
      return banjirList;
    } else {
      // Jika status kode bukan 200, lempar exception
      print('Failed to fetch data: ${response.statusCode}');
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  } catch (e) {
    // Tangani error (misalnya, masalah jaringan atau parsing JSON)
    print('Error occurred: $e');
    throw Exception('Error fetching data: $e');
  }
}