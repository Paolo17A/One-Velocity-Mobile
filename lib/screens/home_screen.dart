import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_velocity_mobile/widgets/custom_button_widgets.dart';
import 'package:one_velocity_mobile/widgets/text_widgets.dart';

import '../providers/loading_provider.dart';
import '../providers/profile_image_url_provider.dart';
import '../providers/user_data_provider.dart';
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
  List<String> randomImages = [
    ImagePaths.spanish,
    ImagePaths.maintenance,
    ImagePaths.sale
  ];

  CarouselSliderController carouselSliderController =
      CarouselSliderController();

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
      serviceDocs.where((serviceDoc) {
        final serviceData = serviceDoc.data() as Map<dynamic, dynamic>;
        return serviceData[ServiceFields.category] ==
            ServiceCategories.paintJob;
      }).toList();
      if (hasLoggedInUser()) {
        final user = await getCurrentUserDoc();
        final userData = user.data() as Map<dynamic, dynamic>;
        ref
            .read(profileImageURLProvider)
            .setImageURL(userData[UserFields.profileImageURL]);
        ref.read(userDataProvider).setName(
            '${userData[UserFields.firstName]} ${userData[UserFields.lastName]}');
        ref.read(userDataProvider).setEmail(userData[UserFields.email]);
      }
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
                  _randomImagesCarousel(),
                  if (wheelProductDocs.isNotEmpty) _wheelProducts(),
                  if (batteryProductDocs.isNotEmpty) _batteryProducts(),
                  //_topProducts(),
                  //const Divider(color: CustomColors.blackBeauty),
                  _topServices(),
                ],
              ))),
        ),
      ),
    );
  }

  Widget _randomImagesCarousel() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: 300,
      child: CarouselSlider.builder(
        carouselController: carouselSliderController,
        itemCount: randomImages.length,
        disableGesture: false,
        options:
            CarouselOptions(viewportFraction: 0.6, enlargeCenterPage: true),
        itemBuilder: (context, index, realIndex) {
          return Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                    image: AssetImage(randomImages[index]), fit: BoxFit.fill)),
          );
        },
      ),
    );
  }

  Widget _wheelProducts() {
    wheelProductDocs.shuffle();
    return slidingProductsTemplate(context, ref,
        label: 'NEED WHEELS?', itemDocs: wheelProductDocs);
  }

  Widget _batteryProducts() {
    batteryProductDocs.shuffle();
    return slidingProductsTemplate(context, ref,
        label: 'NEED BATTERIES?', itemDocs: batteryProductDocs);
  }

  Widget _topServices() {
    serviceDocs.shuffle();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        all10Pix(child: blackSarabunBold('WANT A PAINT JOB?', fontSize: 25)),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 280,
          padding: EdgeInsets.symmetric(vertical: 10),
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
                              child: curvedItemEntry(context,
                                  itemDoc: item,
                                  onPress: () =>
                                      NavigatorRoutes.selectedService(context,
                                          serviceID: item.id)),
                            ))
                        .toList()
                    : [blackSarabunBold('NO AVAILABLE SERVICES TO DISPLAY')]),
          ),
        ),
      ],
    );
  }
}
