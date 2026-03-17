import 'package:flutter/foundation.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _carts = [];
  Map<String, dynamic>? _currentCart;
  String? _storeId;
  String? _branchId;
  bool _isLoading = false;
  String? _lastError;

  List<Map<String, dynamic>> get carts => _carts;
  Map<String, dynamic>? get currentCart => _currentCart;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  int get totalItemCount {
    if (_currentCart != null) {
      return (_currentCart!['item_count'] as int?) ?? 0;
    }
    return _carts.fold<int>(0, (s, c) => s + ((c['item_count'] as int?) ?? 0));
  }

  void _upsertCart(Map<String, dynamic> cart) {
    final cartId = cart['id'];
    if (cartId == null) return;
    final index = _carts.indexWhere((c) => c['id'] == cartId);
    if (index >= 0) {
      _carts[index] = cart;
    } else {
      _carts.add(cart);
    }
  }

  void _applyCurrentCart(Map<String, dynamic> cart) {
    _currentCart = cart;
    _storeId = cart['store_id'] as String?;
    _branchId = cart['branch_id'] as String?;
    _upsertCart(cart);
  }

  void setStoreBranch(String? storeId, String? branchId) {
    _storeId = storeId;
    _branchId = branchId;
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  Future<void> loadCart() async {
    if (_storeId == null || _branchId == null) {
      await loadMyCarts();
      return;
    }
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      _currentCart = await CartService.getCart(_storeId!, _branchId!);
    } catch (e) {
      // Don't clear cart on error, just log it
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyCarts() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final data = await CartService.getMyCarts();
      _carts = List<Map<String, dynamic>>.from(data['carts'] ?? []);
      if (_carts.isNotEmpty) {
        if (_currentCart != null) {
          final currentId = _currentCart!['id'];
          final match = _carts.where((c) => c['id'] == currentId).toList();
          _currentCart = match.isNotEmpty ? match.first : _carts.first;
        } else {
          _currentCart = _carts.first;
        }
        _storeId = _currentCart?['store_id'] as String?;
        _branchId = _currentCart?['branch_id'] as String?;
      } else {
        _currentCart = null;
      }
    } catch (e) {
      _lastError = e.toString();
      _carts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem({
    required String storeId,
    required String branchId,
    required String catalogItemId,
    required String branchCatalogItemId,
    String? variantId,
    int qty = 1,
    String? notes,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final result = await CartService.addItem(
        storeId: storeId,
        branchId: branchId,
        catalogItemId: catalogItemId,
        branchCatalogItemId: branchCatalogItemId,
        variantId: variantId,
        qty: qty,
        notes: notes,
      );
      _applyCurrentCart(result);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      rethrow; // Re-throw to allow UI to handle it (e.g. show snackbar)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQty(String itemId, int qty) async {
    if (qty < 1) {
      await removeItem(itemId);
      return;
    }

    // Optimistic update (optional, but good for UX)
    // For now we'll stick to waiting for server response to ensure consistency

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final result = await CartService.updateItemQty(itemId, qty);
      _applyCurrentCart(result);
    } catch (e) {
      _lastError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeItem(String itemId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final result = await CartService.removeItem(itemId);
      if (result['id'] != null) {
        _applyCurrentCart(result);
      } else if (_currentCart != null && result['items'] is List) {
        _currentCart = {
          ..._currentCart!,
          'items': result['items'],
          'subtotal': result['subtotal'] ?? 0.0,
          'total': result['total'] ?? 0.0,
          'item_count': result['item_count'] ?? 0,
        };
        _upsertCart(_currentCart!);
      }
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCurrent() {
    _currentCart = null;
    _storeId = null;
    _branchId = null;
    notifyListeners();
  }
}
