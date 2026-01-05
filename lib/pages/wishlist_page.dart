import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:new_suvarnraj_group/controller/wishlist_controller.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/pages/product_details_page.dart';
import 'package:new_suvarnraj_group/pages/cart_page.dart';
import 'home_page.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.put(WishlistController());

    return Scaffold(
      backgroundColor: colorScheme.surface.withOpacity(0.3),
      appBar: AppBar(
        title: Text("My Wishlist", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 1,
        centerTitle: true,
        actions: [
          Obx(() => Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${controller.wishlistCount}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onError,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
      body: Obx(() {
        if (controller.wishlistItems.isEmpty) {
          return _buildEmptyWishlist(colorScheme);
        }

        final isWideScreen = MediaQuery.of(context).size.width > 600;
        final cartCtrl = Get.find<CartController>();
        return isWideScreen ? _buildWideLayout(controller, cartCtrl, colorScheme) : _buildMobileLayout(controller, cartCtrl, colorScheme);
      }),
    );
  }

  Widget _buildEmptyWishlist(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80.sp, color: colorScheme.onSurface.withOpacity(0.3)),
          SizedBox(height: 2.h),
          Text(
            "Your wishlist is empty",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Add items to your wishlist",
            style: TextStyle(fontSize: 13.sp, color: colorScheme.onSurface.withOpacity(0.5)),
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () => Get.off(() => HomePage()),
            icon: const Icon(Icons.shopping_bag),
            label: const Text("Continue Shopping"),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(WishlistController controller, CartController cartCtrl, ColorScheme colorScheme) {
    return ListView.builder(
      padding: EdgeInsets.all(3.w),
      itemCount: controller.wishlistItems.length,
      itemBuilder: (context, index) {
        final item = controller.wishlistItems[index];
        return _buildWishlistCard(item, controller, cartCtrl, colorScheme);
      },
    );
  }

  Widget _buildWideLayout(WishlistController controller, CartController cartCtrl, ColorScheme colorScheme) {
    return GridView.builder(
      padding: EdgeInsets.all(3.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
        childAspectRatio: 0.85,
      ),
      itemCount: controller.wishlistItems.length,
      itemBuilder: (context, index) {
        final item = controller.wishlistItems[index];
        return _buildWishlistGridItem(item, controller, cartCtrl, colorScheme);
      },
    );
  }

  Widget _buildWishlistCard(
      Map<String, dynamic> item,
      WishlistController controller,
      CartController cartCtrl,
      ColorScheme colorScheme,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
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
                    imageUrl: item['image_url'] ?? 'https://via.placeholder.com/100',
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 20.w,
                      height: 20.w,
                      color: colorScheme.surface.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 20.w,
                      height: 20.w,
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
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: List.generate(
                          5,
                              (i) => Icon(Icons.star, size: 11.sp, color: Colors.amber),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '₹${item['price'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => controller.removeFromWishlist(item['id']),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
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
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.off(() => HomePage()),
                    icon: Icon(Icons.visibility, size: 14.sp, color: colorScheme.primary),
                    label: Text(
                      'View Details',
                      style: TextStyle(fontSize: 11.sp, color: colorScheme.primary),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (item['id'] == null || item['id'] == 0) {
                        Get.snackbar(
                          "Error",
                          "Invalid product. Cannot add to cart.",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: colorScheme.error,
                          colorText: colorScheme.onError,
                          icon: Icon(Icons.error, color: colorScheme.onError),
                          duration: const Duration(seconds: 3),
                        );
                        return;
                      }

                      try {
                        final serviceData = {
                          'id': item['id'],
                          'title': item['title'],
                          'price': item['price'],
                          'image_url': item['image_url'],
                        };

                        await cartCtrl.addToCart(serviceData, qty: 1);
                        Get.to(() => const CartPage());
                      } catch (e) {
                        String message = e.toString().replaceFirst('Exception: ', '');
                        Get.snackbar(
                          "Failed",
                          message,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: colorScheme.error,
                          colorText: colorScheme.onError,
                          icon: Icon(Icons.error, color: colorScheme.onError),
                          duration: const Duration(seconds: 3),
                        );
                      }
                    },
                    icon: Icon(Icons.shopping_cart, size: 14.sp, color: colorScheme.onPrimary),
                    label: Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 11.sp, color: colorScheme.onPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistGridItem(
      Map<String, dynamic> item,
      WishlistController controller,
      CartController cartCtrl,
      ColorScheme colorScheme,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: item['image_url'] ?? 'https://via.placeholder.com/100',
                  width: double.infinity,
                  height: 12.h,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: colorScheme.surface.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: colorScheme.surface.withOpacity(0.5),
                    child: Icon(Icons.broken_image, color: colorScheme.onSurface.withOpacity(0.4)),
                  ),
                ),
              ),
              Positioned(
                top: 0.5.h,
                right: 0.5.h,
                child: IconButton(
                  onPressed: () => controller.removeFromWishlist(item['id']),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: colorScheme.onError,
                      size: 12.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.8.h),
                Row(
                  children: List.generate(
                    5,
                        (i) => Icon(Icons.star, size: 9.sp, color: Colors.amber),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '₹${item['price'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: 1.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => ProductDetailsPage(productId: item['id'])),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 0.8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View',
                      style: TextStyle(fontSize: 10.sp, color: colorScheme.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}