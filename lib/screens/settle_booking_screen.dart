import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

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
  String serviceName = '';
  List<dynamic> imageURLs = [];
  String description = '';
  DateTime? dateCreated;
  DateTime? dateRequsted;
  num servicePrice = 0;

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

        final serviceID = bookingData[BookingFields.serviceID];
        final serviceDoc = await getThisServiceDoc(serviceID);
        final serviceData = serviceDoc.data() as Map<dynamic, dynamic>;
        serviceName = serviceData[ServiceFields.name];
        imageURLs = serviceData[ServiceFields.imageURLs];
        servicePrice =
            double.parse(serviceData[ServiceFields.price].toString());
        description = serviceData[ServiceFields.description];

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
        appBar: appBarWidget(),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                  child: all20Pix(
                child: Column(
                  children: [
                    blackSarabunBold('SETTLE BOOKING', fontSize: 28),
                    if (imageURLs.isNotEmpty)
                      Image.network(
                        imageURLs[0],
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.width * 0.6,
                        fit: BoxFit.cover,
                      ),
                    Gap(20),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            blackSarabunBold(serviceName, fontSize: 24),
                            blackSarabunRegular(
                                'SRP: PHP ${servicePrice.toStringAsFixed(2)}',
                                fontSize: 16),
                            vertical10Pix(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (dateCreated != null)
                                    blackSarabunRegular(
                                        'Date Booked: ${DateFormat('MMM dd, yyyy').format(dateCreated!)}',
                                        fontSize: 14),
                                  if (dateRequsted != null)
                                    blackSarabunRegular(
                                        'Date Requested: ${DateFormat('MMM dd, yyyy').format(dateRequsted!)}',
                                        fontSize: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(color: CustomColors.blackBeauty),
                    _paymentMethod(),
                    if (ref.read(cartProvider).selectedPaymentMethod.isNotEmpty)
                      _uploadPayment(),
                    _makePaymentButton(),
                    if (ref.read(cartProvider).proofOfPaymentFile != null)
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
                    bookingID: widget.bookingID),
                child: whiteSarabunBold('SETTLE PAYMENT')),
          ),
        )
      ],
    ));
  }
}
