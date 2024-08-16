import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/providers/cart_provider.dart';
import 'package:one_velocity_mobile/providers/loading_provider.dart';
import 'package:one_velocity_mobile/utils/navigator_util.dart';
import 'package:one_velocity_mobile/widgets/app_bar_widget.dart';
import 'package:one_velocity_mobile/widgets/custom_miscellaneous_widgets.dart';
import 'package:one_velocity_mobile/widgets/custom_padding_widgets.dart';

import '../utils/color_util.dart';
import '../utils/delete_entry_dialog_util.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/text_widgets.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  List<DocumentSnapshot> associatedProductDocs = [];
  num paidAmount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(cartProvider).setCartItems(await getCartEntries(context));
        associatedProductDocs = await getSelectedProductDocs(
            ref.read(cartProvider).cartItems.map((cartDoc) {
          final cartData = cartDoc.data() as Map<dynamic, dynamic>;
          return cartData[CartFields.productID].toString();
        }).toList());
        setState(() {});
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting cart entries: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(cartProvider);
    return PopScope(
      onPopInvoked: (didPop) => ref.read(cartProvider).resetSelectedCartItems(),
      child: Scaffold(
        appBar: appBarWidget(),
        bottomNavigationBar: _checkoutBar(),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: all20Pix(child: _cartEntries()),
            )),
      ),
    );
  }

  Widget _checkoutBar() {
    return BottomAppBar(
      color: CustomColors.blackBeauty,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(flex: 2, child: _totalAmountWidget()),
          Flexible(
              //flex: 2,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: CustomColors.ultimateGray),
                  onPressed: ref.read(cartProvider).selectedCartItemIDs.isEmpty
                      ? null
                      : () => Navigator.of(context)
                          .pushNamed(NavigatorRoutes.checkout),
                  child: whiteSarabunRegular('CHECKOUT', fontSize: 10)))
        ],
      ),
    );
  }

  Widget _totalAmountWidget() {
    //  1. Get every associated cart DocumentSnapshot
    List<DocumentSnapshot> selectedCartDocs = [];
    for (var cartID in ref.read(cartProvider).selectedCartItemIDs) {
      selectedCartDocs.add(ref
          .read(cartProvider)
          .cartItems
          .where((element) => element.id == cartID)
          .first);
    }
    //  2. get list of associated products
    num totalAmount = 0;
    //  Go through every selected cart item
    for (var cartDoc in selectedCartDocs) {
      final cartData = cartDoc.data() as Map<dynamic, dynamic>;
      String productID = cartData[CartFields.productID];
      num quantity = cartData[CartFields.quantity];
      DocumentSnapshot? productDoc = associatedProductDocs
          .where((item) => item.id == productID)
          .firstOrNull;
      if (productDoc == null) {
        continue;
      }
      final productData = productDoc.data() as Map<dynamic, dynamic>;
      num price = productData[ProductFields.price];
      totalAmount += quantity * price;
    }
    paidAmount = totalAmount;
    return whiteSarabunBold(
        'TOTAL AMOUNT:\nPHP ${formatPrice(totalAmount.toDouble())}',
        textAlign: TextAlign.left);
  }

  Widget _cartEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        blackSarabunBold('CART ITEMS', fontSize: 40),
        ref.read(cartProvider).cartItems.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: ref.read(cartProvider).cartItems.length,
                itemBuilder: (context, index) {
                  return _cartEntry(ref.read(cartProvider).cartItems[index]);
                })
            : blackSarabunBold('YOU DO NOT HAVE ANY ITEMS IN YOUR CART')
      ],
    );
  }

  Widget _cartEntry(DocumentSnapshot cartDoc) {
    final cartData = cartDoc.data() as Map<dynamic, dynamic>;
    int quantity = cartData[CartFields.quantity];
    DocumentSnapshot? associatedProductDoc =
        associatedProductDocs.where((productDoc) {
      return productDoc.id == cartData[CartFields.productID].toString();
    }).firstOrNull;
    if (associatedProductDoc == null)
      return Container();
    else {
      String name = associatedProductDoc[ProductFields.name];
      List<dynamic> imageURLs = associatedProductDoc[ProductFields.imageURLs];
      num price = associatedProductDoc[ProductFields.price];
      num remainingQuantity = associatedProductDoc[ProductFields.quantity];
      return vertical10Pix(
          child: Container(
              decoration: BoxDecoration(color: CustomColors.ultimateGray),
              padding: EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                      value: ref
                          .read(cartProvider)
                          .selectedCartItemIDs
                          .contains(cartDoc.id),
                      onChanged: (newVal) {
                        if (newVal == null) return;
                        setState(() {
                          if (newVal) {
                            ref.read(cartProvider).selectCartItem(cartDoc.id);
                          } else {
                            ref.read(cartProvider).deselectCartItem(cartDoc.id);
                          }
                        });
                      }),
                  GestureDetector(
                    onTap: () => NavigatorRoutes.selectedProduct(context, ref,
                        productID: cartData[CartFields.productID]),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                                backgroundImage: NetworkImage(imageURLs[0]),
                                backgroundColor: Colors.transparent,
                                radius: 30),
                            Gap(12),
                            ElevatedButton(
                                onPressed: () => displayDeleteEntryDialog(
                                        context,
                                        message:
                                            'Are you sure you wish to remove ${name} from your cart?',
                                        deleteEntry: () {
                                      if (ref
                                          .read(cartProvider)
                                          .selectedCartItemIDs
                                          .contains(cartDoc.id)) {
                                        ref
                                            .read(cartProvider)
                                            .deselectCartItem(cartDoc.id);
                                      }
                                      removeCartItem(context, ref,
                                          cartDoc: cartDoc);
                                    }),
                                child: Icon(Icons.delete, color: Colors.white))
                          ],
                        ),
                        Gap(20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            whiteSarabunBold(name,
                                fontSize: 16,
                                textOverflow: TextOverflow.ellipsis),
                            whiteSarabunBold('SRP: ${price.toStringAsFixed(2)}',
                                fontSize: 14),
                            whiteSarabunRegular(
                                'Remaining Quantity: $remainingQuantity',
                                fontSize: 14),
                            Gap(20),
                            Row(
                              children: [
                                InkWell(
                                  onTap: quantity == 1
                                      ? null
                                      : () => changeCartItemQuantity(
                                          context, ref,
                                          cartEntryDoc: cartDoc,
                                          isIncreasing: false),
                                  child: Container(
                                      width: 50,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: CustomColors.nimbusCloud)),
                                      child: whiteSarabunBold('-')),
                                ),
                                Container(
                                    width: 50,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: CustomColors.nimbusCloud)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: whiteSarabunBold(
                                          quantity.toString(),
                                          fontSize: 15),
                                    )),
                                InkWell(
                                  onTap: quantity == remainingQuantity
                                      ? null
                                      : () => changeCartItemQuantity(
                                          context, ref,
                                          cartEntryDoc: cartDoc,
                                          isIncreasing: true),
                                  child: Container(
                                      width: 50,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: CustomColors.nimbusCloud)),
                                      child: whiteSarabunBold('+')),
                                )
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )));
    }
  }
}
