import 'package:flutter_test/flutter_test.dart';

import 'package:car_rental_mvp/core/constants/legal_texts.dart';
import 'package:car_rental_mvp/core/utils/helpers.dart';

void main() {
  group('T.C. Kimlik No doğrulama', () {
    test('geçerli numaraları kabul eder', () {
      // Algoritmaya uygun, gerçek kişilere ait olmayan örnek numaralar.
      expect(AppHelpers.isValidTcNo('10000000146'), isTrue);
      expect(AppHelpers.isValidTcNo('19191919190'), isTrue);
    });

    test('sıfırla başlayan numarayı reddeder', () {
      expect(AppHelpers.isValidTcNo('01234567890'), isFalse);
    });

    test('hatalı uzunluğu reddeder', () {
      expect(AppHelpers.isValidTcNo('123456789'), isFalse);
      expect(AppHelpers.isValidTcNo('123456789012'), isFalse);
      expect(AppHelpers.isValidTcNo(''), isFalse);
    });

    test('rakam olmayan karakterleri reddeder', () {
      expect(AppHelpers.isValidTcNo('1234567890a'), isFalse);
      expect(AppHelpers.isValidTcNo('12345 67890'), isFalse);
    });

    test('sağlama hanesi tutmayan numarayı reddeder', () {
      // Son hanesi bilinçli olarak bozulmuş geçerli bir numara.
      expect(AppHelpers.isValidTcNo('10000000147'), isFalse);
    });

    test('baştaki ve sondaki boşlukları yok sayar', () {
      expect(AppHelpers.isValidTcNo('  10000000146  '), isTrue);
    });
  });

  group('Tarih ve fiyat yardımcıları', () {
    test('daysBetween iki tarih arasındaki gün sayısını verir', () {
      final baslangic = DateTime(2026, 7, 1);
      final bitis = DateTime(2026, 7, 5);
      expect(AppHelpers.daysBetween(baslangic, bitis), 4);
    });

    test('totalPrice gün sayısıyla çarpar', () {
      final baslangic = DateTime(2026, 7, 1);
      final bitis = DateTime(2026, 7, 4);
      expect(AppHelpers.totalPrice(1500, baslangic, bitis), 4500);
    });
  });

  group('Sayı çözümleme (yönetici formları)', () {
    // Bu testler gerçek bir hatayı kilitler: fiyat alanı eskiden
    // double.parse ile okunuyordu. Yönetici Türkçe biçimde "1.500" yazdığında
    // sonuç sessizce 1.5 oluyor, "1500,00" yazdığında ise FormatException
    // fırlatıp kaydı düşürüyordu.

    test('düz tam sayıyı okur', () {
      expect(AppHelpers.sayiCoz('1500'), 1500);
    });

    test('Türkçe binlik ayracını ondalık sanmaz', () {
      expect(AppHelpers.sayiCoz('1.500'), 1500);
      expect(AppHelpers.sayiCoz('12.500'), 12500);
      expect(AppHelpers.sayiCoz('1.234.500'), 1234500);
    });

    test('Türkçe ondalık virgülünü çözer', () {
      expect(AppHelpers.sayiCoz('1500,50'), 1500.5);
      expect(AppHelpers.sayiCoz('1.500,50'), 1500.5);
    });

    test('İngilizce biçimi de çözer', () {
      expect(AppHelpers.sayiCoz('1,500.50'), 1500.5);
      expect(AppHelpers.sayiCoz('1500.5'), 1500.5);
    });

    test('boşluk ve para birimi simgesini yok sayar', () {
      expect(AppHelpers.sayiCoz(' 1.500 ₺ '), 1500);
    });

    test('çözülemeyen girdide istisna fırlatmaz, null döner', () {
      expect(AppHelpers.sayiCoz(''), isNull);
      expect(AppHelpers.sayiCoz('   '), isNull);
      expect(AppHelpers.sayiCoz(null), isNull);
      expect(AppHelpers.sayiCoz('abc'), isNull);
    });

    test('tamSayiCoz en yakın tam sayıya yuvarlar', () {
      expect(AppHelpers.tamSayiCoz('5'), 5);
      expect(AppHelpers.tamSayiCoz('2024'), 2024);
      expect(AppHelpers.tamSayiCoz('4,6'), 5);
      expect(AppHelpers.tamSayiCoz('abc'), isNull);
    });
  });

  group('Parola politikası', () {
    // Firebase'in kendi alt sınırı 6 karakterdir ve karmaşıklık aramaz.
    // Bu testler, uygulamanın daha sıkı olan kendi kuralını kilitler.

    test('politikaya uyan parolayı kabul eder', () {
      expect(AppHelpers.sifreKontrol('Deneme123'), isNull);
      expect(AppHelpers.sifreKontrol('a1b2c3d4'), isNull);
    });

    test('8 karakterden kısa parolayı reddeder', () {
      expect(AppHelpers.sifreKontrol('abc123'), isNotNull);
      expect(AppHelpers.sifreKontrol('Ab1'), isNotNull);
    });

    test('rakamsız parolayı reddeder', () {
      expect(AppHelpers.sifreKontrol('abcdefgh'), isNotNull);
    });

    test('harfsiz parolayı reddeder', () {
      expect(AppHelpers.sifreKontrol('12345678'), isNotNull);
    });

    test('boş parolayı reddeder', () {
      expect(AppHelpers.sifreKontrol(''), isNotNull);
      expect(AppHelpers.sifreKontrol(null), isNotNull);
    });

    test('yaygın parolaları reddeder', () {
      expect(AppHelpers.sifreKontrol('password'), isNotNull);
      expect(AppHelpers.sifreKontrol('Parola123'), isNotNull);
      expect(AppHelpers.sifreKontrol('senbayrak'), isNotNull);
    });

    test('Türkçe karakterli parolayı harf sayar', () {
      expect(AppHelpers.sifreKontrol('şğüöç123'), isNull);
    });
  });

  group('KVKK yayın öncesi kontrolü', () {
    // Bu test, şirket bilgileri doldurulmadan yayına çıkılmasını engeller.
    // Yer tutucular tamamlandığında kendiliğinden geçer.
    test('yasal metinlerdeki şirket bilgileri doldurulmuş olmalı', () {
      expect(
        SirketBilgileri.eksikBilgiVar,
        isFalse,
        reason: 'lib/core/constants/legal_texts.dart içindeki köşeli '
            'parantezli yer tutucular yayından önce doldurulmalıdır. '
            'Aksi hâlde kullanıcılar "[ŞİRKET TİCARET UNVANI]" gibi '
            'ifadeler görür ve metinler KVKK açısından geçersiz olur.',
      );
    });

    test('yasal metinler boş değil', () {
      expect(LegalTexts.aydinlatmaMetni.trim().length, greaterThan(500));
      expect(LegalTexts.acikRizaMetni.trim().length, greaterThan(200));
      expect(LegalTexts.gizlilikMetni.trim().length, greaterThan(300));
      expect(LegalTexts.kullanimKosullariMetni.trim().length, greaterThan(500));
    });
  });
}
