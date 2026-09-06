import 'package:car_rental_mvp/data/models/campaign_model.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../widgets/primary_button.dart';

class AdminCampaignFormScreen extends StatefulWidget {
  final Campaign? campaign;

  const AdminCampaignFormScreen({super.key, this.campaign});

  @override
  State<AdminCampaignFormScreen> createState() =>
      _AdminCampaignFormScreenState();
}

class _AdminCampaignFormScreenState extends State<AdminCampaignFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _buttonTextController;
  late TextEditingController _whatsappMsgController;
  late TextEditingController _orderController;
  bool _isActive = true;

  // Gradient renk seçenekleri
  int _selectedGradientIndex = 0;
  static const List<List<Color>> _gradientOptions = [
    [Color(0xFF6A1B9A), Color(0xFF42A5F5)], // Mor-Mavi
    [Color(0xFF00BFA5), Color(0xFF00ACC1)], // Yeşil-Cyan
    [Color(0xFFEF6C00), Color(0xFFF4511E)], // Turuncu-Kırmızı
    [Color(0xFF1565C0), Color(0xFF1E88E5)], // Mavi
    [Color(0xFFC62828), Color(0xFFEF5350)], // Kırmızı
    [Color(0xFF2E7D32), Color(0xFF66BB6A)], // Yeşil
  ];

  bool get _isEditing => widget.campaign != null;

  @override
  void initState() {
    super.initState();
    final c = widget.campaign;
    _titleController = TextEditingController(text: c?.title ?? '');
    _descriptionController = TextEditingController(text: c?.description ?? '');
    _buttonTextController =
        TextEditingController(text: c?.buttonText ?? 'Bize Ulaşın');
    _whatsappMsgController =
        TextEditingController(text: c?.whatsappMessage ?? '');
    _orderController =
        TextEditingController(text: c?.order.toString() ?? '0');
    _isActive = c?.isActive ?? true;

    // Mevcut gradient'i bul
    if (c != null && c.gradientColors.length >= 2) {
      for (int i = 0; i < _gradientOptions.length; i++) {
        if (_gradientOptions[i][0].value == c.gradientColors[0].value &&
            _gradientOptions[i][1].value == c.gradientColors[1].value) {
          _selectedGradientIndex = i;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _buttonTextController.dispose();
    _whatsappMsgController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final selectedColors = _gradientOptions[_selectedGradientIndex];
      final campaign = Campaign(
        id: widget.campaign?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        // Kampanya kodunun formda bir alanı yok. Burada aktarılmazsa
        // model null üretiyor ve her düzenleme mevcut kodu siliyordu.
        code: widget.campaign?.code,
        gradientColors: selectedColors,
        buttonText: _buttonTextController.text.trim(),
        whatsappMessage: _whatsappMsgController.text.trim(),
        isActive: _isActive,
        order: AppHelpers.tamSayiCoz(_orderController.text) ?? 0,
      );

      if (_isEditing) {
        await _firestoreService.updateCampaign(
            widget.campaign!.id, campaign.toFirestore());
      } else {
        await _firestoreService.addCampaign(campaign);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  _isEditing ? 'Kampanya güncellendi.' : 'Kampanya eklendi.')),
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
        title: Text(_isEditing ? 'Kampanya Düzenle' : 'Yeni Kampanya Ekle'),
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
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Kampanya Başlığı',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Başlık gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Açıklama gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _whatsappMsgController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'WhatsApp Mesajı',
                      hintText: 'Merhaba, ... kampanyanız hakkında bilgi almak istiyorum.',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Mesaj gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _buttonTextController,
                          decoration: const InputDecoration(
                            labelText: 'Buton Yazısı',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _orderController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Sıra (0, 1, 2...)',
                            helperText: 'Küçük sayı önce gösterilir',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Gradient Seçimi ──
                  Text('Kart Rengi', style: AppTextStyles.headingMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(_gradientOptions.length, (index) {
                      final isSelected = _selectedGradientIndex == index;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedGradientIndex = index),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: _gradientOptions[index],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: isSelected
                                ? Border.all(color: AppColors.primary, width: 3)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  SwitchListTile(
                    title: const Text('Aktif'),
                    subtitle: const Text('Uygulamada görünsün mü?'),
                    value: _isActive,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  const SizedBox(height: 24),

                  // ── Önizleme ──
                  // Yalnızca bu blok, başlık/açıklama alanlarını dinleyerek
                  // yeniden çizilir. Eskiden hiçbir şey dinlemediği için
                  // önizleme yazarken güncellenmiyor, ancak renk seçimi gibi
                  // başka bir setState tetiklendiğinde geç geliyordu.
                  Text('Önizleme', style: AppTextStyles.headingMedium),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_titleController, _descriptionController]),
                    builder: (context, _) => Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: _gradientOptions[_selectedGradientIndex],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleController.text.isEmpty
                                ? 'Başlık'
                                : _titleController.text,
                            style: AppTextStyles.headingMedium
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _descriptionController.text.isEmpty
                                ? 'Açıklama'
                                : _descriptionController.text,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.white70),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: _isEditing ? 'Güncelle' : 'Kampanya Ekle',
                    icon: _isEditing
                        ? Icons.save_rounded
                        : Icons.add_rounded,
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