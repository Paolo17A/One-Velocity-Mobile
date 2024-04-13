import 'package:flutter/material.dart';
import 'package:one_velocity_mobile/utils/firebase_util.dart';

import '../screens/home_screen.dart';
import '../utils/color_util.dart';
import '../utils/navigator_util.dart';
import 'text_widgets.dart';

Color bottomNavButtonColor = CustomColors.blackBeauty;

void _processPress(BuildContext context, int selectedIndex, int currentIndex) {
  //  Do nothing if we are selecting the same bottom bar
  if (selectedIndex == currentIndex) {
    return;
  }
  switch (selectedIndex) {
    case 0:
      //Navigator.of(context).pushNamed(NavigatorRoutes.home);
      Navigator.of(context).pushNamedAndRemoveUntil(
          NavigatorRoutes.home, (route) => route is HomeScreen);
      break;
    case 1:
      Navigator.of(context).pushNamed(NavigatorRoutes.products);
      break;
    case 2:
      Navigator.of(context).pushNamed(NavigatorRoutes.services);
      break;
    case 3:
      Navigator.of(context).pushNamed(NavigatorRoutes.cart);
      break;
  }
}

Widget bottomNavigationBar(BuildContext context, {required int index}) {
  return SizedBox(
    height: 80,
    child: BottomNavigationBar(
      currentIndex: index,
      selectedFontSize: 0,
      backgroundColor: bottomNavButtonColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      items: [
        //  Self-Assessment
        BottomNavigationBarItem(
            icon: _buildIcon(Icons.home, 'Home', index, 0),
            backgroundColor: bottomNavButtonColor,
            label: ''),
        BottomNavigationBarItem(
            icon: _buildIcon(Icons.settings, 'Products', index, 1),
            backgroundColor: bottomNavButtonColor,
            label: ''),
        //  Organizations
        BottomNavigationBarItem(
            icon: _buildIcon(Icons.home_repair_service, 'Services', index, 2),
            backgroundColor: bottomNavButtonColor,
            label: ''),
        if (hasLoggedInUser())
          BottomNavigationBarItem(
              icon: _buildIcon(Icons.shopping_cart, 'Cart', index, 3),
              backgroundColor: bottomNavButtonColor,
              label: '')
      ],
      onTap: (int tappedIndex) {
        _processPress(context, tappedIndex, index);
      },
    ),
  );
}

Widget _buildIcon(
    IconData iconData, String label, int currentIndex, int thisIndex) {
  return Column(
    children: [
      Icon(
        iconData,
        size: currentIndex == thisIndex ? 30 : 20,
        color: currentIndex == thisIndex ? Colors.white : Colors.black,
      ),
      currentIndex == thisIndex
          ? montserratWhiteBold(label, fontSize: 12)
          : montserratBlackBold(label, fontSize: 12)
    ],
  );
}
