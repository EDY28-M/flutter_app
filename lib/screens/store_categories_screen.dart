import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/store_service.dart';
import 'store_catalog_screen.dart';

class StoreCategoriesScreen extends StatefulWidget {
  final Map<String, dynamic> store;

  const StoreCategoriesScreen({super.key, required this.store});

  @override
  State<StoreCategoriesScreen> createState() => _StoreCategoriesScreenState();
}

class _StoreCategoriesScreenState extends State<StoreCategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final storeId = widget.store['id'] as String;
      final categories = await StoreService.getStoreProductCategories(storeId);
      setState(() {
        _categories = categories;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeName = widget.store['name'] as String? ?? 'Tienda';
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.slate700),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          storeName,
          style: const TextStyle(
            color: AppColors.slate700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 64, color: AppColors.slate300),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay categorías disponibles',
                        style: TextStyle(color: AppColors.slate500, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return _CategoryItem(
                      category: cat,
                      store: widget.store,
                    );
                  },
                ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Map<String, dynamic> category;
  final Map<String, dynamic> store;

  const _CategoryItem({required this.category, required this.store});

  @override
  Widget build(BuildContext context) {
    final name = category['name'] as String? ?? '';
    
    return GestureDetector(
      onTap: () {
        // Navigate to catalog (optionally filtered, for now just show full catalog as placeholder)
        // Ideally we would filter by this category
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoreCatalogScreen(
              storeId: store['id'],
              branchId: store['branch_id'] ?? '',
              storeName: store['name'],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.slate400),
          ],
        ),
      ),
    );
  }
}
