// lib/controller/booking_controller.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';
import '../controller/user_controller.dart';
import '../models/booking_model.dart';

class BookingController extends GetxController {
  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  bool _isFetching = false;

  late UserController userCtrl;

  @override
  void onInit() {
    super.onInit();
    userCtrl = Get.find<UserController>();

    if (userCtrl.isLoggedIn.value && userCtrl.token.value.isNotEmpty) {
      fetchBookings();
    }

    ever(userCtrl.isLoggedIn, (isLoggedIn) {
      if (isLoggedIn && userCtrl.token.value.isNotEmpty) {
        fetchBookings();
      } else {
        clearData();
      }
    });
  }

  /// ✅ FETCH BOOKINGS FROM API
  Future<void> fetchBookings() async {
    if (_isFetching) {
      if (kDebugMode) print("⚠️ Already fetching bookings, skipping...");
      return;
    }

    try {
      _isFetching = true;
      isLoading.value = true;
      errorMessage.value = '';

      final token = userCtrl.token.value;
      if (token.isEmpty) {
        errorMessage.value = "Please login to view bookings";
        if (kDebugMode) print("❌ No token available");
        return;
      }

      if (kDebugMode) {
        print("📡 Fetching bookings with token: ${token.substring(0, 20)}...");
      }

      final response = await ApiService.fetchBookings(token);

      if (kDebugMode) {
        print("✅ Bookings API Response received");
        print("   Response Keys: ${response.keys.toList()}");
        print("   Message: ${response['message']}");
        print("   Data Type: ${response['data'].runtimeType}");
      }

      // ✅ Handle both LIST and MAP responses
      List<dynamic> bookingList = [];

      if (response['data'] == null) {
        bookingList = [];
        if (kDebugMode) print("⚠️ No 'data' key in response");
      } else if (response['data'] is List) {
        bookingList = response['data'] as List<dynamic>;
        if (kDebugMode) print("✅ Data is a List with ${bookingList.length} items");
      } else if (response['data'] is Map<String, dynamic>) {
        final dataMap = response['data'] as Map<String, dynamic>;
        if (kDebugMode) print("✅ Data is a Map with keys: ${dataMap.keys.toList()}");

        if (dataMap.containsKey('orders')) {
          bookingList = dataMap['orders'] as List<dynamic>;
          if (kDebugMode) print("   Found 'orders' key");
        } else if (dataMap.containsKey('bookings')) {
          bookingList = dataMap['bookings'] as List<dynamic>;
          if (kDebugMode) print("   Found 'bookings' key");
        } else if (dataMap.containsKey('data')) {
          bookingList = dataMap['data'] as List<dynamic>;
          if (kDebugMode) print("   Found nested 'data' key");
        }
      }

      if (kDebugMode) print("📦 Total bookings found: ${bookingList.length}");

      if (bookingList.isEmpty) {
        bookings.clear();
        if (kDebugMode) print("ℹ️ No bookings to display");
      } else {
        final List<BookingModel> parsed = [];

        for (var i = 0; i < bookingList.length; i++) {
          try {
            final booking = BookingModel.fromJson(bookingList[i] as Map<String, dynamic>);
            parsed.add(booking);
          } catch (e) {
            if (kDebugMode) {
              print("⚠️ Error parsing booking at index $i: $e");
              print("   Raw data: ${bookingList[i]}");
            }
          }
        }

        bookings.assignAll(parsed);
        if (kDebugMode) print("✅ Successfully parsed ${parsed.length} bookings");
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) {
        print("❌ Fetch bookings error: $e");
        print("   Error type: ${e.runtimeType}");
      }

      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          "Error",
          errorMessage.value.isEmpty ? "Failed to load bookings" : errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
        );
      }
    } finally {
      isLoading.value = false;
      _isFetching = false;
    }
  }

  /// ✅ CANCEL BOOKING
  Future<bool> cancelBooking(int orderId) async {
    try {
      isLoading.value = true;
      final token = userCtrl.token.value;
      if (token.isEmpty) throw Exception("Authentication required");

      if (kDebugMode) print("🗑️ Cancelling booking ID: $orderId");

      await ApiService.cancelOrder(orderId, token);
      bookings.removeWhere((b) => b.id == orderId);

      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          "Success",
          "Booking cancelled successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(10),
        );
      }

      if (kDebugMode) print("✅ Booking cancelled: $orderId");
      return true;
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) print("❌ Cancel error: $e");

      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          "Error",
          errorMsg.isEmpty ? "Failed to cancel booking" : errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ CLEAR DATA
  void clearData() {
    bookings.clear();
    errorMessage.value = '';
    isLoading.value = false;
    _isFetching = false;
    if (kDebugMode) print("🧹 Booking data cleared");
  }

  /// ✅ GET BOOKING BY ID
  BookingModel? getBookingById(int id) {
    try {
      return bookings.firstWhere((b) => b.id == id);
    } catch (e) {
      if (kDebugMode) print("⚠️ Booking not found with ID: $id");
      return null;
    }
  }

  /// ✅ REFRESH BOOKINGS
  Future<void> refreshBookings() async {
    if (kDebugMode) print("🔄 Refreshing bookings...");
    await fetchBookings();
  }

  // ✅ GETTERS (Fixed to match exact status strings)
  int get totalBookings => bookings.length;

  int get upcomingCount =>
      bookings.where((b) => b.status == "Confirmed").length;

  int get completedCount =>
      bookings.where((b) => b.status == "Completed").length;

  int get cancelledCount =>
      bookings.where((b) => b.status == "Cancelled").length;

  double get totalRevenue =>
      bookings.fold(0.0, (sum, b) => sum + b.price);

  bool get hasBookings => bookings.isNotEmpty;
  bool get hasError => errorMessage.value.isNotEmpty;

  List<BookingModel> get upcomingBookings =>
      bookings.where((b) => b.status == "Confirmed").toList();

  List<BookingModel> get completedBookings =>
      bookings.where((b) => b.status == "Completed").toList();

  List<BookingModel> get cancelledBookings =>
      bookings.where((b) => b.status == "Cancelled").toList();
}