import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_velocity_mobile/utils/firebase_util.dart';
import 'package:one_velocity_mobile/widgets/text_widgets.dart';

import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  List<DocumentSnapshot> allFAQDocs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        allFAQDocs = await getAllFAQs();
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting all FAQs: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: appBarWidget(),
      drawer: appDrawer(context, route: NavigatorRoutes.help),
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: allFAQDocs.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: allFAQDocs.length,
                        itemBuilder: (context, index) {
                          return vertical10Pix(
                              child: _faqEntry(allFAQDocs[index]));
                        })
                    : SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                            child: blackSarabunBold('NO FAQS CREATED',
                                fontSize: 38)),
                      )),
          )),
    );
  }

  Widget _faqEntry(DocumentSnapshot faqDoc) {
    final faqData = faqDoc.data() as Map<dynamic, dynamic>;
    String question = faqData[FAQFields.question];
    String answer = faqData[FAQFields.answer];
    return vertical10Pix(
        child: ExpansionTile(
      collapsedBackgroundColor: CustomColors.blackBeauty,
      backgroundColor: CustomColors.blackBeauty.withOpacity(0.8),
      collapsedIconColor: Colors.white,
      iconColor: Colors.white,
      collapsedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: whiteSarabunBold(question, fontSize: 16),
      children: [vertical20Pix(child: whiteSarabunBold(answer, fontSize: 16))],
    ));
  }
}
