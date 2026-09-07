import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/mfa_service.dart';
import '../../widgets/primary_button.dart';

/// Yönetici hesabına Authenticator (TOTP) ile iki aşamalı doğrulama kurar.
///
/// Firebase MFA'yı HESAP BAZINDA uygular; "bütün yöneticilere zorunlu kıl"
/// diye bir sunucu anahtarı yoktur. Bu yüzden korunması istenen her yönetici
/// hesabı için bu ekrandan bir kez kurulum yapılmalıdır. Kurulum yapılan
/// hesapta ikinci adım artık atlanamaz: doğrulama sunucuda yapılır, istemci
/// kodu değiştirilse veya REST API doğrudan çağrılsa bile geçilemez.
///
/// AKIŞ
/// ----
/// 1. Parola ile yeniden doğrulama — Firebase hassas işlemler için yakın
///    zamanlı giriş ister.
/// 2. Gizli anahtar üretilir; Authenticator uygulamasına aktarılır.
/// 3. Uygulamanın ürettiği 6 haneli kod girilerek kayıt tamamlanır.
///
/// QR KODU NEDEN YOK
/// -----------------
/// Kurulum, uygulamanın çalıştığı telefonun kendisinde yapılıyor; o telefonun
/// ekranındaki QR'ı yine aynı telefonun kamerasıyla okutmak mümkün değil.
/// Bunun yerine iki yol sunuluyor: Authenticator uygulamasını doğrudan açan
/// bağlantı (aynı cihazda tek dokunuş) ve elle girilebilen kurulum anahtarı
/// (başka bir cihazda kurmak isteyenler için). Böylece ek bir QR kütüphanesi
/// bağımlılığı da gerekmiyor.
class Admin2faScreen extends StatefulWidget {
  const Admin2faScreen({super.key});

  @override
  State<Admin2faScreen> createState() => _Admin2faScreenState();
}

enum _Adim { yukleniyor, durum, parola, anahtar }

class _Admin2faScreenState extends State<Admin2faScreen> {
  final _mfaService = MfaService();
  final _parolaController = TextEditingController();
  final _kodController = TextEditingController();
  final _cihazAdiController = TextEditingController(text: 'Authenticator');

  _Adim _adim = _Adim.yukleniyor;
  List<MultiFactorInfo> _faktorler = const [];
  TotpSecret? _anahtar;
  String? _otpauth;
  String? _hata;
  bool _islemDeVam = false;

  /// Parola adımından sonra kuruluma mı yoksa kaldırmaya mı gidileceği.
  MultiFactorInfo? _kaldirilacak;

  @override
  void initState() {
    super.initState();
    _durumuYukle();
  }

  @override
  void dispose() {
    _parolaController.dispose();
    _kodController.dispose();
    _cihazAdiController.dispose();
    super.dispose();
  }

  Future<void> _durumuYukle() async {
    setState(() {
      _adim = _Adim.yukleniyor;
      _hata = null;
    });
    try {
      final faktorler = await _mfaService.kayitliFaktorler();
      if (!mounted) return;
      setState(() {
        _faktorler = faktorler;
        _adim = _Adim.durum;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hata = MfaService.hataMesaji(e);
        _adim = _Adim.durum;
      });
    }
  }

  void _kurulumaBasla() {
    setState(() {
      _kaldirilacak = null;
      _parolaController.clear();
      _hata = null;
      _adim = _Adim.parola;
    });
  }

  void _kaldirmayaBasla(MultiFactorInfo faktor) {
    setState(() {
      _kaldirilacak = faktor;
      _parolaController.clear();
      _hata = null;
      _adim = _Adim.parola;
    });
  }

  /// Parola doğrulanır; ardından ya kaldırma yapılır ya da anahtar üretilir.
  Future<void> _parolayiDogrula() async {
    if (_parolaController.text.isEmpty) {
      setState(() => _hata = 'Parolanızı girin.');
      return;
    }

    setState(() {
      _islemDeVam = true;
      _hata = null;
    });

    try {
      await _mfaService.yenidenDogrula(_parolaController.text);

      final kaldirilacak = _kaldirilacak;
      if (kaldirilacak != null) {
        await _mfaService.kaldir(kaldirilacak);
        if (!mounted) return;
        _parolaController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İki aşamalı doğrulama kaldırıldı.')),
        );
        await _durumuYukle();
        return;
      }

      // Kurulum yolu: gizli anahtarı ve otpauth adresini hazırla.
      final anahtar = await _mfaService.gizliAnahtarUret();
      final kullanici = FirebaseAuth.instance.currentUser;
      final adres = await _mfaService.otpauthAdresi(
        anahtar,
        hesapAdi: kullanici?.email ?? 'yonetici',
      );

      if (!mounted) return;
      setState(() {
        _anahtar = anahtar;
        _otpauth = adres;
        _kodController.clear();
        _parolaController.clear();
        _adim = _Adim.anahtar;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _hata = MfaService.hataMesaji(e));
    } finally {
      if (mounted) setState(() => _islemDeVam = false);
    }
  }

  Future<void> _authenticatordaAc() async {
    final adres = _otpauth;
    if (adres == null) return;
    try {
      final uri = Uri.parse(adres);
      final acildi = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!acildi && mounted) {
        setState(() => _hata =
            'Authenticator uygulaması bulunamadı. Aşağıdaki kurulum anahtarını '
            'uygulamaya elle girebilirsiniz.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _hata =
            'Authenticator uygulaması açılamadı. Aşağıdaki kurulum anahtarını '
            'uygulamaya elle girebilirsiniz.');
      }
    }
  }

  Future<void> _kaydiTamamla() async {
    final anahtar = _anahtar;
    if (anahtar == null) return;

    final kod = _kodController.text.trim();
    if (kod.length != 6) {
      setState(() => _hata = 'Kod 6 haneli olmalıdır.');
      return;
    }

    final cihazAdi = _cihazAdiController.text.trim();
    if (cihazAdi.isEmpty) {
      setState(() => _hata = 'Cihaz adı boş bırakılamaz.');
      return;
    }

    setState(() {
      _islemDeVam = true;
      _hata = null;
    });

    try {
      await _mfaService.kaydiTamamla(
        anahtar: anahtar,
        kod: kod,
        cihazAdi: cihazAdi,
      );
      if (!mounted) return;
      // Anahtar bir sırdır; kayıt bittiği anda bellekten düşürülür.
      setState(() {
        _anahtar = null;
        _otpauth = null;
        _kodController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İki aşamalı doğrulama açıldı.'),
        ),
      );
      await _durumuYukle();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hata = MfaService.hataMesaji(e);
        _kodController.clear();
      });
    } finally {
      if (mounted) setState(() => _islemDeVam = false);
    }
  }

  /// Kurulum anahtarını 4'erli gruplara ayırır — elle girerken göz kaymasın.
  String _okunakli(String anahtar) {
    final parcalar = <String>[];
    for (var i = 0; i < anahtar.length; i += 4) {
      parcalar.add(
        anahtar.substring(i, i + 4 > anahtar.length ? anahtar.length : i + 4),
      );
    }
    return parcalar.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İki Aşamalı Doğrulama')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: switch (_adim) {
              _Adim.yukleniyor =>
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: CircularProgressIndicator(),
                )),
              _Adim.durum => _durumGorunumu(),
              _Adim.parola => _parolaGorunumu(),
              _Adim.anahtar => _anahtarGorunumu(),
            },
          ),
        ),
      ),
    );
  }

  Widget _hataKutusu() {
    if (_hata == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Text(
        _hata!,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
      ),
    );
  }

  // ── 1. Durum ───────────────────────────────────────────────────

  Widget _durumGorunumu() {
    final acik = _faktorler.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hataKutusu(),
        Row(
          children: [
            Icon(
              acik ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
              color: acik ? AppColors.success : AppColors.textMuted,
              size: 34,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                acik ? 'Açık' : 'Kapalı',
                style: AppTextStyles.headingLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          acik
              ? 'Bu hesaba girişte parolanın yanı sıra Authenticator '
                  'uygulamasındaki 6 haneli kod da isteniyor.'
              : 'Bu hesaba şu anda yalnızca parola ile giriliyor. Yönetim '
                  'paneli üye listesini, rezervasyon kayıtlarını ve filo '
                  'yönetimini içerdiği için ikinci bir doğrulama adımı '
                  'önerilir.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),

        if (acik) ...[
          Text('Kayıtlı cihazlar', style: AppTextStyles.headingMedium),
          const SizedBox(height: 8),
          ..._faktorler.map(_faktorSatiri),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Başka bir cihaz ekle',
            icon: Icons.add_rounded,
            variant: PrimaryButtonVariant.outlined,
            onTap: _kurulumaBasla,
          ),
        ] else
          PrimaryButton(
            label: 'Authenticator ile kurulumu başlat',
            icon: Icons.shield_rounded,
            onTap: _kurulumaBasla,
          ),

        const SizedBox(height: 28),
        _bilgiKutusu(
          'Google Authenticator, Microsoft Authenticator veya benzeri bir '
          'uygulama kullanabilirsiniz. Kodlar cihazda üretilir; SMS '
          'gönderilmediği için mesaj ücreti oluşmaz ve SIM kopyalama '
          'saldırılarından etkilenmez.',
        ),
      ],
    );
  }

  Widget _faktorSatiri(MultiFactorInfo faktor) {
    final tarih = DateTime.fromMillisecondsSinceEpoch(
      (faktor.enrollmentTimestamp * 1000).round(),
    );
    final tarihMetni =
        '${tarih.day.toString().padLeft(2, '0')}.'
        '${tarih.month.toString().padLeft(2, '0')}.${tarih.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.phonelink_lock_rounded),
        title: Text(faktor.displayName ?? 'Adsız cihaz'),
        subtitle: Text('Eklenme: $tarihMetni'),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: AppColors.error),
          tooltip: 'Kaldır',
          onPressed: () => _kaldirmaOnayi(faktor),
        ),
      ),
    );
  }

  void _kaldirmaOnayi(MultiFactorInfo faktor) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Doğrulamayı kaldır'),
        content: Text(
          '"${faktor.displayName ?? 'Adsız cihaz'}" kaldırılırsa bu hesaba '
          'yalnızca parola ile girilebilir. Devam edilsin mi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _kaldirmayaBasla(faktor);
            },
            child: Text('Kaldır', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // ── 2. Parola ──────────────────────────────────────────────────

  Widget _parolaGorunumu() {
    final kaldirma = _kaldirilacak != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hataKutusu(),
        Text('Parolanızı doğrulayın', style: AppTextStyles.headingLarge),
        const SizedBox(height: 8),
        Text(
          kaldirma
              ? 'İkinci faktörü kaldırmak hassas bir işlemdir; Firebase bunun '
                  'için yakın zamanlı bir giriş ister.'
              : 'Kuruluma başlamadan önce hesabın gerçekten sizin olduğunu '
                  'doğrulamamız gerekiyor.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _parolaController,
          obscureText: true,
          autofocus: true,
          enabled: !_islemDeVam,
          decoration: const InputDecoration(
            labelText: 'Parola',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _parolayiDogrula(),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: kaldirma ? 'Doğrula ve kaldır' : 'Devam et',
          isLoading: _islemDeVam,
          onTap: _islemDeVam ? null : _parolayiDogrula,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _islemDeVam ? null : _durumuYukle,
          child: const Text('Vazgeç'),
        ),
      ],
    );
  }

  // ── 3. Anahtar ve kod ──────────────────────────────────────────

  Widget _anahtarGorunumu() {
    final anahtar = _anahtar;
    if (anahtar == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hataKutusu(),
        Text('Authenticator’a ekleyin', style: AppTextStyles.headingLarge),
        const SizedBox(height: 8),
        Text(
          'Aşağıdaki iki yoldan birini kullanın, sonra uygulamanın ürettiği '
          '6 haneli kodu girin.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 20),

        PrimaryButton(
          label: 'Authenticator uygulamasında aç',
          icon: Icons.open_in_new_rounded,
          onTap: _islemDeVam ? null : _authenticatordaAc,
        ),
        const SizedBox(height: 16),

        Text(
          'veya kurulum anahtarını elle girin',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textMuted, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // Messenger, await'ten ÖNCE alınır; panoya yazma bittiğinde
            // context'in hâlâ geçerli olduğunu varsaymak zorunda kalmayız.
            final messenger = ScaffoldMessenger.of(context);
            await Clipboard.setData(ClipboardData(text: anahtar.secretKey));
            messenger.showSnackBar(
              const SnackBar(content: Text('Kurulum anahtarı kopyalandı.')),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _okunakli(anahtar.secretKey),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 15,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.copy_rounded, size: 20, color: AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bu anahtar bir sırdır. Ekran görüntüsünü paylaşmayın; anahtarı '
          'ele geçiren kişi geçerli kod üretebilir.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textMuted, fontSize: 12.5),
        ),

        const SizedBox(height: 24),
        TextField(
          controller: _cihazAdiController,
          enabled: !_islemDeVam,
          maxLength: 30,
          decoration: const InputDecoration(
            labelText: 'Cihaz adı',
            helperText: 'Birden fazla cihaz eklerseniz ayırt etmenizi sağlar.',
            counterText: '',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _kodController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          enabled: !_islemDeVam,
          style: const TextStyle(
            fontSize: 24,
            letterSpacing: 9,
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
          onSubmitted: (_) => _kaydiTamamla(),
        ),

        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Doğrula ve etkinleştir',
          icon: Icons.check_rounded,
          isLoading: _islemDeVam,
          onTap: _islemDeVam ? null : _kaydiTamamla,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _islemDeVam
              ? null
              : () {
                  // Yarıda bırakılan anahtar kaydedilmedi; bellekten düşür.
                  setState(() {
                    _anahtar = null;
                    _otpauth = null;
                  });
                  _durumuYukle();
                },
          child: const Text('Vazgeç'),
        ),
      ],
    );
  }

  Widget _bilgiKutusu(String metin) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              metin,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}
