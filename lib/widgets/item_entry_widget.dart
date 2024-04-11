import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:one_velocity_mobile/widgets/custom_padding_widgets.dart';
import '../utils/color_util.dart';
import 'text_widgets.dart';

Widget itemEntry(BuildContext context,
    {required DocumentSnapshot itemDoc,
    required Function onPress,
    Color fontColor = Colors.black}) {
  final itemData = itemDoc.data() as Map<dynamic, dynamic>;
  List<dynamic> itemImages = itemData['imageURLs'];
  String firstImage = itemImages[0];
  String itemName = itemData['name'];
  num price = itemData['price'];
  return GestureDetector(
    onTap: () => onPress(),
    child: Container(
      width: 150,
      decoration: const BoxDecoration(color: CustomColors.ultimateGray),
      child: Column(
        children: [
          _productImage(firstImage),
          all10Pix(
            child: Container(
              width: 150,
              decoration: BoxDecoration(
                  color: CustomColors.ultimateGray.withOpacity(0.05)),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    montserratWhiteBold(itemName,
                        textOverflow: TextOverflow.ellipsis),
                    _productPrice(price)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}

Widget _productImage(String firstImage) {
  return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
            border: Border.all(),
            image: DecorationImage(
                fit: BoxFit.fill, image: NetworkImage(firstImage))),
      ));
}

Widget _productPrice(num price) {
  return Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          montserratWhiteRegular('PHP ${price.toStringAsFixed(2)}',
              fontSize: 14),
        ],
      ),
    ],
  );
}
