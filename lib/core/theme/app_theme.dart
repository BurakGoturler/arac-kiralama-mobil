import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../navigation/app_page_route.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Brand
  static const Color primary = Color(0xFF0052CC);
  static const Color primaryLight = Color(0xFFE8F0FE);
  static const Color primaryDark = Color(0xFF003A99);

  // WhatsApp
  static const Color whatsapp = Color(0xFF25D366);
  static const Color whatsappDark = Color(0xFF1EAA52);

  // Text
  static const Color textPrimary = Color(0xFF0D1117);
  static const Color textSecondary = Color(0xFF5C6370);
  static const Color textMuted = Color(0xFF9DA3AE);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Utility
  static const Color divider = Color(0xFFEEF0F4);
  static const Color cardShadow = Color(0xFF000000);
  static const Color error = Color(0xFFD93025);
  static const Color success = Color(0xFF1B8A4C);

  // Category chips
  static const Color chipActive = Color(0xFF0052CC);
  static const Color chipInactive = Color(0xFFFFFFFF);
}

class AppTextStyles {
  // Yazı tipleri uygulamanın içinde (assets/fonts). Eskiden google_fonts
  // paketi bunları her kurulumda Google sunucularından indiriyordu: her
  // kullanıcının IP adresi Google'a gidiyordu (yasal metinlerde yoktu) ve
  // bağlantı yavaşken metinler önce başka fontla çizilip sonra değişiyordu.
  static const String jakarta = 'PlusJakartaSans';

  /// DM Serif'te ₺ işareti yok; fiyatlarda Plus Jakarta'ya düşülür.
  static const String serif = 'DMSerifDisplay';

  static TextStyle get displayLarge => TextStyle(
    fontFamily: serif,
    fontFamilyFallback: const [jakarta],
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => TextStyle(
    fontFamily: serif,
    fontFamilyFallback: const [jakarta],
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static TextStyle get headingLarge => TextStyle(
    fontFamily: serif,
    fontFamilyFallback: const [jakarta],
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get headingMedium => TextStyle(
    fontFamily: jakarta,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.35,
    letterSpacing: -0.2,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: jakarta,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: jakarta,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.55,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: jakarta,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static TextStyle get labelLarge => TextStyle(
    fontFamily: jakarta,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: jakarta,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );

  static TextStyle get price => TextStyle(
    fontFamily: serif,
    fontFamilyFallback: const [jakarta],
    fontSize: 26,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
    height: 1.1,
  );

  static TextStyle get priceSmall => TextStyle(
    fontFamily: serif,
    fontFamilyFallback: const [jakarta],
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: jakarta,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );

  static TextStyle get appBarTitle => TextStyle(
    fontFamily: serif,
    fontFamilyFallback: const [jakarta],
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // Stil verilmemiş metinler (diyaloglar, düğmeler, takvim) Roboto'ya
      // düşüyordu; uygulamanın geri kalanıyla aynı aileyi kullansın.
      fontFamily: AppTextStyles.jakarta,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),

      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Sayfa geçişleri tek noktadan yönetilir. Doğrudan MaterialPageRoute
      // kullanan kod da AppPageRoute ile aynı yumuşak geçişi alır, böylece
      // uygulamada iki farklı geçiş hissi oluşmaz.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: AppPageTransitionsBuilder(),
          TargetPlatform.windows: AppPageTransitionsBuilder(),
          TargetPlatform.macOS: AppPageTransitionsBuilder(),
          TargetPlatform.linux: AppPageTransitionsBuilder(),
        },
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.appBarTitle,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        centerTitle: false,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}