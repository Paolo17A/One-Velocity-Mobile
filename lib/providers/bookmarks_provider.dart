import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookMarksNotifier extends ChangeNotifier {
  List<dynamic> _bookmarkedProducts = [];
  List<dynamic> _bookmarkedServices = [];

  List<dynamic> get bookmarkedProducts => _bookmarkedProducts;
  List<dynamic> get bookmarkedServices => _bookmarkedServices;

  void setBookmarkedProducts(List<dynamic> products) {
    _bookmarkedProducts = products;
    notifyListeners();
  }

  void addProductToBookmarks(dynamic product) {
    _bookmarkedProducts.add(product);
    notifyListeners();
  }

  void removeProductFromBookmarks(dynamic product) {
    _bookmarkedProducts.remove(product);
    notifyListeners();
  }

  void setBookmarkedServices(List<dynamic> services) {
    _bookmarkedServices = services;
    notifyListeners();
  }

  void addServiceToBookmarks(dynamic service) {
    _bookmarkedServices.add(service);
    notifyListeners();
  }

  void removeServiceFromBookmarks(dynamic service) {
    _bookmarkedServices.remove(service);
    bookmarkedServices.forEach((element) {
      print(element);
    });
    notifyListeners();
  }
}

final bookmarksProvider =
    ChangeNotifierProvider<BookMarksNotifier>((ref) => BookMarksNotifier());
