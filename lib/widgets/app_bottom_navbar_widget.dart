import 'package:flutter/material.dart';

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
      items: [
        //  Self-Assessment
        BottomNavigationBarItem(
            icon: _buildIcon(Icons.home, 'Home'),
            backgroundColor: bottomNavButtonColor,
            label: 'Plan An Event'),
        BottomNavigationBarItem(
            icon: _buildIcon(Icons.settings, 'Products'),
            backgroundColor: bottomNavButtonColor,
            label: 'Chats'),
        //  Organizations
        BottomNavigationBarItem(
            icon: _buildIcon(Icons.home_repair_service, 'Services'),
            backgroundColor: bottomNavButtonColor,
            label: 'My Account')
      ],
      onTap: (int tappedIndex) {
        _processPress(context, tappedIndex, index);
      },
    ),
  );
}

Widget _buildIcon(IconData iconData, String label) {
  return Column(
    children: [
      Icon(iconData, size: 30),
      montserratWhiteRegular(label, fontSize: 18)
    ],
  );
}
