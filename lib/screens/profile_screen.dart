import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/providers/profile_image_url_provider.dart';
import 'package:one_velocity_mobile/providers/purchases_provider.dart';

import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/text_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String formattedName = '';
  String mobileNumber = '';

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
        final userDoc = await getCurrentUserDoc();
        final userData = userDoc.data() as Map<dynamic, dynamic>;
        formattedName =
            '${userData[UserFields.firstName]} ${userData[UserFields.lastName]}';
        mobileNumber = userData[UserFields.mobileNumber];
        ref
            .read(profileImageURLProvider)
            .setImageURL(userData[UserFields.profileImageURL]);
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
    ref.watch(loadingProvider);
    ref.watch(profileImageURLProvider);
    ref.watch(purchasesProvider);
    return Scaffold(
      appBar: appBarWidget(actions: [
        IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(NavigatorRoutes.editProfile),
            icon: Icon(Icons.edit))
      ]),
      drawer: appDrawer(context, route: NavigatorRoutes.profile),
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(
              children: [
                profileDetails(),
                const Divider(color: CustomColors.blackBeauty),
                purchaseHistory()
              ],
            )),
          )),
    );
  }

  Widget profileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildProfileImage(
                profileImageURL:
                    ref.read(profileImageURLProvider).profileImageURL,
                radius: MediaQuery.of(context).size.width * 0.15),
            Column(
              children: [
                if (ref
                    .read(profileImageURLProvider)
                    .profileImageURL
                    .isNotEmpty)
                  ElevatedButton(
                      onPressed: () => removeProfilePic(context, ref),
                      child: montserratWhiteRegular('REMOVE\nPROFILE PICTURE',
                          fontSize: 14)),
                ElevatedButton(
                    onPressed: () => uploadProfilePicture(context, ref),
                    child: montserratWhiteRegular('UPLOAD\nPROFILE PICTURE',
                        fontSize: 14))
              ],
            ),
          ],
        ),
        montserratBlackBold(formattedName, fontSize: 22),
        Text('Mobile Number: $mobileNumber',
            style: const TextStyle(color: Colors.black, fontSize: 16))
      ],
    );
  }

  Widget purchaseHistory() {
    return Container(
      decoration: BoxDecoration(
          color: CustomColors.blackBeauty,
          borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          montserratWhiteBold('PURCHASE HISTORY'),
          ref.read(purchasesProvider).purchaseDocs.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: ref
                      .read(purchasesProvider)
                      .purchaseDocs
                      .reversed
                      .toList()
                      .length,
                  itemBuilder: (context, index) {
                    return _purchaseHistoryEntry(ref
                        .read(purchasesProvider)
                        .purchaseDocs
                        .reversed
                        .toList()[index]);
                  })
              : vertical20Pix(
                  child: montserratBlackBold(
                      'YOU HAVE NOT MADE ANY PURCHASES YET.'))
        ],
      ),
    );
  }

  Widget _purchaseHistoryEntry(DocumentSnapshot purchaseDoc) {
    final purchaseData = purchaseDoc.data() as Map<dynamic, dynamic>;
    String status = purchaseData[PurchaseFields.purchaseStatus];
    String productID = purchaseData[PurchaseFields.productID];
    num quantity = purchaseData[PurchaseFields.quantity];

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
        return GestureDetector(
            onTap: () {},
            child: all10Pix(
                child: Container(
              decoration: const BoxDecoration(color: CustomColors.ultimateGray),
              padding: EdgeInsets.all(10),
              child: Row(
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
                      montserratWhiteBold(name, fontSize: 25),
                      montserratWhiteRegular('SRP: ${price.toStringAsFixed(2)}',
                          fontSize: 15),
                      montserratWhiteRegular('Quantity: ${quantity.toString()}',
                          fontSize: 15),
                      montserratWhiteRegular('Status: $status', fontSize: 15),
                      montserratWhiteBold(
                          'PHP ${(price * quantity).toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              ),
            )));
      },
    );
  }
}
