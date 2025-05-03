import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const String _apiKey = '4e39df06cb5091186927ce444e1ab4ad'; 

  // Fungsi untuk mendapatkan lokasi pengguna
  Future<Position> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Fungsi untuk mengambil data cuaca dan polusi sekaligus
  Future<Map<String, dynamic>> fetchWeatherAndPollutionData() async {
    try {
      final position = await _getUserLocation();
      final lat = position.latitude;
      final lon = position.longitude;

      final weatherUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
      final weatherResponse = await http.get(weatherUrl);
      if (weatherResponse.statusCode != 200) {
        throw Exception('Failed to load weather data');
      }
      final weatherData = json.decode(weatherResponse.body);
      print('Weather API Response: ${json.encode(weatherData)}');

      final pollutionUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$_apiKey');
      final pollutionResponse = await http.get(pollutionUrl);
      if (pollutionResponse.statusCode != 200) {
        throw Exception('Failed to load pollution data');
      }
      final pollutionData = json.decode(pollutionResponse.body);
      print('Pollution API Response: ${json.encode(pollutionData)}');

      return {
        'weather': weatherData,
        'pollution': pollutionData,
      };
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Error: ${e.toString()}');
    }
  }
  String getWeatherMapTileUrl({
    required String layer,
    required int zoom,
    required int x,
    required int y,
  }) {
    return 'https://tile.openweathermap.org/map/$layer/$zoom/$x/$y.png?appid=$_apiKey';
  }
   /// **NEW** Ambil data *forecast* polusi udara (per jam untuk 5 hari ke depan)
  Future<List<dynamic>> fetchPollutionForecastData() async {
    final position = await _getUserLocation();
    final lat = position.latitude, lon = position.longitude;

    final forecastUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/air_pollution/forecast'
      '?lat=$lat&lon=$lon&appid=$_apiKey'
    );
    final resp = await http.get(forecastUrl);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load pollution forecast');
    }
    final data = json.decode(resp.body);
    // API mengembalikan {"coord":{…},"list":[{…}, …]}
    return data['list'] as List<dynamic>;
  }
    /// Ambil data forecast cuaca 5 hari ke depan (setiap 3 jam)
  Future<List<dynamic>> fetchWeatherForecastData() async {
    final position = await _getUserLocation();
    final lat = position.latitude, lon = position.longitude;

    final forecastUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast'
      '?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'
    );
    final resp = await http.get(forecastUrl);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load weather forecast');
    }
    final data = json.decode(resp.body);
    // Ambil list forecast
    final List<dynamic> list = data['list'];
    // Pilih satu entry per hari (tanggal unik) hingga 5 hari
    final seen = <String>{};
    final daily = <dynamic>[];
    for (var item in list) {
      final date = (item['dt_txt'] as String).split(' ')[0];
      if (!seen.contains(date)) {
        seen.add(date);
        daily.add(item);
      }
      if (daily.length == 5) break;
    }
    return daily;
  }

}
