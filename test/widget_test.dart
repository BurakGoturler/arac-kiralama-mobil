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
