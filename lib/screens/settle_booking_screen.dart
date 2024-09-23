import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/cart_provider.dart';
import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/text_widgets.dart';

class SettleBookingScreen extends ConsumerStatefulWidget {
  final String bookingID;

  const SettleBookingScreen({super.key, required this.bookingID});

  @override
  ConsumerState<SettleBookingScreen> createState() =>
      _SettleBookingScreenState();
}

class _SettleBookingScreenState extends ConsumerState<SettleBookingScreen> {
  List<DocumentSnapshot> serviceDocs = [];
  DateTime? dateCreated;
  DateTime? dateRequsted;
  num totalServicePrice = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        final bookingDoc = await getThisBookingDoc(widget.bookingID);
        final bookingData = bookingDoc.data() as Map<dynamic, dynamic>;
        dateCreated =
            (bookingData[BookingFields.dateCreated] as Timestamp).toDate();
        dateRequsted =
            (bookingData[BookingFields.dateRequested] as Timestamp).toDate();
        if (bookingData[BookingFields.serviceStatus] !=
            ServiceStatuses.pendingPayment) {
          scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('This booking has no pending payment')));
          ref.read(loadingProvider.notifier).toggleLoading(false);
          Navigator.of(context).pop();
          return;
        }

        List<dynamic> serviceIDs = bookingData[BookingFields.serviceIDs];
        serviceDocs = await getSelectedServiceDocs(serviceIDs);
        for (var serviceDoc in serviceDocs) {
          final serviceData = serviceDoc.data() as Map<dynamic, dynamic>;
          totalServicePrice += serviceData[ServiceFields.price];
        }
        ref.read(cartProvider).setSelectedPaymentMethod('');

        ref.read(cartProvider).resetProofOfPaymentFile();
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error getting product checkout details: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(cartProvider);
    return PopScope(
      onPopInvoked: (didPop) {
        ref.read(cartProvider).setSelectedPaymentMethod('');
        ref.read(cartProvider).resetProofOfPaymentFile();
      },
      child: Scaffold(
        appBar: topAppBar(),
        body: Scaffold(
          appBar: appBarWidget(),
          body: switchedLoadingContainer(
              ref.read(loadingProvider).isLoading,
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                    child: all20Pix(
                  child: Column(
                    children: [
                      _serviceDataWidgets(),
                      Divider(color: CustomColors.blackBeauty),
                      _paymentMethod(),
                      if (ref
                          .read(cartProvider)
                          .selectedPaymentMethod
                          .isNotEmpty)
                        _uploadPayment(),
                      _makePaymentButton(),
                      if (ref.read(cartProvider).proofOfPaymentFile != null)
                        _checkoutButton()
                    ],
                  ),
                )),
              )),
        ),
      ),
    );
  }

  Widget _serviceDataWidgets() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          blackSarabunBold('REQUESTED SERVICES: ', fontSize: 32),
          Column(
              children: serviceDocs.map((serviceDoc) {
            final serviceData = serviceDoc.data() as Map<dynamic, dynamic>;
            String name = serviceData[ServiceFields.name];
            List<dynamic> imageURLs = serviceData[ServiceFields.imageURLs];
            num price = serviceData[ServiceFields.price];
            String description = serviceData[ServiceFields.description];
            return vertical10Pix(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageURLs.isNotEmpty)
                    Container(
                        decoration: BoxDecoration(border: Border.all()),
                        child: Image.network(imageURLs[0],
                            width: 100, height: 100, fit: BoxFit.cover)),
                  Gap(20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      blackSarabunBold(name, fontSize: 20),
                      blackSarabunRegular(
                          'PHP: ${formatPrice(price.toDouble())}',
                          fontSize: 20),
                      Gap(12),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: blackSarabunRegular(description,
                            textAlign: TextAlign.left,
                            textOverflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList())
        ],
      ),
    );
  }

  Widget _paymentMethod() {
    return all10Pix(
        child: Column(
      children: [
        Row(
          children: [blackSarabunBold('PAYMENT METHOD')],
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
                blackSarabunBold('SEND YOUR PAYMENT HERE'),
                if (ref.read(cartProvider).selectedPaymentMethod == 'GCASH')
                  blackSarabunBold('GCASH: +639221234567', fontSize: 14)
                else if (ref.read(cartProvider).selectedPaymentMethod ==
                    'PAYMAYA')
                  blackSarabunBold('PAYMAYA: +639221234567', fontSize: 14)
              ],
            )
          ],
        ),
      ],
    ));
  }

  Widget _makePaymentButton() {
    return Container(
      height: 60,
      child: ElevatedButton(
          onPressed: ref.read(cartProvider).selectedPaymentMethod.isEmpty
              ? null
              : () => ref.read(cartProvider).setProofOfPaymentFile(),
          style: ElevatedButton.styleFrom(
              disabledBackgroundColor: CustomColors.ultimateGray),
          child: whiteSarabunBold('SELECT PROOF OF PAYMENT')),
    );
  }

  Widget _checkoutButton() {
    return vertical20Pix(
        child: Column(
      children: [
        all10Pix(
            child: Image.file(ref.read(cartProvider).proofOfPaymentFile!,
                width: 250, height: 250, fit: BoxFit.cover)),
        ElevatedButton(
            onPressed: () => ref.read(cartProvider).resetProofOfPaymentFile(),
            child: const Icon(Icons.delete, color: Colors.white)),
        vertical20Pix(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
                onPressed: () => settleBookingRequestPayment(context, ref,
                    purchaseIDs: [widget.bookingID],
                    bookingID: widget.bookingID,
                    servicePrice: totalServicePrice),
                child: whiteSarabunBold('SETTLE PAYMENT')),
          ),
        )
      ],
    ));
  }
}
