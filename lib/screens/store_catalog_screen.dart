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

  List<_CatalogSection> _groupedSections(List<Map<String, dynamic>> items) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    final sortOrder = <String, int>{};

    for (final item in items) {
      final sectionName = (item['category_name'] as String?)?.trim();
      final key = (sectionName == null || sectionName.isEmpty) ? 'General' : sectionName;
      grouped.putIfAbsent(key, () => []).add(item);

      final order = (item['category_sort_order'] as num?)?.toInt() ?? 999;
      sortOrder[key] = order;
    }

    final sections = grouped.entries
        .map((entry) {
          final products = List<Map<String, dynamic>>.from(entry.value)
            ..sort((a, b) =>
                (a['name'] as String? ?? '').toLowerCase().compareTo((b['name'] as String? ?? '').toLowerCase()));
          return _CatalogSection(
            title: entry.key,
            sortOrder: sortOrder[entry.key] ?? 999,
            products: products,
          );
        })
        .toList()
      ..sort((a, b) {
        final byCount = b.products.length.compareTo(a.products.length);
        if (byCount != 0) return byCount;

        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        if (byOrder != 0) return byOrder;

        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });

    return sections;
  }

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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    children: _groupedSections(_items)
                        .map((section) => _CatalogSectionWidget(
                              section: section,
                              addingIds: _addingIds,
                              onAdd: _addToCart,
                            ))
                        .toList(),
                  ),
                ),
    );
  }
}

class _CatalogSection {
  final String title;
  final int sortOrder;
  final List<Map<String, dynamic>> products;

  const _CatalogSection({
    required this.title,
    required this.sortOrder,
    required this.products,
  });
}

class _CatalogSectionWidget extends StatelessWidget {
  final _CatalogSection section;
  final Map<String, bool> addingIds;
  final Future<void> Function(Map<String, dynamic> item) onAdd;

  const _CatalogSectionWidget({
    required this.section,
    required this.addingIds,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate700,
                  ),
                ),
              ),
              Text(
                '${section.products.length} productos',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 292,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: section.products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final item = section.products[index];
              return SizedBox(
                width: 230,
                child: _ProductCardLarge(
                  item: item,
                  isAdding: addingIds[item['id']] ?? false,
                  canAdd: item['branch_catalog_item_id'] != null,
                  onAdd: () => onAdd(item),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _ProductCardLarge extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isAdding;
  final bool canAdd;
  final VoidCallback onAdd;

  const _ProductCardLarge({
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ProductDetailSheet.show(context, item),
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            height: 132,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              height: 132,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (_, _, _) => Container(
                              height: 132,
                              color: Colors.grey[200],
                              child: const Icon(Icons.restaurant, size: 32),
                            ),
                          )
                        : Container(
                            height: 132,
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.restaurant, size: 32)),
                          ),
                  ),
                  if (isOnOffer)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.94),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'OFERTA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.slate700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                    const SizedBox(height: 10),
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
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: isAdding
                            ? const SizedBox(
                                height: 42,
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: canAdd ? onAdd : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: canAdd ? AppColors.primary : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
