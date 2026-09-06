import 'package:car_rental_mvp/ui/screens/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
/// KAPALI. Firebase projesinde App Check API'si henüz etkin değil; bu hâlde
/// sağlayıcıyı başlatmak her istekte 403 döndürüp log'u
/// "Error returned from API ... has not been used in project" ve ardından
/// "Too many attempts" satırlarıyla dolduruyor. Bu satırlar bir hata DEĞİL:
/// SDK yer tutucu token'la devam eder, istek normal şekilde gider. Ama gerçek
/// hataları görünmez hâle getirdikleri için kapalı tutuluyor.
///
/// AÇMADAN ÖNCE konsol tarafı sırasıyla tamamlanmalı:
///   1. console.cloud.google.com → API'ler → "Firebase App Check API" → Etkinleştir
///   2. Firebase Console → App Check → Android uygulamasını Play Integrity ile kaydet
///   3. Debug derlemesini bir kez çalıştır, logcat'teki debug token'ı
///      App Check → uygulama → "Manage debug tokens" altına ekle
///
/// Zorlamayı (enforcement) en sona bırak: önce Konsol'daki metriklerde
/// isteklerin "doğrulanmış" göründüğünü teyit et, sonra aç. Sırayı bozarsan
/// yayındaki uygulama Firestore ve Storage'a erişemez hâle gelir.
const bool _appCheckAcik = false;

/// Firebase App Check'i devreye alır.
///
/// Başlatma hatası uygulamayı açılışta kilitlememelidir; yutulur, log'lanır.
Future<void> _appCheckBaslat() async {
  if (!_appCheckAcik) return;

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
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
      home: const SplashScreen(),
    );
  }
}
