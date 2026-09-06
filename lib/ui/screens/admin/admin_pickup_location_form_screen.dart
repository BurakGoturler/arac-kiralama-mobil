import 'package:car_rental_mvp/data/models/pickup_location_model.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class AdminPickupLocationFormScreen extends StatefulWidget {
  final PickupLocation? location;

  const AdminPickupLocationFormScreen({super.key, this.location});

  @override
  State<AdminPickupLocationFormScreen> createState() =>
      _AdminPickupLocationFormScreenState();
}

class _AdminPickupLocationFormScreenState
    extends State<AdminPickupLocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _orderController;
  bool _isActive = true;

  bool get _isEditing => widget.location != null;

  @override
  void initState() {
    super.initState();
    final l = widget.location;
    _nameController = TextEditingController(text: l?.name ?? '');
    _addressController = TextEditingController(text: l?.address ?? '');
    _orderController = TextEditingController(text: l?.order.toString() ?? '0');
    _isActive = l?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final location = PickupLocation(
        id: widget.location?.id ?? '',
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        isActive: _isActive,
        order: int.tryParse(_orderController.text.trim()) ?? 0,
      );

      if (_isEditing) {
        await _firestoreService.updatePickupLocation(
          widget.location!.id,
          location.toFirestore(),
        );
      } else {
        await _firestoreService.addPickupLocation(location);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Alım yeri güncellendi.'
                : 'Alım yeri eklendi.'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Alım Yeri Düzenle' : 'Yeni Alım Yeri'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Alım Yeri Adı',
                      hintText: 'Gaziantep Merkez Şube',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? 'İsim gerekli' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Adres',
                      hintText: 'Detaylı adres bilgisi...',
                      prefixIcon: Icon(Icons.map_outlined),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Adres gerekli' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _orderController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sıra (0, 1, 2...)',
                      helperText: 'Küçük sayı önce gösterilir',
                      prefixIcon: Icon(Icons.sort),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  SwitchListTile(
                    title: const Text('Aktif'),
                    subtitle: const Text('Müşteriler tarafından seçilebilir'),
                    value: _isActive,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: _isEditing ? 'Güncelle' : 'Alım Yeri Ekle',
                    icon: _isEditing ? Icons.save_rounded : Icons.add_rounded,
                    isLoading: _isLoading,
                    onTap: _isLoading ? null : _save,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}