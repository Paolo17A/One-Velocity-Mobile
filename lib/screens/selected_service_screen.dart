import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookmarks_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/loading_provider.dart';
import '../providers/pages_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/text_widgets.dart';

class SelectedServiceScreen extends ConsumerStatefulWidget {
  final String serviceID;
  const SelectedServiceScreen({super.key, required this.serviceID});

  @override
  ConsumerState<SelectedServiceScreen> createState() =>
      _SelectedServiceScreenState();
}

class _SelectedServiceScreenState extends ConsumerState<SelectedServiceScreen> {
  //  PRODUCT VARIABLES
  String name = '';
  String description = '';
  num price = 0;
  bool isAvailable = false;
  List<dynamic> imageURLs = [];
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        final service = await getThisServiceDoc(widget.serviceID);
        final serviceData = service.data() as Map<dynamic, dynamic>;
        name = serviceData[ServiceFields.name];
        description = serviceData[ServiceFields.description];
        price = serviceData[ServiceFields.price];
        isAvailable = serviceData[ServiceFields.isAvailable];
        imageURLs = serviceData[ServiceFields.imageURLs];
        //  GET USER DATA
        if (hasLoggedInUser()) {
          final user = await getCurrentUserDoc();
          final userData = user.data() as Map<dynamic, dynamic>;
          ref
              .read(bookmarksProvider)
              .setBookmarkedServices(userData[UserFields.bookmarkedServices]);

          ref
              .read(cartProvider)
              .setCartItems(await getServiceCartEntries(context));
        }
        setState(() {});
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting selected product: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(bookmarksProvider);
    ref.watch(cartProvider);
    currentImageIndex = ref.watch(pagesProvider.notifier).getCurrentPage();
    return Scaffold(
      appBar: topAppBar(),
      body: Scaffold(
        appBar: appBarWidget(
            actions: hasLoggedInUser()
                ? [popUpMenu(context, currentPath: NavigatorRoutes.home)]
                : [loginButton(context)]),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: all20Pix(child: _serviceContainer()),
            )),
      ),
    );
  }

  Widget _serviceContainer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: vertical20Pix(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageURLs.isNotEmpty) _itemImagesDisplay(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      blackSarabunBold(name, fontSize: 48),
                      blackSarabunRegular(
                          'PHP ${formatPrice(price.toDouble())}',
                          fontSize: 32),
                      vertical20Pix(
                        child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero),
                                    disabledBackgroundColor: Colors.blueGrey),
                                onPressed: isAvailable
                                    ? () async {
                                        if (!hasLoggedInUser()) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Please log-in to your account first.')));
                                          return;
                                        }
                                        addServiceToCart(context, ref,
                                            serviceID: widget.serviceID);
                                      }
                                    : null,
                                child: whiteSarabunRegular(
                                    'REQUEST THIS SERVICE',
                                    textAlign: TextAlign.center))),
                      ),
                    ],
                  ),
                  blackSarabunBold(
                      'Is Available: ${isAvailable ? 'YES' : ' NO'}',
                      fontSize: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () => ref
                                  .read(bookmarksProvider)
                                  .bookmarkedServices
                                  .contains(widget.serviceID)
                              ? removeBookmarkedService(context, ref,
                                  serviceID: widget.serviceID)
                              : addBookmarkedService(context, ref,
                                  service: widget.serviceID),
                          icon: Icon(ref
                                  .read(bookmarksProvider)
                                  .bookmarkedServices
                                  .contains(widget.serviceID)
                              ? Icons.bookmark
                              : Icons.bookmark_outline)),
                      blackSarabunRegular(ref
                              .read(bookmarksProvider)
                              .bookmarkedServices
                              .contains(widget.serviceID)
                          ? 'Remove from Bookmarks'
                          : 'Add to Bookmarks')
                    ],
                  ),
                  Divider(color: CustomColors.blackBeauty),
                  all20Pix(child: blackSarabunRegular(description)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _itemImagesDisplay() {
    return Column(
      children: [
        Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                  border: Border.all(),
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(imageURLs[currentImageIndex - 1]))),
            ),
          ],
        ),
        if (imageURLs.length > 1)
          vertical10Pix(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () => currentImageIndex == 0
                            ? null
                            : ref
                                .read(pagesProvider.notifier)
                                .setCurrentPage(currentImageIndex - 1),
                        child: const Icon(Icons.arrow_left)),
                    TextButton(
                        onPressed: () =>
                            currentImageIndex == imageURLs.length - 1
                                ? null
                                : ref
                                    .read(pagesProvider.notifier)
                                    .setCurrentPage(currentImageIndex + 1),
                        child: const Icon(Icons.arrow_right))
                  ]),
            ),
          )
      ],
    );
  }
}
