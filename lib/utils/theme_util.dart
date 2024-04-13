import 'package:flutter/material.dart';
import 'color_util.dart';

ThemeData themeData = ThemeData(
    colorSchemeSeed: CustomColors.grenadine,
    scaffoldBackgroundColor: CustomColors.nimbusCloud,
    appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: CustomColors.blackBeauty,
        titleTextStyle: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        iconTheme: IconThemeData(color: CustomColors.ultimateGray),
        actionsIconTheme: IconThemeData(color: Colors.white)),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(backgroundColor: CustomColors.grenadine)));
