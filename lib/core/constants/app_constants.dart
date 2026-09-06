class AppConstants {
  // ── WhatsApp ──────────────────────────────────────────────
  //
  // TEK KAYNAK. Uygulamadan çıkan bütün WhatsApp bağlantıları bu numarayı
  // kullanır.
  //
  // Denetimde iki AYRI numara tanımlı olduğu görüldü: kampanya kartlarındaki
  // "Bize Ulaşın" 905357605676'ya, rezervasyon talebi ise 905303739446'ya
  // gidiyordu. Müşteri, hangi düğmeye bastığına göre farklı hatta düşüyordu.
  // Numaralar burada birleştirildi.
  //
  // TODO(yayın): Yayına çıkmadan önce işletmenin kullanacağı TEK numara
  // teyit edilip buraya yazılmalı. Ülke kodu ile, '+' ve boşluk olmadan.
  static const String whatsappPhone = '905303739446';

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

  // ── WhatsApp Hat Listesi ──────────────────────────────────
  // Birden fazla hat tanımlanırsa rezervasyon ekranında kullanıcıya seçim
  // sunulur; tek hat varsa seçim gösterilmez. Numaralar [whatsappPhone]
  // üzerinden gelir ki iki ayrı yerde farklı numara tutulamasın.
  static const List<Map<String, String>> whatsappNumbers = [
    {'label': 'Hat 1 - Ofis', 'phone': whatsappPhone},
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
