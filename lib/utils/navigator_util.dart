import 'package:flutter/material.dart';

import '../screens/home_screen.dart';

class NavigatorRoutes {
  static const String home = 'home';
  static const String register = 'register';
  static const String login = 'login';
  static const String profile = 'profile';
  static const String editProfile = 'editProfile';
  static const String products = 'products';
  static const String services = 'services';
  static const String help = 'help';
}

final Map<String, WidgetBuilder> routes = {
  NavigatorRoutes.home: (context) => const HomeScreen(),
  /*NavigatorRoutes.login: (context) => const LoginScreen(),
  NavigatorRoutes.register: (context) => const RegisterScreen(),
  NavigatorRoutes.products: (context) => const ProductsScreen(),
  NavigatorRoutes.services: (context) => const ServicesScreen(),
  NavigatorRoutes.help: (context) => const HelpScreen(),
  NavigatorRoutes.profile: (context) => const ProfileScreen(),
  NavigatorRoutes.editProfile: (context) => const EditProfileScreen()*/
};
