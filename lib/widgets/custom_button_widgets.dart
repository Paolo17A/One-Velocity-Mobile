import 'package:flutter/material.dart';

import '../utils/navigator_util.dart';
import 'text_widgets.dart';

Widget submitButton(BuildContext context,
    {required String label, required Function onPress}) {
  return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () => onPress(),
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ));
}

Widget loginButton(BuildContext context) {
  return TextButton(
      onPressed: () => Navigator.of(context).pushNamed(NavigatorRoutes.login),
      child: whiteSarabunBold('Log-in', fontSize: 12));
}
