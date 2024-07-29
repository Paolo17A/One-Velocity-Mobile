import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import 'custom_padding_widgets.dart';
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
                    child: montserratWhiteRegular('CLOSE')),
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
  String serviceID = bookingData[BookingFields.serviceID];
  DateTime dateCreated =
      (bookingData[BookingFields.dateCreated] as Timestamp).toDate();
  DateTime dateRequsted =
      (bookingData[BookingFields.dateRequested] as Timestamp).toDate();

  return FutureBuilder(
    future: getThisServiceDoc(serviceID),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting ||
          !snapshot.hasData ||
          snapshot.hasError) return snapshotHandler(snapshot);

      final serviceData = snapshot.data!.data() as Map<dynamic, dynamic>;
      List<dynamic> imageURLs = serviceData[ServiceFields.imageURLs];
      String name = serviceData[ServiceFields.name];
      num price = serviceData[ServiceFields.price];
      return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.white)),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Image.network(imageURLs[0],
                width: 90, height: 90, fit: BoxFit.cover),
            Gap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                montserratWhiteBold(name, fontSize: 25),
                montserratWhiteRegular('Status: $serviceStatus', fontSize: 15),
                montserratWhiteRegular(
                    'Date Booked: ${DateFormat('MMM dd, yyyy').format(dateCreated)}',
                    fontSize: 15),
                montserratWhiteRegular(
                    'Date Requested: ${DateFormat('MMM dd, yyyy').format(dateRequsted)}',
                    fontSize: 15),
                Gap(15),
                montserratWhiteBold('SRP: PHP ${formatPrice(price.toDouble())}',
                    fontSize: 15),
                if (serviceStatus == ServiceStatuses.pendingPayment)
                  ElevatedButton(
                      onPressed: () {
                        /*NavigatorRoutes.settleBooking(context,
                            bookingID: bookingDoc.id);*/
                      },
                      child: montserratWhiteRegular('SETTLE PAYMENT'))
              ],
            ),
          ],
        ),
      );
    },
  );
}
