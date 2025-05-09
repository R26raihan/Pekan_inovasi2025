import 'package:flutter/material.dart';
import 'package:pekan_innovasi/screens/auth/login_screen.dart';
import 'package:pekan_innovasi/screens/splash_screen.dart';
import 'package:pekan_innovasi/screens/auth/register_screen.dart';
import 'package:pekan_innovasi/screens/main/mainscreen.dart';
import 'package:pekan_innovasi/screens/main/Fitur/InformasiGempa.dart';
import 'package:pekan_innovasi/screens/main/Fitur/relation/Tambahrelasi.dart';
import 'package:pekan_innovasi/screens/main/Fitur/forcast_weather.dart';
import 'package:pekan_innovasi/screens/main/Fitur/forecast_air_population.dart';
import 'package:pekan_innovasi/screens/main/Fitur/psikologi/prsikologiscreen.dart';
import 'package:pekan_innovasi/screens/main/chatbot/chatbot.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String informasigempa = '/informasigempa';
  static const String tambahrelasi = '/tambahrelasi'; 
  static const String forecastweather = '/forecastweather';
  static const String forecastairpopulation = '/forecastairpopulation';
  static const String psikologi = '/psikologi';
  static const String chatbot = '/chatbot';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    main: (context) => const MainScreen(),
    informasigempa: (context) => const Informasigempa(),
    tambahrelasi: (context) => const Tambahrelasi(),
    forecastweather: (context) => const ForecastWeather(),
    forecastairpopulation: (context) => const ForecastAirPopulation(),
    psikologi: (context) => const Psikologi(),
    chatbot: (context) => const ChatbotScreen(),
  };
}