import 'package:flutter/material.dart';

/// Uygulama genelinde tek tip sayfa geçişi.
///
/// Önceden her ekran `MaterialPageRoute` kullanıyordu; bu, Android'de
/// Material 3'ün varsayılan "zoom" geçişine düşüyor ve ağır ekranlarda
/// (ilk kare pahalıysa) takılıyormuş gibi görünüyordu. Burada geçiş
/// hafif bir yukarı kayma + solma birleşimine sabitlenir: her yerde
/// aynı, ucuz ve akıcı.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required WidgetBuilder builder,
    super.settings,
    super.fullscreenDialog,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          transitionsBuilder: appPageTransition,
        );
}

/// Geçiş efektinin tek kaynağı — hem [AppPageRoute] hem de tema üzerinden
/// çalışan [AppPageTransitionsBuilder] bunu kullanır.
Widget appPageTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  // Giren sayfa: aşağıdan hafifçe yukarı kayarak belirir.
  final girisKaymasi = Tween<Offset>(
    begin: const Offset(0, 0.035),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

  final girisSolmasi = CurvedAnimation(
    parent: animation,
    // İçerik geçişin ilk yarısında belirsin; sonu tamamen opak geçsin.
    curve: const Interval(0, 0.7, curve: Curves.easeOut),
  );

  // Çıkan (alttaki) sayfa: yerinde hafifçe soluklaşır. Tamamen görünmez
  // olmaz, aksi hâlde geçiş sırasında arkada boşluk görünür.
  final cikisSolmasi = Tween<double>(begin: 1, end: 0.92).animate(
    CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
  );

  return FadeTransition(
    opacity: cikisSolmasi,
    child: SlideTransition(
      position: girisKaymasi,
      child: FadeTransition(opacity: girisSolmasi, child: child),
    ),
  );
}

/// Temaya takılan sürüm. Doğrudan `MaterialPageRoute` kullanan kod
/// (paket içi diyaloglar, `showDialog` sonrası push'lar vb.) de aynı
/// geçişi alsın diye `ThemeData.pageTransitionsTheme` içine konur.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return appPageTransition(context, animation, secondaryAnimation, child);
  }
}

/// Çağrı yerlerini kısaltan yardımcılar.
///
/// `Navigator.push(context, MaterialPageRoute(builder: (_) => X()))` yerine
/// `context.sayfayaGit(const X())` yazılır.
extension AppNavigation on BuildContext {
  Future<T?> sayfayaGit<T>(Widget sayfa, {bool tamEkranDiyalog = false}) {
    return Navigator.of(this).push<T>(
      AppPageRoute<T>(
        builder: (_) => sayfa,
        fullscreenDialog: tamEkranDiyalog,
      ),
    );
  }

  /// Mevcut sayfanın yerine geçer (geri tuşuyla dönülemez).
  Future<T?> sayfayiDegistir<T>(Widget sayfa) {
    return Navigator.of(this).pushReplacement<T, dynamic>(
      AppPageRoute<T>(builder: (_) => sayfa),
    );
  }

  /// Tüm gezinme geçmişini temizleyip verilen sayfaya gider
  /// (çıkış yapma, hesap silme gibi akışlar için).
  Future<T?> sayfayaSifirla<T>(Widget sayfa) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      AppPageRoute<T>(builder: (_) => sayfa),
      (route) => false,
    );
  }
}
