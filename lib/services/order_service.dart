import 'dart:convert';
import 'api_client.dart';

class OrderService {
  OrderService._();

  static String _parseError(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final msg = json['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.first.toString();
      final err = json['error'] as String?;
      if (err != null && err.isNotEmpty) return err;
    } catch (_) {}
    return 'Error al crear pedido';
  }

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
      final json = jsonDecode(res.body);
      if (json is Map<String, dynamic>) {
        if (json.containsKey('data') && json['data'] is Map) {
          return json['data'] as Map<String, dynamic>;
        }
        return json;
      }
    }
    return null;
  }

  static Future<Map<String, dynamic>> createOrder({
    required String cartId,
    required String deliveryAddressId,
    String? notes,
    int? pointsToRedeem,
  }) async {
    final body = {
      'cart_id': cartId,
      'delivery_address_id': deliveryAddressId,
      if (notes != null) 'notes': notes,
      if (pointsToRedeem != null && pointsToRedeem > 0)
        'points_to_redeem': pointsToRedeem,
    };
    final res = await ApiClient.post('/api/orders', body: body, useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : (data['data'] ?? data) as Map<String, dynamic>;
    }
    throw Exception(_parseError(res.body));
  }
}
