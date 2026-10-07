import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/blog_post.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/primary_button.dart';

/// Bilgilendirme yazısı ekleme / düzenleme.
///
/// Yazı "Taslak" olarak kaydedilebilir; müşteriler yalnızca "Yayında"
/// işaretli yazıları görür (güvenlik kuralı da bunu zorlar).
class AdminBlogFormScreen extends StatefulWidget {
  final BlogPost? yazi;

  const AdminBlogFormScreen({super.key, this.yazi});

  @override
  State<AdminBlogFormScreen> createState() => _AdminBlogFormScreenState();
}

class _AdminBlogFormScreenState extends State<AdminBlogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();

  late final TextEditingController _baslik;
  late final TextEditingController _ozet;
  late final TextEditingController _icerik;

  bool _yayinda = false;
  bool _kaydediliyor = false;
  Uint8List? _yeniKapak;
  String _mevcutKapakUrl = '';

  bool get _duzenleme => widget.yazi != null;

  @override
  void initState() {
    super.initState();
    final y = widget.yazi;
    _baslik = TextEditingController(text: y?.title ?? '');
    _ozet = TextEditingController(text: y?.summary ?? '');
    _icerik = TextEditingController(text: y?.content ?? '');
    _yayinda = y?.isPublished ?? false;
    _mevcutKapakUrl = y?.coverImageUrl ?? '';
  }

  @override
  void dispose() {
    _baslik.dispose();
    _ozet.dispose();
    _icerik.dispose();
    super.dispose();
  }

  Future<void> _kapakSec() async {
    try {
      final secilen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 900,
        imageQuality: 85,
      );
      if (secilen == null) return;
      final baytlar = await secilen.readAsBytes();
      if (mounted) setState(() => _yeniKapak = baytlar);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görsel seçilemedi: $e')),
        );
      }
    }
  }

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _kaydediliyor = true);

    try {
      final id =
          _duzenleme ? widget.yazi!.id : _firestoreService.yeniBlogKimligi();

      var kapakUrl = _mevcutKapakUrl;
      if (_yeniKapak != null) {
        kapakUrl = await _storageService.uploadBlogImage(
          postId: id,
          fileName: 'kapak_${DateTime.now().millisecondsSinceEpoch}.jpg',
          fileBytes: _yeniKapak!,
        );
      }

      await _firestoreService.blogKaydet(
        id,
        BlogPost(
          title: _baslik.text.trim(),
          summary: _ozet.text.trim(),
          content: _icerik.text.trim(),
          coverImageUrl: kapakUrl,
          isPublished: _yayinda,
        ),
        yeni: !_duzenleme,
        ilkYayin: _yayinda && widget.yazi?.publishedAt == null,
      );

      // Kapak değiştiyse eski dosya Storage'da öksüz kalmasın.
      if (_yeniKapak != null && _mevcutKapakUrl.isNotEmpty) {
        await _storageService.deleteByUrl(_mevcutKapakUrl);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_yayinda ? 'Yazı yayınlandı.' : 'Taslak kaydedildi.'),
        ),
      );
      Navigator.pop(context);
    } catch (e, iz) {
      debugPrint('Blog yazısı kaydedilemedi: $e\n$iz');
      if (!mounted) return;
      final mesaj = e is FirebaseException && e.code == 'permission-denied'
          ? 'Yetki reddedildi. Hesabınızın yönetici olduğundan emin olun.'
          : e is FirebaseException && e.code == 'unavailable'
              ? 'Bağlantı kurulamadı. İnternetinizi kontrol edin.'
              : 'Yazı kaydedilemedi. Lütfen tekrar deneyin.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mesaj), duration: const Duration(seconds: 6)),
      );
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_duzenleme ? 'Yazıyı Düzenle' : 'Yeni Yazı')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _KapakAlani(
                yeniKapak: _yeniKapak,
                mevcutUrl: _mevcutKapakUrl,
                onSec: _kaydediliyor ? null : _kapakSec,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _baslik,
                maxLength: 120,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Başlık gerekli' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ozet,
                maxLength: 300,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Kısa özet (listede görünür, isteğe bağlı)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _icerik,
                maxLength: 20000,
                minLines: 10,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Yazı',
                  helperText: 'Paragrafları boş satırla ayırın.',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Yazı boş olamaz' : null,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Yayında'),
                subtitle: Text(_yayinda
                    ? 'Müşteriler bu yazıyı görür'
                    : 'Taslak — yalnızca yöneticiler görür'),
                value: _yayinda,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => _yayinda = v),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: _yayinda ? 'Yayınla' : 'Taslak Olarak Kaydet',
                icon: _yayinda ? Icons.publish_rounded : Icons.save_rounded,
                isLoading: _kaydediliyor,
                onTap: _kaydediliyor ? null : _kaydet,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _KapakAlani extends StatelessWidget {
  final Uint8List? yeniKapak;
  final String mevcutUrl;
  final VoidCallback? onSec;

  const _KapakAlani({
    required this.yeniKapak,
    required this.mevcutUrl,
    required this.onSec,
  });

  @override
  Widget build(BuildContext context) {
    Widget icerik;
    if (yeniKapak != null) {
      icerik = Image.memory(yeniKapak!, fit: BoxFit.cover);
    } else if (mevcutUrl.isNotEmpty) {
      icerik = CachedNetworkImage(imageUrl: mevcutUrl, fit: BoxFit.cover);
    } else {
      icerik = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_photo_alternate_outlined,
              size: 40, color: AppColors.primary),
          const SizedBox(height: 8),
          Text('Kapak görseli seç (isteğe bağlı)',
              style: AppTextStyles.bodyMedium),
        ],
      );
    }

    return InkWell(
      onTap: onSec,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 180,
          width: double.infinity,
          color: AppColors.primaryLight,
          child: icerik,
        ),
      ),
    );
  }
}
