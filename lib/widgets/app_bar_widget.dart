import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../utils/color_util.dart';
import 'text_widgets.dart';

PreferredSizeWidget appBarWidget({bool mayPop = true, List<Widget>? actions}) {
  return AppBar(
      automaticallyImplyLeading: mayPop,
      backgroundColor: CustomColors.blackBeauty,
      toolbarHeight: 60,
      elevation: 5,
      title: Row(
        children: [
          Image.asset('assets/images/one_velocity.jpg', scale: 15),
          const Gap(8),
          montserratWhiteRegular('One Velocity', fontSize: 20)
        ],
      ),
      actions: actions);
}
