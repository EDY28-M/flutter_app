import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/address_service.dart';

class AddressFormScreen extends StatefulWidget {
  final Map<String, dynamic>? address;

  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressLine1Ctrl = TextEditingController();
  final _addressLine2Ctrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  bool _isDefault = false;
  bool _saving = false;
  bool get _isEdit => widget.address != null;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    if (a != null) {
      _labelCtrl.text = a['label'] as String? ?? '';
      _contactNameCtrl.text = a['contact_name'] as String? ?? '';
      _contactPhoneCtrl.text = a['contact_phone'] as String? ?? '';
      _regionCtrl.text = a['region'] as String? ?? '';
      _provinceCtrl.text = a['province'] as String? ?? '';
      _districtCtrl.text = a['district'] as String? ?? '';
      _cityCtrl.text = a['city'] as String? ?? '';
      _addressLine1Ctrl.text = a['address_line1'] as String? ?? '';
      _addressLine2Ctrl.text = a['address_line2'] as String? ?? '';
      _referenceCtrl.text = a['reference'] as String? ?? '';
      _isDefault = a['is_default'] == true;
    } else {
      _regionCtrl.text = 'Huánuco';
      _provinceCtrl.text = 'Leoncio Prado';
      _districtCtrl.text = 'Rupa-Rupa';
      _cityCtrl.text = 'Tingo María';
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _regionCtrl.dispose();
    _provinceCtrl.dispose();
    _districtCtrl.dispose();
    _cityCtrl.dispose();
    _addressLine1Ctrl.dispose();
    _addressLine2Ctrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final dto = {
        'label': _labelCtrl.text.trim().isEmpty ? null : _labelCtrl.text.trim(),
        'contact_name': _contactNameCtrl.text.trim().isEmpty ? null : _contactNameCtrl.text.trim(),
        'contact_phone': _contactPhoneCtrl.text.trim().isEmpty ? null : _contactPhoneCtrl.text.trim(),
        'country_code': 'PE',
        'region': _regionCtrl.text.trim(),
        'province': _provinceCtrl.text.trim(),
        'district': _districtCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'address_line1': _addressLine1Ctrl.text.trim(),
        'address_line2': _addressLine2Ctrl.text.trim().isEmpty ? null : _addressLine2Ctrl.text.trim(),
        'reference': _referenceCtrl.text.trim().isEmpty ? null : _referenceCtrl.text.trim(),
        'latitude': -9.295,
        'longitude': -75.998,
        'is_default': _isDefault,
      };

      if (_isEdit) {
        await AddressService.update(widget.address!['id'] as String, dto);
      } else {
        await AddressService.create(dto);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Dirección actualizada' : 'Dirección creada'),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
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
      if (mounted) setState(() => _saving = false);
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
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Editar dirección' : 'Nueva dirección',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.slate700,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildField('Etiqueta (ej: Casa, Trabajo)', _labelCtrl, optional: true),
            const SizedBox(height: 16),
            _buildField('Nombre de contacto', _contactNameCtrl, optional: true),
            const SizedBox(height: 16),
            _buildField('Teléfono', _contactPhoneCtrl, optional: true, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildField('Región', _regionCtrl),
            const SizedBox(height: 16),
            _buildField('Provincia', _provinceCtrl),
            const SizedBox(height: 16),
            _buildField('Distrito', _districtCtrl),
            const SizedBox(height: 16),
            _buildField('Ciudad', _cityCtrl),
            const SizedBox(height: 16),
            _buildField('Dirección', _addressLine1Ctrl, hint: 'Calle, número, etc.'),
            const SizedBox(height: 16),
            _buildField('Referencia (opcional)', _addressLine2Ctrl, optional: true),
            const SizedBox(height: 16),
            _buildField('Referencia adicional', _referenceCtrl, optional: true),
            const SizedBox(height: 24),
            SwitchListTile(
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
              title: const Text('Usar como dirección predeterminada'),
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_isEdit ? 'Guardar cambios' : 'Guardar dirección'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    bool optional = false,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      validator: optional
          ? null
          : (v) {
              if (v == null || v.trim().isEmpty) return 'Campo requerido';
              return null;
            },
    );
  }
}
