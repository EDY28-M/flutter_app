import 'dart:convert';
import '../config/app_config.dart';
import 'api_client.dart';

class StoreService {
  StoreService._();

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await ApiClient.get('/api/stores/categories');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] as List? ?? []);
      return List<Map<String, dynamic>>.from(list);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getPopularStores({
    String? category,
  }) async {
    var path = '/api/stores/popular';
    if (category != null && category.isNotEmpty) {
      path += '?category=$category';
    }
    final res = await ApiClient.get(path);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] as List? ?? []);
      return List<Map<String, dynamic>>.from(list);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getStoreBySlug(String slug) async {
    final res = await ApiClient.get('/api/stores/by-slug/$slug');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : data['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getCatalogItems(
    String storeId,
    String branchId,
  ) async {
    final res = await ApiClient.get(
      '/api/stores/catalog?store_id=$storeId&branch_id=$branchId',
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] as List? ?? []);
      return List<Map<String, dynamic>>.from(list);
    }
    return [];
  }
}
