import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/mfa_service.dart';
import '../../widgets/primary_button.dart';

/// Girişin ikinci adımı: Authenticator uygulamasındaki 6 haneli kod.
///
/// Parola doğru olduğunda Firebase oturumu AÇMAZ; ikinci faktör kayıtlı bir
/// hesapta [FirebaseAuthMultiFactorException] fırlatır. Giriş ekranı bu
/// istisnayı yakalayıp bu ekranı açar ve içindeki resolver'ı buraya verir.
///
/// Ekran kapanırken `Navigator.pop(context, true)` ile başarı, `false` veya
/// null ile vazgeçme bildirilir. Oturum, kod doğrulandığı anda Firebase
/// tarafında zaten açılmış olur; çağıran ekran yalnızca yönlendirmeyi yapar.
class MfaChallengeScreen extends StatefulWidget {
  final MultiFactorResolver resolver;

  const MfaChallengeScreen({super.key, required this.resolver});

  @override
  State<MfaChallengeScreen> createState() => _MfaChallengeScreenState();
}

class _MfaChallengeScreenState extends State<MfaChallengeScreen> {
  final _mfaService = MfaService();
  final _kodController = TextEditingController();
  bool _yukleniyor = false;
  String? _hata;

  @override
  void dispose() {
    _kodController.dispose();
    super.dispose();
  }

  Future<void> _dogrula() async {
    final kod = _kodController.text.trim();
    if (kod.length != 6) {
      setState(() => _hata = 'Kod 6 haneli olmalıdır.');
      return;
    }

    setState(() {
      _yukleniyor = true;
      _hata = null;
    });

    try {
      await _mfaService.girisiTamamla(
        resolver: widget.resolver,
        kod: kod,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hata = MfaService.hataMesaji(e);
        // Yanlış kodda alanı boşalt; kullanıcı eski kodun üzerine yazmaya
        // çalışırken karışmasın. Kodlar 30 saniyede bir yenilendiği için
        // ikinci deneme neredeyse her zaman yeni bir kodla yapılır.
        _kodController.clear();
      });
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  /// Hangi cihazın kayıtlı olduğunu kullanıcıya hatırlatır.
  ///
  /// Yönetici birden fazla Authenticator kaydettiyse hangisine bakacağını
  /// bilmesi gerekir; kayıt sırasında verilen ad burada gösterilir.
  String get _kayitliCihazlar {
    final adlar = widget.resolver.hints
        .where((f) => f.factorId == MfaService.totpFaktorId)
        .map((f) => f.displayName)
        .where((ad) => ad != null && ad.trim().isNotEmpty)
        .cast<String>()
        .toList();

    if (adlar.isEmpty) return '';
    return 'Kayıtlı cihaz: ${adlar.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final cihazlar = _kayitliCihazlar;

    return Scaffold(
      appBar: AppBar(title: const Text('İki Aşamalı Doğrulama')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Icon(
                  Icons.shield_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Doğrulama Kodu',
                  style: AppTextStyles.headingLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Authenticator uygulamanızdaki 6 haneli kodu girin.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (cihazlar.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    cihazlar,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textMuted, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 28),

                TextField(
                  controller: _kodController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  maxLength: 6,
                  enabled: !_yukleniyor,
                  style: const TextStyle(
                    fontSize: 26,
                    letterSpacing: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '000000',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _dogrula(),
                ),

                if (_hata != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _hata!,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Doğrula',
                  icon: Icons.check_rounded,
                  isLoading: _yukleniyor,
                  onTap: _yukleniyor ? null : _dogrula,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed:
                      _yukleniyor ? null : () => Navigator.pop(context, false),
                  child: const Text('Vazgeç'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Kodlar 30 saniyede bir yenilenir. Uygulamadaki süre dolmak '
                  'üzereyse yeni kodu bekleyip girin.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textMuted, fontSize: 12.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
