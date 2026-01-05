import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/controller/register_controller.dart';
import 'package:new_suvarnraj_group/pages/login.dart';
import 'package:sizer/sizer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool agreeTerms = false;

  final registerCtrl = Get.put(RegisterController());

  // ✅ Validation logic (unchanged)
  String? validateName(String value) {
    if (value.isEmpty) return "Full name is required";
    if (value.length < 3) return "Name must be at least 3 characters";
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return "Name can only contain letters and spaces";
    }
    return null;
  }

  String? validateEmail(String value) {
    if (value.isEmpty) return "Email address is required";
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? validatePhone(String value) {
    if (value.isEmpty) return "Phone number is required";
    if (value.length != 10) return "Phone number must be exactly 10 digits";
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(value)) {
      return "Phone number must start with 6, 7, 8, or 9";
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  String? validateConfirmPassword(String value, String password) {
    if (value.isEmpty) return "Please confirm your password";
    if (value != password) return "Passwords do not match";
    return null;
  }

  // ✅ Snackbar - THEME COMPLIANT
  void _showCustomSnackbar(String title, String message, bool isError) {
    final colorScheme = Theme.of(context).colorScheme;
    final snackbarColor = isError ? colorScheme.error : colorScheme.primary;
    final textColor = isError ? colorScheme.onError : colorScheme.onPrimary;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 5.h, left: 5.w, right: 5.w),
        content: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: snackbarColor.withOpacity(0.1),
            border: Border.all(
              color: snackbarColor.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: snackbarColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 3.5.w,
                height: 3.5.w,
                decoration: BoxDecoration(
                  color: snackbarColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError ? Icons.close : Icons.check,
                  color: textColor,
                  size: 2.2.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: snackbarColor,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: snackbarColor.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    final nameError = validateName(name);
    if (nameError != null) {
      _showCustomSnackbar("Validation Error", nameError, true);
      return;
    }

    final emailError = validateEmail(email);
    if (emailError != null) {
      _showCustomSnackbar("Validation Error", emailError, true);
      return;
    }

    final phoneError = validatePhone(phone);
    if (phoneError != null) {
      _showCustomSnackbar("Validation Error", phoneError, true);
      return;
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      _showCustomSnackbar("Validation Error", passwordError, true);
      return;
    }

    final confirmPasswordError = validateConfirmPassword(confirmPassword, password);
    if (confirmPasswordError != null) {
      _showCustomSnackbar("Validation Error", confirmPasswordError, true);
      return;
    }

    if (!agreeTerms) {
      _showCustomSnackbar("Terms Required", "Please accept Terms & Privacy Policy", true);
      return;
    }

    final success = await registerCtrl.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (success) {
      Get.off(() => const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8.h),

              Image.asset("assets/images/logo.jpg", height: 9.h),
              SizedBox(height: 5.h),

              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 1.2.h),

              Text(
                "Join us for better cleaning services",
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 3.h),

              // Full Name Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Full Name",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.2.h),
                  TextField(
                    controller: nameController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                    style: TextStyle(fontSize: 13.sp, color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: "Enter your full name",
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 3.w, right: 3.w),
                        child: Icon(
                          Icons.person_outline,
                          color: colorScheme.primary,
                          size: 22.sp,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),

              // Email Address Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Email Address",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.2.h),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 13.sp, color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: "Enter your email address",
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 3.w, right: 3.w),
                        child: Icon(
                          Icons.email_outlined,
                          color: colorScheme.primary,
                          size: 22.sp,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),

              // Phone Number Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Phone Number",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.2.h),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(fontSize: 13.sp, color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: "Enter 10-digit mobile number",
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 3.w, right: 3.w),
                        child: Icon(
                          Icons.phone_outlined,
                          color: colorScheme.primary,
                          size: 22.sp,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      counterText: "",
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),

              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.2.h),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    style: TextStyle(fontSize: 13.sp, color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: "Create a password (min 6 characters)",
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 3.w, right: 3.w),
                        child: Icon(
                          Icons.lock_outline,
                          color: colorScheme.primary,
                          size: 22.sp,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 2.w),
                        child: IconButton(
                          icon: Icon(
                            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: colorScheme.primary,
                            size: 22.sp,
                          ),
                          onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),

              // Confirm Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Confirm Password",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.2.h),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible,
                    style: TextStyle(fontSize: 13.sp, color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: "Confirm your password",
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 3.w, right: 3.w),
                        child: Icon(
                          Icons.lock_outline,
                          color: colorScheme.primary,
                          size: 22.sp,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 2.w),
                        child: IconButton(
                          icon: Icon(
                            isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: colorScheme.primary,
                            size: 22.sp,
                          ),
                          onPressed: () => setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible),
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.5.h),

              Row(
                children: [
                  SizedBox(
                    height: 2.4.h,
                    width: 5.5.w,
                    child: Checkbox(
                      value: agreeTerms,
                      activeColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      onChanged: (value) => setState(() => agreeTerms = value ?? false),
                    ),
                  ),
                  SizedBox(width: 2.5.w),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text(
                          "I agree to the ",
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Terms of Service",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                        Text(
                          " and ",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "Privacy Policy",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.5.h),

              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: registerCtrl.isLoading.value ? null : handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.1),
                    padding: EdgeInsets.symmetric(vertical: 2.1.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: registerCtrl.isLoading.value
                      ? SizedBox(
                    height: 2.5.h,
                    width: 2.5.h,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    "Register",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              )),

              SizedBox(height: 3.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.off(() => const LoginPage());
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}