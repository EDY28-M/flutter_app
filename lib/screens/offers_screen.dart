import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../providers/cart_provider.dart';
import '../services/store_service.dart';
import '../widgets/product_detail_sheet.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  List<Map<String, dynamic>> _offers = [];
  bool _loading = true;
  String _selectedFilter = 'Todo';
  List<String> _filters = ['Todo'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final offers = await StoreService.getOffers();

      // Extract unique categories from offers
      final categories = offers
          .map((o) => o['category_name'] as String? ?? 'Varios')
          .toSet()
          .toList();
      categories.sort();

      setState(() {
        _offers = offers;
        _filters = ['Todo', ...categories];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredOffers = _selectedFilter == 'Todo'
        ? _offers
        : _offers.where((o) {
            final category = o['category_name'] as String? ?? 'Varios';
            return category == _selectedFilter;
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Lighter background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Ofertas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.slate700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filters ──
          Container(
            color: Colors.white,
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.slate600,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── List ──
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : filteredOffers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 64,
                          color: AppColors.slate300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay ofertas disponibles',
                          style: TextStyle(
                            color: AppColors.slate500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOffers.length,
                    itemBuilder: (context, index) {
                      return _OfferCard(offer: filteredOffers[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatefulWidget {
  final Map<String, dynamic> offer;

  const _OfferCard({required this.offer});

  @override
  State<_OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<_OfferCard> {
  bool _isAdding = false;

  Future<void> _addToCart() async {
    final storeId = widget.offer['store_id'] as String?;
    final branchId = widget.offer['branch_id'] as String?;
    final id = widget.offer['id'] as String?; // catalog_item_id
    // Note: In offers endpoint we might need branch_catalog_item_id.
    // Assuming the refactored backend provides it or we fallback to logic.
    // If missing, we show detail sheet.

    final bciId = widget.offer['branch_catalog_item_id'] as String?;

    if (storeId == null || branchId == null || id == null || bciId == null) {
      // Open detail sheet if we miss critical IDs for direct add
      ProductDetailSheet.show(context, widget.offer);
      return;
    }

    setState(() => _isAdding = true);
    try {
      await context.read<CartProvider>().addItem(
        storeId: storeId,
        branchId: branchId,
        catalogItemId: id,
        branchCatalogItemId: bciId,
        qty: 1,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.offer['name']} agregado'),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.offer['name'] as String? ?? 'Producto';
    final imageUrl = widget.offer['image_url'] as String?;
    final basePrice =
        (widget.offer['base_price_amount'] as num?)?.toDouble() ?? 0.0;
    final offerPrice = (widget.offer['offer_price_amount'] as num?)?.toDouble();
    final storeName = widget.offer['store_name'] as String? ?? 'Tienda';

    // Calculate discount percentage
    final discount = offerPrice != null && basePrice > 0
        ? ((basePrice - offerPrice) / basePrice * 100).round()
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ProductDetailSheet.show(context, widget.offer),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image Section (Large Square) ──
                Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade100,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.restaurant,
                                color: Colors.grey,
                                size: 40,
                              ),
                            )
                          : const Icon(
                              Icons.restaurant,
                              color: Colors.grey,
                              size: 40,
                            ),
                    ),
                    if (discount > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            '$discount% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 16),

                // ── Info Section ──
                Expanded(
                  child: SizedBox(
                    height:
                        130, // Match image height for vertical alignment distribution
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    storeName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.slate400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.slate700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Prices
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  'S/ ${(offerPrice ?? basePrice).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (offerPrice != null &&
                                    offerPrice < basePrice) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    'S/ ${basePrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      decoration: TextDecoration.lineThrough,
                                      color: AppColors.slate400,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),

                        // ── Add Button ──
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isAdding ? null : _addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: _isAdding
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Agregar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
