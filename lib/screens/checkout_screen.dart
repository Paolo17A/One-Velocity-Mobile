import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/providers/cart_provider.dart';
import 'package:one_velocity_mobile/providers/loading_provider.dart';
import 'package:one_velocity_mobile/utils/color_util.dart';
import 'package:one_velocity_mobile/utils/firebase_util.dart';
import 'package:one_velocity_mobile/utils/string_util.dart';
import 'package:one_velocity_mobile/widgets/app_bar_widget.dart';
import 'package:one_velocity_mobile/widgets/custom_miscellaneous_widgets.dart';
import 'package:one_velocity_mobile/widgets/custom_padding_widgets.dart';
import 'package:one_velocity_mobile/widgets/text_widgets.dart';

import '../widgets/dropdown_widget.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  List<Map<dynamic, dynamic>> productEntries = [];
  num totalAmount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        ref.read(loadingProvider).toggleLoading(true);
        //  1. Get every associated cart DocumentSnapshot
        List<DocumentSnapshot> selectedCartDocs = [];
        for (var cartID in ref.read(cartProvider).selectedCartItemIDs) {
          selectedCartDocs.add(ref
              .read(cartProvider)
              .cartItems
              .where((element) => element.id == cartID)
              .first);
        }

        //  Get product details
        for (var cartDoc in selectedCartDocs) {
          final cartData = cartDoc.data() as Map<dynamic, dynamic>;
          final product =
              await getThisProductDoc(cartData[CartFields.productID]);
          final productData = product.data() as Map<dynamic, dynamic>;
          Map<dynamic, dynamic> productEntry = {
            ProductFields.imageURLs: productData[ProductFields.imageURLs],
            ProductFields.name: productData[ProductFields.name],
            ProductFields.price: productData[ProductFields.price],
            CartFields.quantity: cartData[CartFields.quantity]
          };
          productEntries.add(productEntry);
          totalAmount +=
              cartData[CartFields.quantity] * productData[ProductFields.price];
        }

        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error getting product checkout details: $error')));
        ref.read(loadingProvider).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(cartProvider);
    return PopScope(
      onPopInvoked: (didPop) =>
          ref.read(cartProvider).setSelectedPaymentMethod(''),
      child: Scaffold(
        appBar: appBarWidget(),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                  child: all20Pix(
                child: Column(
                  children: [
                    montserratBlackBold('PRODUCT CHECKOUT', fontSize: 28),
                    Column(
                        children: productEntries
                            .map((productEntry) => _productEntry(productEntry))
                            .toList()),
                    montserratBlackRegular(
                        'TOTAL: PHP ${formatPrice(totalAmount.toDouble())}'),
                    Divider(color: CustomColors.blackBeauty),
                    _paymentMethod(),
                    if (ref.read(cartProvider).selectedPaymentMethod.isNotEmpty)
                      _uploadPayment(),
                    _checkoutButton()
                  ],
                ),
              )),
            )),
      ),
    );
  }

  Widget _productEntry(Map<dynamic, dynamic> productEntry) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(4)),
          padding: EdgeInsets.all(4),
          child: Row(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((productEntry[ProductFields.imageURLs] as List<dynamic>)
                  .isNotEmpty)
                Image.network(productEntry[ProductFields.imageURLs].first,
                    width: 50, height: 50, fit: BoxFit.cover),
              Gap(4),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                montserratBlackBold(productEntry[ProductFields.name],
                    fontSize: 16, textOverflow: TextOverflow.ellipsis),
                montserratBlackRegular(
                    'Quanitity: ${productEntry[CartFields.quantity]}',
                    fontSize: 12,
                    textAlign: TextAlign.left),
                montserratBlackRegular(
                    'SRP: PHP ${formatPrice(productEntry[ProductFields.price].toDouble())}',
                    fontSize: 12,
                    textAlign: TextAlign.left),
              ]),
            ],
          )),
    );
  }

  Widget _paymentMethod() {
    return all10Pix(
        child: Column(
      children: [
        Row(
          children: [montserratBlackBold('PAYMENT METHOD')],
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: dropdownWidget(ref.read(cartProvider).selectedPaymentMethod,
              (newVal) {
            ref.read(cartProvider).setSelectedPaymentMethod(newVal!);
          }, ['GCASH', 'PAYMAYA'], 'Select your payment method', false),
        )
      ],
    ));
  }

  Widget _uploadPayment() {
    return all10Pix(
        child: Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                montserratBlackBold('SEND YOUR PAYMENT HERE'),
                if (ref.read(cartProvider).selectedPaymentMethod == 'GCASH')
                  montserratBlackBold('GCASH: +639221234567', fontSize: 14)
                else if (ref.read(cartProvider).selectedPaymentMethod ==
                    'PAYMAYA')
                  montserratBlackBold('PAYMAYA: +639221234567', fontSize: 14)
              ],
            )
          ],
        ),
      ],
    ));
  }

  Widget _checkoutButton() {
    return Container(
      height: 60,
      child: ElevatedButton(
          onPressed: ref.read(cartProvider).selectedPaymentMethod.isEmpty
              ? null
              : () => purchaseSelectedCartItems(context, ref,
                  paidAmount: totalAmount),
          style: ElevatedButton.styleFrom(
              disabledBackgroundColor: CustomColors.ultimateGray),
          child: montserratWhiteBold('MAKE PAYMENT')),
    );
  }
}
