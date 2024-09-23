import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/providers/profile_image_url_provider.dart';
import 'package:one_velocity_mobile/utils/color_util.dart';
import 'package:one_velocity_mobile/widgets/custom_miscellaneous_widgets.dart';

import '../providers/user_data_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import 'text_widgets.dart';

Drawer appDrawer(BuildContext context, WidgetRef ref, {required String route}) {
  return Drawer(
    backgroundColor: CustomColors.blackBeauty,
    child: Column(
      children: [
        SizedBox(
          height: !hasLoggedInUser() ? 80 : null,
          child: DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color.fromARGB(255, 79, 8, 2),
                const Color.fromARGB(255, 162, 38, 29)
              ])),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasLoggedInUser()) ...[
                        buildProfileImage(
                            profileImageURL: ref
                                .read(profileImageURLProvider)
                                .profileImageURL,
                            radius: 30),
                        Gap(18),
                        whiteSarabunRegular(ref.read(userDataProvider).name,
                            fontSize: 16),
                        whiteSarabunRegular(ref.read(userDataProvider).email,
                            fontSize: 12)
                      ] else
                        TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushNamed(NavigatorRoutes.login),
                            child: whiteSarabunBold('Log-In Now'))
                    ],
                  ),
                ],
              )),
        ),
        Flexible(
          flex: 1,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _drawerTile(context,
                  label: 'Home',
                  iconData: Icons.home,
                  onPress: () => route == NavigatorRoutes.home
                      ? null
                      : Navigator.of(context).pushNamed(NavigatorRoutes.home)),
              if (hasLoggedInUser())
                _drawerTile(context,
                    label: '3D Customization',
                    iconData: Icons.car_crash,
                    onPress: () => route == NavigatorRoutes.help
                        ? null
                        : Navigator.of(context)
                            .pushNamed(NavigatorRoutes.unity)),
              _drawerTile(context,
                  label: 'Products',
                  iconData: Icons.inventory,
                  onPress: () => route == NavigatorRoutes.products
                      ? null
                      : Navigator.of(context)
                          .pushNamed(NavigatorRoutes.products)),
              _drawerTile(context,
                  label: 'Services',
                  iconData: Icons.home_repair_service,
                  onPress: () => route == NavigatorRoutes.services
                      ? null
                      : Navigator.of(context)
                          .pushNamed(NavigatorRoutes.services)),
              if (hasLoggedInUser())
                _drawerTile(context,
                    label: 'View Cart',
                    iconData: Icons.shopping_cart,
                    onPress: () => route == NavigatorRoutes.productCart ||
                            route == NavigatorRoutes.serviceCart
                        ? null
                        : showModalBottomSheet(
                            context: context,
                            builder: (context) => ListView(
                                  shrinkWrap: true,
                                  children: [
                                    ListTile(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20))),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pushNamed(
                                              NavigatorRoutes.productCart);
                                        },
                                        title:
                                            blackSarabunBold('PRODUCTS CART')),
                                    ListTile(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pushNamed(
                                              NavigatorRoutes.serviceCart);
                                        },
                                        title: blackSarabunBold('SERVICE CART'))
                                  ],
                                ))),
            ],
          ),
        ),
        _drawerTile(context,
            label: 'Help',
            iconData: Icons.help,
            onPress: () => route == NavigatorRoutes.help
                ? null
                : Navigator.of(context).pushNamed(NavigatorRoutes.help)),
        if (hasLoggedInUser())
          _drawerTile(context, label: 'Log-Out', iconData: Icons.exit_to_app,
              onPress: () {
            ref.read(profileImageURLProvider).setImageURL('');
            ref.read(userDataProvider).setName('');
            ref.read(userDataProvider).setEmail('');
            FirebaseAuth.instance.signOut().then((value) =>
                Navigator.of(context)
                    .pushReplacementNamed(NavigatorRoutes.home));
          })
      ],
    ),
  );
}

Widget _drawerTile(BuildContext context,
    {required String label,
    required IconData iconData,
    required Function onPress}) {
  return ListTile(
    title: Row(
      children: [
        Icon(iconData, color: Colors.white, size: 20),
        Gap(8),
        whiteSarabunBold(label, fontSize: 16, textAlign: TextAlign.left),
      ],
    ),
    onTap: () {
      Navigator.of(context).pop();
      onPress();
    },
  );
}
