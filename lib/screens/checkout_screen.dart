import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String imageURL = '';
  String name = '';
  num totalAmount = 0;
  num quantity = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        ref.read(loadingProvider).toggleLoading(true);
        DocumentSnapshot? cartDoc = ref.read(cartProvider).getSelectedCartDoc();
        final cartData = cartDoc!.data() as Map<dynamic, dynamic>;
        quantity = cartData[CartFields.quantity];
        print('QUANTITY: $quantity');
        totalAmount = quantity * ref.read(cartProvider).selectedCartItemSRP;

        //  Get product details
        final product = await getThisProductDoc(cartData[CartFields.productID]);
        final productData = product.data() as Map<dynamic, dynamic>;
        List<dynamic> imageURLs = productData[ProductFields.imageURLs];
        imageURL = imageURLs.first;
        name = productData[ProductFields.name];
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
                    if (imageURL.isNotEmpty)
                      Image.network(
                        imageURL,
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.width * 0.6,
                        fit: BoxFit.fitWidth,
                      ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            montserratBlackBold(name, fontSize: 24),
                            montserratBlackRegular(
                                'SRP: PHP ${ref.read(cartProvider).selectedCartItemSRP.toStringAsFixed(2)}',
                                fontSize: 16),
                            montserratBlackRegular('Quantity: $quantity',
                                fontSize: 16),
                            montserratBlackRegular(
                                'Total: PHP ${totalAmount.toStringAsFixed(2)}')
                          ],
                        ),
                      ],
                    ),
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
              : () => purchaseSelectedCartItem(context, ref),
          style: ElevatedButton.styleFrom(
              disabledBackgroundColor: CustomColors.ultimateGray),
          child: montserratWhiteBold('MAKE PAYMENT')),
    );
  }
}
