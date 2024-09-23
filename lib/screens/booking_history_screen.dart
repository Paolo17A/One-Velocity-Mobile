import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/text_widgets.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  List<DocumentSnapshot> ongoingBookingDocs = [];
  List<DocumentSnapshot> completedBookingDocs = [];
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      try {
        ref.read(loadingProvider.notifier).toggleLoading(true);
        List<DocumentSnapshot> bookingDocs = await getUserBookingDocs();
        ongoingBookingDocs = bookingDocs.where((bookingDoc) {
          final bookingData = bookingDoc.data() as Map<dynamic, dynamic>;
          return bookingData[BookingFields.serviceStatus] !=
                  ServiceStatuses.serviceCompleted &&
              bookingData[BookingFields.serviceStatus] !=
                  ServiceStatuses.denied;
        }).toList();
        completedBookingDocs = bookingDocs.where((bookingDoc) {
          final bookingData = bookingDoc.data() as Map<dynamic, dynamic>;
          return bookingData[BookingFields.serviceStatus] ==
                  ServiceStatuses.serviceCompleted ||
              bookingData[BookingFields.serviceStatus] ==
                  ServiceStatuses.denied;
        }).toList();
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
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: appBarWidget(actions: [
          popUpMenu(context, currentPath: NavigatorRoutes.bookings)
        ]),
        drawer: appDrawer(context, ref, route: NavigatorRoutes.bookings),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
                child: Column(
              children: [
                blackSarabunBold('BOOKINGS'),
                TabBar(tabs: [
                  Tab(child: blackSarabunBold('ONGOING')),
                  Tab(child: blackSarabunBold('COMPLETED'))
                ]),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 220,
                  child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _ongoingBookingHistory(),
                        _completedBookingHistory()
                      ]),
                )
              ],
            ))),
      ),
    );
  }

  Widget _ongoingBookingHistory() {
    return ongoingBookingDocs.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: ongoingBookingDocs.length,
            itemBuilder: (context, index) {
              return bookingHistoryEntry(ongoingBookingDocs[index]);
            })
        : Center(
            child: blackSarabunBold(
                'NO ONGOING SERVICE BOOKING HISTORY AVAILABLE'),
          );
  }

  Widget _completedBookingHistory() {
    return completedBookingDocs.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: completedBookingDocs.length,
            itemBuilder: (context, index) {
              // return blackSarabunBold(
              //     ref.read(bookingsProvider).bookingDocs[index].id);
              return bookingHistoryEntry(completedBookingDocs[index]);
            })
        : Center(
            child: blackSarabunBold(
                'NO COMPLETED SERVICE BOOKING HISTORY AVAILABLE'));
  }
}
