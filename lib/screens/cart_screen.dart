import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadMyCarts();
    });
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
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Revisa tu pedido',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.slate700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (_, cart, __) {
          final current = cart.currentCart ?? (cart.carts.isNotEmpty ? cart.carts.first : null);
          final items = (current?['items'] as List?) ?? [];
          final subtotal = (current?['subtotal'] as num?)?.toDouble() ?? 0.0;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.slate400),
                  const SizedBox(height: 16),
                  Text(
                    'Tu carrito está vacío',
                    style: TextStyle(color: AppColors.slate500, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega productos desde las tiendas',
                    style: TextStyle(color: AppColors.slate400, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _CartItemTile(
                    item: items[i] as Map<String, dynamic>,
                    onUpdate: () => cart.loadMyCarts(),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: TextStyle(color: AppColors.slate500)),
                          Text('S/ ${subtotal.toStringAsFixed(2)}', style: TextStyle(color: AppColors.slate500)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Envío', style: TextStyle(color: AppColors.slate500)),
                          Text('Gratis', style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(
                            'S/ ${subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => _checkout(context, cart, current!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: AppColors.primary.withOpacity(0.4),
                          ),
                          child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Ir a pagar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _checkout(BuildContext context, CartProvider cart, Map<String, dynamic> currentCart) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          cart: currentCart,
          onSuccess: () => cart.clearCurrent(),
        ),
      ),
    ).then((_) {
      cart.loadMyCarts();
    });
  }
}

class _CartItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onUpdate;

  const _CartItemTile({
    required this.item,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as String? ?? '';
    final imageUrl = item['image_url'] as String?;
    final price = (item['unit_price'] as num?)?.toDouble() ?? 0.0;
    final qty = item['qty'] as int? ?? 1;
    final notes = item['notes'] as String?;
    final itemId = item['id'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[200]),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant),
                    ),
                  )
                : Container(
                    width: 96,
                    height: 96,
                    color: Colors.grey[200],
                    child: const Icon(Icons.restaurant, size: 40),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.slate700,
                        ),
                      ),
                    ),
                    Text(
                      'S/ ${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (notes != null && notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      notes,
                      style: TextStyle(color: AppColors.slate500, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: itemId != null && qty > 1
                                ? () => context.read<CartProvider>().updateQty(itemId, qty - 1)
                                : null,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: qty > 1 ? Colors.white : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                                ],
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: qty > 1 ? AppColors.primary : Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 28,
                            child: Text(
                              '$qty',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: itemId != null
                                ? () => context.read<CartProvider>().updateQty(itemId, qty + 1)
                                : null,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 4),
                                ],
                              ),
                              child: const Icon(Icons.add, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
