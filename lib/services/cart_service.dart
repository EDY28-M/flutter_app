import 'dart:convert';
import 'api_client.dart';

class CartService {
  CartService._();

  static dynamic _decodeBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _extractDataMap(String body) {
    final decoded = _decodeBody(body);
    if (decoded is! Map<String, dynamic>) {
      return {};
    }
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return decoded;
  }

  static List<Map<String, dynamic>> _extractDataList(String body) {
    final decoded = _decodeBody(body);
    if (decoded is List) {
      return List<Map<String, dynamic>>.from(decoded);
    }
    if (decoded is! Map<String, dynamic>) {
      return [];
    }
    final data = decoded['data'];
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  static String _extractErrorMessage(String body, String fallback) {
    final decoded = _decodeBody(body);
    if (decoded is! Map<String, dynamic>) {
      return fallback;
    }
    final message = decoded['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    return fallback;
  }

  static Map<String, dynamic> parseCartResponseBody(String body) {
    return _extractDataMap(body);
  }

  static List<Map<String, dynamic>> parseCartsResponseBody(String body) {
    return _extractDataList(body);
  }

  static Future<Map<String, dynamic>> getCart(
    String storeId,
    String branchId,
  ) async {
    final res = await ApiClient.get(
      '/api/carts/current?store_id=$storeId&branch_id=$branchId',
      useAuth: true,
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return parseCartResponseBody(res.body);
    }
    return {'items': [], 'subtotal': 0.0, 'total': 0.0, 'store_name': null};
  }

  static Future<Map<String, dynamic>> getMyCarts() async {
    final res = await ApiClient.get('/api/carts', useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return {'carts': parseCartsResponseBody(res.body)};
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
    final res = await ApiClient.post(
      '/api/carts/items',
      body: body,
      useAuth: true,
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return parseCartResponseBody(res.body);
    }
    throw Exception(
      _extractErrorMessage(res.body, 'Error al agregar al carrito'),
    );
  }

  static Future<Map<String, dynamic>> updateItemQty(
    String itemId,
    int qty,
  ) async {
    return _patchCartItem(itemId, {'qty': qty});
  }

  static Future<Map<String, dynamic>> _patchCartItem(
    String itemId,
    Map<String, dynamic> body,
  ) async {
    final res = await ApiClient.patch(
      '/api/carts/items/$itemId',
      body: body,
      useAuth: true,
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return parseCartResponseBody(res.body);
    }
    throw Exception(
      _extractErrorMessage(res.body, 'Error al actualizar carrito'),
    );
  }

  static Future<Map<String, dynamic>> removeItem(String itemId) async {
    final res = await ApiClient.delete(
      '/api/carts/items/$itemId',
      useAuth: true,
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return parseCartResponseBody(res.body);
    }
    throw Exception(
      _extractErrorMessage(res.body, 'Error al eliminar producto del carrito'),
    );
  }
}
