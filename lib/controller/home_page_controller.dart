// lib/controller/home_page_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';

class HomePageController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMsg = ''.obs;
  final RxList<Map<String, dynamic>> allServices = <Map<String, dynamic>>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearchingBarVisible = false.obs; // 👁️ Controls search bar visibility
  final RxBool isApiSearching = false.obs;        // 🔍 For API search loading state
  final RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>> billingData = Rx<Map<String, dynamic>>({});
  final RxInt currentIndex = 0.obs;

  bool _isFetching = false;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();

    // Debounce search input to avoid too many API calls
    debounce(
      searchQuery,
          (_) => _performApiSearch(),
      time: const Duration(milliseconds: 500),
    );
  }

  void changeTab(int index) {
    currentIndex.value = index;
    if (kDebugMode) print("📍 Changed to tab: $index");
  }

  /// Fetch cleaning services from /home API
  Future<void> fetchHomeData() async {
    if (_isFetching) return;

    try {
      _isFetching = true;
      isLoading.value = true;
      errorMsg.value = '';

      final response = await ApiService.fetchHomeData();

      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];

        List<dynamic> productsList = [];
        if (data is Map && data.containsKey('cleaning_products')) {
          productsList = data['cleaning_products'] as List? ?? [];
        }

        if (productsList.isEmpty) {
          allServices.clear();
          errorMsg.value = 'No cleaning products available';
          return;
        }

        final validProducts = <Map<String, dynamic>>[];

        for (var item in productsList) {
          if (item == null) continue;

          final id = item['id'];
          final title = item['title'];
          final price = item['price'];
          final imageUrl = item['image_url'];

          if (id == null || id == 0) continue;
          if (title == null || title.toString().trim().isEmpty) continue;

          validProducts.add({
            'id': id,
            'title': title.toString().trim(),
            'price': _parseDouble(price),
            'image_url': imageUrl?.toString() ?? '',
            'short_description': (item['short_description'] ?? '').toString(),
            'description': (item['description'] ?? '').toString(),
            'category_id': item['category_id'] ?? 1,
            'sub_category_id': item['sub_category_id'],
            'status': item['status'] ?? 1,
            'in_wishlist': item['in_wishlist'] ?? false,
          });
        }

        allServices.assignAll(validProducts);
        errorMsg.value = '';
      } else {
        allServices.clear();
        errorMsg.value = response['message'] ?? 'Failed to load services';
      }
    } catch (e) {
      allServices.clear();
      errorMsg.value = 'Network or server error. Please try again.';
      if (kDebugMode) print('❌ fetchHomeData error: $e');
    } finally {
      isLoading.value = false;
      _isFetching = false;
    }
  }

  Future<void> refreshHomeData() async {
    allServices.clear();
    errorMsg.value = '';
    await Future.delayed(const Duration(milliseconds: 300));
    await fetchHomeData();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  Future<void> _performApiSearch() async {
    final query = searchQuery.value.trim();
    if (query.isEmpty) {
      searchResults.assignAll(allServices);
      return;
    }

    try {
      isApiSearching.value = true;
      errorMsg.value = '';

      final response = await ApiService.searchProducts(query);

      if (response['status'] == true && response['data'] is Map && response['data']['products'] is List) {
        final products = (response['data']['products'] as List)
            .map((p) => p as Map<String, dynamic>)
            .toList();
        searchResults.assignAll(products);
      } else {
        searchResults.clear();
        errorMsg.value = 'No matching services found';
      }
    } catch (e) {
      searchResults.clear();
      errorMsg.value = 'Search failed. Please try again.';
    } finally {
      isApiSearching.value = false;
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.assignAll(allServices);
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  List<Map<String, dynamic>> get filteredServices => allServices.toList();

  void goToBilling(Map<String, dynamic> data) {
    billingData.value = data;
    if (kDebugMode) print("💳 Navigating to billing with data: ${data['title']}");
  }

  // ✅ TOGGLE SEARCH BAR VISIBILITY — THIS METHOD EXISTS!
  void toggleSearch() {
    isSearchingBarVisible.value = !isSearchingBarVisible.value;
    if (!isSearchingBarVisible.value) {
      clearSearch();
    }
  }
}