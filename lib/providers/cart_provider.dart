import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/string_util.dart';

class CartNotifier extends ChangeNotifier {
  List<DocumentSnapshot> cartItems = [];
  List<String> selectedCartItemIDs = [];
  String selectedPaymentMethod = '';
  File? proofOfPaymentFile;

  void setProofOfPaymentFile() async {
    ImagePicker imagePicker = ImagePicker();
    final selectedXFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedXFile == null) {
      return;
    }
    proofOfPaymentFile = File(selectedXFile.path);
    notifyListeners();
  }

  void resetProofOfPaymentFile() async {
    proofOfPaymentFile = null;
    notifyListeners();
  }

  void setCartItems(List<DocumentSnapshot> items) {
    cartItems = items;
    notifyListeners();
  }

  void addCartItem(dynamic item) {
    cartItems.add(item);
    notifyListeners();
  }

  void removeCartItem(DocumentSnapshot item) {
    cartItems.remove(item);
    notifyListeners();
  }

  void selectCartItem(String item) {
    if (selectedCartItemIDs.contains(item)) return;
    selectedCartItemIDs.add(item);
    notifyListeners();
  }

  void deselectCartItem(String item) {
    if (!selectedCartItemIDs.contains(item)) return;
    selectedCartItemIDs.remove(item);
    notifyListeners();
  }

  void resetSelectedCartItems() {
    selectedCartItemIDs.clear();
    notifyListeners();
  }

  bool cartContainsThisItem(String itemID) {
    return cartItems.any((cartItem) {
      final cartData = cartItem.data() as Map<dynamic, dynamic>;
      return cartData[CartFields.itemID] == itemID;
    });
  }

  void setSelectedPaymentMethod(String paymentMethod) {
    selectedPaymentMethod = paymentMethod;
    notifyListeners();
  }
}

final cartProvider =
    ChangeNotifierProvider<CartNotifier>((ref) => CartNotifier());
