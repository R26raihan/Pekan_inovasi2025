import 'package:flutter/material.dart';

IconData getWeatherIcon(String condition) {
  switch (condition) {
    case 'Clear':
      return Icons.wb_sunny;
    case 'Clouds':
      return Icons.cloud;
    case 'Rain':
      return Icons.beach_access;
    case 'Thunderstorm':
      return Icons.flash_on;
    case 'Snow':
      return Icons.ac_unit;
    case 'Mist':
    case 'Smoke':
    case 'Haze':
    case 'Dust':
    case 'Fog':
      return Icons.blur_on;
    default:
      return Icons.wb_cloudy;
  }
}