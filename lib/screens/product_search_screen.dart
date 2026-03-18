import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../services/store_service.dart';
import '../widgets/product_detail_sheet.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchNow(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final data = await StoreService.searchProducts(q, limit: 60);
      if (!mounted) return;
      setState(() {
        _results = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      _searchNow(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.slate700),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              onSubmitted: _searchNow,
              decoration: InputDecoration(
                hintText: 'Buscar productos, tienda, catalogo...',
                hintStyle: TextStyle(color: AppColors.slate400),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate500),
                suffixIcon: hasQuery
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.slate500),
                        onPressed: () {
                          _controller.clear();
                          _searchNow('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : !hasQuery
              ? _buildHelpState()
              : _results.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () => _searchNow(_controller.text),
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _SearchProductCard(item: _results[i]),
                      ),
                    ),
    );
  }

  Widget _buildHelpState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.manage_search_rounded, size: 60, color: AppColors.slate300),
            const SizedBox(height: 14),
            Text(
              'Busca en toda la tienda',
              style: TextStyle(
                color: AppColors.slate700,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escribe nombre de producto, catalogo o tienda.\nEjemplo: broaster, comida, gaseosa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate500, fontSize: 14, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 58, color: AppColors.slate300),
          const SizedBox(height: 10),
          Text(
            'No encontramos resultados',
            style: TextStyle(color: AppColors.slate600, fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _SearchProductCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _SearchProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    double asDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    final name = (item['name'] as String?) ?? 'Producto';
    final imageUrl = item['image_url'] as String?;
    final storeName = (item['store_name'] as String?) ?? 'Tienda';
    final catalogName = (item['catalog_category_name'] as String?) ?? 'General';

    final price = asDouble(item['price']);
    final offerPrice = item['offer_price_amount'] == null
        ? null
      : asDouble(item['offer_price_amount']);
    final isOnOffer = (item['is_on_offer'] as bool?) ?? false;

    final normalizedItem = <String, dynamic>{
      ...item,
      'base_price_amount': price,
      'store_name': storeName,
      'description': item['description'],
      'branch_id': item['branch_id'],
      'store_id': item['store_id'],
      'branch_catalog_item_id': item['branch_catalog_item_id'],
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => ProductDetailSheet.show(context, normalizedItem),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 76,
                          height: 76,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.fastfood_rounded),
                        ),
                      )
                    : Container(
                        width: 76,
                        height: 76,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(Icons.fastfood_rounded),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.slate700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$storeName • $catalogName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (isOnOffer && offerPrice != null && offerPrice < price)
                      Text(
                        'S/ ${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slate400,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      'S/ ${(isOnOffer && offerPrice != null ? offerPrice : price).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
