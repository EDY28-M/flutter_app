import 'dart:convert';
import 'api_client.dart';
import '../config/app_config.dart';

class StoreService {
  StoreService._();

  static String? _resolveCategoryLogoUrl(dynamic raw) {
    final value = (raw ?? '').toString().trim();
    if (value.isEmpty) return null;

    if (value.startsWith('/uploads/')) {
      return '${AppConfig.adminBaseUrl}$value';
    }

    final uri = Uri.tryParse(value);
    if (uri == null) return value;

    final hasHttpScheme = uri.scheme == 'http' || uri.scheme == 'https';
    if (!hasHttpScheme) return value;

    final host = (uri.host).toLowerCase();
    if (host == 'localhost' || host == '127.0.0.1') {
      final adminBase = Uri.parse(AppConfig.adminBaseUrl);
      final rebuilt = uri.replace(
        scheme: adminBase.scheme,
        host: adminBase.host,
        port: adminBase.hasPort ? adminBase.port : null,
      );
      return rebuilt.toString();
    }

    return value;
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await ApiClient.get('/api/stores/categories');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] as List? ?? []);
      return List<Map<String, dynamic>>.from(list).map((item) {
        final map = Map<String, dynamic>.from(item);
        map['logo_url'] = _resolveCategoryLogoUrl(map['logo_url']);
        return map;
      }).toList();
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

  static Future<List<Map<String, dynamic>>> getPopularProducts({
    int limit = 20,
  }) async {
    final res = await ApiClient.get('/api/stores/popular-products?limit=$limit');
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

  static Future<List<Map<String, dynamic>>> getOffers() async {
    final res = await ApiClient.get('/api/stores/offers');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] as List? ?? []);
      return List<Map<String, dynamic>>.from(list);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getProductsByCategory(String categoryCode) async {
    final res = await ApiClient.get('/api/stores/products/by-category/$categoryCode');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] as List? ?? []);
      return List<Map<String, dynamic>>.from(list);
    }
    return [];
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

  static Future<List<Map<String, dynamic>>> getStoreProductCategories(String storeId) async {
    final res = await ApiClient.get('/api/stores/$storeId/product-categories');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] as List? ?? []);
      return List<Map<String, dynamic>>.from(list);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> searchProducts(
    String query, {
    int limit = 40,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final encodedQuery = Uri.encodeQueryComponent(q);
    final res = await ApiClient.get('/api/stores/search?q=$encodedQuery&limit=$limit');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] as List? ?? []);
      return List<Map<String, dynamic>>.from(list);
    }
    return [];
  }
}
