class AppConstants {
  // ── WhatsApp ve telefon hatları ─────────────────────────
  //
  // TEK KAYNAK. Uygulamadan çıkan bütün WhatsApp bağlantıları ve yasal
  // metinlerdeki hat listesi (SirketBilgileri.whatsappHatti) buradan gelir.
  //
  // 07.10.2026 — Şirket iki WhatsApp Business hattı bildirdi; müşteri
  // rezervasyonda hangisine yazacağını seçer. İki hattın da Business hesabı
  // olduğu şirket tarafından teyit edildi (WhatsApp aktarım dayanağı yalnızca
  // Business hesapta geçerlidir; yeni hat eklenirse yeniden teyit edilmeli).
  //
  // Numara ülke kodu ile, '+' ve boşluk olmadan yazılır.

  /// Birincil hat. Kampanya kartlarının "Bize Ulaşın" düğmesi buraya yazar.
  static const String whatsappPhone = '905323853402';

  /// Ofis hattı (sabit hat, WhatsApp Business).
  static const String ofisWhatsappPhone = '903224355635';

  /// Rezervasyon ekranında seçilebilen hatlar. Birden fazla hat varsa seçim
  /// gösterilir. 'gorunum' yasal metinlerde ve ekranda yazılan biçimdir.
  static const List<Map<String, String>> whatsappNumbers = [
    {'label': 'Cep Hattı', 'phone': whatsappPhone, 'gorunum': '0532 385 34 02'},
    {'label': 'Ofis Hattı', 'phone': ofisWhatsappPhone, 'gorunum': '0322 435 56 35'},
  ];

  /// Acil durum ve arama için gösterilen numaralar (tel: bağlantısı).
  static const List<Map<String, String>> aramaNumaralari = [
    {'label': 'Cep / Acil Durum', 'phone': '+905323853402', 'gorunum': '0532 385 34 02'},
    {'label': 'Ofis', 'phone': '+903224355635', 'gorunum': '0322 435 56 35'},
  ];

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

  // WhatsApp mesaj şablonu (müşteri bilgili + alım yeri versiyon)
  //
  // T.C. Kimlik No satırı YALNIZCA alan doldurulduysa eklenir. Aydınlatma
  // metni "bu alanı doldurursanız mesaja eklenir" diyor; boşken mesajda
  // "TC No:" satırının görünmesi hem metinle çelişiyor hem de müşteriye
  // numarayı yazması gerekiyormuş izlenimi veriyordu.
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
          '${customerTc.trim().isEmpty ? '' : 'TC No: ${customerTc.trim()}\n'}'
          'Telefon: $customerPhone\n'
          'Araç: $vehicleName\n'
          'Tarih: $startDate - $endDate\n'
          'Alım Yeri: $pickupLocation';


  // ── Vehicle Categories ────────────────────────────────────
  /// Araç kategorileri. İlk eleman ('Hepsi') yalnızca filtre içindir;
  /// yönetim formundaki açılır listede gösterilmez.
  ///
  /// 'Hatchback' filoda gerçekten bu gövde tipinde araçlar bulunduğu için
  /// eklendi (Clio, Scala, Corsa). Eskiden listede yoktu ve bu araçlar
  /// zorunlu olarak yanlış bir kategoriye yazılmak durumunda kalıyordu.
  static const List<String> categories = [
    'Hepsi',
    'SUV',
    'Sedan',
    'Hatchback',
    'Luxury',
    'Van',
    'Sports',
  ];

  /// Kategorinin müşteriye gösterilen adı. Kayıtlar eski İngilizce
  /// değerlerle tutuluyor ('Luxury', 'Sports'); kartta "LUXURY" yazıyordu.
  static String kategoriAdi(String kategori) {
    switch (kategori) {
      case 'Luxury':
        return 'Lüks';
      case 'Sports':
        return 'Spor';
      case 'Van':
        return 'Ticari / Van';
      default:
        return kategori;
    }
  }
}
