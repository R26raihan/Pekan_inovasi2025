import 'package:pekan_innovasi/screens/screens/auth/login_screen.dart';
import 'package:pekan_innovasi/screens/screens/splash_screen.dart';
import 'package:pekan_innovasi/screens/screens/auth/register_screen.dart';
import 'package:pekan_innovasi/screens/screens/main/mainscreen.dart';


class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  
  static final routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    main: (context) => const MainScreen(),
  };
}