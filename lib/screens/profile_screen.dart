import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: topAppBar(),
      body: Scaffold(
        appBar: appBarWidget(actions: [
          IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(NavigatorRoutes.editProfile),
              icon: Icon(Icons.edit))
        ]),
        drawer: appDrawer(context, ref, route: NavigatorRoutes.profile),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  profileDetails(),
                  const Divider(color: CustomColors.blackBeauty),
                ],
              )),
            )),
      ),
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
                      child: whiteSarabunRegular('REMOVE\nPROFILE PICTURE',
                          fontSize: 14)),
                ElevatedButton(
                    onPressed: () => uploadProfilePicture(context, ref),
                    child: whiteSarabunRegular('UPLOAD\nPROFILE PICTURE',
                        fontSize: 14))
              ],
            ),
          ],
        ),
        blackSarabunBold(formattedName, fontSize: 22),
        Text('Mobile Number: $mobileNumber',
            style: const TextStyle(color: Colors.black, fontSize: 16))
      ],
    );
  }
}
