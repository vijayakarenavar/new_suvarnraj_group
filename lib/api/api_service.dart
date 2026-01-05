// lib/services/api_service.dart - FULLY CORRECTED FOR CITY & ADDRESS VALIDATION

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:http/http.dart' as http;

import '../controller/user_controller.dart';

class ApiService {
  static const String baseUrl = "https://portfolio2.lemmecode.in/api/v1";
  static const Duration defaultTimeout = Duration(seconds: 15);

  static void _log(String message) {
    if (kDebugMode) {
      print('🌐 API: $message');
    }
  }

  static Exception _handleError(dynamic error) {
    _log('Error: $error');

    if (error is SocketException) {
      return Exception('No internet connection. Please check your network.');
    } else if (error is HttpException) {
      return Exception('Server error. Please try again later.');
    } else if (error is FormatException) {
      return Exception('Invalid response format from server.');
    } else if (error.toString().contains('SocketException')) {
      return Exception('No internet connection. Please check your network.');
    } else if (error.toString().contains('Connection timeout')) {
      return Exception('Connection timeout. Please check your internet.');
    } else if (error is Exception) {
      return error;
    }

    return Exception('Unexpected error: ${error.toString()}');
  }

  static Map<String, dynamic> _parseResponse(http.Response response, String endpoint) {
    _log('$endpoint - Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          final status = data['status'] ?? data['success'];
          if (status == true) {
            return data;
          } else {
            throw Exception(data['message'] ?? 'Request failed');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Invalid JSON response from server');
        }
        rethrow;
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else if (response.statusCode == 422) {
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Validation error');
      } catch (e) {
        throw Exception('Validation error');
      }
    } else if (response.statusCode == 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  static String _buildUrl(String path) {
    return '${baseUrl.trim()}$path';
  }

  // ============================================
  // AUTHENTICATION ENDPOINTS
  // ============================================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      _log('Logging in...');
      final url = Uri.parse(_buildUrl('/login'));

      final body = jsonEncode({
        'email': email,
        'password': password,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'login');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      _log('Registering user...');
      final url = Uri.parse(_buildUrl('/register'));

      final body = jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (phone != null) 'phone': phone,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'register');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> logout(String token) async {
    try {
      _log('Logging out...');
      final url = Uri.parse(_buildUrl('/logout'));

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'logout');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> sendPasswordResetLink(String email) async {
    try {
      _log('Sending password reset link for email: $email');
      final url = Uri.parse(_buildUrl('/forgot-password'));

      final body = jsonEncode({
        'email': email,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'sendPasswordResetLink');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // USER PROFILE ENDPOINTS
  // ============================================

  static Future<Map<String, dynamic>> fetchUserProfile(String token) async {
    try {
      _log('Fetching user profile...');
      final url = Uri.parse(_buildUrl('/profile'));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'fetchUserProfile');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      _log('Updating profile...');
      final url = Uri.parse(_buildUrl('/profile/update'));

      final body = jsonEncode({
        'name': name,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'updateProfile');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    required String token,
  }) async {
    try {
      _log('Updating password...');
      final url = Uri.parse(_buildUrl('/change-password'));

      final body = jsonEncode({
        'old_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'updatePassword');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // HOME & GENERAL ENDPOINTS
  // ============================================

  static Future<Map<String, dynamic>> checkApiStatus() async {
    try {
      _log('Checking API status...');
      final url = Uri.parse(_buildUrl('/status'));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'checkApiStatus');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> fetchHomeData() async {
    try {
      _log('Fetching home data...');
      final url = Uri.parse(_buildUrl('/home'));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'fetchHomeData');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> submitContactForm({
    required String name,
    required String email,
    required String mobile,
    required String service,
    required String message,
  }) async {
    try {
      _log('Submitting contact form...');
      final url = Uri.parse(_buildUrl('/contact'));

      final body = jsonEncode({
        'name': name,
        'email': email,
        'mobile': mobile,
        'service': service,
        'message': message,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'submitContactForm');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // PRODUCT ENDPOINTS
  // ============================================

  static Future<Map<String, dynamic>> searchProducts(String keyword) async {
    try {
      _log('Searching products with keyword: $keyword');

      if (keyword.trim().isEmpty) {
        throw Exception('Search keyword cannot be empty');
      }

      final url = Uri.parse(_buildUrl('/search')).replace(
        queryParameters: {'keyword': keyword.trim()},
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'searchProducts');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getProducts({
    int? categoryId,
    int? subCategoryId,
    int? page,
    int? limit,
  }) async {
    try {
      _log('Fetching products...');

      final queryParams = <String, String>{};
      if (categoryId != null) queryParams['category_id'] = categoryId.toString();
      if (subCategoryId != null) queryParams['sub_category_id'] = subCategoryId.toString();
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final url = Uri.parse(_buildUrl('/products')).replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      final data = _parseResponse(response, 'getProducts');
      _log('Successfully fetched ${(data['data']?['products'] as List?)?.length ?? 0} products');
      return data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getProductDetails(int productId) async {
    try {
      _log('Fetching product details for ID: $productId');
      final url = Uri.parse(_buildUrl('/products/$productId'));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'getProductDetails');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getProductsByCategory(int categoryId) async {
    try {
      _log('Fetching products for category ID: $categoryId');

      final url = Uri.parse(_buildUrl('/products')).replace(
        queryParameters: {'category_id': categoryId.toString()},
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      final data = _parseResponse(response, 'getProductsByCategory');
      _log('Found ${(data['data']?['products'] as List?)?.length ?? 0} products in category');
      return data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CART ENDPOINTS
  // ============================================

  static Future<Map<String, dynamic>> getCart(String token) async {
    try {
      _log('Fetching cart items...');

      if (token.isEmpty) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse(_buildUrl('/cart'));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'getCart');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> addToCart({
    required String token,
    required int productId,
    required int quantity,
  }) async {
    try {
      _log('Adding product $productId to cart (qty: $quantity)...');

      if (token.isEmpty) {
        throw Exception('Authentication required');
      }

      if (productId <= 0) {
        throw Exception('Invalid product ID');
      }

      if (quantity <= 0) {
        throw Exception('Invalid quantity');
      }

      final url = Uri.parse(_buildUrl('/cart/add'));

      final body = jsonEncode({
        'product_id': productId,
        'quantity': quantity,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 409) {
        throw Exception('Product already in cart');
      }

      return _parseResponse(response, 'addToCart');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> updateCartQuantity({
    required String token,
    required String rowId,
    required int quantity,
  }) async {
    try {
      _log('Updating cart quantity...');

      if (token.isEmpty) {
        throw Exception('Authentication required');
      }

      if (rowId.isEmpty) {
        throw Exception('Invalid cart item');
      }

      if (quantity < 1) {
        throw Exception('Quantity must be at least 1');
      }

      final url = Uri.parse(_buildUrl('/cart/update'));

      final body = jsonEncode({
        'row_id': rowId,
        'quantity': quantity,
      });

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'updateCartQuantity');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> removeFromCart({
    required String token,
    required String rowId,
  }) async {
    try {
      _log('Removing cart item: $rowId...');

      if (token.isEmpty) {
        throw Exception('Authentication required');
      }

      if (rowId.isEmpty) {
        throw Exception('Invalid cart item');
      }

      final url = Uri.parse(_buildUrl('/cart/remove'));

      final body = jsonEncode({
        'row_id': rowId,
      });

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      if (response.statusCode == 404) {
        return {'success': true, 'message': 'Item removed or cart was empty'};
      }

      return _parseResponse(response, 'removeFromCart');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> clearCart(String token) async {
    try {
      _log('Clearing cart...');

      if (token.isEmpty) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse(_buildUrl('/cart/clear'));

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'clearCart');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // WISHLIST ENDPOINTS
  // ============================================

  static Future<Map<String, dynamic>> checkWishlist(int productId, String token) async {
    try {
      _log('Checking wishlist for product ID: $productId');

      if (token.isEmpty) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse(_buildUrl('/wishlist/check'));

      final body = jsonEncode({
        'product_id': productId,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'checkWishlist');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> addToWishlist(int productId, String token) async {
    try {
      _log('Adding product $productId to wishlist...');

      if (token.isEmpty) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse(_buildUrl('/wishlist/add'));

      final body = jsonEncode({
        'product_id': productId,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'addToWishlist');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> removeFromWishlist(int productId, String token) async {
    try {
      _log('Removing product $productId from wishlist...');

      if (token.isEmpty) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse(_buildUrl('/wishlist/remove'));

      final body = jsonEncode({
        'product_id': productId,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'removeFromWishlist');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getWishlistCount(String token) async {
    try {
      _log('Fetching wishlist count...');

      if (token.isEmpty) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse(_buildUrl('/wishlist/count'));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'getWishlistCount');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getWishlist(String token) async {
    try {
      _log('Fetching wishlist items...');

      if (token.isEmpty) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse(_buildUrl('/wishlist'));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'getWishlist');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> clearWishlist(String token) async {
    try {
      _log('Clearing wishlist...');

      if (token.isEmpty) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse(_buildUrl('/wishlist/clear'));

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'clearWishlist');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // BOOKING/ORDER ENDPOINTS
  // ============================================

  static Future<Map<String, dynamic>> fetchBookings(String token) async {
    try {
      _log('Fetching bookings...');

      if (token.isEmpty) {
        throw Exception('Authentication token is missing');
      }

      final url = Uri.parse(_buildUrl('/orders'));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'fetchBookings');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getOrderDetails(int orderId, String token) async {
    try {
      _log('Fetching order details for ID: $orderId');
      final url = Uri.parse(_buildUrl('/orders/$orderId'));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'getOrderDetails');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> cancelOrder(int orderId, String token) async {
    try {
      _log('Cancelling order ID: $orderId');
      final url = Uri.parse(_buildUrl('/orders/$orderId/cancel'));

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      return _parseResponse(response, 'cancelOrder');
    } catch (e) {
      throw _handleError(e);
    }
  }

// ADD THESE METHODS TO YOUR EXISTING api_service.dart FILE
// Place them in the PRODUCT ENDPOINTS section or create a new FLAT ENDPOINTS section

// ============================================
// FLAT ENDPOINTS (Furnished & Unfurnished)
// ============================================

  /// Fetch furnished flat products
  static Future<Map<String, dynamic>> getFurnishedFlats() async {
    try {
      _log('Fetching furnished flats...');
      final url = Uri.parse(_buildUrl('/furnished-flats'));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      final data = _parseResponse(response, 'getFurnishedFlats');
      _log('Successfully fetched ${(data['data']?['products'] as List?)?.length ?? 0} furnished flats');
      return data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch unfurnished flat products
  static Future<Map<String, dynamic>> getUnfurnishedFlats() async {
    try {
      _log('Fetching unfurnished flats...');
      final url = Uri.parse(_buildUrl('/unfurnished-flats'));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      final data = _parseResponse(response, 'getUnfurnishedFlats');
      _log('Successfully fetched ${(data['data']?['products'] as List?)?.length ?? 0} unfurnished flats');
      return data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // 🔥 CORRECT ORDER PLACEMENT ENDPOINTS
  // ============================================

  /// ✅ Fetch checkout data - Returns areas (cities) correctly
  static Future<Map<String, dynamic>> fetchCheckoutData({String? token}) async {
    try {
      _log('📡 Fetching checkout data...');
      final url = Uri.parse(_buildUrl('/checkout/data'));

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      _log('✅ Checkout data response status: ${response.statusCode}');
      return _parseResponse(response, 'fetchCheckoutData');
    } catch (e) {
      _log('❌ Checkout data error: $e');
      throw _handleError(e);
    }
  }

  /// ✅ Place order for LOGGED-IN users - CORRECT ENDPOINT & STRUCTURE
  static Future<Map<String, dynamic>> placeOrder({
    required String token,
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String address,
    String? apartment,
    required String state,
    required int cityId,
    required String cityName,
    required String zip,
    required String bookingDate,
    required String bookingTime,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      _log('📡 Placing order for logged-in user...');
      // ✅ USE /checkout/process (NOT /orders)
      final url = Uri.parse(_buildUrl('/checkout/process'));

      // ✅ FLAT STRUCTURE (NO customer_address wrapper)
      final body = jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "mobile": mobile,
        "phone": mobile,
        "address": address,
        "apartment": apartment,
        "state": state,
        "city": cityName,      // ✅ REQUIRED STRING
        "city_id": cityId,     // ✅ REQUIRED INT
        "zip": zip,
        "country_id": 1,
        "booking_date": bookingDate,
        "booking_time": bookingTime,
        "payment_method": paymentMethod,
        "items": items,
      });

      _log('✅ Order Payload: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      _log('📊 Order Response Status: ${response.statusCode}');
      return _parseResponse(response, 'placeOrder');
    } catch (e) {
      _log('❌ Place order error: $e');
      throw _handleError(e);
    }
  }

  /// ✅ Place order for GUEST users
  static Future<Map<String, dynamic>> placeGuestOrder({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String address,
    String? apartment,
    required String state,
    required int cityId,
    required String cityName,
    required String zip,
    String? notes,
    required String bookingDate,
    required String bookingTime,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      _log('📡 Placing guest order...');
      final url = Uri.parse(_buildUrl('/checkout/guest'));

      final body = jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "mobile": mobile,
        "phone": mobile,
        "address": address,
        "apartment": apartment,
        "state": state,
        "city": cityName,      // ✅ REQUIRED STRING
        "city_id": cityId,     // ✅ REQUIRED INT
        "zip": zip,
        "country_id": 1,
        "booking_date": bookingDate,
        "booking_time": bookingTime,
        "payment_method": paymentMethod,
        "items": items,
        if (notes != null) "notes": notes,
      });

      _log('✅ Guest Order Payload: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(defaultTimeout, onTimeout: () {
        throw Exception('Connection timeout. Please check your internet.');
      });

      _log('📊 Guest Order Response Status: ${response.statusCode}');
      return _parseResponse(response, 'placeGuestOrder');
    } catch (e) {
      _log('❌ Place guest order error: $e');
      throw _handleError(e);
    }
  }
}