import 'package:pekan_innovasi/screens/auth/login_screen.dart';
import 'package:pekan_innovasi/screens/splash_screen.dart';
import 'package:pekan_innovasi/screens/auth/register_screen.dart';
import 'package:pekan_innovasi/screens/main/mainscreen.dart';
import 'package:pekan_innovasi/screens/main/Fitur/InformasiGempa.dart';
import 'package:pekan_innovasi/screens/main/Fitur/KorbanBencana.dart';
import 'package:pekan_innovasi/screens/main/Fitur/forcast_weather.dart';
import 'package:pekan_innovasi/screens/main/Fitur/forecast_air_population.dart';
import 'package:pekan_innovasi/screens/main/Fitur/kerabat.dart';


class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String informasigempa = '/informasigempa';
  static const String korbanbencana = '/korbanbencana';
  static const String forecastweather = '/forecastweather';
  static const String forecastairpopulation = '/forecastairpopulation';
  static const String kerabat = '/kerabat';

  
  static final routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    main: (context) => const MainScreen(),
    informasigempa: (context) => const Informasigempa(),
    korbanbencana: (context) => const Korbanbencana(),
    forecastweather: (context) => const ForecastWeather(),
    forecastairpopulation: (context) => const ForecastAirPopulation(),
    kerabat: (contect) => const Kerabat()
  };
}