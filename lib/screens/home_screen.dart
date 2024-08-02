import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/widgets/text_widgets.dart';

import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_bottom_navbar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/item_entry_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<DocumentSnapshot> productDocs = [];
  List<DocumentSnapshot> wheelProductDocs = [];
  List<DocumentSnapshot> batteryProductDocs = [];
  List<DocumentSnapshot> serviceDocs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);

      productDocs = await getAllProducts();
      wheelProductDocs = productDocs.where((productDoc) {
        final productData = productDoc.data() as Map<dynamic, dynamic>;
        return productData[ProductFields.category] == ProductCategories.wheel;
      }).toList();
      batteryProductDocs = productDocs.where((productDoc) {
        final productData = productDoc.data() as Map<dynamic, dynamic>;
        return productData[ProductFields.category] == ProductCategories.battery;
      }).toList();
      serviceDocs = await getAllServices();

      ref.read(loadingProvider.notifier).toggleLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: appBarWidget(),
        drawer: appDrawer(context, route: NavigatorRoutes.home),
        bottomNavigationBar: bottomNavigationBar(context, index: 0),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  if (wheelProductDocs.isNotEmpty) _wheelProducts(),
                  if (batteryProductDocs.isNotEmpty) _batteryProducts(),
                  _topProducts(),
                  const Divider(color: CustomColors.blackBeauty),
                  _topServices()
                ],
              )),
            )),
      ),
    );
  }

  Widget _wheelProducts() {
    wheelProductDocs.shuffle();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        montserratBlackBold('WHEELS', fontSize: 25),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: wheelProductDocs.isNotEmpty
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: wheelProductDocs
                    .take(6)
                    .toList()
                    .map((item) => Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: itemEntry(context,
                                  itemDoc: item,
                                  onPress: () =>
                                      NavigatorRoutes.selectedProduct(
                                          context, ref,
                                          productID: item.id),
                                  fontColor: Colors.white),
                            ),
                          ],
                        ))
                    .toList()),
          ),
        ),
        const Gap(10),
      ],
    );
  }

  Widget _batteryProducts() {
    batteryProductDocs.shuffle();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        montserratBlackBold('BATTERIES', fontSize: 25),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: batteryProductDocs.isNotEmpty
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: batteryProductDocs
                    .take(6)
                    .toList()
                    .map((item) => Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: itemEntry(context,
                                  itemDoc: item,
                                  onPress: () =>
                                      NavigatorRoutes.selectedProduct(
                                          context, ref,
                                          productID: item.id),
                                  fontColor: Colors.white),
                            ),
                          ],
                        ))
                    .toList()),
          ),
        ),
        const Gap(10),
      ],
    );
  }

  Widget _topProducts() {
    productDocs.shuffle();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        all20Pix(child: montserratBlackBold('TOP PRODUCTS', fontSize: 25)),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: productDocs.isNotEmpty
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: productDocs.isNotEmpty
                    ? productDocs
                        .take(6)
                        .toList()
                        .map((item) => Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: itemEntry(context,
                                      itemDoc: item,
                                      onPress: () =>
                                          NavigatorRoutes.selectedProduct(
                                              context, ref,
                                              productID: item.id),
                                      fontColor: Colors.white),
                                ),
                              ],
                            ))
                        .toList()
                    : [
                        Center(
                            child: montserratBlackBold(
                                'NO AVAILABLE PRODUCTS TO DISPLAY'))
                      ]),
          ),
        ),
        const Gap(10),
      ],
    );
  }

  Widget _topServices() {
    serviceDocs.shuffle();
    return Column(
      children: [
        all20Pix(child: montserratBlackBold('TOP SERVICES', fontSize: 25)),
        Container(
          width: MediaQuery.of(context).size.width,
          //color: Colors.blue,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: serviceDocs.isNotEmpty
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: serviceDocs.isNotEmpty
                    ? serviceDocs
                        .take(6)
                        .toList()
                        .map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: itemEntry(context,
                                  itemDoc: item,
                                  onPress: () =>
                                      NavigatorRoutes.selectedService(context,
                                          serviceID: item.id),
                                  fontColor: Colors.white),
                            ))
                        .toList()
                    : [
                        montserratBlackBold('NO AVAILABLE SERVICES TO DISPLAY')
                      ]),
          ),
        ),
        const Gap(10),
      ],
    );
  }
}
