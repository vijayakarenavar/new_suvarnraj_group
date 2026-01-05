// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'controller/booking_controller.dart';
import 'controller/cart_controller.dart';
import 'controller/home_page_controller.dart';
import 'controller/notification_controller.dart';
import 'controller/user_controller.dart';
import 'controller/wishlist_controller.dart';
import 'routes/app_pages.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  final userCtrl = Get.put(UserController());
  await userCtrl.loadSession();

  Get.put(NotificationController());
  Get.put(HomePageController());
  Get.put(CartController());
  Get.put(BookingController());
  Get.put(WishlistController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Suvarnraj Group',

      // 🌞 Light Theme (default)
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      // 🌙 Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // 🔁 Follow system theme (auto switch)
      themeMode: ThemeMode.system,

      // Routing
      initialRoute: AppPages.INITIAL_ROUTE,
      getPages: AppPages.pages,

      // Sizer for responsive design
      builder: (context, widget) {
        return Sizer(
          builder: (context, orientation, deviceType) {
            return widget!;
          },
        );
      },
    );
  }
}