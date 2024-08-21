import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/providers/loading_provider.dart';
import 'package:one_velocity_mobile/utils/navigator_util.dart';
import 'package:one_velocity_mobile/widgets/app_bar_widget.dart';
import 'package:one_velocity_mobile/widgets/app_drawer_widget.dart';
import 'package:one_velocity_mobile/widgets/custom_miscellaneous_widgets.dart';
import 'package:one_velocity_mobile/widgets/custom_padding_widgets.dart';

import '../providers/bookmarks_provider.dart';
import '../utils/color_util.dart';
import '../utils/delete_entry_dialog_util.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/text_widgets.dart';

class BookMarksScreen extends ConsumerStatefulWidget {
  const BookMarksScreen({super.key});

  @override
  ConsumerState<BookMarksScreen> createState() => _BookMarksScreenState();
}

class _BookMarksScreenState extends ConsumerState<BookMarksScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider.notifier).toggleLoading(true);

        final userDoc = await getCurrentUserDoc();
        final userData = userDoc.data() as Map<dynamic, dynamic>;

        ref.read(bookmarksProvider).bookmarkedProducts =
            userData[UserFields.bookmarkedProducts];
        ref.read(bookmarksProvider).bookmarkedServices =
            userData[UserFields.bookmarkedServices];
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting user profile: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(bookmarksProvider);
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: topAppBar(),
        body: Scaffold(
          appBar: appBarWidget(
              actions: hasLoggedInUser()
                  ? [popUpMenu(context, currentPath: NavigatorRoutes.bookmarks)]
                  : [loginButton(context)]),
          drawer: appDrawer(context, ref, route: NavigatorRoutes.bookmarks),
          body: switchedLoadingContainer(
              ref.read(loadingProvider).isLoading,
              Column(
                children: [
                  TabBar(tabs: [
                    Tab(child: blackSarabunBold('PRODUCTS')),
                    Tab(child: blackSarabunBold('SERVICES'))
                  ]),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height - 220,
                    child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          bookmarkedProductsContainer(),
                          bookmarkedServicesContainer()
                        ]),
                  )
                ],
              )),
        ),
      ),
    );
  }

  Widget bookmarkedProductsContainer() {
    return SingleChildScrollView(
        child: (ref.read(bookmarksProvider).bookmarkedProducts.isNotEmpty)
            ? ListView.builder(
                shrinkWrap: true,
                itemCount:
                    ref.read(bookmarksProvider).bookmarkedProducts.length,
                itemBuilder: (context, index) {
                  return _bookmarkedProductEntry(
                      ref.read(bookmarksProvider).bookmarkedProducts[index]);
                })
            : vertical20Pix(
                child: blackSarabunBold('YOU HAVE NO BOOKMARKED ITEMS',
                    fontSize: 24)));
  }

  Widget _bookmarkedProductEntry(String productID) {
    return FutureBuilder(
        future: getThisProductDoc(productID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData ||
              snapshot.hasError) return snapshotHandler(snapshot);
          final productData = snapshot.data!.data() as Map<dynamic, dynamic>;
          String name = productData[ProductFields.name];
          List<dynamic> imageURLs = productData[ProductFields.imageURLs];
          num price = productData[ProductFields.price];

          return GestureDetector(
            onTap: () => NavigatorRoutes.selectedProduct(context, ref,
                productID: productID),
            child: all10Pix(
                child: Container(
                    decoration: BoxDecoration(
                        color: CustomColors.angelic,
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(4, 2),
                              blurRadius: 8,
                              spreadRadius: -4)
                        ],
                        borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                                backgroundImage: NetworkImage(imageURLs[0]),
                                backgroundColor: Colors.transparent,
                                radius: 30),
                            Gap(20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                blackSarabunBold(name, fontSize: 16),
                                blackSarabunRegular(
                                    'SRP: ${price.toStringAsFixed(2)}',
                                    fontSize: 14)
                              ],
                            )
                          ],
                        ),
                        ElevatedButton(
                            onPressed: () => displayDeleteEntryDialog(context,
                                message:
                                    'Are you sure you wish to remove this product from your bookmarks?',
                                deleteEntry: () => removeBookmarkedProduct(
                                    context, ref, productID: productID)),
                            child: Icon(Icons.delete,
                                color: Colors.white, size: 20))
                      ],
                    ))),
          );
        });
  }

  Widget bookmarkedServicesContainer() {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (ref.read(bookmarksProvider).bookmarkedServices.isNotEmpty)
            ? ListView.builder(
                shrinkWrap: true,
                itemCount:
                    ref.read(bookmarksProvider).bookmarkedServices.length,
                itemBuilder: (context, index) {
                  return _bookmarkedServiceEntry(
                      ref.read(bookmarksProvider).bookmarkedServices[index]);
                })
            : vertical20Pix(
                child: blackSarabunBold('YOU HAVE NO BOOKMARKED SERVICES',
                    fontSize: 24))
      ],
    ));
  }

  Widget _bookmarkedServiceEntry(String serviceID) {
    return FutureBuilder(
        future: getThisServiceDoc(serviceID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData ||
              snapshot.hasError) return snapshotHandler(snapshot);
          final serviceData = snapshot.data!.data() as Map<dynamic, dynamic>;
          String name = serviceData[ProductFields.name];
          List<dynamic> imageURLs = serviceData[ProductFields.imageURLs];
          num price = serviceData[ProductFields.price];

          return GestureDetector(
            onTap: () =>
                NavigatorRoutes.selectedService(context, serviceID: serviceID),
            child: all10Pix(
                child: Container(
                    decoration: BoxDecoration(
                        color: CustomColors.angelic,
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(4, 2),
                              blurRadius: 8,
                              spreadRadius: -4)
                        ],
                        borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                                backgroundImage: NetworkImage(imageURLs[0]),
                                backgroundColor: Colors.transparent,
                                radius: 30),
                            Gap(20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                blackSarabunBold(name, fontSize: 16),
                                blackSarabunRegular(
                                    'SRP: ${price.toStringAsFixed(2)}',
                                    fontSize: 14)
                              ],
                            )
                          ],
                        ),
                        ElevatedButton(
                            onPressed: () => displayDeleteEntryDialog(context,
                                message:
                                    'Are you sure you wish to remove this service from your bookmarks?',
                                deleteEntry: () => removeBookmarkedService(
                                    context, ref, serviceID: serviceID)),
                            child: Icon(Icons.delete,
                                color: Colors.white, size: 20))
                      ],
                    ))),
          );
        });
  }
}
