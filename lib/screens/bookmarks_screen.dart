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
import '../widgets/text_widgets.dart';

class BookMarksScreen extends ConsumerStatefulWidget {
  const BookMarksScreen({super.key});

  @override
  ConsumerState<BookMarksScreen> createState() => _BookMarksScreenState();
}

class _BookMarksScreenState extends ConsumerState<BookMarksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider.notifier).toggleLoading(true);

        final userDoc = await getCurrentUserDoc();
        final userData = userDoc.data() as Map<dynamic, dynamic>;

        ref.read(bookmarksProvider).bookmarkedProducts =
            userData[UserFields.bookmarkedProducts];
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
    return Scaffold(
      appBar: appBarWidget(),
      drawer: appDrawer(context, route: NavigatorRoutes.bookmarks),
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading, bookmarksContainer()),
    );
  }

  Widget bookmarksContainer() {
    return SingleChildScrollView(
      child: all20Pix(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          blackSarabunBold('BOOKMARKED PRODUCTS', fontSize: 30),
          Divider(color: CustomColors.blackBeauty),
          if (ref.read(bookmarksProvider).bookmarkedProducts.isNotEmpty)
            ListView.builder(
                shrinkWrap: true,
                itemCount:
                    ref.read(bookmarksProvider).bookmarkedProducts.length,
                itemBuilder: (context, index) {
                  return _bookmarkedProductEntry(
                      ref.read(bookmarksProvider).bookmarkedProducts[index]);
                })
          else
            vertical20Pix(
                child: blackSarabunBold('YOU HAVE NO BOOKMARKED ITEMS',
                    fontSize: 24))
        ],
      )),
    );
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
            onTap: () {},
            child: all10Pix(
                child: Container(
                    decoration: BoxDecoration(color: CustomColors.ultimateGray),
                    padding: EdgeInsets.all(10),
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
                                whiteSarabunBold(name, fontSize: 16),
                                whiteSarabunRegular(
                                    'SRP: ${price.toStringAsFixed(2)}',
                                    fontSize: 14)
                              ],
                            )
                          ],
                        ),
                        IconButton(
                            onPressed: () => displayDeleteEntryDialog(context,
                                message:
                                    'Are you sure you wish to remove this product from your bookmarks?',
                                deleteEntry: () => removeBookmarkedProduct(
                                    context, ref, productID: productID)),
                            icon: Icon(Icons.delete,
                                color: Colors.white, size: 20))
                      ],
                    ))),
          );
        });
  }
}
