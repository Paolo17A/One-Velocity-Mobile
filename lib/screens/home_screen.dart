import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/widgets/custom_button_widgets.dart';
import 'package:one_velocity_mobile/widgets/text_widgets.dart';

import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
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

  CarouselSliderController wheelsController = CarouselSliderController();
  CarouselSliderController batteryController = CarouselSliderController();
  CarouselSliderController allProductsController = CarouselSliderController();
  CarouselSliderController allServicesController = CarouselSliderController();

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
        appBar: topAppBar(),
        body: Scaffold(
          appBar: appBarWidget(
              actions: hasLoggedInUser()
                  ? [popUpMenu(context, currentPath: NavigatorRoutes.home)]
                  : [loginButton(context)]),
          drawer: appDrawer(context, ref, route: NavigatorRoutes.home),
          body: switchedLoadingContainer(
              ref.read(loadingProvider).isLoading,
              SingleChildScrollView(
                  child: Column(
                children: [
                  if (wheelProductDocs.isNotEmpty) _wheelProducts(),
                  if (batteryProductDocs.isNotEmpty) _batteryProducts(),
                  _topProducts(),
                  const Divider(color: CustomColors.blackBeauty),
                  _topServices()
                ],
              ))),
        ),
      ),
    );
  }

  Widget _wheelProducts() {
    wheelProductDocs.shuffle();
    return itemCarouselTemplate(context, ref,
        label: 'WHEELS',
        carouselSliderController: wheelsController,
        itemDocs: wheelProductDocs);
  }

  Widget _batteryProducts() {
    batteryProductDocs.shuffle();
    return itemCarouselTemplate(context, ref,
        label: 'BATTERIES',
        carouselSliderController: batteryController,
        itemDocs: batteryProductDocs);
  }

  Widget _topProducts() {
    productDocs.shuffle();
    return itemCarouselTemplate(context, ref,
        label: 'TOP PRODUCTS',
        carouselSliderController: allProductsController,
        itemDocs: productDocs);
  }

  Widget _topServices() {
    serviceDocs.shuffle();
    return Column(
      children: [
        all20Pix(child: blackSarabunBold('TOP SERVICES', fontSize: 25)),
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
                    : [blackSarabunBold('NO AVAILABLE SERVICES TO DISPLAY')]),
          ),
        ),
        const Gap(10),
      ],
    );
  }
}
