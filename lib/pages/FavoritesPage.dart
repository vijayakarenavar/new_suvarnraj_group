// ✅ lib/pages/favorites_page.dart - FULLY RESPONSIVE WITH SIZER + DARK/LIGHT MODE

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:new_suvarnraj_group/controller/wishlist_controller.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late WishlistController wishlistCtrl;
  late CartController cartCtrl;
  late UserController userCtrl;

  @override
  void initState() {
    super.initState();
    wishlistCtrl = Get.find<WishlistController>();
    cartCtrl = Get.find<CartController>();
    userCtrl = Get.find<UserController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      wishlistCtrl.loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface.withOpacity(0.3),
      appBar: AppBar(
        title: Text('My Favorites', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: () {
              wishlistCtrl.loadWishlist();
              Get.snackbar(
                "Refreshed",
                "Favorites updated",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                colorText: colorScheme.primary,
                duration: const Duration(seconds: 1),
              );
            },
          ),
          Obx(() => wishlistCtrl.wishlistItems.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.delete_sweep, color: colorScheme.error),
            onPressed: () => _showClearDialog(colorScheme),
          )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (wishlistCtrl.isLoading.value && wishlistCtrl.wishlistItems.isEmpty) {
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        }

        if (wishlistCtrl.wishlistItems.isEmpty) {
          return _buildEmptyState(colorScheme);
        }

        return RefreshIndicator(
          onRefresh: () => wishlistCtrl.loadWishlist(),
          color: colorScheme.primary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

              return GridView.builder(
                padding: EdgeInsets.all(3.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 3.w,
                  childAspectRatio: 0.7,
                ),
                itemCount: wishlistCtrl.wishlistItems.length,
                itemBuilder: (context, index) {
                  final item = wishlistCtrl.wishlistItems[index];
                  return _buildFavoriteCard(item, colorScheme);
                },
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> item, ColorScheme colorScheme) {
    final price = _parseDouble(item['price']);
    final comparePrice = _parseDouble(item['compare_price']);
    final hasDiscount = comparePrice > 0 && comparePrice > price;
    final discountPercent = hasDiscount ? ((comparePrice - price) / comparePrice * 100).round() : 0;
    final imageUrl = _normalizeImageUrl(item['image'] ?? item['image_url']);
    final productId = item['id'] ?? item['product_id'];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: colorScheme.surface.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: colorScheme.surface.withOpacity(0.5),
                      child: Icon(
                        Icons.image_not_supported,
                        color: colorScheme.onSurface.withOpacity(0.4),
                        size: 40,
                      ),
                    ),
                  ),
                ),

                if (hasDiscount && discountPercent > 0)
                  Positioned(
                    top: 2.w,
                    left: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.error, colorScheme.error.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "$discountPercent% OFF",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  top: 2.w,
                  right: 2.w,
                  child: GestureDetector(
                    onTap: () async {
                      if (productId != null) {
                        await wishlistCtrl.removeFromWishlist(productId);
                        Get.snackbar(
                          "Removed",
                          "Item removed from favorites",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: colorScheme.secondary.withOpacity(0.1),
                          colorText: colorScheme.secondary,
                          duration: const Duration(seconds: 2),
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: colorScheme.error,
                        size: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      item['title'] ?? item['name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: 0.5.h),

                  Row(
                    children: [
                      Text(
                        "₹${price.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (hasDiscount) ...[
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            "₹${comparePrice.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: colorScheme.onSurface.withOpacity(0.6),
                              decoration: TextDecoration.lineThrough,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 1.h),

                  SizedBox(
                    width: double.infinity,
                    height: 4.5.h,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(item, colorScheme),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart, size: 11.sp, color: colorScheme.onPrimary),
                          SizedBox(width: 1.w),
                          Text(
                            "Add",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            SizedBox(height: 2.h),
            Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Add items to your favorites to see them here',
              style: TextStyle(
                fontSize: 13.sp,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Continue Shopping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(Map<String, dynamic> item, ColorScheme colorScheme) async {
    try {
      if (!userCtrl.isLoggedIn.value || userCtrl.token.value.isEmpty) {
        Get.snackbar(
          "Login Required",
          "Please login to add items to cart",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: colorScheme.error.withOpacity(0.1),
          colorText: colorScheme.onError,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      Get.dialog(
        PopScope(
          canPop: false,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    SizedBox(height: 16),
                    Text("Adding to cart...", style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      await cartCtrl.addToCart(item, qty: 1);

      if (Get.isDialogOpen == true) {
        Navigator.of(Get.overlayContext!).pop();
      }

      await Future.delayed(const Duration(milliseconds: 300));

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${item['title']} added to cart!",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: colorScheme.primary,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Navigator.of(Get.overlayContext!).pop();
      }

      await Future.delayed(const Duration(milliseconds: 200));

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${e.toString().replaceAll('Exception: ', '')}",
              style: const TextStyle(color: Colors.white), // ✅ याऐवजी contentTextStyle वापरू नका
            ),
            backgroundColor: colorScheme.error,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showClearDialog(ColorScheme colorScheme) {
    Get.defaultDialog(
      title: "Clear All Favorites?",
      middleText: "This action cannot be undone.",
      textConfirm: "Clear",
      textCancel: "Cancel",
      confirmTextColor: colorScheme.onPrimary,
      buttonColor: colorScheme.error,
      onConfirm: () {
        wishlistCtrl.clearWishlist();
        Get.back();
      },
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _normalizeImageUrl(dynamic rawImage) {
    if (rawImage == null || rawImage.toString().trim().isEmpty) {
      return 'https://via.placeholder.com/300?text=No+Image';
    }
    String url = rawImage.toString().trim();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return 'https://portfolio2.lemmecode.in$url';
  }
}