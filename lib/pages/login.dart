import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:new_suvarnraj_group/controller/login_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/pages/home_page.dart';
import 'package:new_suvarnraj_group/pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool isPasswordVisible = false;

  final userCtrl = Get.put(UserController());
  final loginCtrl = Get.put(LoginController());

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool("isLoggedIn");
    if (loggedIn == true) {
      await userCtrl.loadSession();
      Get.offAll(() => HomePage());
    }
  }

  String? validateEmail(String value) {
    if (value.isEmpty) return "Email address is required";
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

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

  Future<void> _handleGoogleSignIn() async {
    final colorScheme = Theme.of(context).colorScheme;
    try {
      await _googleSignIn.signIn();
      if (rememberMe) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
      }
      _showCustomSnackbar("Success", "Signed in with Google", false);
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAll(() => HomePage());
      });
    } catch (error) {
      _showCustomSnackbar("Error", "Google Sign-In Failed", true);
    }
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final emailError = validateEmail(email);
    if (emailError != null) {
      _showCustomSnackbar("Validation Error", emailError, true);
      return;
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      _showCustomSnackbar("Validation Error", passwordError, true);
      return;
    }

    await loginCtrl.login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                "Welcome Back",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 1.2.h),

              Text(
                "Sign in to your account to continue",
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 5.h),

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
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colorScheme.onSurface,
                    ),
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
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter your password",
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

              SizedBox(height: 2.5.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 2.4.h,
                        width: 5.5.w,
                        child: Checkbox(
                          value: rememberMe,
                          activeColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          onChanged: (value) => setState(() => rememberMe = value ?? false),
                        ),
                      ),
                      SizedBox(width: 2.5.w),
                      Text(
                        "Remember me",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => const ForgotPasswordPage());
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loginCtrl.isLoading.value ? null : () => _login(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.1),
                    padding: EdgeInsets.symmetric(vertical: 2.1.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: loginCtrl.isLoading.value
                      ? SizedBox(
                    height: 2.5.h,
                    width: 2.5.h,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    "Sign In",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              )),

              SizedBox(height: 3.h),

              Row(
                children: [
                  Expanded(child: Divider(color: colorScheme.outline, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Text(
                      "or",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colorScheme.outline, thickness: 1)),
                ],
              ),

              SizedBox(height: 3.h),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleGoogleSignIn,
                  icon: Image.network(
                    "https://cdn-icons-png.flaticon.com/512/300/300221.png",
                    height: 2.3.h,
                  ),
                  label: Text(
                    "Continue with Google",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: colorScheme.outline, width: 1.2),
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const RegisterPage());
                    },
                    child: Text(
                      "Sign up now",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}