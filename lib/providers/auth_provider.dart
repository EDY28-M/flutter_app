import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isCheckingAuth = true;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get error => _error;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  AuthProvider() {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    _isLoggedIn = await AuthService.isLoggedIn;
    _user = await AuthService.user;
    _isCheckingAuth = false;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    _error = null;
    notifyListeners();
  }

  void _setError(String e) {
    _error = _userFriendlyError(e);
    _isLoading = false;
    notifyListeners();
  }

  static String _userFriendlyError(String e) {
    if (e.contains('TimeoutException') || e.contains('Connection timeout')) {
      return 'La conexión tardó demasiado. Revisa tu internet.';
    }
    if (e.contains('SocketException') || e.contains('Connection refused')) {
      return 'No se pudo conectar. Revisa tu conexión.';
    }
    return e.replaceFirst('Exception: ', '');
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      await AuthService.signInWithGoogle();
      await _checkAuth();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> loginWithOtp(String phone, String code) async {
    _setLoading(true);
    try {
      await AuthService.loginWithOtp(phoneE164: phone, otpCode: code);
      await _checkAuth();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> registerWithPhone(
    String phone,
    String firstName,
    String lastName,
  ) async {
    _setLoading(true);
    try {
      await AuthService.register(
        firstName: firstName,
        lastName: lastName,
        authProvider: 'phone',
        phoneE164: phone,
      );
      await _checkAuth();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await AuthService.loginWithEmail(email: email, password: password);
      await _checkAuth();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> registerWithEmail(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    _setLoading(true);
    try {
      await AuthService.register(
        firstName: firstName,
        lastName: lastName,
        authProvider: 'email',
        email: email,
        password: password,
      );
      await _checkAuth();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(false);
    await AuthService.signOut();
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
