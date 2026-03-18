import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../services/loyalty_service.dart';
import 'addresses_screen.dart';
import 'auth_wrapper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _loyalty;
  bool _loadingLoyalty = false;

  @override
  void initState() {
    super.initState();
    _loadLoyalty();
  }

  Future<void> _loadLoyalty() async {
    if (!mounted) return;
    setState(() => _loadingLoyalty = true);

    final cached = context.read<AuthProvider>().user?['loyalty'];
    if (cached is Map<String, dynamic>) {
      setState(() => _loyalty = cached);
    }

    final fresh = await LoyaltyService.getMyLoyalty();
    if (mounted) {
      setState(() {
        if (fresh != null) _loyalty = fresh;
        _loadingLoyalty = false;
      });
    }
  }

  String _titleCaseLevel(String level) {
    if (level.isEmpty) return 'Bronce';
    return '${level[0].toUpperCase()}${level.substring(1).toLowerCase()}';
  }

  String _pointsText(int points) {
    return points.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }

  String _membershipBadgeText() {
    final isNewShipping = _loyalty?['is_new_user_shipping_active'] as bool? ?? false;
    final days = (_loyalty?['new_user_shipping_days_remaining'] as num?)?.toInt() ?? 0;

    if (isNewShipping && days > 0) {
      return 'PREMIUM $days DIAS';
    }

    final level = _titleCaseLevel(_loyalty?['level'] as String? ?? 'bronce').toUpperCase();
    return 'CLIENTE $level';
  }

  Color _membershipBadgeBackground() {
    final isNewShipping = _loyalty?['is_new_user_shipping_active'] as bool? ?? false;
    return isNewShipping ? AppColors.primary.withOpacity(0.1) : const Color(0xFFE2E8F0);
  }

  Color _membershipBadgeTextColor() {
    final isNewShipping = _loyalty?['is_new_user_shipping_active'] as bool? ?? false;
    return isNewShipping ? AppColors.primary : AppColors.slate600;
  }

  Future<void> _showRedeemInfoSheet(BuildContext context) async {
    final items = await LoyaltyService.getRedeemableProducts();
    if (!context.mounted) return;

    final points = (_loyalty?['points_balance'] as num?)?.toInt() ?? 0;
    final pointsValue = (_loyalty?['points_value_soles'] as num?)?.toDouble() ??
        (points / 100);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.86,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Canje de Puntos FastGo',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Saldo: ${_pointsText(points)} pts  |  Equivale a S/ ${pointsValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '1000 puntos = S/ 10.00',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'Aun no hay productos para canjear.',
                        style: TextStyle(color: AppColors.slate500),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final p = items[i];
                        final required = (p['points_required'] as num?)?.toInt() ?? 0;
                        final canRedeem = p['can_redeem'] as bool? ?? false;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: (p['image_url'] as String?) != null &&
                                        (p['image_url'] as String).isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: p['image_url'] as String,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => const Icon(Icons.fastfood),
                                      )
                                    : const Icon(Icons.fastfood),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p['name'] as String? ?? 'Producto',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.slate700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p['store_name'] as String? ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.slate500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${_pointsText(required)} pts',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: canRedeem
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  canRedeem ? 'Canjeable' : 'Faltan pts',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: canRedeem
                                        ? const Color(0xFF166534)
                                        : AppColors.slate500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelInfoSheet(BuildContext context) {
    final level = (_loyalty?['level'] as String? ?? 'bronce').toLowerCase();
    final next = _loyalty?['next_level'] as String?;
    final toNext = (_loyalty?['points_to_next_level'] as num?)?.toInt() ?? 0;
    final isNewShipping = _loyalty?['is_new_user_shipping_active'] as bool? ?? false;
    final shippingDays =
        (_loyalty?['new_user_shipping_days_remaining'] as num?)?.toInt() ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Nivel actual: ${_titleCaseLevel(level)}',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.slate700,
              ),
            ),
            const SizedBox(height: 14),
            const Text('Bronce: nivel basico.'),
            const SizedBox(height: 6),
            const Text('Oro: algunos pedidos tienen envio gratis.'),
            const SizedBox(height: 6),
            const Text('Platino: todos los pedidos tienen envio gratis.'),
            if (isNewShipping) ...[
              const SizedBox(height: 10),
              Text(
                'Usuario nuevo: envio gratis activo por $shippingDays dias mas.',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
            if (next != null && toNext > 0) ...[
              const SizedBox(height: 10),
              Text(
                'Te faltan ${_pointsText(toNext)} pts para ${_titleCaseLevel(next)}.',
                style: TextStyle(
                  color: AppColors.slate600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.slate700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          final user = auth.user;
          final firstName = user?['first_name'] as String? ?? 'Usuario';
          final lastName = user?['last_name'] as String? ?? '';
          final email = user?['email'] as String? ?? user?['phone_e164'] as String? ?? '';
          final photoUrl = user?['photo_url'] as String?;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.slate400,
                            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                                ? CachedNetworkImageProvider(photoUrl)
                                : null,
                            child: photoUrl == null || photoUrl.isEmpty
                                ? Text(
                                    '${firstName[0]}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(
                                  BorderSide(color: Colors.white, width: 2),
                                ),
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$firstName $lastName'.trim(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate700,
                              ),
                            ),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.slate500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _membershipBadgeBackground(),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _membershipBadgeText(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _membershipBadgeTextColor(),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Puntos FastGo',
                          value: _loadingLoyalty
                              ? '...'
                              : _pointsText(
                                  (_loyalty?['points_balance'] as num?)
                                          ?.toInt() ??
                                      0,
                                ),
                          icon: Icons.monetization_on_outlined,
                          trend: _loadingLoyalty
                              ? null
                              : 'Canjeable S/ ${((_loyalty?['points_value_soles'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                          trendUp: true,
                          onTap: () => _showRedeemInfoSheet(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Nivel Actual',
                          value: _loadingLoyalty
                              ? '...'
                              : _titleCaseLevel(
                                  _loyalty?['level'] as String? ?? 'bronce',
                                ),
                          icon: Icons.workspace_premium_outlined,
                          subtitle: _loadingLoyalty
                              ? null
                              : ((_loyalty?['next_level'] as String?) != null
                                  ? '${_pointsText((_loyalty?['points_to_next_level'] as num?)?.toInt() ?? 0)} pts para ${_titleCaseLevel(_loyalty?['next_level'] as String)}'
                                  : 'Nivel maximo alcanzado'),
                          onTap: () => _showLevelInfoSheet(context),
                        ),
                      ),
                    ],
                  ),
                ),
                _MenuSection(
                  title: 'Mi Cuenta',
                  items: [
                    _MenuItem(icon: Icons.payments_outlined, label: 'Métodos de Pago', onTap: () {}),
                    _MenuItem(icon: Icons.location_on_outlined, label: 'Direcciones de Entrega', onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen()));
                    }),
                    _MenuItem(icon: Icons.shield_outlined, label: 'Seguridad y Privacidad', onTap: () {}),
                  ],
                ),
                _MenuSection(
                  title: 'Soporte',
                  items: [
                    _MenuItem(icon: Icons.help_outline, label: 'Centro de Ayuda', onTap: () {}),
                    _MenuItem(icon: Icons.info_outline, label: 'Acerca de FastGo', onTap: () {}),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _logout(context, auth),
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar Sesión'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFFF43F5E),
                        backgroundColor: const Color(0xFFFFF1F2),
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFFFFE4E6)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Versión 4.2.0 (Stable)',
                    style: TextStyle(color: AppColors.slate400, fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _logout(BuildContext context, AuthProvider auth) async {
    await auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? trend;
  final bool trendUp;
  final String? subtitle;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.trend,
    this.trendUp = false,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate500,
                      letterSpacing: 1,
                    ),
                  ),
                  Icon(icon, color: AppColors.primary, size: 24),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate700,
                ),
              ),
              if (trend != null)
                Row(
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: trendUp ? AppColors.accentGreen : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        trend!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: trendUp ? AppColors.accentGreen : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.slate500, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.slate500,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                final isLast = e.key == items.length - 1;
                return Column(
                  children: [
                    e.value,
                    if (!isLast) const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.slate500, size: 24),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.slate700,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.slate400),
      onTap: onTap,
    );
  }
}
