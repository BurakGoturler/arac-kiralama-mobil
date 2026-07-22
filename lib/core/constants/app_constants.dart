class AppConstants {
  // ── WhatsApp ──────────────────────────────────────────────
  /// Replace with your actual WhatsApp business number (with country code, no '+').
  static const String whatsappPhone = '905357605676';

  // ── Dimensions ────────────────────────────────────────────
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0; // Değer 26.0'dan 16.0'a düzeltildi
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  static const double cardRadius = 20.0;
  static const double buttonRadius = 14.0;
  static const double buttonHeight = 56.0;

  // ── Strings ───────────────────────────────────────────────
  static const String appName = 'Şenbayrak Araç Kiralama';
  static const String tagline = 'Premium araç kiralama, sadece bir mesaj uzağınızda.';
  static const String reserveButtonLabel = 'WhatsApp üzerinden rezervasyon yapın';
  static const String filterTitle = 'Araçları Filtrele';
  static const String allCategory = 'Hepsi';

  // WhatsApp message template
  static String whatsappMessage({
    required String vehicleName,
    required String startDate,
    required String endDate,
  }) =>
      'Merhaba, mobil uygulamanız üzerinden $vehicleName için $startDate - $endDate tarihleri arasında rezervasyon yapmak istiyorum.';



  // ── WhatsApp Çoklu Numara ─────────────────────────────────
  static const List<Map<String, String>> whatsappNumbers = [
    {'label': 'Hat 1 - Ofis', 'phone': '905303739446'},
    // {'label': 'Hat 2 - Mehmet Bey', 'phone': '905303739446'},
    // {'label': 'Hat 3 - Ahmet Bey', 'phone': '905303739446'},
  ];

// WhatsApp mesaj şablonu (müşteri bilgili + alım yeri versiyon)
  static String whatsappMessageWithCustomer({
    required String vehicleName,
    required String startDate,
    required String endDate,
    required String customerName,
    required String customerSurname,
    required String customerTc,
    required String customerPhone,
    required String pickupLocation,
  }) =>
      'Merhaba, mobil uygulamanız üzerinden rezervasyon yapmak istiyorum.\n\n'
          'Ad Soyad: $customerName $customerSurname\n'
          'TC No: $customerTc\n'
          'Telefon: $customerPhone\n'
          'Araç: $vehicleName\n'
          'Tarih: $startDate - $endDate\n'
          'Alım Yeri: $pickupLocation';


  // ── Vehicle Categories ────────────────────────────────────
  static const List<String> categories = [
    'Hepsi',
    'SUV',
    'Sedan',
    'Luxury',
    // 'Electric',
    'Van',
    'Sports'
  ];
}
