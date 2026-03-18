import 'dart:convert';

import 'api_client.dart';

class LoyaltyService {
  LoyaltyService._();

  static Future<Map<String, dynamic>?> getMyLoyalty() async {
    final res = await ApiClient.get('/api/users/me/loyalty', useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic>
          ? data
          : data['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getRedeemableProducts() async {
    final res = await ApiClient.get(
      '/api/users/me/loyalty/redeemable-products',
      useAuth: true,
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final root = data is Map<String, dynamic>
          ? data
          : (data['data'] as Map<String, dynamic>? ?? <String, dynamic>{});
      final list = root['items'] as List? ?? [];
      return List<Map<String, dynamic>>.from(list);
    }
    return [];
  }
}
