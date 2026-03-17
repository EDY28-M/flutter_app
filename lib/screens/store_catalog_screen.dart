import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../providers/cart_provider.dart';
import '../services/store_service.dart';
import '../widgets/product_detail_sheet.dart';

class StoreCatalogScreen extends StatefulWidget {
  final String storeId;
  final String branchId;
  final String storeName;

  const StoreCatalogScreen({
    super.key,
    required this.storeId,
    required this.branchId,
    required this.storeName,
  });

  @override
  State<StoreCatalogScreen> createState() => _StoreCatalogScreenState();
}

class _StoreCatalogScreenState extends State<StoreCatalogScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  final Map<String, bool> _addingIds = {};

  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().setStoreBranch(widget.storeId, widget.branchId);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await StoreService.getCatalogItems(widget.storeId, widget.branchId);
      final enrichedItems = items.map((item) => {
        ...item,
        'store_id': widget.storeId,
        'branch_id': widget.branchId,
        'store_name': widget.storeName,
      }).toList();
      setState(() {
        _items = enrichedItems;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addToCart(Map<String, dynamic> item) async {
    final id = item['id'] as String?;
    final bciId = item['branch_catalog_item_id'] as String?;
    if (id == null || bciId == null || _addingIds[id] == true) return;

    setState(() => _addingIds[id] = true);
    try {
      await context.read<CartProvider>().addItem(
        storeId: widget.storeId,
        branchId: widget.branchId,
        catalogItemId: id,
        branchCatalogItemId: bciId,
        variantId: (item['variant'] as Map?)?['id'] as String?,
        qty: 1,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item['name']} agregado al carrito'),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _addingIds[id] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.storeName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.slate700,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.slate400),
                      const SizedBox(height: 16),
                      Text(
                        'No hay productos disponibles',
                        style: TextStyle(color: AppColors.slate500, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (_, i) => _ProductCard(
                      item: _items[i],
                      isAdding: _addingIds[_items[i]['id']] ?? false,
                      canAdd: _items[i]['branch_catalog_item_id'] != null,
                      onAdd: () => _addToCart(_items[i]),
                    ),
                  ),
                ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isAdding;
  final bool canAdd;
  final VoidCallback onAdd;

  const _ProductCard({
    required this.item,
    required this.isAdding,
    required this.canAdd,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as String? ?? '';
    final imageUrl = item['image_url'] as String?;
    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
    final description = item['description'] as String?;
    final variant = item['variant'] as Map?;
    final isOnOffer = item['is_on_offer'] as bool? ?? false;
    final offerPrice = (item['offer_price_amount'] as num?)?.toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ProductDetailSheet.show(context, item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (_, _, _) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.restaurant, size: 32),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.restaurant, size: 32),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.slate700,
                        ),
                      ),
                      if (variant != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            variant['name'] as String? ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.slate500,
                            ),
                          ),
                        ),
                      if (description != null && description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.slate500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (isOnOffer) ...[  
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'OFERTA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: isAdding
                                ? const SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: Padding(
                                      padding: EdgeInsets.all(6),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: canAdd ? onAdd : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: canAdd ? AppColors.primary : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: canAdd
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primary.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add, color: canAdd ? Colors.white : Colors.grey.shade600, size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            canAdd ? 'Agregar' : 'No disponible',
                                            style: TextStyle(
                                              color: canAdd ? Colors.white : Colors.grey.shade600,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
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
