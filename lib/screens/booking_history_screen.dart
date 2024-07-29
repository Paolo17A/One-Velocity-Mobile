import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/bookings_provider.dart';
import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_bottom_navbar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/text_widgets.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        ref.read(loadingProvider.notifier).toggleLoading(true);
        ref.read(bookingsProvider).setBookingDocs(await getUserBookingDocs());
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('Error getting your booking history: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(bookingsProvider);
    return Scaffold(
      appBar: appBarWidget(),
      bottomNavigationBar: bottomNavigationBar(context, index: 4),
      drawer: appDrawer(context, route: NavigatorRoutes.bookings),
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
              child: Column(
            children: [
              Gap(40),
              _bookingHistory(),
            ],
          ))),
    );
  }

  Widget _bookingHistory() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: CustomColors.ultimateGray,
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          montserratBlackBold('SERVICE BOOKING HISTORY', fontSize: 24),
          const Divider(color: Colors.white),
          ref.read(bookingsProvider).bookingDocs.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: ref.read(bookingsProvider).bookingDocs.length,
                  itemBuilder: (context, index) => bookingHistoryEntry(
                      ref.read(bookingsProvider).bookingDocs[index]))
              : Center(
                  child: montserratWhiteBold(
                      'NO SERVICE BOOKING HISTORY AVAILABLE'),
                )
        ],
      ),
    );
  }
}
