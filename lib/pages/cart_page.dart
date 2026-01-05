import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:new_suvarnraj_group/pages/billing_details_page.dart';
import 'package:new_suvarnraj_group/pages/login.dart';
import 'home_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cartCtrl = Get.find<CartController>();
    final userCtrl = Get.find<UserController>();
    final homeController = Get.find<HomePageController>();

    return Scaffold(
      backgroundColor: colorScheme.surface.withOpacity(0.3),
      appBar: AppBar(
        title: Text('Shopping Cart', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: () => cartCtrl.refreshCart(),
          ),
          Obx(() => cartCtrl.cartItems.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.delete_sweep, color: colorScheme.error),
            onPressed: () => _showClearCartDialog(cartCtrl, colorScheme),
          )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (!userCtrl.isLoggedIn.value) {
          return _buildLoginRequired(colorScheme);
        }
        if (cartCtrl.isLoading.value) {
          return _buildLoadingState(colorScheme);
        }
        if (cartCtrl.errorMsg.value.isNotEmpty) {
          return _buildErrorState(cartCtrl, colorScheme);
        }
        if (cartCtrl.cartItems.isEmpty) {
          return _buildEmptyCart(colorScheme);
        }

        final isWideScreen = MediaQuery.of(context).size.width > 600;
        if (isWideScreen) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildWideLayout(cartCtrl, colorScheme),
                SizedBox(height: 20),
                _buildRelatedServicesSection(homeController, cartCtrl, colorScheme),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildMobileLayout(cartCtrl, colorScheme),
                SizedBox(height: 20),
                _buildRelatedServicesSection(homeController, cartCtrl, colorScheme),
                SizedBox(height: 20),
                _buildMobileCartSummary(cartCtrl, colorScheme),
              ],
            ),
          );
        }
      }),
    );
  }

  Widget _buildRelatedServicesSection(HomePageController homeCtrl, CartController cartCtrl, ColorScheme colorScheme) {
    if (homeCtrl.allServices.isEmpty) return const SizedBox();
    final related = homeCtrl.allServices
        .where((s) => s['title'] != null && s['image_url'] != null && s['id'] != null)
        .take(4)
        .toList();
    if (related.isEmpty) return const SizedBox();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      color: colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "You might also like",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: related.length,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final s = related[index];
                return Container(
                  width: 140,
                  margin: EdgeInsets.only(right: 12),
                  child: _buildRelatedServiceCard(s, cartCtrl, colorScheme),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedServiceCard(Map<String, dynamic> service, CartController cartCtrl, ColorScheme colorScheme) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            _showServiceDetailsModal(Get.context!, service, colorScheme);
          },
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: CachedNetworkImage(
                    imageUrl: service['image_url'] ?? '',
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: colorScheme.surface.withOpacity(0.5),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: colorScheme.surface.withOpacity(0.5),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['title'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "₹${service['price'] ?? '0'}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 14.5,
          child: GestureDetector(
            onTap: () {
              final serviceId = service['id'];
              if (serviceId == null) {
                Get.snackbar(
                  "Error",
                  "Invalid service data",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[900],
                );
                return;
              }

              final alreadyExists = cartCtrl.cartItems.any((item) => item['id'] == serviceId);
              if (alreadyExists) {
                Get.snackbar(
                  "Already Added",
                  "This item is already in your cart",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange[100],
                  colorText: Colors.orange[900],
                );
                return;
              }

              final newItem = {
                'row_id': 'local_${DateTime.now().millisecondsSinceEpoch}',
                'id': serviceId,
                'title': (service['title'] ?? 'Unknown').toString().trim(),
                'price': service['price'] ?? 0,
                'quantity': 1,
                'image': service['image_url'] ?? service['image'] ?? '',
                'subtotal': service['price'] ?? 0,
              };

              String imageUrl = newItem['image'].toString().trim();
              if (imageUrl.isEmpty) {
                newItem['image'] = 'https://via.placeholder.com/100?text=No+Image';
              } else if (!imageUrl.startsWith('http')) {
                // ✅ Fixed: proper string interpolation
                newItem['image'] = 'https://portfolio2.lemmecode.in$imageUrl';
              }

              cartCtrl.cartItems.add(newItem);
              cartCtrl.recalculateTotals();

              Get.snackbar(
                "Added!",
                "${newItem['title']} added to cart",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green[100],
                colorText: Colors.green[900],
                duration: Duration(seconds: 2),
              );
            },
            child: Container(
              height: 30,
              width: 110,
              padding: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "ADD TO CART",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showServiceDetailsModal(BuildContext context, Map<String, dynamic> serviceData, ColorScheme colorScheme) {
    final title = serviceData['title'] ?? 'Service';
    final price = serviceData['price'] ?? 0;
    final comparePrice = serviceData['compare_price'];
    final imageUrl = serviceData['image_url'] ?? serviceData['image'];
    final rawDescription = serviceData['description']?.toString() ?? serviceData['short_description']?.toString() ?? '';

    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    final priceNum = _parseDouble(price);
    final priceStr = priceNum.toStringAsFixed(0);
    final hasDiscount = comparePrice != null && _parseDouble(comparePrice) > priceNum;

    String? fullImageUrl = imageUrl;
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      // ✅ Fixed interpolation
      fullImageUrl = 'https://portfolio2.lemmecode.in$imageUrl';
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
      } else {
        points = [cleaned];
      }
      return points;
    }

    final descriptionPoints = _parseDescriptionToPoints(rawDescription);

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
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            final cartCtrl = Get.find<CartController>();
                            try {
                              await cartCtrl.addToCart(serviceData);
                            } catch (e) {
                              Get.snackbar("Error", e.toString());
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
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
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final cartCtrl = Get.find<CartController>();
                          try {
                            await cartCtrl.addToCart(serviceData);
                          } catch (e) {
                            Get.snackbar("Error", e.toString());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_rounded, size: 24, color: Colors.white),
                            const SizedBox(width: 12),
                            Text("Add to Cart", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

  // ——— Rest of helper widgets (no changes needed for null safety) ———

  Widget _buildLoginRequired(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 80, color: colorScheme.onSurface.withOpacity(0.3)),
          SizedBox(height: 2.h),
          Text(
            'Please login to view your cart',
            style: TextStyle(fontSize: 16.sp, color: colorScheme.onSurface.withOpacity(0.6)),
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const LoginPage()),
            icon: const Icon(Icons.login),
            label: const Text('Login Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(CartController cartCtrl, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: colorScheme.error.withOpacity(0.5)),
          SizedBox(height: 2.h),
          Text(
            cartCtrl.errorMsg.value,
            style: TextStyle(fontSize: 14.sp, color: colorScheme.error),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () => cartCtrl.refreshCart(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(CartController cartCtrl, ColorScheme colorScheme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(3.w),
      itemCount: cartCtrl.cartItems.length,
      itemBuilder: (context, index) {
        final item = cartCtrl.cartItems[index];
        return _buildMobileCartItem(item, cartCtrl, colorScheme);
      },
    );
  }

  Widget _buildMobileCartItem(Map<String, dynamic> item, CartController cartCtrl, ColorScheme colorScheme) {
    final price = _parseDouble(item['price']);
    final qty = item['quantity'] ?? 1;
    final total = price * qty;
    final rowId = item['row_id']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, spreadRadius: 1)],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: item['image'] ?? 'https://via.placeholder.com/100',
                    width: 22.w,
                    height: 22.w,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 22.w,
                      height: 22.w,
                      color: colorScheme.surface.withOpacity(0.5),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 22.w,
                      height: 22.w,
                      color: colorScheme.surface.withOpacity(0.5),
                      child: Icon(Icons.broken_image, color: colorScheme.onSurface.withOpacity(0.4)),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? 'Unknown',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.8.h),
                      Row(children: List.generate(5, (i) => Icon(Icons.star, size: 11.sp, color: Colors.amber))),
                      SizedBox(height: 1.h),
                      Text('₹${price.toStringAsFixed(0)}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => cartCtrl.removeFromCart(rowId),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: colorScheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Icon(Icons.close, color: colorScheme.error, size: 14.sp),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildQtyButton(Icons.remove, colorScheme.onSurface, () => cartCtrl.decreaseQuantity(rowId)),
                    SizedBox(width: 2.w),
                    Text('$qty', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    SizedBox(width: 2.w),
                    _buildQtyButton(Icons.add, colorScheme.onSurface, () => cartCtrl.increaseQuantity(rowId)),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Total', style: TextStyle(fontSize: 11.sp, color: colorScheme.onSurface.withOpacity(0.6))),
                      Text('₹${total.toStringAsFixed(0)}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
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

  Widget _buildMobileCartSummary(CartController cartCtrl, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(color: colorScheme.surface.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: TextStyle(fontSize: 15.sp, color: colorScheme.onSurface.withOpacity(0.7))),
                      Obx(() => Text('₹${(cartCtrl.totalAmount.value - 50).toStringAsFixed(0)}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: colorScheme.onSurface))),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Service Charge', style: TextStyle(fontSize: 15.sp, color: colorScheme.onSurface.withOpacity(0.6))),
                      Text('₹50', style: TextStyle(fontSize: 15.sp, color: colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      Obx(() => Text('₹${cartCtrl.totalAmount.value.toStringAsFixed(0)}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: colorScheme.primary))),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (cartCtrl.validateCart()) _navigateToBillingPage(cartCtrl);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, color: colorScheme.onPrimary),
                    SizedBox(width: 2.w),
                    Text('PROCEED TO CHECKOUT', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: colorScheme.onPrimary, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 1.h),
            TextButton(
              onPressed: () => Get.off(() => HomePage()),
              child: Text(
                'Continue Shopping',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(CartController cartCtrl, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Column(
              children: [
                _buildTableHeader(colorScheme),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    itemCount: cartCtrl.cartItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) => _buildWideCartItemRow(cartCtrl.cartItems[index], cartCtrl, colorScheme),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.all(2.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(color: colorScheme.surface.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
            child: _buildWideSummary(cartCtrl, colorScheme),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('PRODUCT', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.7)))),
          Expanded(flex: 2, child: Text('PRICE', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.7)), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('QUANTITY', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.7)), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('TOTAL', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.7)), textAlign: TextAlign.center)),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }

  Widget _buildWideCartItemRow(Map<String, dynamic> item, CartController cartCtrl, ColorScheme colorScheme) {
    final price = _parseDouble(item['price']);
    final qty = item['quantity'] ?? 1;
    final total = price * qty;
    final rowId = item['row_id']?.toString() ?? '';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: item['image'] ?? '',
                    width: 12.w,
                    height: 12.w,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(width: 12.w, height: 12.w, color: colorScheme.surface.withOpacity(0.5), child: Icon(Icons.image, color: colorScheme.onSurface.withOpacity(0.4))),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] ?? '', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: colorScheme.onSurface), maxLines: 2),
                      SizedBox(height: 0.5.h),
                      Row(children: List.generate(5, (i) => Icon(Icons.star, size: 9.sp, color: Colors.amber))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text('₹${price.toStringAsFixed(0)}', style: TextStyle(fontSize: 11.sp, color: colorScheme.onSurface), textAlign: TextAlign.center)),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQtyButton(Icons.remove, colorScheme.onSurface, () => cartCtrl.decreaseQuantity(rowId)),
                SizedBox(width: 2.w),
                Text('$qty', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                SizedBox(width: 2.w),
                _buildQtyButton(Icons.add, colorScheme.onSurface, () => cartCtrl.increaseQuantity(rowId)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text('₹${total.toStringAsFixed(0)}', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface), textAlign: TextAlign.center)),
          SizedBox(
            width: 8.w,
            child: IconButton(
              onPressed: () => cartCtrl.removeFromCart(rowId),
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: colorScheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Icon(Icons.close, color: colorScheme.error, size: 12.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideSummary(CartController cartCtrl, ColorScheme colorScheme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CART SUMMARY', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: TextStyle(fontSize: 15.sp, color: colorScheme.onSurface.withOpacity(0.7))),
              Obx(() => Text('₹${(cartCtrl.totalAmount.value - 50).toStringAsFixed(0)}', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: colorScheme.primary))),
            ],
          ),
          SizedBox(height: 2.h),
          const Divider(),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              Obx(() => Text('₹${cartCtrl.totalAmount.value.toStringAsFixed(0)}', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: colorScheme.primary))),
            ],
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (cartCtrl.validateCart()) _navigateToBillingPage(cartCtrl);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('PROCEED TO CHECKOUT', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Get.off(() => HomePage()),
              child: Text(
                'Continue Shopping',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          SizedBox(height: 2.h),
          Text('Loading cart...', style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: colorScheme.onSurface.withOpacity(0.3)),
          SizedBox(height: 2.h),
          Text('Your cart is empty', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.6))),
          SizedBox(height: 1.h),
          Text('Add items to get started', style: TextStyle(fontSize: 12.sp, color: colorScheme.onSurface.withOpacity(0.5))),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () => Get.off(() => HomePage()),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Continue Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 10),
      ),
    );
  }

  void _showClearCartDialog(CartController cartCtrl, ColorScheme colorScheme) {
    Get.defaultDialog(
      title: "Clear Cart",
      middleText: "Remove all items?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: colorScheme.onPrimary,
      cancelTextColor: colorScheme.onSurface,
      buttonColor: colorScheme.error,
      onConfirm: () {
        cartCtrl.clearCart();
        Get.back();
      },
      onCancel: () {
        Get.back();
      },
    );
  }

  void _navigateToBillingPage(CartController cartCtrl) {
    final billingData = {
      "items": cartCtrl.cartItems.map((item) => {
        "id": item['id'],
        "title": item['title'],
        "price": item['price'],
        "quantity": item['quantity'],
        "image": item['image']
      }).toList(),
      "totalAmount": cartCtrl.totalAmount.value,
      "totalItems": cartCtrl.totalItems
    };
    Get.to(() => BillingDetailsPage(billingData: billingData));
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}