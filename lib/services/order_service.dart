import 'dart:convert';
import 'api_client.dart';

class OrderService {
  OrderService._();

  static Future<List<Map<String, dynamic>>> getMyOrders({
    String tab = 'active',
  }) async {
    final res = await ApiClient.get('/api/orders?tab=$tab', useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] as List? ?? []);
      return List<Map<String, dynamic>>.from(list);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getOrder(String orderId) async {
    final res = await ApiClient.get('/api/orders/$orderId', useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : data['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  static Future<Map<String, dynamic>> createOrder({
    required String cartId,
    required String deliveryAddressId,
    String? notes,
  }) async {
    final body = {
      'cart_id': cartId,
      'delivery_address_id': deliveryAddressId,
      if (notes != null) 'notes': notes,
    };
    final res = await ApiClient.post('/api/orders', body: body, useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : (data['data'] ?? data) as Map<String, dynamic>;
    }
    throw Exception('Error al crear pedido');
  }
}
