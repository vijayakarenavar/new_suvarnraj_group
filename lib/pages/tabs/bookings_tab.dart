// lib/views/tabs/bookings_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../controller/booking_controller.dart';
import '../../models/booking_model.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  BookingController get bookingController => Get.find<BookingController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (!Get.isRegistered<BookingController>()) {
      Get.put(BookingController());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ColorScheme get cs => Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cs.background,
      body: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.calendarCheck, size: 18.sp, color: cs.onSurface),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'My Bookings',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                ),
                Obx(() => IconButton(
                  tooltip: 'Refresh',
                  icon: bookingController.isLoading.value
                      ? SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(cs.primary)),
                  )
                      : FaIcon(FontAwesomeIcons.rotate, size: 16.sp, color: cs.onSurface),
                  onPressed: bookingController.isLoading.value
                      ? null
                      : () => bookingController.refreshBookings(),
                )),
              ],
            ),
          ),

          // ✅ 3 TABS: Upcoming + Completed + Cancelled
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.06),
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: cs.onPrimary,
              unselectedLabelColor: cs.onSurface.withOpacity(0.7),
              indicator: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(2.w),
                boxShadow: [
                  BoxShadow(color: cs.primary.withOpacity(0.16), blurRadius: 6)
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
              tabs: const [
                Tab(text: "Upcoming"),
                Tab(text: "Completed"),
                Tab(text: "Cancelled"),
              ],
            ),
          ),

          // Body
          Expanded(
            child: Obx(() {
              if (bookingController.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: cs.primary));
              }

              if (bookingController.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.triangleExclamation,
                        size: 48.sp,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          bookingController.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.7),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      ElevatedButton.icon(
                        onPressed: () => bookingController.refreshBookings(),
                        icon: const FaIcon(FontAwesomeIcons.rotate, size: 16),
                        label: const Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.5.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!bookingController.hasBookings) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.calendarXmark,
                        size: 48.sp,
                        color: cs.onSurface.withOpacity(0.3),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "No bookings yet",
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.6),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _bookingList(bookingController.upcomingBookings),
                  _bookingList(bookingController.completedBookings),
                  _bookingList(bookingController.cancelledBookings),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _bookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.folderOpen,
              size: 40.sp,
              color: cs.onSurface.withOpacity(0.3),
            ),
            SizedBox(height: 2.h),
            Text(
              "No bookings in this category",
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.6),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await bookingController.refreshBookings();
      },
      color: cs.primary,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
        itemBuilder: (context, i) {
          return _bookingCard(bookings[i]);
        },
      ),
    );
  }

  Widget _bookingCard(BookingModel booking) {
    final cs = Theme.of(context).colorScheme;

    // ✅ Theme-aware status colors
    late Color statusColor;
    late Color statusBg;

    switch (booking.status) {
      case "Confirmed":
        statusColor = cs.primary;
        statusBg = cs.primary.withOpacity(0.1);
        break;
      case "Completed":
        statusColor = cs.secondary;
        statusBg = cs.secondary.withOpacity(0.1);
        break;
      case "Cancelled":
        statusColor = cs.error;
        statusBg = cs.error.withOpacity(0.1);
        break;
      default:
        statusColor = cs.onSurface.withOpacity(0.6);
        statusBg = cs.surface.withOpacity(0.1);
    }

    final formattedDate = DateFormat("dd MMM yyyy, hh:mm a").format(booking.dateTime);

    return Material(
      color: cs.surface, // ✅ was Colors.white
      elevation: 2,
      borderRadius: BorderRadius.circular(3.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(3.w),
        onTap: () => _showBookingDetails(booking),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      booking.serviceName,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(5.w),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.2.h),
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.toolbox, size: 13.sp, color: cs.onSurface.withOpacity(0.7)),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      booking.category,
                      style: TextStyle(fontSize: 13.sp, color: cs.onSurface.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.calendarDay, size: 13.sp, color: cs.onSurface.withOpacity(0.7)),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: TextStyle(fontSize: 13.sp, color: cs.onSurface.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.locationDot, size: 13.sp, color: cs.onSurface.withOpacity(0.7)),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      booking.address.isNotEmpty ? booking.address : "Address not available",
                      style: TextStyle(fontSize: 13.sp, color: cs.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.user, size: 13.sp, color: cs.onSurface.withOpacity(0.7)),
                  SizedBox(width: 2.w),
                  Text(
                    booking.customerName,
                    style: TextStyle(fontSize: 13.sp, color: cs.onSurface),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${booking.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: cs.primary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showBookingDetails(booking),
                    icon: FaIcon(FontAwesomeIcons.circleInfo, size: 14, color: cs.primary),
                    label: Text("Details", style: TextStyle(color: cs.primary)),
                    style: TextButton.styleFrom(
                      foregroundColor: cs.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(BookingModel booking) {
    final cs = Theme.of(context).colorScheme;
    Get.dialog(
      AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        title: Row(
          children: [
            FaIcon(FontAwesomeIcons.fileInvoice, size: 20, color: cs.onSurface),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                booking.serviceName,
                style: TextStyle(fontSize: 18, color: cs.onSurface),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow("Date", DateFormat('dd MMM yyyy, hh:mm a').format(booking.dateTime), cs),
              _detailRow("Address", booking.address.isNotEmpty ? booking.address : "Not available", cs),
              if (booking.secondaryAddress != null && booking.secondaryAddress!.isNotEmpty)
                _detailRow("Landmark", booking.secondaryAddress!, cs),
              _detailRow("Customer", booking.customerName, cs),
              _detailRow("Category", booking.category, cs),
              _detailRow("Price", "₹${booking.price.toStringAsFixed(2)}", cs),
              _detailRow("Status", booking.status, cs),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text("Close", style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}