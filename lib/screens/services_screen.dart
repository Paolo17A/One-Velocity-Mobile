import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_velocity_mobile/widgets/text_widgets.dart';

import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/item_entry_widget.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  List<DocumentSnapshot> allServiceDocs = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        allServiceDocs = await getAllServices();
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting all services: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: topAppBar(),
      body: Scaffold(
        appBar: appBarWidget(
            actions: hasLoggedInUser()
                ? [popUpMenu(context, currentPath: NavigatorRoutes.services)]
                : [loginButton(context)]),
        drawer: appDrawer(context, ref, route: NavigatorRoutes.services),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: all20Pix(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [servicesHeader(), _availableServices()],
                ),
              ),
            )),
      ),
    );
  }

  Widget servicesHeader() {
    return Row(
        children: [blackSarabunBold('ALL AVAILABLE SERVICES', fontSize: 24)]);
  }

  Widget _availableServices() {
    return Column(
      children: [
        allServiceDocs.isNotEmpty
            ? Wrap(
                alignment: WrapAlignment.start,
                spacing: 40,
                runSpacing: 40,
                children: allServiceDocs.asMap().entries.map((item) {
                  DocumentSnapshot thisService = allServiceDocs[item.key];
                  return itemEntry(context,
                      itemDoc: thisService,
                      onPress: () => NavigatorRoutes.selectedService(context,
                          serviceID: thisService.id));
                }).toList())
            : blackSarabunBold('NO SERVICES AVAILABLE', fontSize: 44),
      ],
    );
  }
}
