import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_velocity_mobile/utils/color_util.dart';

import '../providers/bookmarks_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/text_widgets.dart';

class SelectedProductScreen extends ConsumerStatefulWidget {
  final String productID;
  const SelectedProductScreen({super.key, required this.productID});

  @override
  ConsumerState<SelectedProductScreen> createState() =>
      _SelectedProductScreenState();
}

class _SelectedProductScreenState extends ConsumerState<SelectedProductScreen> {
  //  PRODUCT VARIABLES
  String name = '';
  String description = '';
  String category = '';
  num price = 0;
  num quantity = 0;
  List<dynamic> imageURLs = [];
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        //  GET PRODUCT DATA
        final product = await getThisProductDoc(widget.productID);
        final productData = product.data() as Map<dynamic, dynamic>;
        name = productData[ProductFields.name];
        description = productData[ProductFields.description];
        category = productData[ProductFields.category];
        quantity = productData[ProductFields.quantity];
        price = productData[ProductFields.price];
        imageURLs = productData[ProductFields.imageURLs];

        //  GET USER DATA
        if (hasLoggedInUser()) {
          final user = await getCurrentUserDoc();
          final userData = user.data() as Map<dynamic, dynamic>;
          ref
              .read(bookmarksProvider)
              .setBookmarkedProducts(userData[UserFields.bookmarkedProducts]);

          ref
              .read(cartProvider)
              .setCartItems(await getProductCartEntries(context));
        }

        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting selected product: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(bookmarksProvider);
    ref.watch(cartProvider);
    return Scaffold(
      appBar: topAppBar(),
      body: Scaffold(
        appBar: appBarWidget(),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: all20Pix(child: _productContainer()),
            )),
      ),
    );
  }

  Widget _productContainer() {
    return Column(
      children: [
        if (imageURLs.isNotEmpty) _itemImagesDisplay(),
        blackSarabunBold(name, fontSize: 32),
        blackSarabunBold('PHP ${formatPrice(price.toDouble())}', fontSize: 20),
        blackSarabunRegular('Category: $category', fontSize: 16),
        Divider(color: CustomColors.blackBeauty),
        SizedBox(
          height: 40,
          child: ElevatedButton(
              onPressed: quantity > 0
                  ? () => addProductToCart(context, ref,
                      productID: widget.productID)
                  : null,
              style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  disabledBackgroundColor: Colors.blueGrey),
              child: whiteSarabunRegular('ADD TO CART',
                  textAlign: TextAlign.center)),
        ),
        vertical10Pix(
            child: blackSarabunBold('Remaining Quantity: $quantity',
                fontSize: 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () => ref
                        .read(bookmarksProvider)
                        .bookmarkedProducts
                        .contains(widget.productID)
                    ? removeBookmarkedProduct(context, ref,
                        productID: widget.productID)
                    : addBookmarkedProduct(context, ref,
                        productID: widget.productID),
                icon: Icon(ref
                        .read(bookmarksProvider)
                        .bookmarkedProducts
                        .contains(widget.productID)
                    ? Icons.bookmark
                    : Icons.bookmark_outline)),
            blackSarabunRegular(ref
                    .read(bookmarksProvider)
                    .bookmarkedProducts
                    .contains(widget.productID)
                ? 'Remove from Bookmarks'
                : 'Add to Bookmarks')
          ],
        ),
        Divider(color: CustomColors.blackBeauty),
        all20Pix(child: blackSarabunRegular(description)),
      ],
    );
  }

  Widget _itemImagesDisplay() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
          border: Border.all(),
          image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(imageURLs[currentImageIndex]))),
    );
  }
}
