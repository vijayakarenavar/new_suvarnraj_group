// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/notification_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/controller/wishlist_controller.dart';
import 'package:new_suvarnraj_group/pages/billing_details_page.dart';
import 'package:new_suvarnraj_group/pages/enquiry_form_page.dart';
import 'package:new_suvarnraj_group/pages/flat_details_page.dart';
import 'package:new_suvarnraj_group/pages/furnished_flat_page.dart';
import 'package:new_suvarnraj_group/pages/login.dart';
import 'package:new_suvarnraj_group/pages/notification_page.dart';
import 'package:new_suvarnraj_group/pages/tabs/bookings_tab.dart';
import 'package:new_suvarnraj_group/pages/tabs/home_tab.dart';
import 'package:new_suvarnraj_group/pages/tabs/profile_tab.dart';
import 'package:new_suvarnraj_group/pages/tabs/services_tab.dart' hide ServicesTab, EnquiryFormPage;
import 'package:new_suvarnraj_group/pages/cart_page.dart';
import 'package:new_suvarnraj_group/pages/unfurnished_flat_page.dart';
import 'package:new_suvarnraj_group/pages/wishlist_page.dart';

class HomePageTabs {
  static const int home = 0;
  static const int services = 1;
  static const int bookings = 2;
  static const int profile = 3;
  static const int cart = 4;
  static const int flatDetails = 5;
  static const int furnishedFlat = 6;
  static const int unfurnishedFlat = 7;
  static const int enquiry = 8;
  static const int billing = 9;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomePageController controller;
  late final CartController cartController;
  late final NotificationController notifCtrl;
  late final UserController userCtrl;
  late final WishlistController wishlistCtrl;

  final PageController pageController = PageController();

  final List<Widget> swipePages = [
    HomeTab(),
    const ServicesTab(),
    const BookingsTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomePageController());
    cartController = Get.find<CartController>();
    notifCtrl = Get.find<NotificationController>();
    userCtrl = Get.find<UserController>();
    wishlistCtrl = Get.find<WishlistController>();
    wishlistCtrl.updateWishlistCount();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 🔑 एकदा घ्या
    final colorScheme = theme.colorScheme;

    final screenWidth = MediaQuery.of(context).size.width;
    final appBarHeight = screenWidth < 400 ? 56.0 : 64.0;
    final logoHeight = screenWidth < 400 ? 35.0 : 45.0;
    final logoPadding = screenWidth < 400 ? 10.0 : 12.0;

    return Scaffold(
      backgroundColor: colorScheme.background, // ✅ ऑटोमॅटिक light/dark
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Obx(() {
          if (controller.isSearchingBarVisible.value) {
            return AppBar(
              backgroundColor: colorScheme.surface, // ✅
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface), // ✅
                onPressed: () => controller.toggleSearch(),
              ),
              title: TextField(
                decoration: InputDecoration(
                  hintText: "Search services...",
                  hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)), // ✅
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: TextStyle(color: colorScheme.onSurface), // ✅
                onChanged: controller.updateSearch,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => controller.toggleSearch(),
              ),
            );
          } else {
            return AppBar(
              elevation: 0,
              backgroundColor: colorScheme.surface, // ✅
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              toolbarHeight: appBarHeight,
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: logoPadding),
                child: Image.asset(
                  "assets/images/logo.jpg",
                  height: logoHeight * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: IconButton(
                    onPressed: () => controller.toggleSearch(),
                    icon: Icon(Icons.search, color: colorScheme.onSurface, size: 24), // ✅
                  ),
                ),
                // Notifications
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => Get.to(() => NotificationsPage()),
                        icon: Icon(Icons.notifications_none, color: colorScheme.onSurface, size: 26), // ✅
                        padding: const EdgeInsets.all(8),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Obx(() => notifCtrl.notifications.isNotEmpty
                            ? Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(color: colorScheme.error, shape: BoxShape.circle), // ✅
                          child: Text(
                            "${notifCtrl.notifications.length}",
                            style: TextStyle(color: colorScheme.onError, fontSize: 11, fontWeight: FontWeight.bold), // ✅
                          ),
                        )
                            : const SizedBox()),
                      ),
                    ],
                  ),
                ),
                // Wishlist
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => Get.to(() => WishlistPage()),
                        icon: Icon(Icons.favorite_outline, color: colorScheme.onSurface, size: 26), // ✅
                        padding: const EdgeInsets.all(8),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Obx(() => wishlistCtrl.wishlistCount.value > 0
                            ? Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(color: colorScheme.error, shape: BoxShape.circle), // ✅
                          child: Text(
                            "${wishlistCtrl.wishlistCount.value}",
                            style: TextStyle(color: colorScheme.onError, fontSize: 11, fontWeight: FontWeight.bold), // ✅
                          ),
                        )
                            : const SizedBox()),
                      ),
                    ],
                  ),
                ),
                // 🛒 Cart Icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (!userCtrl.isLoggedIn.value) {
                            Get.snackbar(
                              "Login Required",
                              "Please login to view your cart",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: colorScheme.error,
                              colorText: colorScheme.onError,
                              icon: Icon(Icons.login, color: colorScheme.onError),
                              mainButton: TextButton(
                                onPressed: () {
                                  Get.back();
                                  Get.to(() => const LoginPage());
                                },
                                child: Text("Login",
                                    style: TextStyle(color: colorScheme.onError, fontWeight: FontWeight.bold)),
                              ),
                            );
                            return;
                          }
                          Get.to(() => const CartPage()); // ✅ हेच नवीन कोड
                        },
                        icon: Icon(Icons.shopping_cart_outlined, color: colorScheme.onSurface, size: 26),
                        padding: const EdgeInsets.all(8),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Obx(() {
                          final itemCount = cartController.totalItems;
                          return itemCount > 0
                              ? Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(color: colorScheme.error, shape: BoxShape.circle),
                            child: Text(
                              "$itemCount",
                              style: TextStyle(color: colorScheme.onError, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          )
                              : const SizedBox();
                        }),
                      ),
                    ],
                  ),
                ),
                // Login Button
                Obx(() => !userCtrl.isLoggedIn.value
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextButton(
                    onPressed: () => Get.to(() => const LoginPage()),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: colorScheme.primary, // ✅
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
                    : const SizedBox()),
              ],
            );
          }
        }),
      ),
      body: _buildBody(context),
      bottomNavigationBar: Obx(() {
        final currentTab = controller.currentIndex.value;
        final selectedIndex = currentTab > 3 ? 0 : currentTab;

        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          selectedItemColor: colorScheme.primary, // ✅
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.6), // ✅
          onTap: (index) {
            controller.currentIndex.value = index;
            if (index <= 3 && pageController.hasClients) {
              pageController.jumpToPage(index);
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.home_repair_service), label: "Services"),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: "Bookings"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        );
      }),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      final currentTab = controller.currentIndex.value;

      switch (currentTab) {
        case HomePageTabs.billing:
          final data = controller.billingData.value;
          return data.isEmpty || !data.containsKey('items')
              ? Center(
            child: Text(
              "⚠ No billing details available",
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground), // ✅
            ),
          )
              : BillingDetailsPage(billingData: data);

        case HomePageTabs.cart:
          return const CartPage();

        case HomePageTabs.flatDetails:
          return const FlatDetailsPage();

        case HomePageTabs.furnishedFlat:
          return const FurnishedFlatPage();

        case HomePageTabs.unfurnishedFlat:
          return const UnfurnishedFlatPage();

        case HomePageTabs.enquiry:
          return EnquiryFormPage(serviceName: "Choose Service");

        default:
          if (currentTab >= 0 && currentTab <= 3) {
            return PageView(
              controller: pageController,
              onPageChanged: (index) => controller.currentIndex.value = index,
              children: swipePages,
            );
          }
          return swipePages[0];
      }
    });
  }
}