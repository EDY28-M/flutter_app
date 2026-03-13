import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Cliente HTTP reutilizable con timeout y refresh token automático.
class ApiClient {
  ApiClient._();

  static final _http = http.Client();
  static const _storage = FlutterSecureStorage();
  static const _timeout = Duration(seconds: 15);
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  static String? _accessToken;
  static String? _refreshToken;

  static Future<void> _loadTokens() async {
    _accessToken ??= await _storage.read(key: _keyAccessToken);
    _refreshToken ??= await _storage.read(key: _keyRefreshToken);
  }

  static Future<bool> _refreshAccessToken() async {
    await _loadTokens();
    final refresh = _refreshToken;
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (AppConfig.useNgrok) ...{
          'ngrok-skip-browser-warning': '69420',
          'User-Agent': 'FastGo-App/1.0',
        },
      };
      final response = await _http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}/api/auth/refresh'),
            headers: headers,
            body: jsonEncode({'refresh_token': refresh}),
          )
          .timeout(_timeout);

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json['data'] as Map<String, dynamic>? ?? json;
        final access = data['access_token'] as String?;
        final newRefresh = data['refresh_token'] as String?;
        if (access != null) {
          _accessToken = access;
          _refreshToken = newRefresh ?? refresh;
          await _storage.write(key: _keyAccessToken, value: access);
          if (newRefresh != null) {
            await _storage.write(key: _keyRefreshToken, value: newRefresh);
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// GET con token opcional. Si recibe 401, intenta refresh y reintenta una vez.
  static Future<http.Response> get(
    String path, {
    bool useAuth = false,
  }) async {
    await _loadTokens();
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (AppConfig.useNgrok) ...{
        'ngrok-skip-browser-warning': '69420',
        'User-Agent': 'FastGo-App/1.0',
      },
      if (useAuth && _accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };

    Future<http.Response> doRequest() =>
        _http.get(uri, headers: headers).timeout(_timeout);

    var response = await doRequest();

    if (response.statusCode == 401 && useAuth && await _refreshAccessToken()) {
      headers['Authorization'] = 'Bearer $_accessToken';
      response = await doRequest();
    }

    return response;
  }

  /// POST con token opcional. Si recibe 401, intenta refresh y reintenta una vez.
  static Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    bool useAuth = false,
  }) async {
    await _loadTokens();
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (AppConfig.useNgrok) ...{
        'ngrok-skip-browser-warning': '69420',
        'User-Agent': 'FastGo-App/1.0',
      },
      if (useAuth && _accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };

    Future<http.Response> doRequest() => _http
        .post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
        .timeout(_timeout);

    var response = await doRequest();

    if (response.statusCode == 401 && useAuth && await _refreshAccessToken()) {
      headers['Authorization'] = 'Bearer $_accessToken';
      response = await doRequest();
    }

    return response;
  }

  /// PATCH con token opcional.
  static Future<http.Response> patch(
    String path, {
    Map<String, dynamic>? body,
    bool useAuth = false,
  }) async {
    await _loadTokens();
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (AppConfig.useNgrok) ...{
        'ngrok-skip-browser-warning': '69420',
        'User-Agent': 'FastGo-App/1.0',
      },
      if (useAuth && _accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };

    Future<http.Response> doRequest() => _http
        .patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
        .timeout(_timeout);

    var response = await doRequest();

    if (response.statusCode == 401 && useAuth && await _refreshAccessToken()) {
      headers['Authorization'] = 'Bearer $_accessToken';
      response = await doRequest();
    }

    return response;
  }

  /// DELETE con token opcional.
  static Future<http.Response> delete(
    String path, {
    bool useAuth = false,
  }) async {
    await _loadTokens();
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (AppConfig.useNgrok) ...{
        'ngrok-skip-browser-warning': '69420',
        'User-Agent': 'FastGo-App/1.0',
      },
      if (useAuth && _accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };

    Future<http.Response> doRequest() =>
        _http.delete(uri, headers: headers).timeout(_timeout);

    var response = await doRequest();

    if (response.statusCode == 401 && useAuth && await _refreshAccessToken()) {
      headers['Authorization'] = 'Bearer $_accessToken';
      response = await doRequest();
    }

    return response;
  }

  static void setTokens(String? access, String? refresh) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  static void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }
}
