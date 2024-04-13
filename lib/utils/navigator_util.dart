import 'package:flutter/material.dart';
import 'package:one_velocity_mobile/screens/bookmarks_screen.dart';
import 'package:one_velocity_mobile/screens/forgot_password_screen.dart';

import '../screens/edit_profile_screen.dart';
import '../screens/help_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/products_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../screens/services_screen.dart';

class NavigatorRoutes {
  static const String home = 'home';
  static const String register = 'register';
  static const String login = 'login';
  static const String forgotPassword = 'forgotPassword';
  static const String profile = 'profile';
  static const String editProfile = 'editProfile';
  static const String products = 'products';
  static const String services = 'services';
  static const String cart = 'cart';
  static const String bookmarks = 'bookmarks';
  static const String help = 'help';
}

final Map<String, WidgetBuilder> routes = {
  NavigatorRoutes.home: (context) => const HomeScreen(),
  NavigatorRoutes.login: (context) => const LoginScreen(),
  NavigatorRoutes.register: (context) => const RegisterScreen(),
  NavigatorRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
  NavigatorRoutes.profile: (context) => const ProfileScreen(),
  NavigatorRoutes.editProfile: (context) => const EditProfileScreen(),
  NavigatorRoutes.products: (context) => const ProductsScreen(),
  NavigatorRoutes.services: (context) => const ServicesScreen(),
  NavigatorRoutes.bookmarks: (context) => const BookMarksScreen(),
  NavigatorRoutes.help: (context) => const HelpScreen(),
};
