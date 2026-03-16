import 'package:flutter/foundation.dart';
import '../services/favorites_service.dart';

class FavoritesProvider with ChangeNotifier {
  Set<String> _favoriteStoreIds = {};
  bool _loaded = false;

  Set<String> get favoriteStoreIds => _favoriteStoreIds;
  bool get loaded => _loaded;

  bool isFavorite(String storeId) => _favoriteStoreIds.contains(storeId);

  Future<void> load() async {
    try {
      final ids = await FavoritesService.getIds();
      _favoriteStoreIds = ids.toSet();
      _loaded = true;
      notifyListeners();
    } catch (_) {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<bool> toggle(String storeId) async {
    final isFav = _favoriteStoreIds.contains(storeId);
    try {
      if (isFav) {
        await FavoritesService.remove(storeId);
        _favoriteStoreIds.remove(storeId);
      } else {
        await FavoritesService.add(storeId);
        _favoriteStoreIds.add(storeId);
      }
      notifyListeners();
      return !isFav;
    } catch (_) {
      return isFav;
    }
  }
}
