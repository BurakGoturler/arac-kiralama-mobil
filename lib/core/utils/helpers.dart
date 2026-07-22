import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

class AppHelpers {
  // ── Date Formatting ───────────────────────────────────────
  static final DateFormat _displayFormat = DateFormat('d MMM yyyy', 'tr_TR');
  static final DateFormat _shortFormat = DateFormat('d MMM', 'tr_TR');

  static String formatDate(DateTime date) => _displayFormat.format(date);
  static String formatShortDate(DateTime date) => _shortFormat.format(date);

  // ── Currency Formatting ───────────────────────────────────
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  static String formatPrice(double price) => _currencyFormat.format(price);

  // ── Date Range Helpers ────────────────────────────────────
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  // ── T.C. Kimlik No Doğrulama ──────────────────────────────
  /// T.C. Kimlik Numarasının resmî algoritmaya göre geçerliliğini kontrol eder.
  ///
  /// Numara hiçbir yerde saklanmadığı için bu kontrol, yalnızca WhatsApp
  /// mesajına hatalı bir numara yazılmasını ve sözleşme aşamasında sorun
  /// çıkmasını önlemek amacıyla yapılır.
  static bool isValidTcNo(String value) {
    final tc = value.trim();

    if (tc.length != 11) return false;
    if (!RegExp(r'^[0-9]{11}$').hasMatch(tc)) return false;
    if (tc[0] == '0') return false;

    final d = tc.split('').map(int.parse).toList();

    // 1, 3, 5, 7, 9. hanelerin toplamının 7 katından
    // 2, 4, 6, 8. hanelerin toplamı çıkarılır; mod 10'u 10. haneyi verir.
    final tekToplam = d[0] + d[2] + d[4] + d[6] + d[8];
    final ciftToplam = d[1] + d[3] + d[5] + d[7];

    if ((tekToplam * 7 - ciftToplam) % 10 != d[9]) return false;

    // İlk 10 hanenin toplamının mod 10'u 11. haneyi verir.
    final ilkOnToplam = d.take(10).reduce((a, b) => a + b);
    if (ilkOnToplam % 10 != d[10]) return false;

    return true;
  }

  static double totalPrice(double dailyPrice, DateTime start, DateTime end) {
    final days = daysBetween(start, end);
    return dailyPrice * days;
  }

  // ── WhatsApp Launcher ─────────────────────────────────────
  static Future<bool> openWhatsApp({
    required String vehicleName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final message = AppConstants.whatsappMessage(
      vehicleName: vehicleName,
      startDate: formatDate(startDate),
      endDate: formatDate(endDate),
    );
    return await openWhatsAppWithMessage(message);
  }

  static Future<bool> openWhatsAppWithMessage(String message) async {
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse(
      'whatsapp://send?phone=${AppConstants.whatsappPhone}&text=$encoded',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }

    // Fallback: web WhatsApp
    final webUri = Uri.parse(
      'https://api.whatsapp.com/send?phone=${AppConstants.whatsappPhone}&text=$encoded',
    );
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

// ── WhatsApp Launcher (Müşteri Bilgili + Numara Seçimli + Alım Yeri) ──
  static Future<bool> openWhatsAppWithDetails({
    required String vehicleName,
    required DateTime startDate,
    required DateTime endDate,
    required String customerName,
    required String customerSurname,
    required String customerTc,
    required String customerPhone,
    required String pickupLocation,
    required String phoneNumber,
  }) async {
    final message = AppConstants.whatsappMessageWithCustomer(
      vehicleName: vehicleName,
      startDate: formatDate(startDate),
      endDate: formatDate(endDate),
      customerName: customerName,
      customerSurname: customerSurname,
      customerTc: customerTc,
      customerPhone: customerPhone,
      pickupLocation: pickupLocation,
    );

    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse(
      'whatsapp://send?phone=$phoneNumber&text=$encoded',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }

    // Fallback: web WhatsApp
    final webUri = Uri.parse(
      'https://api.whatsapp.com/send?phone=$phoneNumber&text=$encoded',
    );
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

}