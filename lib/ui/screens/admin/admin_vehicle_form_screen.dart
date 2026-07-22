import 'dart:typed_data';
import 'package:car_rental_mvp/data/models/vehicle.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';
import 'package:car_rental_mvp/data/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class AdminVehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AdminVehicleFormScreen({super.key, this.vehicle});

  @override
  State<AdminVehicleFormScreen> createState() => _AdminVehicleFormScreenState();
}

class _AdminVehicleFormScreenState extends State<AdminVehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  // Form alanları
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _priceController;
  late TextEditingController _seatsController;
  late TextEditingController _engineSizeController;
  late TextEditingController _yearController;
  late TextEditingController _featuresController;

  String _selectedCategory = 'SUV';
  String _selectedTransmission = 'Otomatik';
  String _selectedFuelType = 'Gasoline';
  bool _isFeatured = false;
  bool _isAvailable = true;

  // Görsel verileri
  Uint8List? _mainImageBytes;
  String _existingImageUrl = '';
  final List<Uint8List> _galleryImageBytesList = [];
  // Galeri listesinde önizleme ve silme için dosya adları tutulur;
  // bayt listesiyle aynı sırada kalmalıdır.
  final List<String> _galleryImageNames = [];
  List<String> _existingGalleryUrls = [];

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _nameController = TextEditingController(text: v?.name ?? '');
    _brandController = TextEditingController(text: v?.brand ?? '');
    _priceController =
        TextEditingController(text: v != null ? v.dailyPrice.toInt().toString() : '');
    _seatsController =
        TextEditingController(text: v?.seats.toString() ?? '5');
    _engineSizeController =
        TextEditingController(text: v?.engineSize ?? '');
    _yearController =
        TextEditingController(text: v?.year.toString() ?? '2024');
    _featuresController =
        TextEditingController(text: v?.features.join(', ') ?? '');

    if (v != null) {
      _selectedCategory = v.category;
      _selectedTransmission = v.transmission;
      _selectedFuelType = v.fuelType;
      _isFeatured = v.isFeatured;
      _isAvailable = v.isAvailable;
      _existingImageUrl = v.imagePath;
      _existingGalleryUrls = List<String>.from(v.galleryPaths);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _engineSizeController.dispose();
    _yearController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  // ── Ana Görsel Seç ──
  Future<void> _pickMainImage() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _mainImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görsel seçilemedi: $e')),
        );
      }
    }
  }

  // ── Galeri Görselleri Seç ──
  Future<void> _pickGalleryImages() async {
    try {
      final List<XFile> picked = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked.isNotEmpty) {
        for (final file in picked) {
          final bytes = await file.readAsBytes();
          setState(() {
            _galleryImageBytesList.add(bytes);
            _galleryImageNames.add(file.name);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görseller seçilemedi: $e')),
        );
      }
    }
  }

  // ── Kaydet ──
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final features = _featuresController.text
          .split(',')
          .map((f) => f.trim())
          .where((f) => f.isNotEmpty)
          .toList();

      // Önce araç verisini kaydet/güncelle (ID'ye ihtiyacımız var)
      String vehicleId;

      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'brand': _brandController.text.trim(),
        'category': _selectedCategory,
        'dailyPrice': double.parse(_priceController.text.trim()),
        'transmission': _selectedTransmission,
        'fuelType': _selectedFuelType,
        'seats': int.parse(_seatsController.text.trim()),
        'engineSize': _engineSizeController.text.trim(),
        'year': int.parse(_yearController.text.trim()),
        'features': features,
        'isFeatured': _isFeatured,
        'isAvailable': _isAvailable,
      };

      if (_isEditing) {
        vehicleId = widget.vehicle!.id;
      } else {
        // Yeni araç — önce boş görsel URL'leri ile oluştur
        data['imagePath'] = '';
        data['galleryPaths'] = <String>[];
        vehicleId = await _firestoreService.addVehicleData(data);
      }

      // Ana görseli yükle
      String mainImageUrl = _existingImageUrl;
      if (_mainImageBytes != null) {
        mainImageUrl = await _storageService.uploadVehicleImage(
          vehicleId: vehicleId,
          fileName: 'main_${DateTime.now().millisecondsSinceEpoch}.jpg',
          fileBytes: _mainImageBytes!,
        );
      }

      // Galeri görsellerini yükle
      List<String> galleryUrls = List<String>.from(_existingGalleryUrls);
      for (int i = 0; i < _galleryImageBytesList.length; i++) {
        final url = await _storageService.uploadVehicleImage(
          vehicleId: vehicleId,
          fileName: 'gallery_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          fileBytes: _galleryImageBytesList[i],
        );
        galleryUrls.add(url);
      }

      // Firestore'u güncelle — görsel URL'leri ile
      final updateData = <String, dynamic>{
        ...data,
        'imagePath': mainImageUrl,
        'galleryPaths': galleryUrls,
      };

      if (_isEditing) {
        await _firestoreService.updateVehicle(vehicleId, updateData);
      } else {
        // Yeni eklendiyse güncelle (görsel URL'lerini ekle)
        await _firestoreService.updateVehicle(vehicleId, {
          'imagePath': mainImageUrl,
          'galleryPaths': galleryUrls,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text(_isEditing ? 'Araç güncellendi.' : 'Araç eklendi.')),
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

  // ── Görsel Önizleme Widget'ı ──
  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ana Görsel', style: AppTextStyles.headingMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickMainImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
            ),
            child: _mainImageBytes != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _mainImageBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
                : _existingImageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _existingImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              ),
            )
                : _buildPlaceholder(),
          ),
        ),
        const SizedBox(height: 16),
        Text('Galeri Görselleri', style: AppTextStyles.headingMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Mevcut galeri görselleri
            ..._existingGalleryUrls.asMap().entries.map((entry) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      entry.value,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 24),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _existingGalleryUrls.removeAt(entry.key);
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              );
            }),
            // Yeni seçilen galeri görselleri
            ..._galleryImageBytesList.asMap().entries.map((entry) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      entry.value,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _galleryImageBytesList.removeAt(entry.key);
                          _galleryImageNames.removeAt(entry.key);
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              );
            }),
            // Ekleme butonu
            GestureDetector(
              onTap: _pickGalleryImages,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: const Icon(Icons.add_photo_alternate, color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 40, color: Colors.grey[500]),
        const SizedBox(height: 8),
        Text('Fotoğraf Seç', style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Araç Düzenle' : 'Yeni Araç Ekle'),
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
                  // ── Görsel Seçimi ──
                  _buildImagePreview(),
                  const SizedBox(height: 24),

                  // ── Marka & Model ──
                  TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'Marka',
                      hintText: 'BMW, Mercedes-Benz, Tesla...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Marka gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Model Adı',
                      hintText: 'X5 xDrive40i',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Model adı gerekli' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Kategori ──
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: AppConstants.categories
                        .where((c) => c != 'Hepsi')
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCategory = v ?? 'SUV'),
                  ),
                  const SizedBox(height: 16),

                  // ── Fiyat & Koltuk ──
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Günlük Fiyat (₺)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Fiyat gerekli' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _seatsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Koltuk Sayısı',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Vites & Yakıt ──
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTransmission,
                          decoration: const InputDecoration(
                            labelText: 'Vites',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Otomatik', 'Manuel']
                              .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) => setState(
                                  () => _selectedTransmission = v ?? 'Otomatik'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedFuelType,
                          decoration: const InputDecoration(
                            labelText: 'Yakıt Tipi',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Gasoline', 'Diesel', 'Electric', 'Hybrid']
                              .map((f) =>
                              DropdownMenuItem(value: f, child: Text(f)))
                              .toList(),
                          onChanged: (v) => setState(
                                  () => _selectedFuelType = v ?? 'Gasoline'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Motor & Yıl ──
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _engineSizeController,
                          decoration: const InputDecoration(
                            labelText: 'Motor',
                            hintText: '3.0L, 358 kW...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Yıl',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Özellikler ──
                  TextFormField(
                    controller: _featuresController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Özellikler',
                      hintText:
                      'Virgülle ayırın: Panoramic Roof, Heated Seats, Apple CarPlay',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Toggle'lar ──
                  SwitchListTile(
                    title: const Text('Öne Çıkan Araç'),
                    subtitle: const Text('Ana sayfada vurgulanır'),
                    value: _isFeatured,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isFeatured = v),
                  ),
                  SwitchListTile(
                    title: const Text('Müsait'),
                    subtitle: const Text('Kiralamaya açık mı?'),
                    value: _isAvailable,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isAvailable = v),
                  ),
                  const SizedBox(height: 24),

                  // ── Kaydet ──
                  PrimaryButton(
                    label: _isEditing ? 'Güncelle' : 'Araç Ekle',
                    icon:
                    _isEditing ? Icons.save_rounded : Icons.add_rounded,
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