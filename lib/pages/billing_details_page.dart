import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/pages/success_animation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../api/api_service.dart';
import '../controller/booking_controller.dart';
import '../controller/cart_controller.dart';
import '../controller/user_controller.dart';
import 'home_page.dart';

class BillingDetailsPage extends StatefulWidget {
  final Map<String, dynamic> billingData;
  const BillingDetailsPage({super.key, required this.billingData});

  @override
  State<BillingDetailsPage> createState() => _BillingDetailsPageState();
}

class _BillingDetailsPageState extends State<BillingDetailsPage> {
  DateTime? bookingDate;
  String? bookingTime;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController couponController = TextEditingController();

  bool hasCoupon = false;
  double discount = 0.0;
  String appliedCoupon = "";
  String paymentMethod = "cod";
  int? selectedCityId;
  String? selectedCityName;

  bool _isProcessing = false;
  bool _citiesLoading = true;
  List<Map<String, dynamic>> cities = [];

  final List<String> times = ["09:00 AM", "12:00 PM", "03:00 PM", "06:00 PM"];

  late UserController userCtrl;
  late CartController cartCtrl;
  late BookingController bookingCtrl;

  @override
  void initState() {
    super.initState();
    userCtrl = Get.find<UserController>();
    cartCtrl = Get.find<CartController>();
    bookingCtrl = Get.find<BookingController>();

    _loadUserData();
    _fetchCities();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fullName = prefs.getString("name") ?? "";
      final email = prefs.getString("email") ?? "";
      final phone = prefs.getString("phone") ?? "";

      final parts = fullName.trim().split(' ');
      firstNameController.text = parts.isNotEmpty ? parts.first : "";
      lastNameController.text = parts.length > 1 ? parts.sublist(1).join(' ') : "";
      emailController.text = email;
      phoneController.text = phone;
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  Future<void> _fetchCities() async {
    try {
      setState(() => _citiesLoading = true);

      final token = userCtrl.token.value;
      final response = await ApiService.fetchCheckoutData(
        token: token.isNotEmpty ? token : null,
      );

      final fetchedCities = response['data']['areas'] as List<dynamic>?;

      if (fetchedCities != null) {
        setState(() {
          cities = fetchedCities.map((c) {
            return {
              'id': c['id'] as int? ?? 0,
              'name': c['name'] as String? ?? 'Unknown',
            };
          }).toList();
          _citiesLoading = false;
        });
      } else {
        setState(() => _citiesLoading = false);
        _showError('No cities available');
      }
    } catch (e) {
      setState(() => _citiesLoading = false);
      _showError('Failed to load cities: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    apartmentController.dispose();
    stateController.dispose();
    pinController.dispose();
    couponController.dispose();
    super.dispose();
  }

  late ColorScheme _colorScheme;

  @override
  Widget build(BuildContext context) {
    _colorScheme = Theme.of(context).colorScheme;
    final items = widget.billingData["items"] as List<dynamic>;
    final total = (widget.billingData["totalAmount"] as num).toDouble();
    final payable = (total - discount).clamp(0.0, double.infinity);
    final advance = (payable * 0.1).toInt();

    return Scaffold(
      backgroundColor: _colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: _colorScheme.surface,
              elevation: 1,
              expandedHeight: 12.h,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                title: Center(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 80),
                        child: FaIcon(FontAwesomeIcons.receipt, size: 18.sp, color: _colorScheme.primary),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          "Booking & Billing",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: _colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                background: Container(color: _colorScheme.surface),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(4.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildBookingScheduleCard(),
                  SizedBox(height: 2.h),
                  _buildPersonalInfoCard(),
                  SizedBox(height: 2.h),
                  _buildAddressDetailsCard(),
                  SizedBox(height: 2.h),
                  _buildCouponCard(total),
                  SizedBox(height: 2.h),
                  _buildOrderSummaryCard(items, total, payable, advance),
                  SizedBox(height: 2.h),
                  _buildPaymentMethodCard(),
                  SizedBox(height: 2.h),
                  _buildConfirmButton(payable),
                  SizedBox(height: 3.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingScheduleCard() {
    return _fancyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            FaIcon(FontAwesomeIcons.calendarAlt, size: 18.sp, color: Colors.purple),
            SizedBox(width: 3.w),
            Text("Booking Schedule", style: _boldStyle()),
          ]),
          SizedBox(height: 2.h),
          _calendarDatePicker(),
          SizedBox(height: 2.h),
          _timeDropdown(),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return _fancyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            FaIcon(FontAwesomeIcons.user, size: 18.sp, color: Colors.teal),
            SizedBox(width: 3.w),
            Text("Personal Information", style: _boldStyle()),
          ]),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(child: _buildTextField("First Name *", firstNameController, Icons.person)),
              SizedBox(width: 3.w),
              Expanded(child: _buildTextField("Last Name *", lastNameController, null)),
            ],
          ),
          SizedBox(height: 2.h),
          _buildTextField("Email *", emailController, Icons.email, TextInputType.emailAddress),
          SizedBox(height: 2.h),
          _buildTextField("Phone *", phoneController, Icons.phone, TextInputType.phone, 10),
        ],
      ),
    );
  }

  Widget _buildAddressDetailsCard() {
    return _fancyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            FaIcon(FontAwesomeIcons.mapMarkedAlt, size: 18.sp, color: Colors.red),
            SizedBox(width: 3.w),
            Text("Address Details", style: _boldStyle()),
          ]),
          SizedBox(height: 2.h),

          if (_citiesLoading)
            SizedBox(
              height: 5.h,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_colorScheme.primary),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      "Loading cities...",
                      style: _bodyStyle().copyWith(color: _colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            )
          else if (cities.isEmpty)
            Container(
              padding: EdgeInsets.all(2.h),
              decoration: BoxDecoration(
                color: _colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: _colorScheme.error),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      "No cities available. Please try again.",
                      style: _bodyStyle().copyWith(color: _colorScheme.error),
                    ),
                  ),
                  TextButton(
                    onPressed: _fetchCities,
                    child: Text(
                      "Retry",
                      style: _bodyStyle().copyWith(color: _colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          else
            DropdownButtonFormField<int>(
              value: selectedCityId,
              isExpanded: true,
              items: cities.map((city) {
                return DropdownMenuItem<int>(
                  value: city['id'],
                  child: Text(
                    city['name'],
                    style: _bodyStyle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  final city = cities.firstWhere((c) => c['id'] == val);
                  setState(() {
                    selectedCityId = val;
                    selectedCityName = city['name'];
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Select City / Area *",
                labelStyle: _bodyStyle(),
                prefixIcon: Icon(Icons.location_city, size: 18.sp, color: _colorScheme.onSurface.withOpacity(0.6)),
                contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w)),
                filled: true,
                fillColor: _colorScheme.surface,
              ),
            ),

          SizedBox(height: 2.h),
          _buildTextField("Address *", addressController, Icons.location_on, TextInputType.text, null, 2),
          SizedBox(height: 2.h),
          _buildTextField("Apartment/Landmark", apartmentController, Icons.home_outlined),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(child: _buildTextField("State *", stateController, null)),
              SizedBox(width: 3.w),
              Expanded(child: _buildTextField("Pin *", pinController, null, TextInputType.number, 6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(double total) {
    return _fancyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            FaIcon(FontAwesomeIcons.tag, size: 18.sp, color: Colors.indigo),
            SizedBox(width: 3.w),
            Text("Discount Coupon", style: _boldStyle()),
          ]),
          SizedBox(height: 1.h),
          CheckboxListTile(
            value: hasCoupon,
            onChanged: (val) {
              setState(() {
                hasCoupon = val ?? false;
                if (!hasCoupon) {
                  discount = 0.0;
                  appliedCoupon = "";
                  couponController.clear();
                }
              });
            },
            title: Text("I have a discount coupon", style: _bodyStyle()),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: _colorScheme.primary,
          ),
          if (hasCoupon)
            Row(
              children: [
                Expanded(child: _buildTextField("Coupon Code", couponController, null)),
                SizedBox(width: 3.w),
                ElevatedButton.icon(
                  icon: FaIcon(FontAwesomeIcons.check, size: 14.sp, color: Colors.white),
                  label: Text("Apply", style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () => _applyCoupon(total),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
                  ),
                ),
              ],
            ),
          if (appliedCoupon.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Text(
                "Applied: $appliedCoupon - Saved ₹${discount.toStringAsFixed(0)}",
                style: TextStyle(color: _colorScheme.secondary, fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(List<dynamic> items, double total, double payable, int advance) {
    return _fancyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            FaIcon(FontAwesomeIcons.shoppingCart, size: 18.sp, color: Colors.orange),
            SizedBox(width: 3.w),
            Text("Order Summary", style: _boldStyle()),
          ]),
          SizedBox(height: 2.h),
          ...items.map((item) => Padding(
            padding: EdgeInsets.symmetric(vertical: 0.6.h),
            child: Row(
              children: [
                Expanded(
                  child: Text("${item['title']} × ${item['quantity']}", style: _bodyStyle()),
                ),
                Text(
                  "₹${((item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(0)}",
                  style: _boldStyle(),
                ),
              ],
            ),
          )),
          Divider(color: _colorScheme.outlineVariant, thickness: 0.3.h),
          _summaryRow("Subtotal", "₹${total.toStringAsFixed(0)}"),
          _summaryRow("Discount", "- ₹${discount.toStringAsFixed(0)}"),
          _summaryRow("Service Charge", "₹50"),
          Divider(color: _colorScheme.outlineVariant, thickness: 0.3.h),
          _summaryRowBold("Final Amount", "₹${payable.toStringAsFixed(0)}"),
          SizedBox(height: 1.h),
          Text(
            "Advance (10%): ₹$advance",
            style: TextStyle(color: _colorScheme.secondary, fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return _fancyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            FaIcon(FontAwesomeIcons.moneyCheckAlt, size: 18.sp, color: Colors.brown),
            SizedBox(width: 3.w),
            Text("Payment Method", style: _boldStyle()),
          ]),
          SizedBox(height: 1.h),
          RadioListTile<String>(
            value: "cod",
            groupValue: paymentMethod,
            onChanged: (val) => setState(() => paymentMethod = val ?? "cod"),
            title: Text("Cash on Delivery (COD)", style: _bodyStyle()),
            secondary: FaIcon(FontAwesomeIcons.moneyBillWave, size: 16.sp),
            contentPadding: EdgeInsets.zero,
            activeColor: _colorScheme.primary,
          ),
          // RadioListTile<String>(
          //   value: "advance",
          //   groupValue: paymentMethod,
          //   onChanged: (val) => setState(() => paymentMethod = val ?? "advance"),
          //   title: Text("Pay 10% Advance", style: _bodyStyle()),
          //   secondary: FaIcon(FontAwesomeIcons.handHoldingUsd, size: 16.sp),
          //   contentPadding: EdgeInsets.zero,
          //   activeColor: _colorScheme.primary,
          // ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(double payable) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _colorScheme.primary,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        ),
        onPressed: _isProcessing ? null : () => _placeOrder(payable),
        child: Text(
          _isProcessing ? "Processing..." : "Confirm Booking • ₹${payable.toStringAsFixed(0)}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: _colorScheme.onPrimary),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData? icon, [
        TextInputType type = TextInputType.text,
        int? maxLength,
        int maxLines = 1,
      ]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: _bodyStyle(),
        prefixIcon: icon != null ? Icon(icon, size: 18.sp, color: _colorScheme.onSurface.withOpacity(0.6)) : null,
        contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
        counterText: "",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.w),
          borderSide: BorderSide(color: _colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.w),
          borderSide: BorderSide(color: _colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: _colorScheme.surface,
      ),
      style: _bodyStyle(),
    );
  }

  Widget _fancyCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4.sp, offset: Offset(0, 2.sp))],
      ),
      padding: EdgeInsets.all(3.w),
      child: child,
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.6.h),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _bodyStyle())),
          Text(value, style: _bodyStyle().copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _summaryRowBold(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.6.h),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _bodyStyle())),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: _colorScheme.primary)),
        ],
      ),
    );
  }

  TextStyle _bodyStyle() => TextStyle(fontSize: 14.sp, height: 1.3, color: _colorScheme.onSurface);
  TextStyle _boldStyle() => TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, height: 1.3, color: _colorScheme.onSurface);

  Widget _calendarDatePicker() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_colorScheme.primary.withOpacity(0.1), _colorScheme.surface],
            ),
            borderRadius: BorderRadius.circular(2.w),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4.sp, offset: Offset(0, 2.sp))],
          ),
          padding: EdgeInsets.all(3.w),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime(DateTime.now().year + 2),
            focusedDay: bookingDate ?? DateTime.now(),
            selectedDayPredicate: (day) => bookingDate != null && isSameDay(bookingDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() => bookingDate = selectedDay);
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _colorScheme.onSurface),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [_colorScheme.primary, _colorScheme.primary.withOpacity(0.7)]),
              ),
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _colorScheme.primary.withOpacity(0.1),
                border: Border.all(color: _colorScheme.primary),
              ),
              defaultTextStyle: TextStyle(color: _colorScheme.onSurface),
              outsideTextStyle: TextStyle(color: _colorScheme.onSurface.withOpacity(0.4)),
            ),
          ),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }

  Widget _timeDropdown() {
    return DropdownButtonFormField<String>(
      value: bookingTime,
      items: times.map((t) => DropdownMenuItem(value: t, child: Text(t, style: _bodyStyle()))).toList(),
      onChanged: (val) => setState(() => bookingTime = val),
      decoration: InputDecoration(
        labelText: "Select Time *",
        labelStyle: _bodyStyle(),
        prefixIcon: Icon(Icons.access_time, size: 18.sp, color: _colorScheme.onSurface.withOpacity(0.6)),
        contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.w)),
        filled: true,
        fillColor: _colorScheme.surface,
      ),
    );
  }

  void _applyCoupon(double total) {
    final enteredCode = couponController.text.trim().toUpperCase();
    final coupons = {"KITCHEN25": 0.25, "CLEAN20": 0.20, "WELCOME30": 0.30};

    if (enteredCode.isEmpty) {
      _showError("Please enter a coupon code");
      return;
    }

    if (coupons.containsKey(enteredCode)) {
      setState(() {
        appliedCoupon = enteredCode;
        discount = total * coupons[enteredCode]!;
      });
      Get.snackbar(
        "Success",
        "Coupon applied! Saved ₹${discount.toStringAsFixed(0)}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _colorScheme.secondary.withOpacity(0.1),
        colorText: _colorScheme.secondary,
        duration: Duration(seconds: 3),
      );
    } else {
      setState(() {
        appliedCoupon = "";
        discount = 0.0;
      });
      _showError("Invalid coupon code");
    }
  }

  // ✅ UPDATED: Robust 400 error handling for duplicate booking
  void _placeOrder(double payable) async {
    if (_isProcessing) return;

    if (!_validateForm()) return;

    final address = addressController.text.trim();
    if (address.length < 10) {
      _showError("Address must be at least 10 characters long.");
      return;
    }

    if (selectedCityName == null || selectedCityName!.isEmpty) {
      _showError("Please select a city.");
      return;
    }

    try {
      setState(() => _isProcessing = true);

      final timeOnly = bookingTime!.split(' ')[0];
      final formattedDate = DateFormat('yyyy-MM-dd').format(bookingDate!);

      final items = widget.billingData["items"] as List<dynamic>;
      final List<Map<String, dynamic>> apiItems = [];
      for (var item in items) {
        apiItems.add({
          "product_id": item['id'],
          "qty": item['quantity'],
          "price": item['price'],
        });
      }

      final response = userCtrl.isLoggedIn.value && userCtrl.token.value.isNotEmpty
          ? await ApiService.placeOrder(
        token: userCtrl.token.value,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        mobile: phoneController.text.trim(),
        address: address,
        apartment: apartmentController.text.trim(),
        state: stateController.text.trim(),
        cityId: selectedCityId!,
        cityName: selectedCityName!,
        zip: pinController.text.trim(),
        bookingDate: formattedDate,
        bookingTime: timeOnly,
        paymentMethod: paymentMethod,
        items: apiItems,
      )
          : await ApiService.placeGuestOrder(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        mobile: phoneController.text.trim(),
        address: address,
        apartment: apartmentController.text.trim(),
        state: stateController.text.trim(),
        cityId: selectedCityId!,
        cityName: selectedCityName!,
        zip: pinController.text.trim(),
        bookingDate: formattedDate,
        bookingTime: timeOnly,
        paymentMethod: paymentMethod,
        items: apiItems,
      );

      final String responseText = response.toString().toLowerCase();
      if (responseText.contains('400') ||
          responseText.contains('already booked') ||
          responseText.contains('already exists') ||
          responseText.contains('duplicate') ||
          responseText.contains('not available')) {
        Get.snackbar(
          "Date Unavailable",
          "The selected date is already booked.\nPlease choose another date.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _colorScheme.error.withOpacity(0.1),
          colorText: _colorScheme.error,
          duration: Duration(seconds: 5),
          margin: EdgeInsets.all(16),
          borderRadius: 12,
          icon: Icon(Icons.date_range, color: _colorScheme.error),
        );
        return;
      }

      if (response['success'] != true) {
        _showError(response['message'] ?? 'Failed to place order');
        return;
      }

      final orderId = response['data']?['order_id'] ?? 'N/A';

      await cartCtrl.clearCart();
      if (userCtrl.isLoggedIn.value) {
        await bookingCtrl.fetchBookings();
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SuccessAnimationScreen(orderId: orderId.toString())),
      );

      _showSuccessDialog(orderId.toString());

    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      print("❌ Error: $errorMsg");

      if (errorMsg.toLowerCase().contains('400') ||
          errorMsg.toLowerCase().contains('already booked') ||
          errorMsg.toLowerCase().contains('duplicate')) {
        Get.snackbar(
          "Date Unavailable",
          "The selected date is already booked.\nPlease choose another date.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _colorScheme.error.withOpacity(0.1),
          colorText: _colorScheme.error,
          duration: Duration(seconds: 5),
          margin: EdgeInsets.all(16),
          borderRadius: 12,
          icon: Icon(Icons.date_range, color: _colorScheme.error),
        );
        return;
      }

      _showError(errorMsg);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  bool _validateForm() {
    if (bookingDate == null) return _showErrorBool("Select booking date");
    if (bookingTime == null) return _showErrorBool("Select booking time");
    if (firstNameController.text.trim().isEmpty) return _showErrorBool("Enter first name");
    if (lastNameController.text.trim().isEmpty) return _showErrorBool("Enter last name");
    if (emailController.text.trim().isEmpty) return _showErrorBool("Enter email");
    if (phoneController.text.trim().isEmpty) return _showErrorBool("Enter phone");
    if (addressController.text.trim().isEmpty) return _showErrorBool("Enter address");
    if (stateController.text.trim().isEmpty) return _showErrorBool("Enter state");
    if (pinController.text.trim().isEmpty) return _showErrorBool("Enter pin");
    if (selectedCityId == null) return _showErrorBool("Select city");

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(emailController.text.trim())) {
      return _showErrorBool("Invalid email");
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneController.text.trim())) {
      return _showErrorBool("Phone must be 10 digits");
    }

    if (pinController.text.trim().length != 6) {
      return _showErrorBool("Pin must be 6 digits");
    }

    return true;
  }

  bool _showErrorBool(String msg) {
    _showError(msg);
    return false;
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _colorScheme.error.withOpacity(0.1),
      colorText: _colorScheme.error,
      duration: Duration(seconds: 3),
    );
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          decoration: BoxDecoration(
            color: _colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
          ),
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(color: _colorScheme.primary, shape: BoxShape.circle),
                padding: EdgeInsets.all(12),
                child: Icon(Icons.check, color: _colorScheme.onPrimary, size: 30),
              ),
              SizedBox(height: 16),
              // ✅ FIXED: No yellow highlight using RichText
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _colorScheme.primary),
                  children: [
                    TextSpan(text: "Order Placed Successfully! ✅"),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text("Order ID: $orderId", style: TextStyle(fontSize: 14, color: _colorScheme.onSurface.withOpacity(0.7))),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.off(() => HomePage()),
                style: ElevatedButton.styleFrom(backgroundColor: _colorScheme.primary),
                child: Text("Go to Home", style: TextStyle(color: _colorScheme.onPrimary)),
              )
            ],
          ),
        ),
      ),
    );
  }
}