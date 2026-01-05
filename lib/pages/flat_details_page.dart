import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:new_suvarnraj_group/pages/furnished_flat_page.dart';
import 'package:new_suvarnraj_group/pages/unfurnished_flat_page.dart';
import 'package:sizer/sizer.dart';

import 'enquiry_form_page.dart';
import 'home_page.dart';

class FlatDetailsPage extends StatelessWidget {
  const FlatDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Get.back(), // ✅ सोपं आणि काम करणारं
        ),
        title: Text(
          "Flat Cleaning Services",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: isTablet ? 18.sp : 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Professional apartment cleaning services for furnished and unfurnished flats",
                  style: TextStyle(
                    fontSize: isTablet ? 12.sp : 14.sp,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  "Select Your Flat Category",
                  style: TextStyle(
                    fontSize: isTablet ? 16.sp : 18.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),

                // Furnished Flats Card
                _buildFlatCard(
                  context: context,
                  title: "Furnished Flats",
                  subtitle: "Complete cleaning for furnished apartments with furniture care",
                  image: "assets/images/furnished_flat.png",
                  features: const [
                    "Furniture dusting and polishing",
                    "Floor cleaning and mopping",
                    "Kitchen deep cleaning",
                    "Bathroom sanitization",
                    "Window cleaning",
                    "Balcony cleaning"
                  ],
                  isTablet: isTablet,
                  onTap: () => Get.to(() => FurnishedFlatPage()),
                  colorScheme: colorScheme,
                ),
                SizedBox(height: 2.h),

                // Unfurnished Flats Card
                _buildFlatCard(
                  context: context,
                  title: "Unfurnished Flats",
                  subtitle: "Deep cleaning for empty apartments and move-in preparation",
                  image: "assets/images/unfurnished_flat.png",
                  features: const [
                    "Deep floor scrubbing",
                    "Wall cleaning and washing",
                    "Kitchen cabinet cleaning",
                    "Bathroom deep cleaning",
                    "Window and glass cleaning",
                    "Balcony power washing"
                  ],
                  isTablet: isTablet,
                  onTap: () => Get.to(() => UnfurnishedFlatPage()),
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlatCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String image,
    required List<String> features,
    required bool isTablet,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(3.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth > 600;
                  return AspectRatio(
                    aspectRatio: isTablet ? 2.5 : 1.8,
                    child: Image.asset(
                      image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 14.sp : 16.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isTablet ? 11.sp : 13.sp,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: features
                        .map(
                          (f) => Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check,
                                size: isTablet ? 15.sp : 18.sp,
                                color: colorScheme.secondary),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                f,
                                style: TextStyle(
                                  fontSize: isTablet ? 11.sp : 13.sp,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding:
                        EdgeInsets.symmetric(vertical: isTablet ? 1.5.h : 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                      onPressed: onTap,
                      child: Text(
                        "EXPLORE NOW",
                        style: TextStyle(
                          fontSize: isTablet ? 12.sp : 14.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}