import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_velocity_mobile/utils/string_util.dart';
import 'package:one_velocity_mobile/widgets/text_widgets.dart';

import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/item_entry_widget.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  List<DocumentSnapshot> allServiceDocs = [];
  List<DocumentSnapshot> filteredServiceDocs = [];
  String selectedCategory = 'VIEW ALL';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        allServiceDocs = await getAllServices();
        filteredServiceDocs = allServiceDocs;
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
                  children: [
                    servicesHeader(),
                    _serviceCategoryWidget(),
                    _availableServices()
                  ],
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

  Widget _serviceCategoryWidget() {
    return vertical20Pix(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: dropdownWidget(selectedCategory, (newVal) {
              setState(() {
                selectedCategory = newVal!;
                if (selectedCategory == 'VIEW ALL') {
                  filteredServiceDocs = allServiceDocs;
                } else {
                  filteredServiceDocs = allServiceDocs.where((serviceDoc) {
                    final serviceData =
                        serviceDoc.data() as Map<dynamic, dynamic>;
                    return serviceData[ServiceFields.category] ==
                        selectedCategory;
                  }).toList();
                }
              });
            },
                [
                  'VIEW ALL',
                  ServiceCategories.paintJob,
                  ServiceCategories.repair,
                ],
                selectedCategory.isNotEmpty
                    ? selectedCategory
                    : 'Select a category',
                false),
          ),
          vertical10Pix(
              child: Container(
                  width: double.infinity,
                  height: 8,
                  color: CustomColors.grenadine))
        ],
      ),
    );
  }

  Widget _availableServices() {
    return Column(
      children: [
        filteredServiceDocs.isNotEmpty
            ? Wrap(
                alignment: WrapAlignment.start,
                spacing: 40,
                runSpacing: 40,
                children: filteredServiceDocs.asMap().entries.map((item) {
                  DocumentSnapshot thisService = filteredServiceDocs[item.key];
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
