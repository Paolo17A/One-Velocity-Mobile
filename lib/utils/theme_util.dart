import 'package:flutter/material.dart';
import 'color_util.dart';

ThemeData themeData = ThemeData(
    colorSchemeSeed: CustomColors.grenadine,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: CustomColors.crimson,
        titleTextStyle: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        iconTheme: IconThemeData(color: CustomColors.ultimateGray),
        actionsIconTheme: IconThemeData(color: Colors.white)),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(backgroundColor: CustomColors.crimson)));
