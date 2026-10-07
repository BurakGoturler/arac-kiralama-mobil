import 'package:car_rental_mvp/data/services/auth_service.dart';
import 'package:car_rental_mvp/ui/screens/auth/email_verification_screen.dart';
import 'package:car_rental_mvp/ui/screens/legal/legal_document_screen.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/legal_texts.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  /// Aydınlatma metni + kullanım koşulları onayı — üyelik için zorunlu.
  ///
  /// 14.09.2026 — Ayrı "WhatsApp açık rızası" kutusu kaldırıldı. Kiralama
  /// yalnızca WhatsApp'tan yürüdüğü için o aktarım rızaya dayanamaz (tek
  /// kanal + rıza = hizmet şartı, geçersiz rıza); dayanak Kurul standart
  /// sözleşmesidir. Bkz. SirketBilgileri.whatsappAktarimDayanagi.
  bool _sozlesmeOnayi = false;

  /// Aydınlatma Metni'nin okunduğuna ilişkin GERİ BİLDİRİM — zorunlu.
  ///
  /// Kurul'un 18.02.2026 tarihli ve 2026/347 sayılı ilke kararı: aydınlatma
  /// için kişiden yalnızca "okudum" geri bildirimi alınır; onay veya rıza
  /// istenmez. Bu yüzden eskiden tek kutuda birleşen "Aydınlatma Metni ve
  /// Kullanım Koşulları" beyanı ikiye ayrıldı: sözleşme KABULÜ ile aydınlatma
  /// GERİ BİLDİRİMİ aynı beyanda duramaz.
  bool _aydinlatmaOkundu = false;

  /// Kampanya iletişimi onayı — İSTEĞE BAĞLI, önceden işaretli DEĞİL.
  ///
  /// Uygulamadaki tek açık rıza. "Üye olan kampanyaya izin vermiş sayılır"
  /// kurgusu geçersiz olduğu için ayrı kutuyla alınır: KVKK m.3/1-a açık
  /// rızanın belirli, bilgilendirilmiş ve özgür iradeyle açıklanmış olmasını,
  /// 6563 m.6 ise ticari elektronik iletiden önce onay alınmasını ister.
  bool _kampanyaOnayi = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _passwordConfirmController.text) {
      setState(() => _errorMessage = 'Şifreler eşleşmiyor.');
      return;
    }

    if (!_aydinlatmaOkundu || !_sozlesmeOnayi) {
      setState(() => _errorMessage =
          'Üye olabilmek için Aydınlatma Metni\'ni okuduğunuzu belirtmeniz '
          've Kullanım Koşulları\'nı kabul etmeniz gerekiyor.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        surname: _surnameController.text,
        phone: _phoneController.text,
        sozlesmeOnayi: _sozlesmeOnayi,
        aydinlatmaOkundu: _aydinlatmaOkundu,
        kampanyaOnayi: _kampanyaOnayi,
      );

      if (mounted) {
        context.sayfayiDegistir(const EmailVerificationScreen());
      }
    } catch (e) {
      String msg = 'Kayıt başarısız. Tekrar deneyin.';
      final errStr = e.toString();
      if (errStr.contains('email-already-in-use')) {
        msg = 'Bu e-posta zaten kullanımda.';
      } else if (errStr.contains('weak-password')) {
        msg = 'Şifre çok zayıf. En az 8 karakter, harf ve rakam içermeli.';
      } else if (errStr.contains('invalid-email')) {
        msg = 'Geçersiz e-posta adresi.';
      }
      setState(() => _errorMessage = msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Üye Ol')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Text('Yeni Hesap Oluştur',
                      style: AppTextStyles.headingLarge,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'İsim',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Gerekli' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _surnameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Soyisim',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Gerekli' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    decoration: const InputDecoration(
                      labelText: 'Telefon (05XXXXXXXXX)',
                      prefixIcon: Icon(Icons.phone_outlined),
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Gerekli';
                      if (v.length < 10) return 'Geçersiz numara';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Gerekli';
                      if (!v.contains('@')) return 'Geçersiz e-posta';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Şifre (en az 8 karakter, harf ve rakam)',
                      prefixIcon: Icon(Icons.lock_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: AppHelpers.sifreKontrol,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _passwordConfirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Şifre Tekrar',
                      prefixIcon: Icon(Icons.lock_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Gerekli' : null,
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 4),

                  // ── Zorunlu: Aydınlatma Metni okundu (geri bildirim) ──
                  // Onay/rıza DEĞİL; Kurul 2026/347 ilke kararı gereği yalnızca
                  // okunduğu bildirilir ve sözleşme kabulünden ayrı tutulur.
                  _OnayKutusu(
                    deger: _aydinlatmaOkundu,
                    onDegisti: (v) => setState(() => _aydinlatmaOkundu = v),
                    zorunlu: true,
                    icerik: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MetinBaglantisi(
                          etiket: 'Aydınlatma Metni',
                          ekran: LegalDocumentScreen.aydinlatma(),
                        ),
                        Text("'ni okudum.", style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),

                  // ── Zorunlu: Kullanım Koşulları kabulü ──
                  _OnayKutusu(
                    deger: _sozlesmeOnayi,
                    onDegisti: (v) => setState(() => _sozlesmeOnayi = v),
                    zorunlu: true,
                    icerik: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MetinBaglantisi(
                          etiket: 'Kullanım Koşulları',
                          ekran: LegalDocumentScreen.kullanimKosullari(),
                        ),
                        Text("'nı okudum ve kabul ediyorum.",
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),

                  // ── İsteğe bağlı onay: kampanya iletişimi ──
                  _OnayKutusu(
                    deger: _kampanyaOnayi,
                    onDegisti: (v) => setState(() => _kampanyaOnayi = v),
                    zorunlu: false,
                    icerik: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(LegalTexts.kampanyaOnayMetni,
                            style: AppTextStyles.bodySmall),
                        const SizedBox(height: 2),
                        _MetinBaglantisi(
                          etiket: 'Açık Rıza Metni',
                          ekran: LegalDocumentScreen.acikRiza(),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          LegalTexts.kampanyaOnayAciklama,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(_errorMessage!,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                        textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 20),

                  PrimaryButton(
                    label: 'Üye Ol',
                    icon: Icons.person_add_rounded,
                    isLoading: _isLoading,
                    onTap: _isLoading ? null : _register,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ── KVKK onay kutusu ────────────────────────────────────────────────
// Onay kutuları KVKK gereği ÖNCEDEN İŞARETLİ OLMAMALIDIR; varsayılan
// değerleri her zaman false'tur.
class _OnayKutusu extends StatelessWidget {
  final bool deger;
  final ValueChanged<bool> onDegisti;
  final Widget icerik;
  final bool zorunlu;

  const _OnayKutusu({
    required this.deger,
    required this.onDegisti,
    required this.icerik,
    required this.zorunlu,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onDegisti(!deger),
      borderRadius: BorderRadius.circular(AppConstants.radiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                value: deger,
                onChanged: (v) => onDegisti(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: icerik),
                    if (zorunlu)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 1),
                        child: Text('*',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.error)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Yasal metne giden bağlantı ──────────────────────────────────────
class _MetinBaglantisi extends StatelessWidget {
  final String etiket;
  final LegalDocumentScreen ekran;

  const _MetinBaglantisi({required this.etiket, required this.ekran});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => LegalDocumentScreen.ac(context, ekran),
      child: Text(
        etiket,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primary,
        ),
      ),
    );
  }
}
