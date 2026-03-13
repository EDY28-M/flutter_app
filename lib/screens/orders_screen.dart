import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../services/order_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _activeOrders = [];
  List<Map<String, dynamic>> _historyOrders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final [active, history] = await Future.wait([
        OrderService.getMyOrders(tab: 'active'),
        OrderService.getMyOrders(tab: 'history'),
      ]);
      setState(() {
        _activeOrders = active;
        _historyOrders = history;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
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
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Pedidos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.slate700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.slate500,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'En Curso'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _OrdersList(orders: _activeOrders, onRefresh: _load),
                _OrdersList(orders: _historyOrders, onRefresh: _load),
              ],
            ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final VoidCallback onRefresh;

  const _OrdersList({required this.orders, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.slate400),
            const SizedBox(height: 16),
            Text(
              'No hay pedidos',
              style: TextStyle(color: AppColors.slate500, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (_, i) => _OrderCard(order: orders[i]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String? ?? '';
    final orderCode = order['order_code'] as String? ?? '';
    final storeName = order['store_name'] as String? ?? '';
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;
    final eta = order['eta_minutes'] as int?;

    return GestureDetector(
      onTap: () => _openOrderDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delivery_dining_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.slate700,
                          ),
                        ),
                        Text(
                          orderCode,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'S/ ${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      if (eta != null)
                        Text(
                          '$eta min',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.slate500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _statusColor(status).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon(status), size: 16, color: _statusColor(status)),
                  const SizedBox(width: 8),
                  Text(
                    _statusLabel(status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(status),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openOrderDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(orderId: order['id'] as String),
      ),
    );
  }

  Color _statusColor(String s) {
    if (s.contains('delivered')) return AppColors.accentGreen;
    if (s.contains('cancelled') || s.contains('failed')) return Colors.red;
    return AppColors.primary;
  }

  IconData _statusIcon(String s) {
    if (s.contains('delivered')) return Icons.check_circle;
    if (s.contains('cancelled') || s.contains('failed')) return Icons.cancel;
    return Icons.schedule;
  }

  String _statusLabel(String s) {
    const map = {
      'created': 'Creado',
      'pending_store_acceptance': 'Esperando tienda',
      'accepted_by_store': 'Aceptado',
      'preparing': 'Preparando',
      'ready_for_pickup': 'Listo para recoger',
      'rider_assigned': 'Repartidor asignado',
      'picked_up': 'Recogido',
      'on_the_way': 'En camino',
      'delivered': 'Entregado',
      'cancelled': 'Cancelado',
      'failed_delivery': 'Falló entrega',
    };
    return map[s] ?? s;
  }
}

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final order = await OrderService.getOrder(widget.orderId);
      setState(() {
        _order = order;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  int _statusStep(String status) {
    if (status.contains('delivered')) return 3;
    if (status.contains('on_the_way') || status.contains('picked_up')) return 2;
    if (status.contains('preparing') || status.contains('accepted') || status.contains('ready')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: Text('Pedido no encontrado')),
      );
    }

    final o = _order!;
    final items = o['items'] as List? ?? [];
    final rider = o['rider'] as Map?;
    final eta = o['eta_minutes'] as int?;
    final status = o['status'] as String? ?? '';
    final currentStep = _statusStep(status);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pedidos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.slate700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Map Placeholder ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 192,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Map background placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 192,
                        color: const Color(0xFFCBD5E1),
                        child: CustomPaint(painter: _MapGridPainter()),
                      ),
                    ),
                    // Delivery icon overlay
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.delivery_dining_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- ETA Section ---
            if (eta != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Tiempo estimado de entrega',
                        style: TextStyle(
                          color: AppColors.slate500,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$eta - ${eta + 5} min',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // --- Tracking Timeline ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                children: [
                  _TimelineStep(
                    icon: Icons.check_circle,
                    label: 'Recibido',
                    subtitle: '12:30 PM',
                    isCompleted: currentStep >= 0,
                    isActive: currentStep == 0,
                    showLine: true,
                    lineCompleted: currentStep > 0,
                  ),
                  _TimelineStep(
                    icon: Icons.soup_kitchen_rounded,
                    label: 'Preparando tu pedido',
                    subtitle: 'El restaurante está cocinando',
                    isCompleted: currentStep >= 1,
                    isActive: currentStep == 1,
                    showLine: true,
                    lineCompleted: currentStep > 1,
                  ),
                  _TimelineStep(
                    icon: Icons.delivery_dining_rounded,
                    label: 'En camino',
                    subtitle: currentStep >= 2 ? 'Tu pedido está en ruta' : 'Pendiente',
                    isCompleted: currentStep >= 2,
                    isActive: currentStep == 2,
                    showLine: true,
                    lineCompleted: currentStep > 2,
                  ),
                  _TimelineStep(
                    icon: Icons.inventory_2_rounded,
                    label: 'Entregado',
                    subtitle: currentStep >= 3 ? '¡Disfruta!' : '',
                    isCompleted: currentStep >= 3,
                    isActive: currentStep == 3,
                    showLine: false,
                    lineCompleted: false,
                  ),
                ],
              ),
            ),

            // --- Rider Card ---
            if (rider != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Rider photo
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE2E8F0),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFFCBD5E1),
                        child: Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REPARTIDOR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate500,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rider['name'] as String? ?? 'Repartidor',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  rider['plate'] as String? ?? 'ABC-1234',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.star, color: Colors.orange, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                '${rider['rating'] ?? 4.9}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Call button
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.call, color: AppColors.primary, size: 20),
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                      ),
                    ),
                    // Chat button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chat, color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),

            // --- Order Summary ---
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resumen del pedido',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.slate700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            o['store_name'] as String? ?? '',
                            style: TextStyle(color: AppColors.slate500, fontSize: 12),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.help_outline, color: AppColors.primary, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Ayuda',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...items.map<Widget>((i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${i['qty']}x ${i['name']}',
                              style: TextStyle(color: AppColors.slate500, fontSize: 14),
                            ),
                            Text(
                              'S/ ${(i['line_total'] as num).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate700,
                              ),
                            ),
                          ],
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      width: double.infinity,
                      height: 1,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total pagado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.slate700,
                        ),
                      ),
                      Text(
                        'S/ ${(o['total'] as num).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primary,
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
    );
  }
}

// --- Timeline Step Widget ---
class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final bool showLine;
  final bool lineCompleted;

  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
    required this.showLine,
    required this.lineCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isCompleted
                    ? (isActive ? AppColors.primary.withOpacity(0.2) : AppColors.primary)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted && !isActive ? Icons.check_circle : icon,
                size: 20,
                color: isCompleted
                    ? (isActive ? AppColors.primary : Colors.white)
                    : AppColors.slate400,
              ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 40,
                color: lineCompleted ? AppColors.primary : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Opacity(
              opacity: isCompleted || isActive ? 1.0 : 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.primary : AppColors.slate700,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.slate500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Map Grid Painter (placeholder) ---
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB0BEC5).withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Draw grid lines to simulate a map
    const spacing = 24.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
