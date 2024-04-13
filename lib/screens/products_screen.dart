import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_velocity_mobile/widgets/text_widgets.dart';

import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_bottom_navbar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/item_entry_widget.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  List<DocumentSnapshot> allProductDocs = [];

  @override
  void initState() {
    super.initState();
    print('product');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        allProductDocs = await getAllProducts();

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [productsHeader(), _availableProducts()],
            )),
          )),
    );
  }

  Widget productsHeader() {
    return Row(children: [
      montserratBlackBold('ALL AVAILABLE PRODUCTS', fontSize: 24)
    ]);
  }

  Widget _availableProducts() {
    return Column(
      children: [
        allProductDocs.isNotEmpty
            ? Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 10,
                runSpacing: 10,
                children: allProductDocs.asMap().entries.map((item) {
                  DocumentSnapshot thisProduct = allProductDocs[item.key];
                  //allProductDocs[item.key + ((currentPage - 1) * 20)];
                  return itemEntry(context,
                      itemDoc: thisProduct,
                      onPress: () => NavigatorRoutes.selectedProduct(
                          context, ref,
                          productID: thisProduct.id));
                }).toList())
            : montserratBlackBold('NO PRODUCTS AVAILABLE', fontSize: 44),
      ],
    );
  }
}
