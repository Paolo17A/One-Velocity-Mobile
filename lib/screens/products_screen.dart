import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_velocity_mobile/widgets/text_widgets.dart';

import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_bottom_navbar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/item_entry_widget.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  List<DocumentSnapshot> allProductDocs = [];
  List<DocumentSnapshot> filteredProductDocs = [];
  String selectedCategory = 'VIEW ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        allProductDocs = await getAllProducts();
        filteredProductDocs = allProductDocs;
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting all services: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: appBarWidget(),
      drawer: appDrawer(context, route: NavigatorRoutes.products),
      bottomNavigationBar: bottomNavigationBar(context, index: 1),
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(
              children: [
                productsHeader(),
                _productCategoryWidget(),
                _availableProducts()
              ],
            )),
          )),
    );
  }

  Widget productsHeader() {
    return Row(children: [
      blackSarabunBold(
          '${selectedCategory == 'VIEW ALL' ? 'ALL AVAILABLE PRODUCTS' : '$selectedCategory PRODUCTS'}',
          fontSize: 20)
    ]);
  }

  Widget _productCategoryWidget() {
    return vertical20Pix(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: dropdownWidget(selectedCategory, (newVal) {
          setState(() {
            selectedCategory = newVal!;
            print(selectedCategory);
            if (selectedCategory == 'VIEW ALL') {
              filteredProductDocs = allProductDocs;
            } else {
              filteredProductDocs = allProductDocs.where((productDoc) {
                final productData = productDoc.data() as Map<dynamic, dynamic>;
                return productData[ProductFields.category] == selectedCategory;
              }).toList();
              print('products found: ${filteredProductDocs.length}');
            }
          });
        }, [
          'VIEW ALL',
          ProductCategories.wheel,
          ProductCategories.battery,
          ProductCategories.accessory,
          ProductCategories.others
        ], selectedCategory.isNotEmpty ? selectedCategory : 'Select a category',
            false),
      ),
    );
  }

  Widget _availableProducts() {
    return Column(
      children: [
        filteredProductDocs.isNotEmpty
            ? Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 10,
                runSpacing: 10,
                children: filteredProductDocs.asMap().entries.map((item) {
                  DocumentSnapshot thisProduct = allProductDocs[item.key];
                  return itemEntry(context,
                      itemDoc: thisProduct,
                      onPress: () => NavigatorRoutes.selectedProduct(
                          context, ref,
                          productID: thisProduct.id));
                }).toList())
            : blackSarabunBold('NO PRODUCTS AVAILABLE', fontSize: 16),
      ],
    );
  }
}
