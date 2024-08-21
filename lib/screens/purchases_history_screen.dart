import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/providers/loading_provider.dart';
import 'package:one_velocity_mobile/utils/navigator_util.dart';
import 'package:one_velocity_mobile/widgets/app_bar_widget.dart';
import 'package:one_velocity_mobile/widgets/custom_button_widgets.dart';
import 'package:one_velocity_mobile/widgets/custom_miscellaneous_widgets.dart';

import '../providers/purchases_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/text_widgets.dart';

class PurchasesHistoryScreen extends ConsumerStatefulWidget {
  const PurchasesHistoryScreen({super.key});

  @override
  ConsumerState<PurchasesHistoryScreen> createState() =>
      _PurchasesHistoryScreenState();
}

class _PurchasesHistoryScreenState
    extends ConsumerState<PurchasesHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        if (!hasLoggedInUser()) {
          navigator.pop();
          return;
        }
        ref
            .read(purchasesProvider)
            .setPurchaseDocs(await getClientPurchaseHistory());
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
    ref.watch(purchasesProvider);
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: topAppBar(),
      body: Scaffold(
        appBar: appBarWidget(
            actions: hasLoggedInUser()
                ? [popUpMenu(context, currentPath: NavigatorRoutes.purchases)]
                : [loginButton(context)]),
        drawer: appDrawer(context, ref, route: NavigatorRoutes.purchases),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading, purchaseHistory()),
      ),
    );
  }

  Widget purchaseHistory() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          whiteSarabunBold('PURCHASE HISTORY'),
          ref.read(purchasesProvider).purchaseDocs.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount:
                      ref.read(purchasesProvider).purchaseDocs.toList().length,
                  itemBuilder: (context, index) => _purchaseHistoryEntry(ref
                      .read(purchasesProvider)
                      .purchaseDocs
                      .reversed
                      .toList()[index]))
              : vertical20Pix(
                  child:
                      blackSarabunBold('YOU HAVE NOT MADE ANY PURCHASES YET.'))
        ],
      ),
    );
  }

  Widget _purchaseHistoryEntry(DocumentSnapshot purchaseDoc) {
    final purchaseData = purchaseDoc.data() as Map<dynamic, dynamic>;
    String status = purchaseData[PurchaseFields.purchaseStatus];
    String productID = purchaseData[PurchaseFields.productID];
    num quantity = purchaseData[PurchaseFields.quantity];
    String paymentID = purchaseData[PurchaseFields.paymentID];

    return FutureBuilder(
      future: getThisProductDoc(productID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData ||
            snapshot.hasError) return snapshotHandler(snapshot);

        final productData = snapshot.data!.data() as Map<dynamic, dynamic>;
        List<dynamic> imageURLs = productData[ProductFields.imageURLs];
        String name = productData[ProductFields.name];
        num price = productData[ProductFields.price];
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: NetworkImage(imageURLs[0]),
                      radius: 30),
                  Gap(4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: blackSarabunBold(name,
                            textAlign: TextAlign.left,
                            fontSize: 25,
                            textOverflow: TextOverflow.ellipsis),
                      ),
                      blackSarabunRegular('SRP: ${price.toStringAsFixed(2)}',
                          fontSize: 15),
                      blackSarabunRegular('Quantity: ${quantity.toString()}',
                          fontSize: 15),
                      blackSarabunRegular('Status: $status', fontSize: 15),
                      blackSarabunRegular(
                          'PHP ${formatPrice((price * quantity).toDouble())}'),
                      if (status == PurchaseStatuses.pickedUp)
                        _downloadInvoiceFutureBuilder(paymentID)
                    ],
                  ),
                ],
              ),
              Divider(color: CustomColors.nimbusCloud)
            ],
          ),
        );
      },
    );
  }

  Widget _downloadInvoiceFutureBuilder(String paymentID) {
    return FutureBuilder(
      future: getThisPaymentDoc(paymentID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData ||
            snapshot.hasError) return snapshotHandler(snapshot);
        final paymentData = snapshot.data!.data() as Map<dynamic, dynamic>;
        String invoiceURL = paymentData[PaymentFields.invoiceURL];
        return Container(
          height: 40,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10)),
          child: TextButton(
              onPressed: () =>
                  NavigatorRoutes.quotation(context, quotationURL: invoiceURL),
              child: blackSarabunRegular('View Invoice',
                  fontSize: 12,
                  textAlign: TextAlign.left,
                  decoration: TextDecoration.underline)),
        );
      },
    );
  }
}
