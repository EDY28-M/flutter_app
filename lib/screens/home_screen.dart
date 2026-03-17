import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../providers/favorites_provider.dart';
import '../services/store_service.dart';
import 'stores_list_screen.dart';
import '../widgets/product_detail_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  // Dynamic Professional Theme mapping & Hash Fallback
  static Map<String, dynamic> themeForCategory(String categoryName) {
    if (categoryName.isEmpty) return _fallbackTheme('default');
    final code = categoryName.trim().toLowerCase();

    // 1. Expanded Premium Mappings with Rounded Icons
    if (code.contains('farmacia') || code.contains('pharmacy') || code.contains('salud') || code.contains('medic') || code.contains('botica')) {
      return {
        'bg': Colors.blue.shade100.withOpacity(0.4),
        'border': Colors.blue.shade200.withOpacity(0.5),
        'iconColor': Colors.blue.shade600,
        'icon': Icons.local_pharmacy_rounded,
      };
    } else if (code.contains('boutique') || code.contains('ropa') || code.contains('zapatos') || code.contains('moda') || code.contains('retail')) {
      return {
        'bg': Colors.purple.shade100.withOpacity(0.4),
        'border': Colors.purple.shade200.withOpacity(0.5),
        'iconColor': Colors.purple.shade600,
        'icon': Icons.checkroom_rounded,
      };
    } else if (code.contains('tech') || code.contains('tecnolog') || code.contains('celular') || code.contains('comput')) {
      return {
        'bg': Colors.teal.shade100.withOpacity(0.4),
        'border': Colors.teal.shade200.withOpacity(0.5),
        'iconColor': Colors.teal.shade600,
        'icon': Icons.devices_rounded,
      };
    } else if (code.contains('market') || code.contains('bodega') || code.contains('super') || code.contains('abarrote') || code.contains('mini') || code.contains('tienda') || code.contains('store')) {
      return {
        'bg': Colors.green.shade100.withOpacity(0.4),
        'border': Colors.green.shade200.withOpacity(0.5),
        'iconColor': Colors.green.shade600,
        'icon': Icons.shopping_basket_rounded,
      };
    } else if (code.contains('mascota') || code.contains('pet') || code.contains('veterinaria') || code.contains('animal')) {
      return {
        'bg': Colors.brown.shade100.withOpacity(0.4),
        'border': Colors.brown.shade200.withOpacity(0.5),
        'iconColor': Colors.brown.shade600,
        'icon': Icons.pets_rounded,
      };
    } else if (code.contains('licor') || code.contains('bebida') || code.contains('trago') || code.contains('cerveza')) {
      return {
        'bg': Colors.pink.shade100.withOpacity(0.4),
        'border': Colors.pink.shade200.withOpacity(0.5),
        'iconColor': Colors.pink.shade600,
        'icon': Icons.liquor_rounded,
      };
    } else if (code.contains('restaurant') || code.contains('comida') || code.contains('burger') || code.contains('pollo') || code.contains('fast') || code.contains('cafe')) {
      return {
        'bg': Colors.orange.shade100.withOpacity(0.4),
        'border': Colors.orange.shade200.withOpacity(0.5),
        'iconColor': Colors.orange.shade800,
        'icon': code.contains('pizza') ? Icons.local_pizza_rounded : Icons.restaurant_rounded,
      };
    }
    
    // 2. Hash-based dynamic generated beautiful fallbacks for unseen custom categories
    return _fallbackTheme(code);
  }

  static Map<String, dynamic> _fallbackTheme(String hashSource) {
    int hash = 0;
    for (int i = 0; i < hashSource.length; i++) {
      hash = hashSource.codeUnitAt(i) + ((hash << 5) - hash);
    }
    hash = hash.abs();

    final palette = [
      Colors.indigo, Colors.indigoAccent,
      Colors.deepOrange, Colors.deepOrangeAccent,
      Colors.cyan, Colors.cyanAccent,
      Colors.pink, Colors.pinkAccent,
      Colors.lightBlue, Colors.lightBlueAccent,
      Colors.amber, Colors.amberAccent,
    ];

    final icons = [
      Icons.storefront_rounded,
      Icons.shopping_bag_rounded,
      Icons.local_mall_rounded,
      Icons.stars_rounded,
      Icons.inventory_2_rounded,
      Icons.category_rounded,
      Icons.sell_rounded,
      Icons.redeem_rounded,
      Icons.dashboard_customize_rounded,
    ];

    final colorBase = palette[hash % palette.length];
    final selectedIcon = icons[hash % icons.length];

    // Some MaterialColor objects don't map directly back cleanly to shades, 
    // but the palette mostly consists of primary swatches that work with opacity
    final bgColor = (colorBase is MaterialColor) ? colorBase.shade100.withOpacity(0.4) : colorBase.withOpacity(0.15);
    final borderColor = (colorBase is MaterialColor) ? colorBase.shade200.withOpacity(0.5) : colorBase.withOpacity(0.3);
    final iconColor = (colorBase is MaterialColor) ? colorBase.shade600 : colorBase;

    return {
      'bg': bgColor,
      'border': borderColor,
      'iconColor': iconColor,
      'icon': selectedIcon,
    };
  }
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _popularProducts = [];
  bool _loading = true;

  // ── Fallback data matching HTML exactly ──
  static const _fallbackCategories = [
    {'code': 'restaurant', 'name': 'Comida'},
    {'code': 'pharmacy', 'name': 'Farmacia'},
    {'code': 'boutique', 'name': 'Moda'},
    {'code': 'tech', 'name': 'Tech'},
    {'code': 'store', 'name': 'Tienda'},
  ];

  static const _fallbackProducts = [
    {
      'id': 'demo1',
      'branch_catalog_item_id': 'bci1',
      'name': 'Hamburguesa Clásica',
      'store_name': 'The Burger Lab',
      'image_url': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCvFaiJZLhlmNTHj1X9SjAvpncboNT6k1r_VlluG1CF4vHJCH1NL6Ldp5397iWvRSmmFw5ARmbX4wPzXtWNmIJeFgeg7DHFBI-rNzj3rPqIKuoYMQMxXeAN1MwQU8NamdC70XVCYVoUbuF9BNY2svPfG3Fhdxi3l7zwdp30UWT6j8L3v4TxTaoUv3KJq2gh15iJERogk841Bjdys2991RqMoaIJ3HZA3V0wR0Unt_PMhmK7q2yxMAUphgnEaURhwM6EcnHJWmTB0A50',
      'base_price_amount': 25.00,
      'is_on_offer': true,
      'offer_price_amount': 19.90,
      'store_id': 's1',
      'branch_id': 'b1',
      'description': 'Hamburguesa de res con queso, lechuga y tomate.',
    },
    {
      'id': 'demo2',
      'branch_catalog_item_id': 'bci2',
      'name': 'Pizza Pepperoni',
      'store_name': 'Bella Pizza',
      'image_url': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAkY7PYpnSAcmhitcx-hBE4GeeElv6Pug2qAc9LTq4td2sOhXDe_5S7SwZkTz8H76EZ4aOt17brngh_TVZvlga0EH_EiLQ5hePJU3c0n--bTC0yLQufQIei0reftPM-MLHl6w3bfHQnE5nTMMvXX6boUV9U_nQtZCcq3mU5ePdk33AM0OZKENfuT10ah0KZQjVhd7YRgXY2ky_luzPgYJ6mJTHifkK4v-yG4ZqhOOcVhLxuDI1aNi5CIi_E6NQVWAvRJzEOGCrjRh8a',
      'base_price_amount': 45.00,
      'is_on_offer': false,
      'store_id': 's2',
      'branch_id': 'b2',
      'description': 'Pizza artesanal con pepperoni y queso mozzarella.',
    },
  ];

  static const _promoImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuD-M4Rp0EAKJY3p49IM8wuoySXX2xrwvVuiklpl1CPerUzSYmFfk9nkV9M0r654sYLVzeUZrMchPJEN_nMEB793Xb3PCgrxLkeVveoggLyA9fwqepeBxwW6XG9yImuvLdGuesLxw1gGS8aSCOUu-O-Q2J8g4Mt1b9XgKSKkcSeYy3uJZqIhDGMcrowGZEBCwwBY7bRBFWZ4bGUIZwb4jfVjkkIIR7bVxRK8a285jcP5RBVgTdPEn1LLK2_96GPSBjTa9TYqy4AODW6N';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        StoreService.getCategories(),
        StoreService.getPopularProducts(),
      ]);
      setState(() {
        _categories = results[0];
        _popularProducts = results[1];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  // ════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final cats = _categories.isNotEmpty
        ? _categories
        : _fallbackCategories.map((e) => Map<String, dynamic>.from(e)).toList();
    final products = _popularProducts.isNotEmpty
        ? _popularProducts
        : _fallbackProducts.map((e) => Map<String, dynamic>.from(e)).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Header(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16), // Spacing below the orange header
                // ── Categories ──
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: cats.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (_, i) => _CategoryChip(
                      code: cats[i]['code'] as String? ?? '',
                      name: cats[i]['name'] as String? ?? '',
                      selected: false,
                      onTap: () {
                        final categoryCode = cats[i]['code'] as String;
                        final categoryName = cats[i]['name'] as String;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StoresListScreen(
                              categoryCode: categoryCode,
                              categoryName: categoryName,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ── Promo Banner ──
                _PromoBanner(imageUrl: _promoImageUrl),

                // ── Popular Products Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Productos populares',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Ver todos',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Popular Products Grid ──
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    child: Column(
                      children: products
                          .map((p) => _PopularProductCard(
                                item: p,
                                onTap: () {
                                  ProductDetailSheet.show(context, p);
                                },
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  POPULAR PRODUCT CARD (Large)
// ════════════════════════════════════════════════════
class _PopularProductCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _PopularProductCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as String? ?? '';
    final imageUrl = item['image_url'] as String?;
    final price = (item['base_price_amount'] as num?)?.toDouble() ?? 0.0;
    final isOnOffer = item['is_on_offer'] as bool? ?? false;
    final offerPrice = (item['offer_price_amount'] as num?)?.toDouble();
    final storeName = item['store_name'] as String? ?? 'Tienda';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            SizedBox(
              height: 192,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                   if (imageUrl != null && imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: Colors.grey.shade200, 
                        child: const Icon(Icons.restaurant, size: 48, color: Colors.grey)
                      ),
                    )
                  else
                    Container(color: Colors.grey.shade200, child: const Icon(Icons.restaurant, size: 48, color: Colors.grey)),
                  
                  // Offer Badge
                  if (isOnOffer)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
                          ],
                        ),
                        child: const Text(
                          'OFERTA',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        storeName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'S/ ${(isOnOffer && offerPrice != null ? offerPrice : price).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.slate700,
                        ),
                      ),
                      if (isOnOffer && offerPrice != null && offerPrice < price) ...[
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            'S/ ${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.slate400,
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ════════════════════════════════════════════════════
//  HEADER — matches <header> in HTML exactly
// ════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 64),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // dot‑pattern overlay
          Positioned.fill(child: CustomPaint(painter: _DotPainter(0.15))),
          Column(
            children: [
              // ── Top row: location + bell ──
              Row(
                children: [
                  // location icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.location_on,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ENTREGAR EN',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                          ),
                        ),
                        const Text(
                          'Tingo María, PE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // bell icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 24),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primary, width: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // ── Search bar ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.slate400, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      '¿Qué se te antoja hoy?',
                      style: TextStyle(
                        color: AppColors.slate400,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  CATEGORY CHIP — matches each <button> in HTML
// ════════════════════════════════════════════════════
class _CategoryChip extends StatelessWidget {
  final String code;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.code,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = HomeScreen.themeForCategory(name);
    final bgColor = theme['bg'] as Color;
    final borderColor = theme['border'] as Color;
    final iconColor = theme['iconColor'] as Color;
    final icon = theme['icon'] as IconData;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Center(
                  child: Icon(icon, color: iconColor, size: 36)),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.slate700,
              ),
            ),
          ],
        ),
      ),
    );
  }


}

// ════════════════════════════════════════════════════
//  PROMO BANNER — matches the HTML promo section
// ════════════════════════════════════════════════════
class _PromoBanner extends StatelessWidget {
  final String imageUrl;
  const _PromoBanner({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 21 / 9, // aspect-[21/9] from HTML
        child: Stack(
          fit: StackFit.expand,
          children: [
            // gradient bg
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFFFB923C)], // to-orange-400
                ),
              ),
            ),
            // dot pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: CustomPaint(painter: _DotPainter(1)),
              ),
            ),
            // text side
            Positioned(
              left: 24,
              top: 0,
              bottom: 0,
              right: MediaQuery.of(context).size.width * 0.5 - 16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Limitado" pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'LIMITADO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ofertas del día',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hasta 50% de descuento',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // image side (right half) — rounded-l-[4rem] border-l-4 border-white/20
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.5 - 16,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(64),
                    bottomLeft: Radius.circular(64),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                          color: Colors.orange.withOpacity(0.4)),
                      errorWidget: (_, _, _) => Container(
                          color: Colors.orange.withOpacity(0.4)),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 4,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
  //  STORE CARD — matches each card in HTML grid
  // ════════════════════════════════════════════════════
  // ignore: unused_element
  class _StoreCard extends StatelessWidget {
  final Map<String, dynamic> store;
  final VoidCallback onTap;

  const _StoreCard({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final storeId = store['id'] as String?;
    final name = store['name'] as String? ?? 'Tienda';
    final imageUrl =
        store['image_url'] as String? ?? store['cover_image_url'] as String?;
    final rating = store['avg_rating'] != null
        ? (store['avg_rating'] as num).toDouble()
        : null;
    final prepTime = store['prep_time_min'] as int? ?? 20;
    final category = store['category'] as Map?;
    final categoryName = category?['name'] as String? ?? '';
    final badge = store['badge'] as String? ?? 'free_delivery';
    final isFavorite = storeId != null
        ? context.watch<FavoritesProvider>().isFavorite(storeId)
        : false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image section (h-48 = 192px) ──
            SizedBox(
              height: 192,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: Colors.grey.shade200),
                      errorWidget: (_, _, _) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.restaurant,
                            size: 48, color: Colors.grey),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.restaurant,
                          size: 48, color: Colors.grey),
                    ),
                  // Badge top-left
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: badge == 'popular'
                            ? AppColors.primary
                            : AppColors.accentGreen,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (badge != 'popular') ...[
                            const Icon(Icons.bolt,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            badge == 'popular'
                                ? 'POPULAR'
                                : 'ENVÍO GRATIS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Favorite top-right
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: storeId != null
                          ? () async {
                              await context
                                  .read<FavoritesProvider>()
                                  .toggle(storeId);
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? AppColors.primary
                              : AppColors.slate400,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Info section (p-5 = 20px) ──
            Padding(
              padding: const EdgeInsets.all(20),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate700,
                          ),
                        ),
                      ),
                      if (rating != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: AppColors.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 16, color: AppColors.slate500),
                      const SizedBox(width: 4),
                      Text(
                        '$prepTime-${prepTime + 10} min',
                        style: TextStyle(
                            color: AppColors.slate500, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.slate400.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$categoryName • \$\$',
                        style: TextStyle(
                            color: AppColors.slate500, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  DOT PATTERN PAINTER — replicates .dot-pattern CSS
// ════════════════════════════════════════════════════
class _DotPainter extends CustomPainter {
  final double opacity;
  _DotPainter(this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(opacity);
    const spacing = 16.0;
    for (var y = 0.0; y < size.height; y += spacing) {
      for (var x = 0.0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


