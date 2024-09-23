import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
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
import '../widgets/text_widgets.dart';

class PurchasesHistoryScreen extends ConsumerStatefulWidget {
  const PurchasesHistoryScreen({super.key});

  @override
  ConsumerState<PurchasesHistoryScreen> createState() =>
      _PurchasesHistoryScreenState();
}

class _PurchasesHistoryScreenState extends ConsumerState<PurchasesHistoryScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  List<DocumentSnapshot> ongoingPurchaseDocs = [];
  List<DocumentSnapshot> completedPurchaseDocs = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        if (!hasLoggedInUser()) {
          navigator.pop();
          return;
        }
        List<DocumentSnapshot> purchaseHistoryDocs =
            await getClientPurchaseHistory();

        purchaseHistoryDocs.sort((a, b) {
          DateTime aTime =
              (a[PurchaseFields.dateCreated] as Timestamp).toDate();
          DateTime bTime =
              (b[PurchaseFields.dateCreated] as Timestamp).toDate();
          return bTime.compareTo(aTime);
        });
        ongoingPurchaseDocs = purchaseHistoryDocs.where((purchaseDoc) {
          final purchaseData = purchaseDoc.data() as Map<dynamic, dynamic>;
          return purchaseData[PurchaseFields.purchaseStatus] ==
                  PurchaseStatuses.pending ||
              purchaseData[PurchaseFields.purchaseStatus] ==
                  PurchaseStatuses.forPickUp ||
              purchaseData[PurchaseFields.purchaseStatus] ==
                  PurchaseStatuses.processing;
        }).toList();
        completedPurchaseDocs = purchaseHistoryDocs.where((purchaseDoc) {
          final purchaseData = purchaseDoc.data() as Map<dynamic, dynamic>;
          return purchaseData[PurchaseFields.purchaseStatus] ==
                  PurchaseStatuses.pickedUp ||
              purchaseData[PurchaseFields.purchaseStatus] ==
                  PurchaseStatuses.denied;
        }).toList();
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
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
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
      ),
    );
  }

  Widget purchaseHistory() {
    return SingleChildScrollView(
      child: Column(
        children: [
          blackSarabunBold('PURCHASE HISTORY'),
          TabBar(tabs: [
            Tab(child: blackSarabunBold('ONGOING')),
            Tab(child: blackSarabunBold('COMPLETED'))
          ]),
          SizedBox(
            height: MediaQuery.of(context).size.height - 220,
            child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _ongoingPurchaseHistoryEntries(),
                  _completedPurchaseHistoryEntries()
                ]),
          )
        ],
      ),
    );
  }

  Widget _ongoingPurchaseHistoryEntries() {
    return ongoingPurchaseDocs.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: ongoingPurchaseDocs.length,
            itemBuilder: (context, index) => _purchaseHistoryEntry(
                ongoingPurchaseDocs.reversed.toList()[index]))
        : Center(
            child: blackSarabunBold('YOU HAVE NO ONGOING PURCHASES.',
                fontSize: 24));
  }

  Widget _completedPurchaseHistoryEntries() {
    return completedPurchaseDocs.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: completedPurchaseDocs.length,
            itemBuilder: (context, index) {
              return _purchaseHistoryEntry(completedPurchaseDocs[index]);
            })
        : Center(
            child: blackSarabunBold('YOU HAVE NO COMPLETED PURCHASES',
                fontSize: 24),
          );
  }

  Widget _purchaseHistoryEntry(DocumentSnapshot purchaseDoc) {
    final purchaseData = purchaseDoc.data() as Map<dynamic, dynamic>;
    String status = purchaseData[PurchaseFields.purchaseStatus];
    String productID = purchaseData[PurchaseFields.productID];
    num quantity = purchaseData[PurchaseFields.quantity];
    DateTime dateCreated =
        (purchaseData[PurchaseFields.dateCreated] as Timestamp).toDate();
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
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: blackSarabunBold(name,
                            textAlign: TextAlign.left,
                            fontSize: 25,
                            textOverflow: TextOverflow.ellipsis),
                      ),
                      blackSarabunRegular('SRP: ${price.toStringAsFixed(2)}',
                          fontSize: 15),
                      blackSarabunRegular('Quantity: ${quantity.toString()}',
                          fontSize: 15),
                      blackSarabunRegular(
                          'Date Purchased: ${(DateFormat('MMM dd, yyyy').format(dateCreated))}',
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
