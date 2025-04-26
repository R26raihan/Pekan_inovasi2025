import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const String _apiKey = '4e39df06cb5091186927ce444e1ab4ad'; // Ganti dengan API key Anda

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

  // 🆕 Fungsi untuk mendapatkan URL tile map berdasarkan layer, zoom, x, y
  String getWeatherMapTileUrl({
    required String layer,
    required int zoom,
    required int x,
    required int y,
  }) {
    return 'https://tile.openweathermap.org/map/$layer/$zoom/$x/$y.png?appid=$_apiKey';
  }
}
