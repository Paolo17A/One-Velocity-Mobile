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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(cartProvider).setCartItems(await getCartEntries(context));
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
      onPopInvoked: (didPop) =>
          ref.read(cartProvider).setSelectedCartItem('', 0, 0),
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
    DocumentSnapshot? selectedCartDoc =
        ref.read(cartProvider).getSelectedCartDoc();
    num totalAmount = 0;
    if (selectedCartDoc != null) {
      final cartData = selectedCartDoc.data() as Map<dynamic, dynamic>;
      totalAmount = cartData[CartFields.quantity] *
          ref.read(cartProvider).selectedCartItemSRP;
    }
    return BottomAppBar(
      color: CustomColors.blackBeauty,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              flex: 2,
              child: montserratWhiteBold(
                  'Total: PHP ${totalAmount.toStringAsFixed(2)}')),
          Flexible(
              //flex: 2,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: CustomColors.ultimateGray),
                  onPressed: ref.read(cartProvider).selectedCartItem.isEmpty
                      ? null
                      : () => Navigator.of(context)
                          .pushNamed(NavigatorRoutes.checkout),
                  child: montserratWhiteRegular('CHECKOUT', fontSize: 10)))
        ],
      ),
    );
  }

  Widget _cartEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        montserratBlackBold('CART ITEMS', fontSize: 40),
        ref.read(cartProvider).cartItems.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: ref.read(cartProvider).cartItems.length,
                itemBuilder: (context, index) {
                  return _cartEntry(ref.read(cartProvider).cartItems[index]);
                })
            : montserratBlackBold('YOU DO NOT HAVE ANY ITEMS IN YOUR CART')
      ],
    );
  }

  Widget _cartEntry(DocumentSnapshot cartDoc) {
    final cartData = cartDoc.data() as Map<dynamic, dynamic>;
    int quantity = cartData[CartFields.quantity];
    return FutureBuilder(
        future: getThisProductDoc(cartData[CartFields.productID]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData ||
              snapshot.hasError) return snapshotHandler(snapshot);
          final productData = snapshot.data!.data() as Map<dynamic, dynamic>;
          String name = productData[ProductFields.name];
          List<dynamic> imageURLs = productData[ProductFields.imageURLs];
          num price = productData[ProductFields.price];
          num remainingQuantity = productData[ProductFields.quantity];

          return vertical10Pix(
              child: Container(
                  decoration: BoxDecoration(color: CustomColors.ultimateGray),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio<String>(
                          value: cartDoc.id,
                          groupValue: ref.read(cartProvider).selectedCartItem,
                          onChanged: (_) {
                            ref.read(cartProvider).setSelectedCartItem(
                                cartDoc.id, price, quantity);
                          }),
                      GestureDetector(
                        onTap: () => NavigatorRoutes.selectedProduct(
                            context, ref,
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
                                        deleteEntry: () => removeCartItem(
                                            context, ref,
                                            cartDoc: cartDoc)),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                            Gap(20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                montserratWhiteBold(name,
                                    fontSize: 16,
                                    textOverflow: TextOverflow.ellipsis),
                                montserratWhiteBold(
                                    'SRP: ${price.toStringAsFixed(2)}',
                                    fontSize: 14),
                                montserratWhiteRegular(
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
                                                  color: CustomColors
                                                      .nimbusCloud)),
                                          child: montserratWhiteBold('-')),
                                    ),
                                    Container(
                                        width: 50,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                    CustomColors.nimbusCloud)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          child: montserratWhiteBold(
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
                                                  color: CustomColors
                                                      .nimbusCloud)),
                                          child: montserratWhiteBold('+')),
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
        });
  }
}
