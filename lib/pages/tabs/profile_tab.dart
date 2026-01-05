// lib/pages/tabs/profile_tab.dart - DARK/LIGHT MODE READY
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:new_suvarnraj_group/controller/profile_controller.dart';
import 'package:new_suvarnraj_group/controller/login_controller.dart';
import 'package:new_suvarnraj_group/controller/logout_controller.dart';
import 'package:flutter/services.dart';
import '../FavoritesPage.dart';
import '../privacy_policy_page.dart';
import '../supportpage.dart';
import 'bookings_tab.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with SingleTickerProviderStateMixin {
  late ProfileController profileCtrl;
  late LoginController loginCtrl;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    profileCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    loginCtrl = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Obx(() {
          if (profileCtrl.isLoading.value && profileCtrl.name.value.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: colorScheme.primary,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Loading Profile...",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => profileCtrl.fetchProfile(),
            color: colorScheme.primary,
            backgroundColor: colorScheme.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(_animationController),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(colorScheme),
                    SizedBox(height: 3.h),
                    _buildContactInfoCard(colorScheme),
                    SizedBox(height: 3.h),
                    _buildMenuSection(
                      title: "Account",
                      icon: Icons.account_circle_outlined,
                      colorScheme: colorScheme,
                      items: [
                        _ProfileMenuItem(
                          icon: FontAwesomeIcons.userPen,
                          text: "Edit Profile",
                          bgColor: colorScheme.primary,
                          onTap: () => _showEditProfileDialog(colorScheme),
                        ),
                        _ProfileMenuItem(
                          icon: FontAwesomeIcons.key,
                          text: "Change Password",
                          bgColor: Colors.deepOrange, // brand color → keep
                          onTap: () => _showChangePasswordDialog(colorScheme),
                        ),
                        _ProfileMenuItem(
                          icon: FontAwesomeIcons.bookOpen,
                          text: "My Bookings",
                          bgColor: Colors.green, // brand color → keep
                          onTap: () => Get.to(
                                () => const BookingsTab(),
                            transition: Transition.rightToLeft,
                          ),
                        ),
                        _ProfileMenuItem(
                          icon: FontAwesomeIcons.shieldAlt,
                          text: "Privacy Policy",
                          bgColor: Colors.indigo, // brand color → keep
                          onTap: () => Get.to(
                                () => const PrivacyPolicyPage(),
                            transition: Transition.rightToLeft,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    _buildMenuSection(
                      title: "Explore",
                      icon: Icons.explore_outlined,
                      colorScheme: colorScheme,
                      items: [
                        _ProfileMenuItem(
                          icon: FontAwesomeIcons.heart,
                          text: "Favorites",
                          bgColor: Colors.pink, // brand color → keep
                          onTap: () => Get.to(
                                () => const FavoritesPage(),
                            transition: Transition.rightToLeft,
                          ),
                        ),
                        _ProfileMenuItem(
                          icon: FontAwesomeIcons.headset,
                          text: "Support & Help",
                          bgColor: Colors.purple, // brand color → keep
                          onTap: () => Get.to(
                                () => const SupportPage(),
                            transition: Transition.rightToLeft,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    _buildMenuSection(
                      title: "Security",
                      icon: Icons.security_outlined,
                      colorScheme: colorScheme,
                      items: [
                        _ProfileMenuItem(
                          icon: FontAwesomeIcons.arrowRightFromBracket,
                          text: "Logout",
                          color: colorScheme.error,
                          bgColor: colorScheme.error.withOpacity(0.1),
                          onTap: () => _showLogoutDialog(colorScheme),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Version 1.0.0",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: colorScheme.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            "Made with ❤️ by Suvarnraj Group",
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfileHeader(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary.withOpacity(0.9), colorScheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 12.w,
              backgroundColor: Colors.white,
              child: Text(
                profileCtrl.name.value.isNotEmpty
                    ? profileCtrl.name.value[0].toUpperCase()
                    : 'G',
                style: TextStyle(
                  fontSize: 22.sp,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  profileCtrl.name.value.isNotEmpty
                      ? profileCtrl.name.value
                      : "Guest User",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.9.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 2.w),
                      Flexible(
                        child: Text(
                          profileCtrl.email.value.isNotEmpty
                              ? profileCtrl.email.value
                              : "No email",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.contact_phone_outlined,
                  color: colorScheme.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                "Contact Information",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),
          _contactItem(
            Icons.phone_android_outlined,
            profileCtrl.phone.value.isNotEmpty
                ? profileCtrl.phone.value
                : "No phone added",
            colorScheme.primary,
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _contactItem(IconData icon, String text, Color iconColor, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.8.w),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required IconData icon,
    required ColorScheme colorScheme,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: colorScheme.onSurface.withOpacity(0.7),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 2.5.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 0, thickness: 0.8, color: colorScheme.outlineVariant),
            ...items,
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(ColorScheme colorScheme) {
    final nameCtrl = TextEditingController(text: profileCtrl.name.value);
    final emailCtrl = TextEditingController(text: profileCtrl.email.value);
    final phoneCtrl = TextEditingController(text: profileCtrl.phone.value);
    final formKey = GlobalKey<FormState>();
    final originalName = profileCtrl.name.value;
    final originalEmail = profileCtrl.email.value;
    final originalPhone = profileCtrl.phone.value;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(5.w),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, color: colorScheme.primary, size: 26.sp),
                        SizedBox(width: 3.w),
                        Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  _buildFormField(
                    controller: nameCtrl,
                    label: "Full Name",
                    hint: "Enter your full name",
                    icon: Icons.person_outline,
                    colorScheme: colorScheme,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]*$'))],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Name is required";
                      if (value.trim().length < 3) return "Name must be at least 3 characters";
                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                        return "Only letters and spaces allowed";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),
                  _buildFormField(
                    controller: emailCtrl,
                    label: "Email Address",
                    hint: "example@domain.com",
                    icon: Icons.email_outlined,
                    colorScheme: colorScheme,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Email is required";
                      if (!GetUtils.isEmail(value.trim())) return "Enter a valid email";
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),
                  _buildFormField(
                    controller: phoneCtrl,
                    label: "Phone Number",
                    hint: "10-digit mobile number",
                    icon: Icons.phone_outlined,
                    colorScheme: colorScheme,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Phone is required";
                      if (value.trim().length != 10) return "Must be 10 digits";
                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
                        return "Must start with 6, 7, 8, or 9";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 4.h),
                  Obx(() => Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: profileCtrl.isLoading.value
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: colorScheme.outline),
                            foregroundColor: colorScheme.onSurface,
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: profileCtrl.isLoading.value
                              ? null
                              : () async {
                            if (formKey.currentState!.validate()) {
                              bool hasChanges =
                                  nameCtrl.text.trim() != originalName.trim() ||
                                      emailCtrl.text.trim() != originalEmail.trim() ||
                                      phoneCtrl.text.trim() != originalPhone.trim();
                              if (!hasChanges) {
                                Get.snackbar(
                                  "No Changes",
                                  "Profile information is the same",
                                  backgroundColor: colorScheme.onSurface.withOpacity(0.1),
                                  colorText: colorScheme.onSurface,
                                  duration: const Duration(seconds: 2),
                                );
                                return;
                              }
                              final success = await profileCtrl.updateProfile(
                                name: nameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                              );
                              if (success && context.mounted) {
                                Navigator.pop(context);
                                Get.snackbar(
                                  "Success",
                                  "Profile updated successfully",
                                  backgroundColor: colorScheme.inversePrimary.withOpacity(0.1),
                                  colorText: colorScheme.inversePrimary,
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: profileCtrl.isLoading.value
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Text(
                            "Save Changes",
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(ColorScheme colorScheme) {
    final currentPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    final confirmPwdCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(5.w),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_reset_outlined, color: Colors.deepOrange[600], size: 26.sp),
                          SizedBox(width: 3.w),
                          Text(
                            "Change Password",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    _buildPasswordField(
                      controller: currentPwdCtrl,
                      label: "Current Password",
                      hint: "Enter current password",
                      colorScheme: colorScheme,
                      onVisibilityToggle: () => setState(() {}),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Current password is required"
                          : null,
                    ),
                    SizedBox(height: 2.h),
                    _buildPasswordField(
                      controller: newPwdCtrl,
                      label: "New Password",
                      hint: "Min 6 characters",
                      colorScheme: colorScheme,
                      onVisibilityToggle: () => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "New password is required";
                        }
                        if (value.length < 6) return "Min 6 characters";
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    _buildPasswordField(
                      controller: confirmPwdCtrl,
                      label: "Confirm Password",
                      hint: "Re-enter new password",
                      colorScheme: colorScheme,
                      onVisibilityToggle: () => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please confirm password";
                        }
                        if (value != newPwdCtrl.text) {
                          return "Passwords don't match";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 4.h),
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: profileCtrl.isLoading.value
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 1.8.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: colorScheme.outline),
                              foregroundColor: colorScheme.onSurface,
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: profileCtrl.isLoading.value
                                ? null
                                : () async {
                              if (formKey.currentState!.validate()) {
                                final success = await profileCtrl.updatePassword(
                                  currentPassword: currentPwdCtrl.text.trim(),
                                  newPassword: newPwdCtrl.text.trim(),
                                  confirmPassword: confirmPwdCtrl.text.trim(),
                                );
                                if (success && context.mounted) {
                                  Navigator.pop(context);
                                  Get.snackbar(
                                    "Success",
                                    "Password changed successfully",
                                    backgroundColor: colorScheme.inversePrimary.withOpacity(0.1),
                                    colorText: colorScheme.inversePrimary,
                                    duration: const Duration(seconds: 2),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange[600],
                              padding: EdgeInsets.symmetric(vertical: 1.8.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: profileCtrl.isLoading.value
                                ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : Text(
                              "Update Password",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(ColorScheme colorScheme) {
    final logoutCtrl = Get.isRegistered<LogoutController>()
        ? Get.find<LogoutController>()
        : Get.put(LogoutController());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.logout,
                  color: colorScheme.error,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "Logout",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: colorScheme.outline),
                        foregroundColor: colorScheme.onSurface,
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      onPressed: logoutCtrl.isLoading.value
                          ? null
                          : () async {
                        Navigator.pop(context);
                        await logoutCtrl.logoutUser();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: logoutCtrl.isLoading.value
                          ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: colorScheme.onError,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Text(
                        "Logout",
                        style: TextStyle(
                          color: colorScheme.onError,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(fontSize: 12.sp, color: colorScheme.onSurface),
        hintStyle: TextStyle(fontSize: 12.sp, color: colorScheme.onSurface.withOpacity(0.6)),
        floatingLabelStyle: TextStyle(color: colorScheme.primary),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ColorScheme colorScheme,
    required VoidCallback onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    bool showPassword = false;
    return StatefulBuilder(
      builder: (context, setState) => TextFormField(
        controller: controller,
        obscureText: !showPassword,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(Icons.lock_outline, color: Colors.deepOrange[600]),
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.deepOrange[600],
            ),
            onPressed: () => setState(() => showPassword = !showPassword),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepOrange[600]!, width: 2),
          ),
          labelStyle: TextStyle(fontSize: 12.sp, color: colorScheme.onSurface),
          hintStyle: TextStyle(fontSize: 12.sp, color: colorScheme.onSurface.withOpacity(0.6)),
          floatingLabelStyle: TextStyle(color: Colors.deepOrange[600]),
        ),
        validator: validator,
      ),
    );
  }
}

class _ProfileMenuItem extends StatefulWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;
  const _ProfileMenuItem({
    required this.icon,
    required this.text,
    this.color = Colors.black,
    this.bgColor = Colors.blue,
    this.onTap,
  });

  @override
  State<_ProfileMenuItem> createState() => _ProfileMenuItemState();
}

class _ProfileMenuItemState extends State<_ProfileMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = widget.color == Colors.black ? colorScheme.onSurface : widget.color;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isHovered ? colorScheme.surface.withOpacity(0.5) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
            leading: Container(
              padding: EdgeInsets.all(2.8.w),
              decoration: BoxDecoration(
                color: widget.bgColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: widget.bgColor, size: 21.sp),
            ),
            title: Text(
              widget.text,
              style: TextStyle(
                color: effectiveColor,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                letterSpacing: 0.2,
              ),
            ),
            trailing: AnimatedRotation(
              turns: _isHovered ? 0.15 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: colorScheme.outline,
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}