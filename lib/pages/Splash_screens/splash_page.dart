// lib/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:new_suvarnraj_group/routes/app_routes.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed(AppRoutes.HOME_PAGE_ROUTE);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // ✅ Theme-aware
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/Cleaning.json',
              width: 300,
              height: 300,
              repeat: true,
            ),
            const SizedBox(height: 80),
            Image.asset("assets/images/logo.jpg", height: 60),
            const SizedBox(height: 20),
            Text(
              "Welcome to Deep Cleaning Services",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary, // ✅ Theme-aware (was green)
              ),
            ),
          ],
        ),
      ),
    );
  }
}