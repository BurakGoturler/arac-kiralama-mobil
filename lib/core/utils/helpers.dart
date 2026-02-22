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
}