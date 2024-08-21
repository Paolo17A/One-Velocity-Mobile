import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
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
import '../widgets/custom_button_widgets.dart';
import '../widgets/text_widgets.dart';

class ServiceCartScreen extends ConsumerStatefulWidget {
  const ServiceCartScreen({super.key});

  @override
  ConsumerState<ServiceCartScreen> createState() => _ServiceCartScreenState();
}

class _ServiceCartScreenState extends ConsumerState<ServiceCartScreen> {
  List<DocumentSnapshot> associatedServiceDocs = [];
  num paidAmount = 0;
  DateTime? proposedDateTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref
            .read(cartProvider)
            .setCartItems(await getServiceCartEntries(context));
        associatedServiceDocs = await getSelectedServiceDocs(
            ref.read(cartProvider).cartItems.map((cartDoc) {
          final cartData = cartDoc.data() as Map<dynamic, dynamic>;
          return cartData[CartFields.itemID].toString();
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
        appBar: appBarWidget(
            actions: hasLoggedInUser()
                ? [popUpMenu(context, currentPath: NavigatorRoutes.serviceCart)]
                : [loginButton(context)]),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_timeSelector(), _checkoutBar()],
        ),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: all20Pix(child: _cartEntries()),
            )),
      ),
    );
  }

  Widget _timeSelector() {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: CustomColors.nimbusCloud)),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          blackSarabunBold('Drop-off Date', fontSize: 24),
          ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                    barrierDismissible: false,
                    context: context,
                    firstDate: DateTime.now().add(Duration(days: 1)),
                    lastDate: DateTime.now().add(Duration(days: 14)));
                if (pickedDate == null) return null;
                setState(() {
                  proposedDateTime = pickedDate;
                });
              },
              child: whiteSarabunBold(proposedDateTime != null
                  ? DateFormat('MMM dd, yyyy').format(proposedDateTime!)
                  : 'Select date')),
        ],
      ),
    );
  }

  Widget _checkoutBar() {
    return BottomAppBar(
      color: CustomColors.blackBeauty,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(flex: 2, child: _totalAmountFutureBuilder()),
          Flexible(
              //flex: 2,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: CustomColors.ultimateGray),
                  onPressed: ref.read(cartProvider).selectedCartItemIDs.isEmpty
                      ? null
                      : () => Navigator.of(context)
                          .pushNamed(NavigatorRoutes.checkout),
                  child: whiteSarabunRegular('REQUEST', fontSize: 10)))
        ],
      ),
    );
  }

  Widget _totalAmountFutureBuilder() {
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
      String itemID = cartData[CartFields.itemID];
      DocumentSnapshot? serviceDoc =
          associatedServiceDocs.where((item) => item.id == itemID).firstOrNull;
      if (serviceDoc == null) {
        continue;
      }
      final serviceData = serviceDoc.data() as Map<dynamic, dynamic>;
      num price = serviceData[ProductFields.price];
      totalAmount += price;
    }
    totalAmount = totalAmount;
    return whiteSarabunBold(
        'TOTAL AMOUNT: PHP ${formatPrice(totalAmount.toDouble())}');
  }

  Widget _cartEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        blackSarabunBold('REQUESTED SERVICES', fontSize: 32),
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
    DocumentSnapshot? associatedServiceDoc =
        associatedServiceDocs.where((productDoc) {
      return productDoc.id == cartData[CartFields.itemID].toString();
    }).firstOrNull;
    if (associatedServiceDoc == null)
      return Container();
    else {
      String name = associatedServiceDoc[ServiceFields.name];
      List<dynamic> imageURLs = associatedServiceDoc[ServiceFields.imageURLs];
      num price = associatedServiceDoc[ServiceFields.price];
      return vertical10Pix(
          child: Container(
              decoration: BoxDecoration(color: CustomColors.ultimateGray),
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                                ref
                                    .read(cartProvider)
                                    .selectCartItem(cartDoc.id);
                              } else {
                                ref
                                    .read(cartProvider)
                                    .deselectCartItem(cartDoc.id);
                              }
                            });
                          }),
                      GestureDetector(
                        onTap: () => NavigatorRoutes.selectedProduct(
                            context, ref,
                            productID: cartData[CartFields.itemID]),
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
                              ],
                            ),
                            Gap(20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                whiteSarabunBold(name,
                                    fontSize: 16,
                                    textOverflow: TextOverflow.ellipsis),
                                whiteSarabunBold(
                                    'PHP ${formatPrice(price.toDouble())}',
                                    fontSize: 14),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () => displayDeleteEntryDialog(context,
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
                            removeCartItem(context, ref, cartDoc: cartDoc);
                          }),
                      child: Icon(Icons.delete, color: Colors.white))
                ],
              )));
    }
  }
}
