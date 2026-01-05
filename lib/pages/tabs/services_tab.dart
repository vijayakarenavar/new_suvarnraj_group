// ==================== FILE: pages/tabs/services_tab.dart ====================
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:new_suvarnraj_group/pages/enquiry_form_page.dart';
import 'package:new_suvarnraj_group/api/api_contact.dart';
import 'package:new_suvarnraj_group/models/contact_model.dart';

// ==================== SERVICES TAB ====================
class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});

  static const List<Map<String, String>> services = [
    {"title": "Flats", "subtitle": "Complete apartment cleaning", "image": "assets/images/flat.png"},
    {"title": "Bungalows", "subtitle": "Full house deep cleaning", "image": "assets/images/bungalow.png"},
    {"title": "Offices", "subtitle": "Commercial workspace cleaning", "image": "assets/images/office.png"},
    {"title": "Societies", "subtitle": "Community area maintenance", "image": "assets/images/society.png"},
    {"title": "Restaurant Cleaning", "subtitle": "Food service hygiene", "image": "assets/images/restaurant.png"},
    {"title": "Shops Cleaning", "subtitle": "Retail space maintenance", "image": "assets/images/shops.png"},
    {"title": "School/Colleges Cleaning", "subtitle": "Educational facility care", "image": "assets/images/school.png"},
    {"title": "Car Wash", "subtitle": "Vehicle cleaning service", "image": "assets/images/carwash.png"},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "OTHER\n",
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  TextSpan(
                    text: "SERVICES\n",
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Container(height: 0.5.h, width: 20.w, color: colorScheme.error),
            SizedBox(height: 1.h),
            Text(
              "Choose from our wide range of cleaning services",
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13.sp),
            ),
            SizedBox(height: 3.h),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 2,
                crossAxisSpacing: 2.w,
                mainAxisSpacing: 2.w,
                childAspectRatio: isTablet ? 1.1 : 0.8,
              ),
              itemBuilder: (context, index) {
                final service = services[index];
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: _AnimatedServiceCard(
                    title: service["title"]!,
                    subtitle: service["subtitle"]!,
                    image: service["image"]!,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedServiceCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String image;

  const _AnimatedServiceCard({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  State<_AnimatedServiceCard> createState() => _AnimatedServiceCardState();
}

class _AnimatedServiceCardState extends State<_AnimatedServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTap: () {
            final controller = Get.find<HomePageController>();
            if (widget.title == "Flats") {
              controller.changeTab(5);
            } else {
              Get.to(() => EnquiryFormPage(serviceName: widget.title));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.w),
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(3.w),
                    topRight: Radius.circular(3.w),
                  ),
                  child: Image.asset(
                    widget.image,
                    height: isTablet ? 20.h : 15.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 14.sp : 12.sp,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        widget.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 12.sp : 11.sp,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Row(
                    children: [
                      Text(
                        "View Details",
                        style: TextStyle(
                          fontSize: isTablet ? 13.sp : 11.sp,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: isTablet ? 13.sp : 11.sp,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== ENQUIRY FORM PAGE ====================
class EnquiryFormPage extends StatefulWidget {
  final String serviceName;
  const EnquiryFormPage({super.key, required this.serviceName});

  @override
  State<EnquiryFormPage> createState() => _EnquiryFormPageState();
}

class _EnquiryFormPageState extends State<EnquiryFormPage> {
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController areaCtrl = TextEditingController();
  final TextEditingController messageCtrl = TextEditingController();

  String? selectedService;
  DateTime? selectedDate;
  String? selectedTime;
  bool orderInspection = false;
  bool _isSubmitting = false;

  static const double inspectionPrice = 200.0;

  final List<String> services = [
    "Choose Service",
    "Flats Cleaning",
    "Bungalows Cleaning",
    "Offices Cleaning",
    "Societies Cleaning",
    "Restaurant Cleaning",
    "Shops Cleaning",
    "School/College Cleaning",
    "Car Wash"
  ];

  static const List<String> timeSlots = [
    "10:00 AM",
    "10:30 AM",
    "11:00 AM",
    "11:30 AM",
    "12:00 PM",
    "02:00 PM",
    "02:30 PM",
    "03:00 PM",
    "03:30 PM",
    "04:00 PM",
    "04:30 PM",
    "05:00 PM"
  ];

  @override
  void initState() {
    super.initState();
    if (services.contains(widget.serviceName)) {
      selectedService = widget.serviceName;
    } else {
      selectedService = "Choose Service";
    }
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    mobileCtrl.dispose();
    addressCtrl.dispose();
    stateCtrl.dispose();
    cityCtrl.dispose();
    areaCtrl.dispose();
    messageCtrl.dispose();
    super.dispose();
  }

  void _showPopup(String msg, {bool success = true}) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: success ? colorScheme.primary : colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _submitEnquiry() async {
    final firstName = firstNameCtrl.text.trim();
    final email = emailCtrl.text.trim();

    if (firstName.isEmpty || email.isEmpty) {
      _showPopup("First Name and Email are required!", success: false);
      return;
    }

    if (selectedService == "Choose Service") {
      _showPopup("Please select a service!", success: false);
      return;
    }

    if (orderInspection && (selectedDate == null || selectedTime == null)) {
      _showPopup("Please select date and time for inspection!", success: false);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final contact = Contact(
        firstName: firstName,
        email: email,
        mobile: mobileCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        state: stateCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        service: selectedService ?? 'Choose Service',
        area: areaCtrl.text.trim(),
        date: selectedDate?.toIso8601String(),
        time: selectedTime,
        orderInspection: orderInspection ? "1" : "0",
        message: messageCtrl.text.trim(),
      );

      print("📤 Submitting contact: ${contact.toJson()}");

      final res = await ApiContact.submitContact(contact);
      print("📥 Response: $res");

      if (res["status"] == true || res["success"] == true) {
        _showPopup(res["message"] ?? "Enquiry submitted successfully!", success: true);

        if (orderInspection) {
          Future.delayed(const Duration(seconds: 2), () {
            _initiatePayment();
          });
        } else {
          Future.delayed(const Duration(seconds: 2), () {
            Get.back();
          });
        }
      } else {
        _showPopup(res["message"] ?? "Failed to submit enquiry", success: false);
      }
    } on SocketException {
      _showPopup("Network error. Please check your connection!", success: false);
    } on TimeoutException {
      _showPopup("Request timeout. Please try again!", success: false);
    } catch (e) {
      print("❌ Error: $e");
      _showPopup("Error: ${e.toString()}", success: false);
    }

    setState(() => _isSubmitting = false);
  }

  void _initiatePayment() {
    _showPopup("Redirecting to PhonePe...", success: true);
    // TODO: Implement PhonePe payment gateway
  }

  InputDecoration _inputDecoration(String label, {String? hint, BuildContext? context}) {
    final colorScheme = Theme.of(context!).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: colorScheme.surface,
      labelStyle: TextStyle(color: colorScheme.onSurface),
      hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit an Enquiry"),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // Header Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: colorScheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Fill details below to submit your service enquiry",
                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Personal Information Section
            _sectionTitle("Personal Information", colorScheme),
            const SizedBox(height: 12),

            isTablet
                ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: firstNameCtrl,
                    decoration: _inputDecoration("First Name", hint: "John", context: context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: lastNameCtrl,
                    decoration: _inputDecoration("Last Name", hint: "Doe", context: context),
                  ),
                ),
              ],
            )
                : Column(
              children: [
                TextField(controller: firstNameCtrl, decoration: _inputDecoration("First Name", hint: "John", context: context)),
                const SizedBox(height: 12),
                TextField(controller: lastNameCtrl, decoration: _inputDecoration("Last Name", hint: "Doe", context: context)),
              ],
            ),

            const SizedBox(height: 12),
            isTablet
                ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: emailCtrl,
                    decoration: _inputDecoration("Email", hint: "john@example.com", context: context),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: mobileCtrl,
                    decoration: _inputDecoration("Mobile", hint: "10 digits", context: context),
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                  ),
                ),
              ],
            )
                : Column(
              children: [
                TextField(
                  controller: emailCtrl,
                  decoration: _inputDecoration("Email", hint: "john@example.com", context: context),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mobileCtrl,
                  decoration: _inputDecoration("Mobile", hint: "10 digits", context: context),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Location Information
            _sectionTitle("Location Information", colorScheme),
            const SizedBox(height: 12),

            TextField(
              controller: addressCtrl,
              maxLines: 2,
              decoration: _inputDecoration("Address", hint: "Enter complete address", context: context),
            ),
            const SizedBox(height: 12),

            isTablet
                ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: stateCtrl,
                    decoration: _inputDecoration("State", hint: "Maharashtra", context: context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: cityCtrl,
                    decoration: _inputDecoration("City", hint: "Pune", context: context),
                  ),
                ),
              ],
            )
                : Column(
              children: [
                TextField(controller: stateCtrl, decoration: _inputDecoration("State", hint: "Maharashtra", context: context)),
                const SizedBox(height: 12),
                TextField(controller: cityCtrl, decoration: _inputDecoration("City", hint: "Pune", context: context)),
              ],
            ),

            const SizedBox(height: 12),
            TextField(
              controller: areaCtrl,
              decoration: _inputDecoration("Total Area in Sq. Ft.", hint: "if known", context: context),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            // Service & Message
            _sectionTitle("Service Details", colorScheme),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedService,
              items: services.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => selectedService = val),
              decoration: _inputDecoration("Service", context: context),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: messageCtrl,
              maxLines: 3,
              decoration: _inputDecoration("Message", hint: "Tell us more about your requirements", context: context),
            ),

            const SizedBox(height: 24),

            // Inspection Section
            _inspectionSection(colorScheme),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEnquiry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : Text(
                  "Submit Enquiry",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _inspectionSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: orderInspection,
                onChanged: (val) => setState(() => orderInspection = val ?? false),
                activeColor: colorScheme.primary,
              ),
              Expanded(
                child: Text(
                  "Order inspection at just Rs ${inspectionPrice.toStringAsFixed(0)}/-",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: colorScheme.onSurface),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "*",
                  style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.onSurface.withOpacity(0.7), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "You will be redirected to PhonePe gateway to complete the Rs ${inspectionPrice.toStringAsFixed(0)} payment for inspection scheduling.",
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          if (orderInspection) ...[
            const SizedBox(height: 16),
            _sectionTitle("Schedule Your Inspection", colorScheme),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.surface,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedDate != null
                            ? DateFormat("dd-MM-yyyy").format(selectedDate!)
                            : "Select Date (from tomorrow)",
                        style: TextStyle(
                          fontSize: 14,
                          color: selectedDate != null ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedTime,
              items: timeSlots.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => selectedTime = val),
              decoration: _inputDecoration("Inspection Time *", hint: "Select Time", context: context),
            ),
            const SizedBox(height: 8),
            Text(
              "Available between 10:00 AM - 5:00 PM",
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ],
      ),
    );
  }
}