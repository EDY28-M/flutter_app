import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_client.dart';
import '../config/app_config.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUser = 'user';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: AppConfig.googleWebClientId,
  );

  static Map<String, dynamic>? _user;

  static Future<String?> get accessToken async =>
      await _storage.read(key: _keyAccessToken);

  static Future<Map<String, dynamic>?> get user async {
    if (_user != null) return _user;
    final json = await _storage.read(key: _keyUser);
    if (json == null) return null;
    _user = jsonDecode(json) as Map<String, dynamic>;
    return _user;
  }

  static Future<bool> get isLoggedIn async {
    final token = await accessToken;
    return token != null && token.isNotEmpty;
  }

  static Future<void> _saveSession(Map<String, dynamic> response) async {
    final data = response['data'] as Map<String, dynamic>? ?? response;
    final access = data['access_token'] as String?;
    final refresh = data['refresh_token'] as String?;
    final userData = data['user'] as Map<String, dynamic>?;

    if (access != null) {
      await _storage.write(key: _keyAccessToken, value: access);
      ApiClient.setTokens(access, refresh);
    }
    if (refresh != null) {
      await _storage.write(key: _keyRefreshToken, value: refresh);
    }
    if (userData != null) {
      _user = userData;
      await _storage.write(key: _keyUser, value: jsonEncode(userData));
    }
  }

  static Future<void> clearSession() async {
    _user = null;
    ApiClient.clearTokens();
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUser);
    await _googleSignIn.signOut();
  }

  static Future<Map<String, dynamic>> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Cancelado por el usuario');

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception('No se obtuvo id_token de Google');

    final response = await ApiClient.post(
      '/api/auth/google',
      body: {'id_token': idToken},
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _saveSession(json);
      return json;
    }
    throw Exception(
      (json['message'] as String?) ?? 'Error en Google Sign-In',
    );
  }

  static Future<Map<String, dynamic>> sendOtp({
    required String target,
    required String channel,
    required String purpose,
  }) async {
    try {
      final response = await ApiClient.post(
        '/api/auth/otp/send',
        body: {'target': target, 'channel': channel, 'purpose': purpose},
      );

      final json = _parseJson(response.body, 'Error al enviar OTP');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json;
      }
      throw Exception((json['message'] as String?) ?? 'Error al enviar OTP');
    } on FormatException catch (_) {
      throw Exception(
        'Servidor no disponible. Verifica que el backend (npm run start) y ngrok estén corriendo.',
      );
    } on Exception catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection') ||
          e.toString().contains('Timeout')) {
        throw Exception(
          'Sin conexión. Verifica tu internet y que el backend y ngrok estén activos.',
        );
      }
      rethrow;
    }
  }

  static Map<String, dynamic> _parseJson(String body, String fallbackError) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } on FormatException {
      if (body.toLowerCase().contains('offline') || body.contains('<')) {
        throw Exception(
          'Servidor no disponible. Verifica que el backend (npm run start) y ngrok estén corriendo.',
        );
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> loginWithOtp({
    required String phoneE164,
    required String otpCode,
  }) async {
    final response = await ApiClient.post(
      '/api/auth/login',
      body: {'phone_e164': phoneE164, 'otp_code': otpCode},
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _saveSession(json);
      return json;
    }
    throw Exception((json['message'] as String?) ?? 'Credenciales inválidas');
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String authProvider,
    String? phoneE164,
    String? email,
    String? password,
  }) async {
    final body = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'auth_provider': authProvider,
    };
    if (phoneE164 != null) body['phone_e164'] = phoneE164;
    if (email != null) body['email'] = email;
    if (password != null && password.isNotEmpty) body['password'] = password;

    final response = await ApiClient.post('/api/auth/register', body: body);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _saveSession(json);
      return json;
    }
    throw Exception((json['message'] as String?) ?? 'Error al registrarse');
  }

  static Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _saveSession(json);
      return json;
    }
    throw Exception((json['message'] as String?) ?? 'Credenciales inválidas');
  }

  static Future<void> signOut() async {
    await clearSession();
  }
}
