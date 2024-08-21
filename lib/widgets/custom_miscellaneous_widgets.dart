import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import 'custom_padding_widgets.dart';
import 'item_entry_widget.dart';
import 'text_widgets.dart';

Widget stackedLoadingContainer(
    BuildContext context, bool isLoading, Widget child) {
  return Stack(children: [
    child,
    if (isLoading)
      Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.5),
          child: const Center(child: CircularProgressIndicator()))
  ]);
}

Widget switchedLoadingContainer(bool isLoading, Widget child) {
  return isLoading ? const Center(child: CircularProgressIndicator()) : child;
}

Widget buildProfileImage(
    {required String profileImageURL, double radius = 70}) {
  return profileImageURL.isNotEmpty
      ? CircleAvatar(
          radius: radius,
          backgroundColor: CustomColors.blackBeauty,
          backgroundImage: NetworkImage(profileImageURL),
        )
      : CircleAvatar(
          radius: radius,
          backgroundColor: CustomColors.blackBeauty,
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: radius + 10,
          ));
}

Widget roundedWhiteContainer(BuildContext context, {required Widget child}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white),
      padding: const EdgeInsets.all(20),
      child: child);
}

Widget roundedNimbusContainer(BuildContext context, {required Widget child}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: CustomColors.nimbusCloud),
      padding: const EdgeInsets.all(20),
      child: child);
}

void showOtherPics(BuildContext context, {required String selectedImage}) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
              content: SingleChildScrollView(
            child: Column(children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(selectedImage), fit: BoxFit.fill)),
              ),
              vertical10Pix(
                child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: whiteSarabunRegular('CLOSE')),
              )
            ]),
          )));
}

Widget snapshotHandler(AsyncSnapshot snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const CircularProgressIndicator();
  } else if (!snapshot.hasData) {
    return Text('No data found');
  } else if (snapshot.hasError) {
    return Text('Error getting data: ${snapshot.error.toString()}');
  }
  return Container();
}

Widget bookingHistoryEntry(DocumentSnapshot bookingDoc,
    {String userType = UserTypes.client}) {
  final bookingData = bookingDoc.data() as Map<dynamic, dynamic>;
  String serviceStatus = bookingData[BookingFields.serviceStatus];
  List<dynamic> serviceIDs = bookingData[BookingFields.serviceIDs];
  DateTime dateCreated =
      (bookingData[BookingFields.dateCreated] as Timestamp).toDate();
  DateTime dateRequsted =
      (bookingData[BookingFields.dateRequested] as Timestamp).toDate();

  return FutureBuilder(
    future: getSelectedServiceDocs(serviceIDs),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting ||
          !snapshot.hasData ||
          snapshot.hasError) return snapshotHandler(snapshot);
      List<dynamic> selectedServices =
          snapshot.data!.map((e) => e.data() as Map<dynamic, dynamic>).toList();
      num totalPrice = 0;
      for (var serviceData in selectedServices) {
        totalPrice += serviceData[ServiceFields.price];
      }

      return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: selectedServices.map((serviceData) {
                            final List<dynamic> imageURLs =
                                serviceData[ServiceFields.imageURLs];
                            return vertical10Pix(
                              child: Row(
                                children: [
                                  Image.network(imageURLs.first,
                                      width: 50, height: 50, fit: BoxFit.cover),
                                  Gap(10),
                                  blackSarabunBold(
                                      serviceData[ServiceFields.name],
                                      fontSize: 18,
                                      textAlign: TextAlign.left),
                                ],
                              ),
                            );
                          }).toList()),
                      if (serviceStatus != ServiceStatuses.pendingPayment)
                        const Gap(30),
                      blackSarabunRegular('Status: $serviceStatus',
                          fontSize: 15),
                    ],
                  ),
                  Gap(10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      blackSarabunRegular('Status: $serviceStatus',
                          fontSize: 15),
                      blackSarabunRegular(
                          'Date Booked: ${DateFormat('MMM dd, yyyy').format(dateCreated)}',
                          fontSize: 15),
                      blackSarabunRegular(
                          'Date Requested: ${DateFormat('MMM dd, yyyy').format(dateRequsted)}',
                          fontSize: 15),
                      Gap(15),
                      blackSarabunBold(
                          'Total: PHP ${formatPrice(totalPrice.toDouble())}',
                          fontSize: 15),
                      if (serviceStatus == ServiceStatuses.pendingPayment)
                        ElevatedButton(
                            onPressed: () => NavigatorRoutes.settleBooking(
                                context,
                                bookingID: bookingDoc.id),
                            child: whiteSarabunRegular('SETTLE PAYMENT'))
                    ],
                  ),
                ],
              ),
              Divider()
            ],
          ));
    },
  );
}

Widget itemCarouselTemplate(BuildContext context, WidgetRef ref,
    {required String label,
    required CarouselSliderController carouselSliderController,
    required List<DocumentSnapshot> itemDocs}) {
  return vertical10Pix(
    child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          blackSarabunBold(label, fontSize: 32),
          Container(width: 220, height: 8, color: CustomColors.crimson),
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: 300,
            child: CarouselSlider.builder(
              carouselController: carouselSliderController,
              itemCount: itemDocs.length,
              disableGesture: false,
              options: CarouselOptions(
                  viewportFraction: 0.4, enlargeCenterPage: false),
              itemBuilder: (context, index, realIndex) {
                return itemEntry(context, itemDoc: itemDocs[index],
                    onPress: () {
                  NavigatorRoutes.selectedProduct(context, ref,
                      productID: itemDocs[index].id);
                });
              },
            ),
          )
        ])),
  );
}
