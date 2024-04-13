import 'package:flutter/material.dart';

import '../utils/color_util.dart';
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
    return Text('Error gettin data: ${snapshot.error.toString()}');
  }
  return Container();
}
