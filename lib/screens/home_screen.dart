import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/widgets/text_widgets.dart';

import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);

      productDocs = await getAllProducts();

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
                  _topProducts(),
                  const Divider(color: CustomColors.blackBeauty),
                ],
              )),
            )),
      ),
    );
  }

  Widget _topProducts() {
    productDocs.shuffle();
    return Column(
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
                                      onPress: () {},
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
}
