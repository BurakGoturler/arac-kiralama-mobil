import 'package:car_rental_mvp/ui/screens/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _appCheckBaslat();
  await initializeDateFormatting('tr_TR', null);
  runApp(const MyApp());
}

/// App Check'in devreye alınıp alınmayacağı.
///
/// AÇIK. App Check, Firestore ve Storage isteklerinin gerçekten bu
/// uygulamadan geldiğini doğrular. Kapalıyken güvenlik kuralları hâlâ
/// koruyordu, ancak istekleri uygulama dışından da (curl, betik, değiştirilmiş
/// paket) göndermek mümkündü.
///
/// Sağlayıcılar:
///   • Debug derlemesi → Debug provider. Cihaz başına yerel bir "debug
///     secret" üretir ve logcat'e basar. Bu değer Konsol'da
///     App Check → uygulama → "Manage debug tokens" altına eklenmelidir,
///     yoksa geliştirme cihazı doğrulanamaz.
///   • Yayın derlemesi → Play Integrity (Android) / App Attest (iOS).
///
/// ZORLAMA (enforcement) AYRI BİR ADIMDIR ve en sona bırakılmalıdır.
/// Buradaki bayrak yalnızca token ÜRETİMİNİ açar; istekler zorlama
/// açılana kadar reddedilmez. Sıra:
///   1. Cloud Console → "Firebase App Check API" → Etkinleştir
///   2. Firebase Console → App Check → Android'i Play Integrity ile kaydet
///   3. Logcat'teki debug token'ı Konsol'a ekle
///   4. Metriklerde isteklerin "doğrulanmış" göründüğünü TEYİT ET
///   5. Ancak o zaman Firestore ve Storage için zorlamayı aç
///
/// Sırayı bozup zorlamayı erken açarsan yayındaki uygulama veritabanına
/// erişemez hâle gelir. Ayrıca Play App Signing kullanılıyorsa Play
/// Console'daki SHA-256 de Firebase'e eklenmiş olmalıdır; yoksa mağazadan
/// inen sürüm doğrulanamaz.
const bool _appCheckAcik = true;

/// Firebase App Check'i devreye alır.
///
/// Başlatma hatası uygulamayı açılışta kilitlememelidir; yutulur, log'lanır.
/// API henüz etkinleştirilmemişse SDK yer tutucu token'la devam eder ve
/// istekler normal şekilde gider — bu bir arıza değildir.
Future<void> _appCheckBaslat() async {
  if (!_appCheckAcik) return;

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );

    // Debug derlemesinde token'ı hemen istiyoruz: Debug provider'ın
    // "debug secret" satırını logcat'e basması bu çağrıyla tetikleniyor.
    // Aksi hâlde token ilk Firestore isteğine kadar görünmüyor ve
    // Konsol'a eklenecek değeri bulmak zorlaşıyor.
    if (kDebugMode) {
      try {
        await FirebaseAppCheck.instance.getToken();
      } catch (e) {
        debugPrint('App Check debug token alınamadı: $e');
      }
    }
  } catch (e) {
    debugPrint('App Check başlatılamadı: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Şenbayrak Araç Kiralama',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Uygulama tek dilli (Türkçe). Bu üç delege olmadan Flutter'ın
      // hazır widget'ları (takvim, saat seçici, metin seçim menüsü,
      // "Cancel/OK" düğmeleri) İngilizce'ye düşer.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR')],
      locale: const Locale('tr', 'TR'),
      home: const SplashScreen(),
    );
  }
}
