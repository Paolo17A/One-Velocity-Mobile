import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_velocity_mobile/screens/bookmarks_screen.dart';
import 'package:one_velocity_mobile/screens/change_password_screen.dart';
import 'package:one_velocity_mobile/screens/chat_screen.dart';
import 'package:one_velocity_mobile/screens/product_cart_screen.dart';
import 'package:one_velocity_mobile/screens/checkout_screen.dart';
import 'package:one_velocity_mobile/screens/forgot_password_screen.dart';
import 'package:one_velocity_mobile/screens/purchases_history_screen.dart';
import 'package:one_velocity_mobile/screens/selected_product_screen.dart';
import 'package:one_velocity_mobile/screens/service_cart_screen.dart';
import 'package:one_velocity_mobile/screens/unity_screen.dart';

import '../screens/booking_history_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/help_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/products_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/quotation_screen.dart';
import '../screens/register_screen.dart';
import '../screens/selected_service_screen.dart';
import '../screens/services_screen.dart';
import '../screens/settle_booking_screen.dart';

class NavigatorRoutes {
  static const String home = 'home';
  static const String register = 'register';
  static const String login = 'login';
  static const String forgotPassword = 'forgotPassword';
  static const String profile = 'profile';
  static const String editProfile = 'editProfile';
  static const String products = 'products';
  static void selectedProduct(BuildContext context, WidgetRef ref,
      {required String productID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SelectedProductScreen(productID: productID)));
  }

  static void selectedService(BuildContext context,
      {required String serviceID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SelectedServiceScreen(serviceID: serviceID)));
  }

  static void settleBooking(BuildContext context, {required String bookingID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SettleBookingScreen(bookingID: bookingID)));
  }

  static const String services = 'services';
  static const String productCart = 'productCart';
  static const String serviceCart = 'serviceCart';
  static const String checkout = 'checkout';
  static const String purchases = 'purchases';
  static const String bookings = 'bookings';
  static const String bookmarks = 'bookmarks';
  static const String help = 'help';
  static const String unity = 'unity';
  static void quotation(BuildContext context, {required String quotationURL}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => QuotationScreen(quotationURL: quotationURL)));
  }

  static const String chat = 'chat';
  static const String changePassword = 'changePassword';
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
  NavigatorRoutes.productCart: (context) => const ProductCartScreen(),
  NavigatorRoutes.serviceCart: (context) => const ServiceCartScreen(),
  NavigatorRoutes.checkout: (context) => const CheckoutScreen(),
  NavigatorRoutes.bookmarks: (context) => const BookMarksScreen(),
  NavigatorRoutes.purchases: (context) => const PurchasesHistoryScreen(),
  NavigatorRoutes.bookings: (context) => const BookingHistoryScreen(),
  NavigatorRoutes.help: (context) => const HelpScreen(),
  NavigatorRoutes.unity: (context) => const UnityScreen(),
  NavigatorRoutes.chat: (context) => const ChatScreen(),
  NavigatorRoutes.changePassword: (context) => const ChangePasswordScreen()
};
