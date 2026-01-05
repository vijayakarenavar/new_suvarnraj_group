// lib/models/booking_model.dart

class BookingModel {
  final int id;
  final String serviceName;
  final String category;
  final DateTime dateTime;
  final String address;
  final String? secondaryAddress;
  final String customerName;
  final double price;
  final String status;

  BookingModel({
    required this.id,
    required this.serviceName,
    required this.category,
    required this.dateTime,
    required this.address,
    this.secondaryAddress,
    required this.customerName,
    required this.price,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // ✅ Parse DATE from booking_date safely
    DateTime datePart = DateTime.now();
    try {
      final dateValue = json['booking_date'];
      if (dateValue is String) {
        // Handle ISO format: "2025-12-29T03:00:00.000000Z"
        datePart = DateTime.parse(dateValue);
      } else if (dateValue is int) {
        // Handle timestamp (rare)
        datePart = DateTime.fromMillisecondsSinceEpoch(dateValue * 1000);
      }
    } catch (e) {
      print('❌ Failed to parse booking_date: $e');
    }

    // ✅ Parse TIME from booking_time ("03:00:00" or "03:00")
    int hour = 0, minute = 0;
    try {
      final timeStr = json['booking_time'] as String?;
      if (timeStr != null) {
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          hour = int.tryParse(parts[0]) ?? 0;
          minute = int.tryParse(parts[1]) ?? 0;
        }
      }
    } catch (e) {
      print('❌ Failed to parse booking_time: $e');
    }

    // ✅ Combine date + time
    final parsedDateTime = DateTime(
      datePart.year,
      datePart.month,
      datePart.day,
      hour,
      minute,
    );

    // ✅ Service & Category from items
    List<dynamic> items = json['items'] ?? [];
    String serviceName = "Service";
    String category = "Cleaning";

    if (items.isNotEmpty && items[0] is Map<String, dynamic>) {
      final firstItem = items[0] as Map<String, dynamic>;
      serviceName = firstItem['name']?.toString() ?? "Service";
    }

    // ✅ ID: Handle both int and String
    int id = 0;
    final idValue = json['id'];
    if (idValue is int) {
      id = idValue;
    } else if (idValue is String) {
      id = int.tryParse(idValue) ?? 0;
    }

    // ✅ Address & Customer Name
    final address = json['address']?.toString() ?? "Address not available";
    final secondaryAddress = json['apartment']?.toString();

    final firstName = json['first_name']?.toString() ?? '';
    final lastName = json['last_name']?.toString() ?? '';
    final customerName = (firstName.trim() + ' ' + lastName.trim()).trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : "You";

    // ✅ PRICE: Handle BOTH numeric and string values from API
    double price = 0.0;
    final totalValue = json['grand_total'];
    if (totalValue is num) {
      price = totalValue.toDouble(); // ✅ Handles int/double from API
    } else if (totalValue is String) {
      // Remove commas if present (e.g., "1,850.00")
      final cleanValue = totalValue.replaceAll(',', '');
      price = double.tryParse(cleanValue) ?? 0.0;
    }

    // ✅ Status mapping
    String rawStatus = (json['status'] as String?)?.toLowerCase() ?? "pending";
    String status = getStatusFromApi(rawStatus);

    return BookingModel(
      id: id,
      serviceName: serviceName,
      category: category,
      dateTime: parsedDateTime,
      address: address,
      secondaryAddress: secondaryAddress,
      customerName: customerName,
      price: price,
      status: status,
    );
  }

  static String getStatusFromApi(String apiStatus) {
    switch (apiStatus) {
      case 'confirmed':
      case 'booked':
      case 'pending':
      case 'processing':
        return "Confirmed";
      case 'completed':
      case 'delivered':
        return "Completed";
      case 'cancelled':
      case 'canceled':
      case 'failed':
        return "Cancelled";
      default:
        return "Confirmed";
    }
  }

  // ✅ COPYWITH for updating immutable fields
  BookingModel copyWith({
    int? id,
    String? serviceName,
    String? category,
    DateTime? dateTime,
    String? address,
    String? secondaryAddress,
    String? customerName,
    double? price,
    String? status,
  }) {
    return BookingModel(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      address: address ?? this.address,
      secondaryAddress: secondaryAddress ?? this.secondaryAddress,
      customerName: customerName ?? this.customerName,
      price: price ?? this.price,
      status: status ?? this.status,
    );
  }
}