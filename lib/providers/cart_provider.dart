import 'package:flutter/foundation.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _carts = [];
  Map<String, dynamic>? _currentCart;
  String? _storeId;
  String? _branchId;

  List<Map<String, dynamic>> get carts => _carts;
  Map<String, dynamic>? get currentCart => _currentCart;
  int get totalItemCount {
    if (_currentCart != null) {
      return (_currentCart!['item_count'] as int?) ?? 0;
    }
    return _carts.fold<int>(
      0,
      (s, c) => s + ((c['item_count'] as int?) ?? 0),
    );
  }

  void setStoreBranch(String? storeId, String? branchId) {
    _storeId = storeId;
    _branchId = branchId;
  }

  Future<void> loadCart() async {
    if (_storeId == null || _branchId == null) {
      await loadMyCarts();
      return;
    }
    try {
      _currentCart = await CartService.getCart(_storeId!, _branchId!);
      notifyListeners();
    } catch (_) {
      _currentCart = {'items': [], 'subtotal': 0.0, 'total': 0.0};
      notifyListeners();
    }
  }

  Future<void> loadMyCarts() async {
    try {
      final data = await CartService.getMyCarts();
      _carts = List<Map<String, dynamic>>.from(data['carts'] ?? []);
      if (_carts.isNotEmpty) {
        if (_currentCart == null || _storeId == null) {
          _currentCart = _carts.first;
          _storeId = _currentCart?['store_id'] as String?;
          _branchId = _currentCart?['branch_id'] as String?;
        }
      } else {
        _currentCart = null;
      }
      notifyListeners();
    } catch (_) {
      _carts = [];
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
    await CartService.addItem(
      storeId: storeId,
      branchId: branchId,
      catalogItemId: catalogItemId,
      branchCatalogItemId: branchCatalogItemId,
      variantId: variantId,
      qty: qty,
      notes: notes,
    );
    setStoreBranch(storeId, branchId);
    await loadCart();
  }

  Future<void> updateQty(String itemId, int qty) async {
    try {
      final result = await CartService.updateItemQty(itemId, qty);
      _currentCart = result;
      if (result['store_id'] != null && result['branch_id'] != null) {
        _storeId = result['store_id'] as String?;
        _branchId = result['branch_id'] as String?;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> removeItem(String itemId) async {
    try {
      final result = await CartService.removeItem(itemId);
      _currentCart = result;
      if (result['store_id'] != null && result['branch_id'] != null) {
        _storeId = result['store_id'] as String?;
        _branchId = result['branch_id'] as String?;
      }
      notifyListeners();
    } catch (_) {}
  }

  void clearCurrent() {
    _currentCart = null;
    _storeId = null;
    _branchId = null;
    notifyListeners();
  }
}
