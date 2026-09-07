import 'package:firebase_auth/firebase_auth.dart';

/// Yönetici hesapları için TOTP tabanlı iki faktörlü kimlik doğrulama.
///
/// NEDEN TOTP, NEDEN SMS DEĞİL
/// ---------------------------
/// Firebase iki ikinci faktör sunar: SMS ve TOTP (Google Authenticator,
/// Microsoft Authenticator gibi uygulamaların ürettiği 6 haneli kod).
/// TOTP seçildi çünkü:
///   • Kullanım başına ücreti yoktur; SMS mesaj başına faturalandırılır ve
///     Blaze planı ister.
///   • SIM takası (SIM swap) saldırılarına karşı dayanıklıdır.
///   • İnternet bağlantısı gerektirmez; kod cihazda üretilir.
///
/// NEDEN "E-POSTAYA KOD GÖNDERME" YAPILMADI
/// ----------------------------------------
/// Parolayı ele geçiren saldırgan çoğu durumda e-posta hesabına da erişir.
/// Aynı kanaldan gelen kod ikinci bir faktör sayılmaz; güvenlik tiyatrosu
/// olur ve bankaya "2FA var" diye beyan edilirse yanlış beyan olur.
///
/// ÖN KOŞUL — IDENTITY PLATFORM
/// ----------------------------
/// TOTP, Firebase Authentication'ın temel sürümünde YOKTUR; projenin
/// "Firebase Authentication with Identity Platform"a yükseltilmesi gerekir.
/// Yükseltmenin kendi ücreti yoktur ve Spark (ücretsiz) planda da yapılabilir;
/// tek etkisi, ücretsiz planda kotanın 50.000 aylık aktif kullanıcıdan
/// 3.000 GÜNLÜK aktif kullanıcıya dönmesidir.
///
/// Yükseltme yapılmadan bu servisin kayıt akışı hata verir. Hata, kullanıcıya
/// "kod yanlış" gibi yanıltıcı bir mesajla değil, [hataMesaji] üzerinden
/// gerçek sebebiyle gösterilir.
///
/// ZORLAMA HAKKINDA
/// ----------------
/// Firebase MFA'yı hesap bazında uygular: yalnızca ikinci faktör KAYITLI olan
/// hesaplarda girişte kod istenir. Yani "tüm yöneticilere zorunlu" diye bir
/// sunucu ayarı yoktur; her yönetici hesabı için bu ekrandan bir kez kurulum
/// yapılmalıdır. Kurulum yapılmış bir hesapta ikinci adım artık atlanamaz —
/// doğrulama sunucu tarafında yapılır, istemci kodu değiştirilse bile geçilemez.
class MfaService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Firebase'in TOTP faktörleri için kullandığı sabit tanımlayıcı.
  static const String totpFaktorId = 'totp';

  /// Authenticator uygulamasında hesabın altında görünecek yayıncı adı.
  static const String yayinciAdi = 'Şenbayrak Araç Kiralama';

  /// Oturumdaki kullanıcının kayıtlı ikinci faktörleri.
  ///
  /// Oturum yoksa boş liste döner; çağıranın ayrıca null kontrolü yapmasına
  /// gerek kalmaz.
  Future<List<MultiFactorInfo>> kayitliFaktorler() async {
    final kullanici = _auth.currentUser;
    if (kullanici == null) return const [];
    return kullanici.multiFactor.getEnrolledFactors();
  }

  /// Hesapta iki faktörlü doğrulama açık mı?
  Future<bool> ikiFaktorAcikMi() async {
    final faktorler = await kayitliFaktorler();
    return faktorler.isNotEmpty;
  }

  /// Kayıt öncesi yeniden kimlik doğrulaması.
  ///
  /// Firebase, ikinci faktör ekleme/kaldırma gibi hassas işlemler için yakın
  /// zamanlı bir giriş ister (`requires-recent-login`). Uygulama açık
  /// kaldığında oturum eskir, bu yüzden kuruluma parola sorularak başlanır.
  Future<void> yenidenDogrula(String parola) async {
    final kullanici = _auth.currentUser;
    if (kullanici == null || kullanici.email == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Oturum bulunamadı.',
      );
    }
    final kimlik = EmailAuthProvider.credential(
      email: kullanici.email!,
      password: parola,
    );
    await kullanici.reauthenticateWithCredential(kimlik);
  }

  /// Authenticator uygulamasına girilecek gizli anahtarı üretir.
  ///
  /// Bu anahtar bir SIRDIR: ele geçiren kişi geçerli kodlar üretebilir.
  /// Ekranda gösterilir ama hiçbir yere kaydedilmez ve loglanmaz.
  Future<TotpSecret> gizliAnahtarUret() async {
    final kullanici = _auth.currentUser;
    if (kullanici == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Oturum bulunamadı.',
      );
    }
    final oturum = await kullanici.multiFactor.getSession();
    return TotpMultiFactorGenerator.generateSecret(oturum);
  }

  /// Authenticator uygulamalarının anladığı `otpauth://` adresi.
  ///
  /// Bu adres aynı cihazdaki Authenticator uygulamasında açılabilir; hesap ve
  /// gizli anahtar elle yazılmadan eklenir. Adres gizli anahtarı İÇERİR,
  /// dolayısıyla o da bir sırdır.
  Future<String> otpauthAdresi(TotpSecret anahtar, {required String hesapAdi}) {
    return anahtar.generateQrCodeUrl(
      accountName: hesapAdi,
      issuer: yayinciAdi,
    );
  }

  /// Kullanıcının girdiği kodu doğrulayıp ikinci faktörü hesaba bağlar.
  ///
  /// [cihazAdi] Firebase tarafında zorunludur (TOTP için `displayName` şart);
  /// yöneticinin birden fazla cihaz kaydetmesi hâlinde hangisinin hangisi
  /// olduğunu ayırt etmeye yarar.
  Future<void> kaydiTamamla({
    required TotpSecret anahtar,
    required String kod,
    required String cihazAdi,
  }) async {
    final kullanici = _auth.currentUser;
    if (kullanici == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Oturum bulunamadı.',
      );
    }
    final iddia = await TotpMultiFactorGenerator.getAssertionForEnrollment(
      anahtar,
      kod.trim(),
    );
    await kullanici.multiFactor.enroll(iddia, displayName: cihazAdi);
  }

  /// Kayıtlı bir ikinci faktörü kaldırır.
  ///
  /// Kaldırma da yakın zamanlı giriş ister; çağıran önce [yenidenDogrula]
  /// çağırmalıdır.
  Future<void> kaldir(MultiFactorInfo faktor) async {
    final kullanici = _auth.currentUser;
    if (kullanici == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Oturum bulunamadı.',
      );
    }
    await kullanici.multiFactor.unenroll(multiFactorInfo: faktor);
  }

  /// Girişin ikinci adımını tamamlar.
  ///
  /// Parola doğru olduğunda Firebase girişi tamamlamak yerine
  /// [FirebaseAuthMultiFactorException] fırlatır; içindeki resolver bu
  /// metoda verilir ve kod doğrulanınca oturum açılır.
  Future<UserCredential> girisiTamamla({
    required MultiFactorResolver resolver,
    required String kod,
  }) async {
    MultiFactorInfo? totp;
    for (final faktor in resolver.hints) {
      if (faktor.factorId == totpFaktorId) {
        totp = faktor;
        break;
      }
    }

    if (totp == null) {
      // Hesapta yalnızca SMS gibi başka bir faktör kayıtlıysa buraya düşeriz.
      // Uygulama SMS akışını içermiyor; sessizce "kod yanlış" demek yerine
      // durumu olduğu gibi bildiriyoruz.
      throw FirebaseAuthException(
        code: 'totp-faktoru-yok',
        message: 'Bu hesapta Authenticator ile doğrulama kayıtlı değil.',
      );
    }

    final iddia = await TotpMultiFactorGenerator.getAssertionForSignIn(
      totp.uid,
      kod.trim(),
    );
    return resolver.resolveSignIn(iddia);
  }

  /// Firebase hata kodlarını kullanıcıya gösterilebilir Türkçe metne çevirir.
  ///
  /// Tanınmayan kodlarda kodun kendisi de yazılır; aksi hâlde alan tarafındaki
  /// bir arıza "bir hata oluştu" arkasında görünmez kalır.
  static String hataMesaji(Object hata) {
    if (hata is! FirebaseAuthException) {
      return 'Beklenmeyen bir hata oluştu: $hata';
    }

    switch (hata.code) {
      case 'invalid-verification-code':
      case 'invalid-totp-code':
        return 'Kod doğrulanamadı. Authenticator uygulamasındaki güncel '
            '6 haneli kodu girin; kodlar 30 saniyede bir yenilenir.';

      case 'requires-recent-login':
        return 'Güvenlik için parolanızı yeniden girmeniz gerekiyor.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Parola hatalı.';

      case 'second-factor-already-in-use':
        return 'Bu doğrulama yöntemi hesapta zaten kayıtlı.';

      case 'maximum-second-factor-count-exceeded':
        return 'Bu hesap için izin verilen ikinci faktör sayısına ulaşıldı. '
            'Yeni bir cihaz eklemeden önce eskisini kaldırın.';

      case 'unverified-email':
        return 'İki faktörlü doğrulama kurulabilmesi için e-posta adresinizin '
            'doğrulanmış olması gerekir.';

      case 'operation-not-allowed':
      case 'admin-restricted-operation':
        return 'İki faktörlü doğrulama bu projede henüz etkin değil. '
            'Firebase Konsolu → Authentication bölümünden "Identity Platform" '
            'yükseltmesi yapılmalı ve çok faktörlü doğrulamada TOTP '
            'etkinleştirilmelidir. Yükseltmenin ücreti yoktur.';

      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Bir süre bekleyip tekrar deneyin.';

      case 'network-request-failed':
        return 'İnternet bağlantısı kurulamadı.';

      case 'totp-faktoru-yok':
        return hata.message ??
            'Bu hesapta Authenticator ile doğrulama kayıtlı değil.';

      default:
        return 'İşlem tamamlanamadı (${hata.code}). '
            '${hata.message ?? ''}'.trim();
    }
  }
}
