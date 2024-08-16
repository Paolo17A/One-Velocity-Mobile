import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/utils/string_util.dart';
import 'text_widgets.dart';

PreferredSizeWidget topAppBar() {
  return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
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
