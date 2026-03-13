import 'dart:convert';
import 'api_client.dart';

class CartService {
  CartService._();

  static Future<Map<String, dynamic>> getCart(String storeId, String branchId) async {
    final res = await ApiClient.get(
      '/api/carts/current?store_id=$storeId&branch_id=$branchId',
      useAuth: true,
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : (data['data'] ?? data) as Map<String, dynamic>;
    }
    return {'items': [], 'subtotal': 0.0, 'total': 0.0, 'store_name': null};
  }

  static Future<Map<String, dynamic>> getMyCarts() async {
    final res = await ApiClient.get('/api/carts', useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] as List? ?? []);
      return {'carts': List<Map<String, dynamic>>.from(list)};
    }
    return {'carts': []};
  }

  static Future<Map<String, dynamic>> addItem({
    required String storeId,
    required String branchId,
    required String catalogItemId,
    required String branchCatalogItemId,
    String? variantId,
    int qty = 1,
    String? notes,
  }) async {
    final body = {
      'store_id': storeId,
      'branch_id': branchId,
      'catalog_item_id': catalogItemId,
      'branch_catalog_item_id': branchCatalogItemId,
      'qty': qty,
      if (variantId != null) 'variant_id': variantId,
      if (notes != null) 'notes': notes,
    };
    final res = await ApiClient.post('/api/carts/items', body: body, useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : (data['data'] ?? data) as Map<String, dynamic>;
    }
    throw Exception('Error al agregar al carrito');
  }

  static Future<Map<String, dynamic>> updateItemQty(String itemId, int qty) async {
    return _patchCartItem(itemId, {'qty': qty});
  }

  static Future<Map<String, dynamic>> _patchCartItem(
    String itemId,
    Map<String, dynamic> body,
  ) async {
    final res = await ApiClient.patch('/api/carts/items/$itemId', body: body, useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : (data['data'] ?? data) as Map<String, dynamic>;
    }
    throw Exception('Error al actualizar');
  }

  static Future<Map<String, dynamic>> removeItem(String itemId) async {
    final res = await ApiClient.delete('/api/carts/items/$itemId', useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : (data['data'] ?? data) as Map<String, dynamic>;
    }
    throw Exception('Error al eliminar');
  }
}
