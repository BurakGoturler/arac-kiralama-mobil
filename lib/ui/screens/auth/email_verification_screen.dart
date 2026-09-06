import 'dart:async';
import 'package:car_rental_mvp/data/services/auth_service.dart';
import 'package:car_rental_mvp/ui/screens/auth/login_screen.dart';
import 'package:car_rental_mvp/ui/screens/home_screen.dart';
import 'package:car_rental_mvp/ui/screens/admin/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();

  /// Doğrulama durumunu yoklayan zamanlayıcı.
  Timer? _timer;

  /// "Tekrar gönder" geri sayımı. Ayrı bir alanda tutulur; aksi hâlde
  /// ekran kapandığında iptal edilemez ve arka planda çalışmaya devam eder.
  Timer? _cooldownTimer;

  bool _canResend = true;
  int _resendCooldown = 0;

  /// Yoklama aralığı 3 sn'den 10 sn'ye çıkarıldı. 3 saniyede bir sorgu,
  /// ekran açık bırakıldığında saatte ~1.200 gereksiz istek üretiyordu.
  static const Duration _yoklamaAraligi = Duration(seconds: 10);

  /// Kullanıcı ekranı açık unutursa yoklama süresiz devam etmesin.
  static const int _maksYoklama = 60; // ~10 dakika
  int _yoklamaSayisi = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_yoklamaAraligi, (_) => _checkVerified());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerified() async {
    if (++_yoklamaSayisi > _maksYoklama) {
      _timer?.cancel();
      return;
    }

    // Ağ hatası yoklamayı durdurmamalı; bir sonraki turda tekrar denenir.
    try {
      await _authService.reloadUser();
    } catch (_) {
      return;
    }

    if (_authService.isEmailVerified && mounted) {
      _timer?.cancel();
      final isAdmin = await _authService.isCurrentUserAdmin();
      if (!mounted) return;
      context.sayfayaSifirla(
        isAdmin ? const AdminDashboardScreen() : const HomeScreen(),
      );
    }
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;
    try {
      await _authService.resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doğrulama maili tekrar gönderildi.')),
        );
      }
      setState(() {
        _canResend = false;
        _resendCooldown = 60;
      });

      _cooldownTimer?.cancel();
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_resendCooldown <= 0) {
          timer.cancel();
          setState(() => _canResend = true);
        } else {
          setState(() => _resendCooldown--);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      context.sayfayaSifirla(const LoginScreen());
    }
  }

  bool _isDeleting = false;

  /// Doğrulama ekranından hesap silme (KVKK m.7).
  ///
  /// Silme, Firebase tarafından yakın zamanlı kimlik doğrulaması istendiği
  /// için parola sorularak yapılır; akış profil ekranındakiyle aynıdır.
  Future<void> _hesabiSil() async {
    final parolaKontrolcusu = TextEditingController();

    final onaylandi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hesabınızı silmek istiyor musunuz?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bu işlem geri alınamaz. Hesabınız ve ad, soyad, telefon, '
              'e-posta bilgileriniz kalıcı olarak silinecektir.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: parolaKontrolcusu,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Şifreniz',
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
            child: Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    final parola = parolaKontrolcusu.text;
    parolaKontrolcusu.dispose();

    if (onaylandi != true || parola.isEmpty) return;
    if (!mounted) return;

    setState(() => _isDeleting = true);

    // Yoklama zamanlayıcıları silme sırasında istek atmaya devam etmesin.
    _timer?.cancel();
    _cooldownTimer?.cancel();

    try {
      await _authService.deleteAccount(currentPassword: parola);
      if (!mounted) return;
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
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _authService.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-posta Doğrulama'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.mark_email_unread_rounded,
                    size: 80, color: AppColors.primary),
                const SizedBox(height: 24),
                Text('E-postanızı Doğrulayın',
                    style: AppTextStyles.headingLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  '$email\nadresine bir doğrulama bağlantısı gönderdik. '
                      'Lütfen mailinizi kontrol edip bağlantıya tıklayın.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Doğrulama tamamlandığında otomatik olarak yönlendirileceksiniz.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: _canResend
                      ? 'Maili Tekrar Gönder'
                      : 'Tekrar Gönder ($_resendCooldown sn)',
                  icon: Icons.refresh_rounded,
                  onTap: _canResend ? _resendEmail : null,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _logout,
                  child: const Text('Çıkış Yap'),
                ),

                // ── Hesabı sil ──
                //
                // Bu ekran bir çıkmaz olabilir: giriş akışı, e-postası
                // doğrulanmamış kullanıcıyı her seferinde buraya gönderir.
                // Silme seçeneği yalnızca profil ekranındayken, oraya
                // ulaşamayan kullanıcı hesabını silemiyor, verisini
                // göremiyor ve KVKK m.7 haklarını uygulama içinden hiç
                // kullanamıyordu — üstelik adı, soyadı, telefonu ve
                // e-postası veritabanında duruyordu. App Store Guideline
                // 5.1.1(v) de silme yolunun erişilebilir olmasını şart
                // koşar. Bu yüzden silme buraya da konuldu.
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _isDeleting ? null : _hesabiSil,
                  child: Text(
                    _isDeleting ? 'Siliniyor...' : 'Hesabımı Sil',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}