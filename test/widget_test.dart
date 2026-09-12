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

  group('Araç kartı özet satırı', () {
    // REGRESYON: Kart bu satırı `features.first` ile kuruyordu. Gerçek filo
    // içe aktarıldığında ekipman listesi boş olduğu için tek bir araç bile
    // "Bad state: No element" fırlatıp ARAÇ LİSTESİNİN TAMAMINI çökertti.
    test('ekipman listesi boşken çökmez, motor hacmini gösterir', () {
      expect(AppHelpers.aracOzetSatiri('1.4 - 1.6 L', const []),
          '1.4 - 1.6 L');
    });

    test('ekipman varsa motor hacmiyle birleştirir', () {
      expect(
        AppHelpers.aracOzetSatiri('1.4 - 1.6 L', const ['Otomatik vites', 'Dizel']),
        '1.4 - 1.6 L • Otomatik vites',
      );
    });

    test('motor hacmi boşsa iki ekipman gösterir', () {
      // İçe aktarılan filoda motor hacmi bilerek boş (kaynak veri ilan
      // sitesinin filtre aralığıydı ve yanlıştı). Satırın tek kelimeye
      // düşmemesi için yerini ikinci özellik alır.
      expect(
        AppHelpers.aracOzetSatiri('', const ['Otomatik vites', 'Benzin', '5 koltuk']),
        'Otomatik vites • Benzin',
      );
    });

    test('motor hacmi boş ve tek ekipman varsa onu gösterir', () {
      expect(AppHelpers.aracOzetSatiri('', const ['Manuel vites']),
          'Manuel vites');
    });

    test('rozetlerde zaten görünen özellikleri elemez', () {
      // Cihazda ölçüldü: eleme olmadan alt satır üstteki rozetlerin
      // birebir tekrarı oluyordu ("Manuel vites • Dizel").
      expect(
        AppHelpers.aracOzetSatiri(
          '',
          const ['Manuel vites', 'Dizel', '5 koltuk', 'Camlı Van', '2020 model'],
          zatenGosterilen: const {'Manuel', 'Dizel', '5 koltuk', '2020'},
        ),
        'Camlı Van',
      );
    });

    test('eleme sonrası hiçbir özellik kalmazsa boş döner', () {
      expect(
        AppHelpers.aracOzetSatiri('', const ['Manuel vites'],
            zatenGosterilen: const {'Manuel'}),
        '',
      );
    });

    test('en fazla iki parça gösterir', () {
      expect(
        AppHelpers.aracOzetSatiri('2.0 L', const ['Otomatik vites', 'Dizel', '5 koltuk']),
        '2.0 L • Otomatik vites',
      );
    });

    test('ikisi de boşsa boş dize döner', () {
      expect(AppHelpers.aracOzetSatiri('', const []), '');
    });

    test('yalnızca boşluktan oluşan değerleri yok sayar', () {
      expect(AppHelpers.aracOzetSatiri('   ', const ['  ']), '');
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

    // Firebase yurt dışı aktarımı, banka uyum incelemesinin en ağır
    // bulgusuydu (KVKK m.9). Kurul hiçbir ülke için yeterlilik kararı
    // ilan etmedi; verinin Belçika'da olması dayanak değildir. Firebase
    // sürekli hizmet olduğu için "arızi aktarım" istisnasına da girmez,
    // yani açık rıza da bir yol değildir. Geriye tek yol uygun güvence
    // (standart sözleşme / Kurul onaylı taahhütname) kalıyor.
    //
    // Bu test bilerek kırmızıdır: güvence kurulup tarihi yazılmadan
    // yayına çıkılırsa aydınlatma metni, hukuki dayanağı olmayan bir
    // aktarımı beyan etmiş olur.
    test('Firebase yurt dışı aktarımının hukuki dayanağı yazılmış olmalı', () {
      expect(
        SirketBilgileri.firebaseAktarimDayanagi.contains('['),
        isFalse,
        reason: 'Google Firebase için KVKK m.9 güvencesi henüz kurulmadı. '
            'Güvence seçilip (Kurul standart sözleşmesi ya da Kurul onaylı '
            'taahhütname) imzalandıktan ve 5 iş günü içinde Kurum\'a '
            'bildirildikten sonra SirketBilgileri.firebaseAktarimDayanagi '
            'alanına dayanağın adı ve tarihi yazılmalıdır.',
      );
    });

    test('yasal metinler boş değil', () {
      expect(LegalTexts.aydinlatmaMetni.trim().length, greaterThan(500));
      expect(LegalTexts.acikRizaMetni.trim().length, greaterThan(200));
      expect(LegalTexts.gizlilikMetni.trim().length, greaterThan(300));
      expect(LegalTexts.kullanimKosullariMetni.trim().length, greaterThan(500));
    });

    // Bankanın "hizmet şartına bağlanmış açık rıza" bulgusunun kod
    // tarafındaki karşılığı: metinler, WhatsApp'sız bir yolun VARLIĞINI
    // açıkça söylemek zorunda. Metin bu cümleyi kaybederse rıza yeniden
    // sakatlanır.
    test('açık rıza metni WhatsApp\'sız alternatifi duyurmalı', () {
      expect(LegalTexts.acikRizaMetni, contains('ZORUNLU DEĞİLDİR'));
      expect(LegalTexts.acikRizaMetni, contains('uygulama içinden'));
      expect(LegalTexts.aydinlatmaMetni, contains('ZORUNDA DEĞİLSİNİZ'));
    });

    // Bankanın usul hataları: toplama yöntemi (m.10/1-ç), amaç-hukuki
    // sebep eşleştirmesi (Tebliğ m.5/1-h), fiziki başvuru kanalı
    // (Başvuru Tebliği m.5) ve periyodik imha (İmha Yönetmeliği m.11).
    test('aydınlatma metni zorunlu usul başlıklarını içermeli', () {
      const metin = 'aydinlatmaMetni';
      final t = LegalTexts.aydinlatmaMetni;
      expect(t, contains('KİŞİSEL VERİLERİN TOPLANMA YÖNTEMİ'),
          reason: '$metin: KVKK m.10/1-ç toplama yöntemi bölümü eksik');
      expect(t, contains('HER AMACIN HUKUKİ SEBEBİ'),
          reason: '$metin: Tebliğ m.5/1-h amaç-hukuki sebep eşleştirmesi eksik');
      expect(t, contains('noter'),
          reason: '$metin: fiziki/yazılı başvuru kanalı sayılmamış');
      expect(t, contains('6 AYLIK PERİYOTLARLA'),
          reason: '$metin: periyodik imha süresi belirtilmemiş');
    });

    // KVKK m.11'de böyle bir hak yok; GDPR m.18'den sızmıştı.
    // Kanunda karşılığı olmayan bir hakkı taahhüt etmek, yerine
    // getirilemeyecek bir yükümlülük doğurur.
    test('kanunda olmayan "işlemenin sınırlandırılması" hakkı bulunmamalı', () {
      expect(LegalTexts.aydinlatmaMetni, isNot(contains('sınırlandırılmasını')));
    });
  });
}
