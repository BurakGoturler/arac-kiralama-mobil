import 'package:car_rental_mvp/data/models/user_model.dart';
import 'package:car_rental_mvp/data/services/auth_service.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';
import 'package:car_rental_mvp/ui/screens/auth/login_screen.dart';
import 'package:car_rental_mvp/ui/screens/legal/legal_document_screen.dart';
import 'package:car_rental_mvp/ui/screens/profile/change_password_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/legal_texts.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _phoneController;

  AppUser? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = await _authService.getCurrentUserProfile();
    if (!mounted) return;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    _nameController.text = user.name;
    _surnameController.text = user.surname;
    _phoneController.text = user.phone;
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  void _startEditing() {
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    // Orijinal değerlere geri dön
    _nameController.text = _user?.name ?? '';
    _surnameController.text = _user?.surname ?? '';
    _phoneController.text = _user?.phone ?? '';
    setState(() => _isEditing = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_user == null) return;

    setState(() => _isSaving = true);

    try {
      await _firestoreService.updateUser(_user!.uid, {
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellendi.')),
        );
        setState(() => _isEditing = false);
        _loadProfile(); // güncel veriyi tekrar çek
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _goToChangePassword() {
    context.sayfayaGit(const ChangePasswordScreen());
  }

  /// Kampanya iletişimi onayını verir veya geri alır.
  ///
  /// Uygulamadaki tek açık rıza; isteğe bağlıdır ve her an geri alınabilir.
  /// Verildiği ve geri alındığı an ayrı alanlara yazılır: ispat yükü
  /// Şirket'tedir ve onay/ret İYS'ye bu tarihlerle yüklenir. firestore.rules
  /// tarihlerin sunucu saatiyle yazılmasını zorunlu tutar.
  Future<void> _toggleKampanyaOnayi(bool yeniDeger) async {
    if (_user == null) return;

    setState(() => _isSaving = true);
    try {
      await _firestoreService.updateUser(_user!.uid, {
        'kampanyaOnayi': yeniDeger,
        if (yeniDeger) ...{
          'kampanyaOnayTarihi': FieldValue.serverTimestamp(),
          'kampanyaMetinSurumu': SirketBilgileri.sonGuncelleme,
        } else
          'kampanyaRetTarihi': FieldValue.serverTimestamp(),
      });
      await _loadProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(yeniDeger
              ? 'Kampanya onayınız kaydedildi.'
              : 'Kampanya onayınız geri alındı. Kampanya iletisi gönderilmeyecek.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Onay güncellenemedi. Tekrar deneyin.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Hesap silme akışı — KVKK m.7 ve App Store Guideline 5.1.1(v) gereği.
  Future<void> _deleteAccount() async {
    final passwordController = TextEditingController();

    final onaylandi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hesabınızı silmek istiyor musunuz?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bu işlem geri alınamaz. Aşağıdaki verilerinizin tamamı '
              'kalıcı olarak silinecektir:',
            ),
            const SizedBox(height: 8),
            const Text(
              '•  Hesabınız ve giriş bilgileriniz\n'
              '•  Ad, soyad, telefon ve e-posta bilgileriniz\n'
              '•  Favori araç listeniz\n'
              '•  Uygulama üzerinden ilettiğiniz rezervasyon talepleri',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Güvenliğiniz için şifrenizi tekrar girin:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Hesabımı Sil',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (onaylandi != true) {
      passwordController.dispose();
      return;
    }

    final password = passwordController.text;
    passwordController.dispose();

    if (password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifrenizi girmeniz gerekiyor.')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _authService.deleteAccount(currentPassword: password);
      if (!mounted) return;

      // Hesap silindi — tüm gezinme geçmişi temizlenip girişe dönülür.
      context.sayfayaSifirla(const LoginScreen());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hesabınız ve verileriniz silindi.')),
      );
    } catch (e) {
      if (!mounted) return;
      final hata = e.toString();
      String mesaj = 'Hesap silinemedi. Lütfen tekrar deneyin.';
      if (hata.contains('wrong-password') ||
          hata.contains('invalid-credential')) {
        mesaj = 'Şifre hatalı.';
      } else if (hata.contains('auth-kaydi-silinemedi')) {
        mesaj = 'Verileriniz silindi ancak hesap kaydı kapatılamadı. '
            'Lütfen tekrar deneyin.';
      } else if (hata.contains('network')) {
        mesaj = 'Bağlantı hatası. İnternetinizi kontrol edin.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          if (!_isLoading && _user != null && !_isEditing)
            IconButton(
              onPressed: _startEditing,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Düzenle',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? const Center(child: Text('Profil bilgileri yüklenemedi.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Avatar ──
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor:
                      AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        _user!.name.isNotEmpty
                            ? _user!.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(_user!.fullName,
                        style: AppTextStyles.headingLarge),
                  ),
                  Center(
                    child: Text(_user!.email,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted)),
                  ),
                  const SizedBox(height: 24),

                  // ── Form Alanları ──
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          enabled: _isEditing,
                          textCapitalization:
                          TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'İsim',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Gerekli'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _surnameController,
                          enabled: _isEditing,
                          textCapitalization:
                          TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Soyisim',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Gerekli'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _phoneController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    decoration: const InputDecoration(
                      labelText: 'Telefon',
                      prefixIcon: Icon(Icons.phone_outlined),
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Gerekli';
                      }
                      if (v.length < 10) return 'Geçersiz numara';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Email (değiştirilemez, bilgi amaçlı)
                  TextFormField(
                    initialValue: _user!.email,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'E-posta (değiştirilemez)',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Aksiyon Butonları ──
                  if (_isEditing) ...[
                    PrimaryButton(
                      label: 'Kaydet',
                      icon: Icons.save_rounded,
                      isLoading: _isSaving,
                      onTap: _isSaving ? null : _save,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isSaving ? null : _cancelEditing,
                      child: const Text('İptal'),
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      onPressed: _goToChangePassword,
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Şifre Değiştir'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Kampanya iletişimi onayı (isteğe bağlı) ──
                    // Uygulamadaki tek açık rıza. Kiralama rızaya
                    // dayanmadığı için anahtar kapalıyken hiçbir işlev
                    // kısıtlanmaz; alt yazı bunu açıkça söyler.
                    const Divider(),
                    const SizedBox(height: 8),
                    Text('Kampanya İletişimi', style: AppTextStyles.labelMedium),
                    const SizedBox(height: 4),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _user!.kampanyaOnayi,
                      onChanged: _isSaving ? null : _toggleKampanyaOnayi,
                      title: Text('SMS ve WhatsApp ile kampanya ve fırsatlar',
                          style: AppTextStyles.bodyMedium),
                      subtitle: Text(
                        _user!.kampanyaOnayi
                            ? LegalTexts.kampanyaProfilAcik
                            : LegalTexts.kampanyaProfilKapali,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Yasal metinler ──
                    _YasalBaglanti(
                      etiket: 'Aydınlatma Metni',
                      ekran: LegalDocumentScreen.aydinlatma(),
                    ),
                    _YasalBaglanti(
                      etiket: 'Açık Rıza Metni (Kampanya İletişimi)',
                      ekran: LegalDocumentScreen.acikRiza(),
                    ),
                    _YasalBaglanti(
                      etiket: 'Gizlilik Politikası',
                      ekran: LegalDocumentScreen.gizlilik(),
                    ),
                    _YasalBaglanti(
                      etiket: 'Kullanım Koşulları',
                      ekran: LegalDocumentScreen.kullanimKosullari(),
                    ),
                    const SizedBox(height: 24),

                    // ── Hesap silme (KVKK m.7) ──
                    // Açıklama LegalTexts'ten gelir: aydınlatma metninin
                    // 6. maddesi ile aynı kapsamı söyler.
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      LegalTexts.hesapSilmeBilgisi,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _isSaving ? null : _deleteAccount,
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Hesabımı Sil'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
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
// ── Yasal metin bağlantı satırı ─────────────────────────────────────
class _YasalBaglanti extends StatelessWidget {
  final String etiket;
  final LegalDocumentScreen ekran;

  const _YasalBaglanti({required this.etiket, required this.ekran});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => LegalDocumentScreen.ac(context, ekran),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(Icons.description_outlined,
                size: 18, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(child: Text(etiket, style: AppTextStyles.bodyMedium)),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
