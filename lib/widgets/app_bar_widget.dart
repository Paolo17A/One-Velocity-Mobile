import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/utils/color_util.dart';
import 'package:one_velocity_mobile/utils/navigator_util.dart';
import 'package:one_velocity_mobile/utils/string_util.dart';
import 'text_widgets.dart';

PreferredSizeWidget topAppBar() {
  return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(ImagePaths.logo, scale: 15),
          const Gap(8),
          crimsonSarabunBold('ONE ', fontSize: 20),
          blackSarabunBold('VELOCITY CAR CARE INC', fontSize: 20)
        ],
      ));
}

PreferredSizeWidget appBarWidget({bool mayPop = true, List<Widget>? actions}) {
  return AppBar(
      automaticallyImplyLeading: mayPop,
      toolbarHeight: 60,
      elevation: 5,
      iconTheme: IconThemeData(color: Colors.white),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30))),
      actions: actions);
}

Widget popUpMenu(BuildContext context, {required String currentPath}) {
  return PopupMenuButton(
      color: CustomColors.blackBeauty,
      onSelected: (value) {
        if (currentPath == value) return;
        Navigator.of(context).pushNamed(value);
      },
      itemBuilder: (context) => [
            PopupMenuItem(
                value: NavigatorRoutes.profile,
                child: whiteSarabunBold('Profile')),
            PopupMenuItem(
                value: NavigatorRoutes.bookmarks,
                child: whiteSarabunBold('Bookmarks')),
            PopupMenuItem(
                value: NavigatorRoutes.purchases,
                child: whiteSarabunBold('Product Purchase History')),
            PopupMenuItem(
                value: NavigatorRoutes.bookings,
                child: whiteSarabunBold('Service Booking History')),
            PopupMenuItem(
                value: NavigatorRoutes.changePassword,
                child: whiteSarabunBold('Change Password')),
          ]);
}
