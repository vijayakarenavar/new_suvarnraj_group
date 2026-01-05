// lib/controller/cart_controller.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import '../api/api_service.dart';

class CartController extends GetxController {
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMsg = ''.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxInt totalItemsCount = 0.obs;

  late UserController userCtrl;

  @override
  void onInit() {
    super.onInit();
    userCtrl = Get.find<UserController>();

    if (userCtrl.isLoggedIn.value) {
      final token = userCtrl.token.value;
      if (token != null && token.isNotEmpty) {
        loadCart();
      }
    }

    ever(userCtrl.isLoggedIn, (isLoggedIn) {
      if (isLoggedIn) {
        final token = userCtrl.token.value;
        if (token != null && token.isNotEmpty) {
          loadCart();
          return;
        }
      }
      clearLocalCart();
    });
  }

  String _normalizeImageUrl(dynamic rawImage) {
    if (rawImage == null || rawImage.toString().trim().isEmpty) {
      return 'https://via.placeholder.com/100?text=No+Image';
    }
    String url = rawImage.toString().trim();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return 'https://portfolio2.lemmecode.in$url';
  }

  Future<void> loadCart() async {
    if (!userCtrl.isLoggedIn.value) {
      _log('⚠️ User not logged in, skipping cart load');
      return;
    }

    try {
      _log('🔄 Loading cart...');
      isLoading.value = true;
      errorMsg.value = '';

      final token = userCtrl.token.value;
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token');
      }

      final response = await ApiService.getCart(token);
      final data = response['data'];

      if (data == null) {
        throw Exception('Invalid cart response');
      }

      List<Map<String, dynamic>> items = [];

      if (data is Map) {
        if (data.containsKey('cart_items')) {
          final cartItemsData = data['cart_items'];
          if (cartItemsData is Map) {
            cartItemsData.forEach((key, value) {
              if (value is Map) {
                final parsed = _parseCartItem(key.toString(), value);
                if (parsed['id'] != 0) items.add(parsed);
              }
            });
          } else if (cartItemsData is List) {
            for (var item in cartItemsData) {
              if (item is Map) {
                final parsed = _parseCartItem('', item);
                if (parsed['id'] != 0) items.add(parsed);
              }
            }
          }
        } else if (data.containsKey('items')) {
          final itemsList = data['items'];
          if (itemsList is List) {
            for (var item in itemsList) {
              if (item is Map) {
                final parsed = _parseCartItem('', item);
                if (parsed['id'] != 0) items.add(parsed);
              }
            }
          }
        }
      }

      // ✅ Preserve local items (row_id starts with 'local_')
      final localItems = cartItems
          .where((item) => (item['row_id'] as String?)?.startsWith('local_') == true)
          .toList();

      cartItems.assignAll([...items, ...localItems]);
      _calculateTotals();
      _log('✅ Cart loaded: ${items.length} server + ${localItems.length} local items');
    } catch (e) {
      errorMsg.value = e.toString().replaceAll('Exception: ', '');
      cartItems.clear();
      _calculateTotals();
      _log('❌ Cart load error: $errorMsg');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _parseCartItem(String key, Map<dynamic, dynamic> item) {
    try {
      final rowId = key.isNotEmpty
          ? key
          : (item['rowId'] ?? item['row_id'] ?? item['id'] ?? '').toString();
      final productId = item['id'] ?? item['product_id'] ?? item['productId'] ?? 0;
      final productName = item['name'] ?? item['title'] ?? item['product_name'] ?? 'Unknown';
      final price = _parseDouble(item['price']);
      final quantity = item['qty'] ?? item['quantity'] ?? 1;
      final imageUrl = item['product_image'] ?? item['image'] ?? item['image_url'] ?? item['options']?['product_image'];
      final subtotal = _parseDouble(item['subtotal'] ?? (price * (quantity is int ? quantity : 1)));

      return {
        'row_id': rowId,
        'id': productId is int ? productId : int.tryParse(productId.toString()) ?? 0,
        'title': productName.toString().trim(),
        'price': price,
        'quantity': quantity is int ? quantity : int.tryParse(quantity.toString()) ?? 1,
        'image': _normalizeImageUrl(imageUrl),
        'subtotal': subtotal,
      };
    } catch (e) {
      _log('⚠️ Error parsing cart item: $e');
      return {
        'row_id': '',
        'id': 0,
        'title': 'Error',
        'price': 0.0,
        'quantity': 1,
        'image': 'https://via.placeholder.com/100?text=Error',
        'subtotal': 0.0,
      };
    }
  }

  Future<void> addToCart(Map<String, dynamic> service, {int qty = 1}) async {
    final id = service['id'] ?? service['product_id'];
    if (id == null || id == 0) {
      throw Exception("Invalid product ID");
    }

    if (!userCtrl.isLoggedIn.value) {
      throw Exception("Please login to add items to cart");
    }

    final token = userCtrl.token.value;
    if (token == null || token.isEmpty) {
      throw Exception("Please login to add items to cart");
    }

    try {
      isLoading.value = true;
      final productId = id is int ? id : int.tryParse(id.toString()) ?? 0;

      final existingIndex = cartItems.indexWhere((item) => item['id'] == productId);
      if (existingIndex >= 0) {
        final existingItem = cartItems[existingIndex];
        final currentQty = existingItem['quantity'] as int? ?? 1;
        final newQty = currentQty + qty;
        final rowId = existingItem['row_id'].toString();
        updateQuantity(rowId, newQty);
        return;
      }

      final response = await ApiService.addToCart(
        token: token,
        productId: productId,
        quantity: qty,
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception('Request timeout. Please check your internet.'),
      );

      String serverRowId = 'server_${DateTime.now().millisecondsSinceEpoch}';
      if (response['data'] != null && response['data'] is Map) {
        serverRowId = response['data']['row_id']?.toString() ?? serverRowId;
      }

      final newItem = {
        'row_id': serverRowId,
        'id': productId,
        'title': (service['title'] ?? service['name'] ?? 'Unknown').toString().trim(),
        'price': service['price'] ?? 0,
        'quantity': qty,
        'image': _normalizeImageUrl(service['image_url'] ?? service['image']),
        'subtotal': _parseDouble(service['price']) * qty,
      };

      cartItems.add(newItem);
      _calculateTotals();
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.contains('409') || errorMessage.contains('already in your cart')) {
        await loadCart();
      } else if (errorMessage.contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      throw Exception(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFromCart(String rowId) async {
    if (rowId.isEmpty) return;

    if (rowId.startsWith('local_')) {
      final index = cartItems.indexWhere((item) => item['row_id'].toString() == rowId);
      if (index >= 0) {
        cartItems.removeAt(index);
        _calculateTotals();
      }
      return;
    }

    if (!userCtrl.isLoggedIn.value) return;

    try {
      await ApiService.removeFromCart(
        token: userCtrl.token.value,
        rowId: rowId,
      );

      final index = cartItems.indexWhere((item) => item['row_id'].toString() == rowId);
      if (index >= 0) {
        cartItems.removeAt(index);
        _calculateTotals();
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void updateQuantity(String rowId, int newQty) {
    if (rowId.isEmpty || newQty < 0) return;

    final index = cartItems.indexWhere((item) => item['row_id'].toString() == rowId);
    if (index < 0) return;

    if (newQty == 0) {
      removeFromCart(rowId);
      return;
    }

    final oldItem = cartItems[index];
    final updatedItem = Map<String, dynamic>.from(oldItem);
    updatedItem['quantity'] = newQty;
    updatedItem['subtotal'] = _parseDouble(updatedItem['price']) * newQty;

    cartItems[index] = updatedItem;
    _calculateTotals();

    if (!rowId.startsWith('local_')) {
      _updateQuantityOnServer(rowId, newQty).catchError((error) {
        cartItems[index] = oldItem;
        _calculateTotals();
      });
    }
  }

  Future<void> _updateQuantityOnServer(String rowId, int newQty) async {
    try {
      await ApiService.updateCartQuantity(
        token: userCtrl.token.value,
        rowId: rowId,
        quantity: newQty,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timeout. Please try again.'),
      );
    } catch (e) {
      rethrow;
    }
  }

  void increaseQuantity(String rowId) {
    final index = cartItems.indexWhere((item) => item['row_id'].toString() == rowId);
    if (index >= 0) {
      final currentQty = cartItems[index]['quantity'] as int? ?? 1;
      updateQuantity(rowId, currentQty + 1);
    }
  }

  void decreaseQuantity(String rowId) {
    final index = cartItems.indexWhere((item) => item['row_id'].toString() == rowId);
    if (index >= 0) {
      final currentQty = cartItems[index]['quantity'] as int? ?? 1;
      if (currentQty > 1) {
        updateQuantity(rowId, currentQty - 1);
      } else {
        removeFromCart(rowId);
      }
    }
  }

  Future<void> clearCart() async {
    if (!userCtrl.isLoggedIn.value) return;

    try {
      isLoading.value = true;
      final token = userCtrl.token.value;
      if (token != null && token.isNotEmpty) {
        await ApiService.clearCart(token);
      }
      // Keep local items? No — clear all as per current UX
      cartItems.clear();
      _calculateTotals();
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateTotals() {
    double subtotal = 0.0;
    int totalCount = 0;

    for (var item in cartItems) {
      final price = _parseDouble(item['price']);
      final qty = item['quantity'] as int? ?? 1;
      subtotal += price * qty;
      totalCount += qty;
    }

    const serviceCharge = 50.0;
    totalAmount.value = subtotal + serviceCharge;
    totalItemsCount.value = totalCount;
    _log('💰 Total: ₹${totalAmount.value} (Items: $totalCount)');
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  bool validateCart() {
    if (cartItems.isEmpty) {
      Get.snackbar(
        "Empty Cart",
        "Please add items first",
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
      );
      return false;
    }
    return true;
  }

  void clearLocalCart() {
    cartItems.clear();
    errorMsg.value = '';
    _calculateTotals();
    _log('🧹 Local cart cleared');
  }

  int get totalItems => totalItemsCount.value;

  Future<void> refreshCart() async {
    _log('🔄 Manual refresh triggered');
    await loadCart();
  }

  void _log(String message) {
    if (kDebugMode) {
      print('🛒 CartController: $message');
    }
  }

  void recalculateTotals() {
    _calculateTotals();
  }
}