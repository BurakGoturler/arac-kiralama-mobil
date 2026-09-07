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

  /// Kullanıcının yazdığı sayıyı Türkçe biçimlere dayanıklı biçimde çözer.
  ///
  /// `double.parse` burada güvenli değildi: yönetici fiyatı "1.500" diye
  /// yazdığında (Türkçe binlik ayracı) sonuç sessizce **1.5** oluyor,
  /// "1500,00" yazdığında ise FormatException fırlatıp kaydı düşürüyordu.
  /// Burada binlik ayracı atılır, ondalık virgül noktaya çevrilir.
  /// Çözülemezse `null` döner — çağıran taraf bunu doğrulama hatası olarak
  /// gösterir, exception'a düşmez.
  static double? sayiCoz(String? girdi) {
    if (girdi == null) return null;

    var metin = girdi.trim().replaceAll(RegExp(r'[\s₺]'), '');
    if (metin.isEmpty) return null;

    final sonVirgul = metin.lastIndexOf(',');
    final sonNokta = metin.lastIndexOf('.');

    if (sonVirgul > sonNokta) {
      // "1.500,50" → nokta binlik, virgül ondalık
      metin = metin.replaceAll('.', '').replaceAll(',', '.');
    } else if (sonNokta > sonVirgul) {
      // "1,500.50" → virgül binlik. Tek nokta varsa ve ardından tam 3 hane
      // geliyorsa ("1.500") bu Türkçe binlik ayracıdır, ondalık değil.
      metin = metin.replaceAll(',', '');
      final noktaSayisi = '.'.allMatches(metin).length;
      final basamak = metin.length - metin.lastIndexOf('.') - 1;
      if (noktaSayisi > 1 || basamak == 3) {
        metin = metin.replaceAll('.', '');
      }
    } else {
      metin = metin.replaceAll(',', '');
    }

    return double.tryParse(metin);
  }

  /// Tam sayı alanları (koltuk, yıl, sıra) için [sayiCoz] üzerinden çözer.
  static int? tamSayiCoz(String? girdi) => sayiCoz(girdi)?.round();

  // ── Date Range Helpers ────────────────────────────────────
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  // ── Parola Politikası ─────────────────────────────────────
  /// Parolanın kurumsal politikaya uygunluğunu denetler.
  ///
  /// Uygun ise `null`, değilse kullanıcıya gösterilecek mesajı döndürür —
  /// böylece doğrudan `TextFormField.validator` olarak kullanılabilir.
  ///
  /// Firebase'in kendi alt sınırı 6 karakterdir ve karmaşıklık aramaz;
  /// "123456" kabul edilir. Ödeme sürecine bağlı bir hesap için bu yetersiz
  /// olduğundan sınır burada yükseltilmiştir. Kural, kaba kuvvet ve sözlük
  /// saldırılarına karşı anlamlı bir eşik oluşturmayı hedefler.
  static const int sifreAsgariUzunluk = 8;

  static String? sifreKontrol(String? girdi) {
    final sifre = girdi ?? '';

    if (sifre.isEmpty) return 'Gerekli';
    if (sifre.length < sifreAsgariUzunluk) {
      return 'En az $sifreAsgariUzunluk karakter olmalı';
    }
    // Çok uzun girdiler bazı sağlayıcılarda sorun çıkarır.
    if (sifre.length > 128) return 'En fazla 128 karakter olabilir';

    if (!RegExp(r'[A-Za-zÇĞİÖŞÜçğıöşü]').hasMatch(sifre)) {
      return 'En az bir harf içermeli';
    }
    if (!RegExp(r'[0-9]').hasMatch(sifre)) {
      return 'En az bir rakam içermeli';
    }

    // Yaygın ve tahmin edilmesi kolay parolalar. Kısa bir liste bile
    // gerçek dünyada en sık kullanılan seçimleri eler.
    const yasakli = {
      '12345678', '123456789', '1234567890', 'password', 'parola123',
      'qwerty123', '11111111', '00000000', 'sifre123', 'senbayrak',
      'admin123', '123456a', 'abcd1234', 'a1234567',
    };
    if (yasakli.contains(sifre.toLowerCase())) {
      return 'Bu parola çok yaygın, farklı bir parola seçin';
    }

    return null;
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

  /// Araç kartının alt satırında gösterilen özet: motor hacmi ve ilk özellik.
  ///
  /// Kart bu satırı eskiden `'${vehicle.engineSize} • ${vehicle.features.first}'`
  /// diye kuruyordu. Ekipman listesi BOŞ olan tek bir araç listeye girdiğinde
  /// `.first` "Bad state: No element" fırlatıyor ve araç listesinin tamamı
  /// çöküyordu — gerçek filo içe aktarıldığında tam olarak bu oldu.
  ///
  /// Mantık buraya taşındı çünkü kartın kendisi AuthService ve
  /// FirestoreService kullanıyor; widget testi Firebase başlatmayı
  /// gerektiriyordu. Burada saf bir fonksiyon olarak test edilebiliyor.
  ///
  /// Dolu olan parçalar birleştirilir; hiçbiri yoksa boş dize döner ve kart
  /// yine sorunsuz çizilir.
  ///
  /// En çok iki parça gösterilir. Motor hacmi boş olduğunda (içe aktarılan
  /// filoda öyle: kaynak veri gerçek motor hacmi değil, sahibinden'in arama
  /// filtresi aralığıydı ve BMW 520i ile Mitsubishi L200 için açıkça yanlıştı)
  /// yerini ikinci bir özellik alır; böylece satır tek kelimeye düşmez.
  static String aracOzetSatiri(String engineSize, List<String> features) {
    final parcalar = <String>[
      engineSize,
      ...features,
    ].where((parca) => parca.trim().isNotEmpty).take(2);

    return parcalar.join(' • ');
  }

  static double totalPrice(double dailyPrice, DateTime start, DateTime end) {
    final days = daysBetween(start, end);
    return dailyPrice * days;
  }

  // ── WhatsApp Launcher ─────────────────────────────────────
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