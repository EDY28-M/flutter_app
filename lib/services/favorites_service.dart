import 'dart:convert';
import 'api_client.dart';

class FavoritesService {
  FavoritesService._();

  static Future<List<Map<String, dynamic>>> list() async {
    final res = await ApiClient.get('/api/favorites', useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] as List? ?? []);
      return List<Map<String, dynamic>>.from(list);
    }
    return [];
  }

  static Future<List<String>> getIds() async {
    final res = await ApiClient.get('/api/favorites/ids', useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] as List? ?? []);
      return List<String>.from(list);
    }
    return [];
  }

  static Future<bool> add(String storeId) async {
    final res = await ApiClient.post('/api/favorites/$storeId', useAuth: true);
    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<bool> remove(String storeId) async {
    final res = await ApiClient.delete('/api/favorites/$storeId', useAuth: true);
    return res.statusCode >= 200 && res.statusCode < 300;
  }
}
