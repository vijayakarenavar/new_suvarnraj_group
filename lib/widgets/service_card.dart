// lib/widgets/service_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/controller/wishlist_controller.dart';
import 'package:new_suvarnraj_group/pages/cart_page.dart';
import 'package:new_suvarnraj_group/pages/login.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final dynamic price;
  final dynamic comparePrice;
  final String? imageUrl;
  final Map<String, dynamic> serviceData;

  const ServiceCard({
    super.key,
    required this.title,
    required this.price,
    this.comparePrice,
    this.imageUrl,
    required this.serviceData,
  });

  String? getFullImageUrl() {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return imageUrl;
    }
    // ✅ FIXED: Removed trailing space in baseUrl
    const baseUrl = 'https://portfolio2.lemmecode.in';
    return '$baseUrl$imageUrl';
  }

  int? getDiscountPercentage() {
    try {
      final comparePriceNum = _parseDouble(comparePrice);
      final priceNum = _parseDouble(price);
      if (comparePriceNum <= 0 || priceNum <= 0) return null;
      if (comparePriceNum <= priceNum) return null;
      final discount = (((comparePriceNum - priceNum) / comparePriceNum) * 100);
      return discount.round();
    } catch (e) {
      return null;
    }
  }

  double _parseDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priceNum = _parseDouble(price);
    final priceStr = priceNum.toStringAsFixed(0);
    final hasDiscount = comparePrice != null && _parseDouble(comparePrice) > priceNum;
    final discountPercent = getDiscountPercentage();
    final fullImageUrl = getFullImageUrl();
    final productId = serviceData['id'];

    return GestureDetector(
      onTap: () => _showProductDetailsModal(context, colorScheme),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.w),
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  _buildImageSection(fullImageUrl, hasDiscount, discountPercent, colorScheme),
                  if (productId != null && productId != 0)
                    Positioned(
                      top: 2.w,
                      right: 2.w,
                      child: _buildWishlistButton(productId, colorScheme),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(2.5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTitle(colorScheme),
                  SizedBox(height: 1.5.w),
                  _buildPriceSection(priceStr, hasDiscount, colorScheme),
                  SizedBox(height: 2.5.w),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showProductDetailsModal(context, colorScheme),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 1.1.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility, size: 13.sp, color: colorScheme.onPrimary),
                          SizedBox(width: 2.w),
                          Text(
                            "View Details",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
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
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistButton(int productId, ColorScheme colorScheme) {
    return GetBuilder<WishlistController>(
      builder: (wishlistCtrl) {
        final isInWishlist = wishlistCtrl.isItemInWishlist(productId);
        return GestureDetector(
          onTap: () => _toggleWishlist(productId, colorScheme),
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
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? colorScheme.error : colorScheme.onSurface.withOpacity(0.6),
              size: 18.sp,
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleWishlist(int productId, ColorScheme colorScheme) async {
    try {
      final userCtrl = Get.find<UserController>();
      final wishlistCtrl = Get.find<WishlistController>();

      if (!userCtrl.isLoggedIn.value || userCtrl.token.value.isEmpty) {
        Get.snackbar(
          "Login Required",
          "Please log in to add items to wishlist",
          backgroundColor: colorScheme.secondary.withOpacity(0.1),
          colorText: colorScheme.onSecondary,
          snackPosition: SnackPosition.BOTTOM,
          mainButton: TextButton(
            onPressed: () {
              Get.back();
              Get.to(() => const LoginPage());
            },
            child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
        return;
      }

      final isInWishlist = wishlistCtrl.isItemInWishlist(productId);
      if (isInWishlist) {
        await wishlistCtrl.removeFromWishlist(productId);
      } else {
        await wishlistCtrl.addToWishlist(productId);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: colorScheme.error.withOpacity(0.1),
        colorText: colorScheme.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _onAddToCart(BuildContext context, ColorScheme colorScheme) async {
    try {
      final userCtrl = Get.find<UserController>();
      final cartController = Get.find<CartController>();

      if (!userCtrl.isLoggedIn.value || userCtrl.token.value.isEmpty) {
        Get.snackbar(
          "Login Required",
          "Please login to add items to cart",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: colorScheme.secondary.withOpacity(0.1),
          colorText: colorScheme.onSecondary,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          mainButton: TextButton(
            onPressed: () {
              Get.back();
              Get.to(() => const LoginPage());
            },
            child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
        return;
      }

      final productId = serviceData['id'];
      if (productId == null || productId == 0) {
        Get.snackbar(
          "Error",
          "Invalid product",
          backgroundColor: colorScheme.error,
          colorText: colorScheme.onError,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await cartController.addToCart(serviceData, qty: 1);

      Get.snackbar(
        "Success",
        "$title added to cart!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: colorScheme.primary,
        colorText: colorScheme.onPrimary,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
        icon: Icon(Icons.check_circle, color: colorScheme.onPrimary),
      );

      await Future.delayed(const Duration(milliseconds: 300));
      Get.to(() => const CartPage());

    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.contains('already in cart') || errorMessage.contains('409')) {
        Get.snackbar(
          "Info",
          "This item is already in your cart.",
          backgroundColor: colorScheme.primary,
          colorText: colorScheme.onPrimary,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          icon: Icon(Icons.info, color: colorScheme.onPrimary),
        );
        await Future.delayed(const Duration(milliseconds: 300));
        Get.to(() => const CartPage());
      } else {
        Get.snackbar(
          "Error",
          errorMessage,
          backgroundColor: colorScheme.error,
          colorText: colorScheme.onError,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
        );
      }
    }
  }

  List<String> _parseDescriptionToPoints(String htmlString) {
    if (htmlString.isEmpty) return [];
    String cleaned = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&lsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return [];

    List<String> points = [];
    if (cleaned.contains('•')) {
      points = cleaned.split('•').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else if (cleaned.contains('\n')) {
      points = cleaned.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else if (RegExp(r'\d+\.').hasMatch(cleaned)) {
      points = cleaned.split(RegExp(r'\d+\.')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else {
      if (cleaned.length < 200) {
        points = [cleaned];
      } else {
        points = cleaned.split(RegExp(r'\.\s+(?=[A-Z])')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }
    return points;
  }

  void _showProductDetailsModal(BuildContext context, ColorScheme colorScheme) {
    final priceNum = _parseDouble(price);
    final priceStr = priceNum.toStringAsFixed(0);
    final hasDiscount = comparePrice != null && _parseDouble(comparePrice) > priceNum;
    final discountPercent = getDiscountPercentage();
    final fullImageUrl = getFullImageUrl();

    String rawDescription = serviceData['description']?.toString() ?? serviceData['short_description']?.toString() ?? '';
    final descriptionPoints = _parseDescriptionToPoints(rawDescription);
    final servicesIncluded = serviceData['services_included'] as List<dynamic>? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: fullImageUrl != null
                          ? CachedNetworkImage(
                        imageUrl: fullImageUrl,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 300,
                          color: colorScheme.surface.withOpacity(0.5),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 300,
                          color: colorScheme.surface.withOpacity(0.5),
                          child: Icon(Icons.broken_image, color: colorScheme.onSurface.withOpacity(0.4)),
                        ),
                      )
                          : Container(
                        height: 300,
                        color: colorScheme.surface.withOpacity(0.5),
                        child: Icon(Icons.image, color: colorScheme.onSurface.withOpacity(0.4)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                "₹$priceStr",
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.primary),
                              ),
                              if (hasDiscount) ...[
                                const SizedBox(width: 10),
                                Text(
                                  "₹${_parseDouble(comparePrice).toStringAsFixed(0)}",
                                  style: TextStyle(fontSize: 18, color: colorScheme.onSurface.withOpacity(0.6), decoration: TextDecoration.lineThrough),
                                ),
                                if (discountPercent != null) ...[
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: colorScheme.secondary.withOpacity(0.2), borderRadius: BorderRadius.circular(5)),
                                    child: Text(
                                      "$discountPercent% OFF",
                                      style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            await _onAddToCart(context, colorScheme);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.add_shopping_cart, color: colorScheme.onPrimary, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (descriptionPoints.isNotEmpty) ...[
                      Text("Services Included:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      const SizedBox(height: 15),
                      ...descriptionPoints.map((point) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                point,
                                style: TextStyle(fontSize: 15, color: colorScheme.onSurface.withOpacity(0.9), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                    if (servicesIncluded.isNotEmpty && servicesIncluded.length != descriptionPoints.length) ...[
                      const SizedBox(height: 20),
                      Text("Additional Services:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      const SizedBox(height: 10),
                      ...servicesIncluded.map((service) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: colorScheme.secondary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                service.toString(),
                                style: TextStyle(fontSize: 15, color: colorScheme.onSurface.withOpacity(0.9)),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _onAddToCart(context, colorScheme);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_rounded, size: 24, color: colorScheme.onPrimary),
                            const SizedBox(width: 12),
                            Text("Add to Cart", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(String? imageUrl, bool hasDiscount, int? discountPercent, ColorScheme colorScheme) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(3.w), topRight: Radius.circular(3.w)),
          child: _buildImage(imageUrl, colorScheme),
        ),
        if (hasDiscount && discountPercent != null)
          Positioned(
            top: 2.w,
            left: 2.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.error, colorScheme.error.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(1.5.w),
                boxShadow: [BoxShadow(color: colorScheme.error.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_offer_rounded, color: Colors.white, size: 10.sp),
                  SizedBox(width: 1.w),
                  Text(
                    "$discountPercent% OFF",
                    style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage(String? imageUrl, ColorScheme colorScheme) {
    if (imageUrl == null || imageUrl.isEmpty) return _buildFallbackImage(colorScheme);
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => _buildPlaceholder(colorScheme),
      errorWidget: (_, __, ___) => _buildErrorImage(colorScheme),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surface.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2.5)),
            SizedBox(height: 1.h),
            Text('Loading...', style: TextStyle(fontSize: 9.sp, color: colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surface.withOpacity(0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded, size: 40, color: colorScheme.onSurface.withOpacity(0.4)),
          SizedBox(height: 1.h),
          Text('Image unavailable', style: TextStyle(fontSize: 9.sp, color: colorScheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildFallbackImage(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surface.withOpacity(0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cleaning_services_rounded, size: 45, color: colorScheme.primary.withOpacity(0.5)),
          SizedBox(height: 1.h),
          Text(
            title.split(' ').first,
            style: TextStyle(fontSize: 10.sp, color: colorScheme.primary, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5.sp, color: colorScheme.onSurface, height: 1.2),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPriceSection(String priceStr, bool hasDiscount, ColorScheme colorScheme) {
    return Row(
      children: [
        Text("₹$priceStr", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 15.sp)),
        if (hasDiscount) ...[
          SizedBox(width: 2.w),
          Text(
            "₹${_parseDouble(comparePrice).toStringAsFixed(0)}",
            style: TextStyle(fontSize: 11.sp, color: colorScheme.onSurface.withOpacity(0.6), decoration: TextDecoration.lineThrough),
          ),
        ],
      ],
    );
  }
}