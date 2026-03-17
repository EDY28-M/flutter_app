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
      final cart = context.read<CartProvider>();
      cart.loadMyCarts();
      cart.addListener(_onError);
    });
  }

  @override
  void dispose() {
    context.read<CartProvider>().removeListener(_onError);
    super.dispose();
  }

  void _onError() {
    if (!mounted) return;
    final cart = context.read<CartProvider>();
    if (cart.lastError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cart.lastError!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Cerrar',
            textColor: Colors.white,
            onPressed: () => cart.clearError(),
          ),
        ),
      );
      cart.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.slate700,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Revisa tu pedido',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.slate700,
          ),
        ),
        actions: [
          // Optional: Clear cart button implementation could go here
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (_, cart, child) {
          if (cart.isLoading &&
              cart.carts.isEmpty &&
              cart.currentCart == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final current =
              cart.currentCart ??
              (cart.carts.isNotEmpty ? cart.carts.first : null);
          final items = (current?['items'] as List?) ?? [];
          final subtotal = (current?['subtotal'] as num?)?.toDouble() ?? 0.0;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppColors.slate400,
                  ),
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

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, i) =>
                          _CartItemTile(item: items[i] as Map<String, dynamic>),
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
                              Text(
                                'Subtotal',
                                style: TextStyle(color: AppColors.slate500),
                              ),
                              Text(
                                'S/ ${subtotal.toStringAsFixed(2)}',
                                style: TextStyle(color: AppColors.slate500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Envío',
                                style: TextStyle(color: AppColors.slate500),
                              ),
                              Text(
                                'Gratis',
                                style: TextStyle(
                                  color: AppColors.accentGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
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
                              onPressed: cart.isLoading
                                  ? null
                                  : () => _checkout(context, cart, current!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                shadowColor: AppColors.primary.withOpacity(0.4),
                                disabledBackgroundColor: AppColors.primary
                                    .withOpacity(0.6),
                              ),
                              child: cart.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Ir a pagar',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
              ),
              if (cart.isLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _checkout(
    BuildContext context,
    CartProvider cart,
    Map<String, dynamic> currentCart,
  ) {
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

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as String? ?? '';
    final imageUrl = item['image_url'] as String?;
    final price = (item['unit_price'] as num?)?.toDouble() ?? 0.0;
    final qty = item['qty'] as int? ?? 1;
    final notes = item['notes'] as String?;
    final itemId = item['id'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.grey[100],
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: Colors.grey[200]),
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.fastfood, color: Colors.grey),
                    )
                  : const SizedBox(
                      width: 80,
                      height: 80,
                      child: Icon(Icons.fastfood, color: Colors.grey, size: 30),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.slate700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'S/ ${(price * qty).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'S/ ${price.toStringAsFixed(2)} c/u',
                      style: TextStyle(color: AppColors.slate400, fontSize: 12),
                    ),
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QuantityButton(
                            icon: qty == 1
                                ? Icons.delete_outline
                                : Icons.remove,
                            color: qty == 1 ? Colors.red : AppColors.slate700,
                            onTap: itemId != null
                                ? () {
                                    if (qty == 1) {
                                      context.read<CartProvider>().removeItem(
                                        itemId,
                                      );
                                    } else {
                                      context.read<CartProvider>().updateQty(
                                        itemId,
                                        qty - 1,
                                      );
                                    }
                                  }
                                : null,
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 32),
                            alignment: Alignment.center,
                            child: Text(
                              '$qty',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.slate700,
                              ),
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add,
                            color: AppColors.primary,
                            onTap: itemId != null
                                ? () => context.read<CartProvider>().updateQty(
                                    itemId,
                                    qty + 1,
                                  )
                                : null,
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

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
