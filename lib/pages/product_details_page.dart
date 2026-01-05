import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/wishlist_controller.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late WishlistController wishlistController;
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    wishlistController = Get.put(WishlistController());
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final isIn = await wishlistController.isInWishlist(widget.productId);
    if (mounted) {
      setState(() {
        _isInWishlist = isIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details", style: TextStyle(color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            icon: Icon(
              _isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: _isInWishlist ? colorScheme.error : colorScheme.onSurface.withOpacity(0.6),
            ),
            onPressed: () async {
              await wishlistController.toggleWishlist(widget.productId);
              if (mounted) {
                setState(() {
                  _isInWishlist = !_isInWishlist;
                });
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Product ID: ${widget.productId}",
              style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isInWishlist ? colorScheme.error : colorScheme.primary,
              ),
              onPressed: () async {
                await wishlistController.toggleWishlist(widget.productId);
                if (mounted) {
                  setState(() {
                    _isInWishlist = !_isInWishlist;
                  });
                }
              },
              child: Text(
                _isInWishlist ? "Remove from Wishlist" : "Add to Wishlist",
                style: TextStyle(
                  color: _isInWishlist ? colorScheme.onError : colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}