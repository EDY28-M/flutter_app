import 'dart:convert';
import 'api_client.dart';

class AddressService {
  AddressService._();

  static Future<List<Map<String, dynamic>>> getMyAddresses() async {
    final res = await ApiClient.get('/api/addresses', useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final list = data is List ? data : (data['data'] as List? ?? []);
      return List<Map<String, dynamic>>.from(list);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getDefaultAddress() async {
    final addresses = await getMyAddresses();
    if (addresses.isEmpty) return null;
    try {
      return addresses.firstWhere((a) => a['is_default'] == true);
    } catch (_) {
      return addresses.first;
    }
  }

  static Future<Map<String, dynamic>> create(Map<String, dynamic> dto) async {
    final res = await ApiClient.post('/api/addresses', body: dto, useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : (data['data'] ?? data) as Map<String, dynamic>;
    }
    throw Exception(_parseError(res.body));
  }

  static Future<Map<String, dynamic>> update(String id, Map<String, dynamic> dto) async {
    final res = await ApiClient.patch('/api/addresses/$id', body: dto, useAuth: true);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : (data['data'] ?? data) as Map<String, dynamic>;
    }
    throw Exception(_parseError(res.body));
  }

  static Future<void> delete(String id) async {
    final res = await ApiClient.delete('/api/addresses/$id', useAuth: true);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_parseError(res.body));
    }
  }

  static Future<void> setDefault(String id) async {
    final res = await ApiClient.patch('/api/addresses/$id/default', body: {}, useAuth: true);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_parseError(res.body));
    }
  }

  static String _parseError(String body) {
    try {
      final j = jsonDecode(body) as Map<String, dynamic>;
      return j['message'] as String? ?? j['error'] as String? ?? 'Error';
    } catch (_) {
      return body.isNotEmpty ? body : 'Error desconocido';
    }
  }
}
