import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/address_service.dart';
import 'address_form_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await AddressService.getMyAddresses();
      setState(() {
        _addresses = list;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _setDefault(String id) async {
    try {
      await AddressService.setDefault(id);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dirección predeterminada actualizada'),
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
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar dirección'),
        content: const Text('¿Estás seguro de eliminar esta dirección?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      await AddressService.delete(id);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dirección eliminada'),
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
        title: const Text(
          'Direcciones de Entrega',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.slate700,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_outlined, size: 64, color: AppColors.slate400),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes direcciones',
                        style: TextStyle(color: AppColors.slate500, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega una para recibir tus pedidos',
                        style: TextStyle(color: AppColors.slate400, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToForm(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar dirección'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _addresses.length + 1,
                    itemBuilder: (_, i) {
                      if (i == _addresses.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToForm(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Nueva dirección'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        );
                      }
                      return _AddressCard(
                        address: _addresses[i],
                        onSetDefault: () => _setDefault(_addresses[i]['id'] as String),
                        onEdit: () => _navigateToForm(context, address: _addresses[i]),
                        onDelete: () => _delete(_addresses[i]['id'] as String),
                      );
                    },
                  ),
                ),
      floatingActionButton: _addresses.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToForm(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add),
              label: const Text('Nueva'),
            )
          : null,
    );
  }

  Future<void> _navigateToForm(BuildContext context, {Map<String, dynamic>? address}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressFormScreen(address: address),
      ),
    );
    if (mounted) _load();
  }
}

class _AddressCard extends StatelessWidget {
  final Map<String, dynamic> address;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final label = address['label'] as String? ?? 'Sin etiqueta';
    final line1 = address['address_line1'] as String? ?? '';
    final district = address['district'] as String? ?? '';
    final city = address['city'] as String? ?? '';
    final isDefault = address['is_default'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault ? AppColors.primary : const Color(0xFFE2E8F0),
          width: isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: isDefault ? AppColors.primary : AppColors.slate500,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDefault ? AppColors.primary : AppColors.slate700,
                    ),
                  ),
                ),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Predeterminada',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$line1, $district, $city',
              style: TextStyle(color: AppColors.slate500, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!isDefault)
                  TextButton(
                    onPressed: onSetDefault,
                    child: const Text('Usar como predeterminada'),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
