import 'package:flutter/material.dart';

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
