import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:car_rental_mvp/data/models/vehicle.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';
import 'package:car_rental_mvp/data/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
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
  late TextEditingController _monthlyPriceController;
  late TextEditingController _yearlyPriceController;
  late TextEditingController _seatsController;
  late TextEditingController _engineSizeController;
  late TextEditingController _yearController;
  late TextEditingController _featuresController;

  String _selectedCategory = 'SUV';
  String _selectedTransmission = 'Otomatik';
  String _selectedFuelType = 'Benzin';
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
    _monthlyPriceController = TextEditingController(
        text: v != null && v.monthlyPrice > 0
            ? v.monthlyPrice.toInt().toString()
            : '');
    _yearlyPriceController = TextEditingController(
        text: v != null && v.yearlyPrice > 0
            ? v.yearlyPrice.toInt().toString()
            : '');
    _seatsController =
        TextEditingController(text: v?.seats.toString() ?? '5');
    _engineSizeController =
        TextEditingController(text: v?.engineSize ?? '');
    _yearController =
        TextEditingController(text: v?.year.toString() ?? '2024');
    _featuresController =
        TextEditingController(text: v?.features.join(', ') ?? '');

    if (v != null) {
      // Açılır listeler, listede olmayan bir değerle açılınca alanı boş
      // gösteriyor (debug'da hata ekranı). Eski/elle girilmiş değerler
      // listedeki bir karşılığa düşürülür.
      _selectedCategory = AppConstants.categories.skip(1).contains(v.category)
          ? v.category
          : 'Sedan';
      _selectedTransmission =
          v.transmission == 'Manuel' ? 'Manuel' : 'Otomatik';
      _selectedFuelType = Vehicle.yakitNormal(v.fuelType);
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
    _monthlyPriceController.dispose();
    _yearlyPriceController.dispose();
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
  ///
  /// Akış bilinçli olarak "önce görseller, sonra tek yazma" şeklindedir.
  /// Eskiden yeni araç için önce boş bir Firestore dokümanı açılıyor, sonra
  /// görseller yükleniyor, sonra doküman güncelleniyordu. Yükleme ortada
  /// başarısız olduğunda geriye görselsiz bir "hayalet araç" kalıyordu ve
  /// her ekleme iki yazma harcıyordu.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final features = _featuresController.text
          .split(',')
          .map((f) => f.trim())
          .where((f) => f.isNotEmpty)
          .toList();

      // Kimlik: düzenlemede mevcut olan, eklemede önceden üretilen.
      // Görseller Storage'da vehicles/{id}/ altına yazıldığı için kimlik
      // yükleme öncesinde gerekli.
      final vehicleId =
          _isEditing ? widget.vehicle!.id : _firestoreService.yeniAracKimligi();

      // ── Görseller ──
      String mainImageUrl = _existingImageUrl;
      if (_mainImageBytes != null) {
        mainImageUrl = await _storageService.uploadVehicleImage(
          vehicleId: vehicleId,
          fileName: 'main_${DateTime.now().millisecondsSinceEpoch}.jpg',
          fileBytes: _mainImageBytes!,
        );
      }

      final galleryUrls = List<String>.from(_existingGalleryUrls);
      for (int i = 0; i < _galleryImageBytesList.length; i++) {
        final url = await _storageService.uploadVehicleImage(
          vehicleId: vehicleId,
          fileName: 'gallery_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          fileBytes: _galleryImageBytesList[i],
        );
        galleryUrls.add(url);
      }

      // ── Tek yazma ──
      // Doğrulayıcılar geçtiği için sayı çözümlemeleri burada başarısız
      // olamaz; yine de null'a düşerse mevcut/varsayılan değer korunur.
      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'brand': _brandController.text.trim(),
        'category': _selectedCategory,
        'dailyPrice': AppHelpers.sayiCoz(_priceController.text) ?? 0,
        'monthlyPrice': AppHelpers.sayiCoz(_monthlyPriceController.text) ?? 0,
        'yearlyPrice': AppHelpers.sayiCoz(_yearlyPriceController.text) ?? 0,
        'transmission': _selectedTransmission,
        'fuelType': _selectedFuelType,
        'seats': AppHelpers.tamSayiCoz(_seatsController.text) ?? 5,
        'engineSize': _engineSizeController.text.trim(),
        'year': AppHelpers.tamSayiCoz(_yearController.text) ?? DateTime.now().year,
        'features': features,
        'isFeatured': _isFeatured,
        'isAvailable': _isAvailable,
        'imagePath': mainImageUrl,
        'galleryPaths': galleryUrls,
      };

      if (_isEditing) {
        await _firestoreService.updateVehicle(vehicleId, data);
        await _artakalanGorselleriTemizle(mainImageUrl, galleryUrls);
      } else {
        await _firestoreService.createVehicle(vehicleId, data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text(_isEditing ? 'Araç güncellendi.' : 'Araç eklendi.')),
        );
        Navigator.pop(context);
      }
    } catch (e, iz) {
      // Ham hata log'a; okunabilir çeviri ekrana. Eskiden yalnızca
      // "Hata: $e" gösteriliyordu ve yetki hatası ile ağ hatası aynı
      // görünüyordu — hangisi olduğu anlaşılmıyordu.
      debugPrint('Araç kaydedilemedi: $e\n$iz');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_hataMesaji(e)),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Firebase hatalarını yöneticinin ne yapacağını anlayacağı hâle çevirir.
  String _hataMesaji(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        // Hangi servisin reddettiği kritik: Storage reddediyorsa storage.rules,
        // Firestore reddediyorsa firestore.rules ya da role alanı sorunlu.
        case 'permission-denied':
        case 'unauthorized':
          final servis =
              e.plugin.contains('storage') ? 'STORAGE' : 'FIRESTORE';
          return '$servis yetki reddi (${e.plugin}/${e.code}). '
              'Kurallar deploy edilmemiş olabilir veya users kaydınızda '
              'role != "admin".';
        case 'unauthenticated':
          return 'Oturum düşmüş. Çıkıp tekrar giriş yapın.';
        case 'unavailable':
        case 'network-request-failed':
        case 'retry-limit-exceeded':
          return 'Bağlantı kurulamadı. İnternetinizi kontrol edip tekrar deneyin.';
        case 'object-not-found':
          return 'Storage kovası bulunamadı. Firebase Console\'da Storage '
              'etkinleştirilmiş mi?';
        case 'quota-exceeded':
          return 'Storage kotası dolmuş.';
      }
      // Tanımadığımız kodlarda ham bilgiyi göster — teşhis edilebilsin.
      return 'Kaydedilemedi (${e.plugin}/${e.code}): ${e.message ?? ''}';
    }
    return 'Kaydedilemedi: $e';
  }

  /// Düzenleme sırasında formdan çıkarılan görselleri Storage'dan da siler.
  ///
  /// Bunlar eskiden yalnızca Firestore'daki URL listesinden düşüyor, dosyanın
  /// kendisi kotayı işgal etmeye devam ediyordu. Temizlik kayıt işleminden
  /// SONRA yapılır: silme başarısız olsa bile araç doğru kaydedilmiş olur.
  Future<void> _artakalanGorselleriTemizle(
    String yeniAnaGorsel,
    List<String> yeniGaleri,
  ) async {
    final eski = widget.vehicle!;

    final silinecek = <String>{
      ...eski.galleryPaths.where((url) => !yeniGaleri.contains(url)),
      if (eski.imagePath.isNotEmpty && eski.imagePath != yeniAnaGorsel)
        eski.imagePath,
    };

    if (silinecek.isNotEmpty) {
      await _storageService.deleteByUrls(silinecek);
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
              child: CachedNetworkImage(
                imageUrl: _existingImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorWidget: (_, __, ___) => _buildPlaceholder(),
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
                    child: CachedNetworkImage(
                      imageUrl: entry.value,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
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

  Widget _istegeBagliFiyat(
      TextEditingController kontrolcu, String etiket, String ornek) {
    return TextFormField(
      controller: kontrolcu,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: etiket,
        hintText: ornek,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        final fiyat = AppHelpers.sayiCoz(v);
        if (fiyat == null) return 'Geçerli bir sayı girin';
        if (fiyat < 0) return 'Negatif olamaz';
        return null;
      },
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
                    initialValue: _selectedCategory,
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
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          // Harf girilmesini baştan engelle; ayraç olarak
                          // hem virgül hem nokta kabul edilir.
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Günlük Fiyat (₺)',
                            hintText: '1500',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Fiyat gerekli';
                            }
                            final fiyat = AppHelpers.sayiCoz(v);
                            if (fiyat == null) return 'Geçerli bir sayı girin';
                            if (fiyat <= 0) return 'Fiyat 0\'dan büyük olmalı';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _seatsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Koltuk Sayısı',
                            border: OutlineInputBorder(),
                          ),
                          // Eskiden doğrulayıcı yoktu ve boş bırakılırsa
                          // int.parse FormatException fırlatıp kaydı
                          // "Hata: FormatException" mesajıyla düşürüyordu.
                          validator: (v) {
                            final koltuk = AppHelpers.tamSayiCoz(v);
                            if (koltuk == null) return 'Koltuk sayısı gerekli';
                            if (koltuk < 1 || koltuk > 20) return '1–20 arası';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Aylık ve yıllık fiyat ──
                  // İsteğe bağlı. Boş bırakılan tür için müşteri kartında
                  // "Teklif alın" yazar.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _istegeBagliFiyat(
                            _monthlyPriceController, 'Aylık Fiyat (₺)', '36000'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _istegeBagliFiyat(
                            _yearlyPriceController, 'Yıllık Fiyat (₺)', '400000'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aylık ve yıllık fiyat isteğe bağlıdır; boş bırakılırsa '
                    'müşteriye "Teklif alın" gösterilir.',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // ── Vites & Yakıt ──
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedTransmission,
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
                          initialValue: _selectedFuelType,
                          decoration: const InputDecoration(
                            labelText: 'Yakıt Tipi',
                            border: OutlineInputBorder(),
                          ),
                          items: Vehicle.yakitTurleri
                              .map((f) =>
                              DropdownMenuItem(value: f, child: Text(f)))
                              .toList(),
                          onChanged: (v) => setState(
                                  () => _selectedFuelType = v ?? 'Benzin'),
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Yıl',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final yil = AppHelpers.tamSayiCoz(v);
                            if (yil == null) return 'Yıl gerekli';
                            final enSon = DateTime.now().year + 1;
                            if (yil < 1990 || yil > enSon) {
                              return '1990–$enSon arası';
                            }
                            return null;
                          },
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
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isFeatured = v),
                  ),
                  SwitchListTile(
                    title: const Text('Müsait'),
                    subtitle: const Text('Kiralamaya açık mı?'),
                    value: _isAvailable,
                    activeThumbColor: AppColors.primary,
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