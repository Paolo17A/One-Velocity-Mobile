import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import 'text_widgets.dart';

Drawer appDrawer(BuildContext context, {required String route}) {
  return Drawer(
    backgroundColor: CustomColors.blackBeauty,
    child: Column(
      children: [
        const Gap(40),
        Flexible(
          flex: 1,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _drawerTile(context,
                  label: 'Home',
                  onPress: () => route == NavigatorRoutes.home
                      ? null
                      : Navigator.of(context).pushNamed(NavigatorRoutes.home)),
              const Divider(
                color: CustomColors.nimbusCloud,
                indent: 20,
                endIndent: 20,
              ),
              if (hasLoggedInUser())
                _drawerTile(context,
                    label: 'Profile',
                    onPress: () => route == NavigatorRoutes.profile
                        ? null
                        : Navigator.of(context)
                            .pushNamed(NavigatorRoutes.profile))
              else
                _drawerTile(context,
                    label: 'Log-In',
                    onPress: () =>
                        Navigator.of(context).pushNamed(NavigatorRoutes.login)),
              if (hasLoggedInUser())
                _drawerTile(context,
                    label: 'Bookmarks',
                    onPress: () => route == NavigatorRoutes.bookmarks
                        ? null
                        : Navigator.of(context)
                            .pushNamed(NavigatorRoutes.bookmarks)),
              if (hasLoggedInUser())
                _drawerTile(context,
                    label: '3D Customization',
                    onPress: () => route == NavigatorRoutes.help
                        ? null
                        : Navigator.of(context)
                            .pushNamed(NavigatorRoutes.unity)),
              _drawerTile(context,
                  label: 'Help',
                  onPress: () => route == NavigatorRoutes.help
                      ? null
                      : Navigator.of(context).pushNamed(NavigatorRoutes.help))
            ],
          ),
        ),
        if (hasLoggedInUser())
          _drawerTile(context, label: 'Log-Out', onPress: () {
            FirebaseAuth.instance.signOut().then((value) =>
                Navigator.of(context)
                    .pushReplacementNamed(NavigatorRoutes.home));
          })
      ],
    ),
  );
}

Widget _drawerTile(BuildContext context,
    {required String label, required Function onPress}) {
  return ListTile(
    title: montserratWhiteBold(label, fontSize: 16),
    onTap: () {
      Navigator.of(context).pop();
      onPress();
    },
  );
}
