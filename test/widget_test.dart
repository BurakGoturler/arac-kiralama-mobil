import 'package:flutter_test/flutter_test.dart';

import 'package:car_rental_mvp/core/constants/app_constants.dart';
import 'package:car_rental_mvp/core/constants/kvkk_envanter.dart';
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

  group('WhatsApp rezervasyon mesajı', () {
    String mesaj(String tc) => AppConstants.whatsappMessageWithCustomer(
          vehicleName: 'Renault Clio',
          startDate: '1 Eki 2026',
          endDate: '3 Eki 2026',
          customerName: 'Ayşe',
          customerSurname: 'Yılmaz',
          customerTc: tc,
          customerPhone: '05321234567',
          pickupLocation: 'Merkez Şube',
        );

    // Aydınlatma metni: "bu alanı doldurursanız mesaja eklenir".
    test('T.C. Kimlik No boşsa mesajda hiç geçmez', () {
      expect(mesaj(''), isNot(contains('TC No')));
      expect(mesaj('   '), isNot(contains('TC No')));
    });

    test('T.C. Kimlik No yazıldıysa mesaja eklenir', () {
      expect(mesaj('10000000146'), contains('TC No: 10000000146\n'));
    });

    test('talep bilgilerini eksiksiz taşır', () {
      final m = mesaj('');
      for (final parca in ['Ayşe Yılmaz', '05321234567', 'Renault Clio',
          '1 Eki 2026 - 3 Eki 2026', 'Merkez Şube']) {
        expect(m, contains(parca));
      }
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
    // Tüm metinler — uygulama ekranlarındaki kısa bilgilendirmeler dâhil.
    List<String> tumMetinler() => [
          LegalTexts.aydinlatmaMetni,
          LegalTexts.gizlilikMetni,
          LegalTexts.kullanimKosullariMetni,
          LegalTexts.saklamaImhaPolitikasiMetni,
          LegalTexts.acikRizaMetni,
          ...LegalTexts.ekranMetinleri,
        ];

    // Şirket bilgileri doldurulmadan yayına çıkılmasını engeller. İki m.9
    // dayanağı ayrı testlerde, kendi gerekçeleriyle denetlenir.
    test('yasal metinlerdeki şirket bilgileri doldurulmuş olmalı', () {
      final eksik = SirketBilgileri.doldurulmamisAlanlar
          .where((a) => !a.endsWith('AktarimDayanagi'))
          .toList();
      expect(eksik, isEmpty,
          reason: 'lib/core/constants/legal_texts.dart içindeki köşeli '
              'parantezli yer tutucular yayından önce doldurulmalıdır: $eksik');
    });

    // Avukat analizinin en ağır bulgusu (KVKK m.9). Kurul hiçbir ülke
    // için yeterlilik kararı ilan etmedi; Firebase sürekli hizmet olduğu
    // için açık rıza da bir yol değil. Bilerek kırmızıdır.
    test('Firebase yurt dışı aktarımının hukuki dayanağı yazılmış olmalı', () {
      expect(SirketBilgileri.firebaseAktarimDayanagi.contains('['), isFalse,
          reason: 'Google Firebase için KVKK m.9 güvencesi henüz kurulmadı. '
              'Güvence imzalanıp 5 iş günü içinde Kurum\'a bildirildikten '
              'sonra SirketBilgileri.firebaseAktarimDayanagi alanına '
              'dayanağın adı ve tarihi yazılmalıdır.');
    });

    // 14.09.2026 — Kiralama yalnızca WhatsApp'tan yürüyor; bu aktarım rızaya
    // dayanamaz, standart sözleşmeye dayanır. Bildirim yapılmadan yayına
    // çıkılırsa metinler dayanağı olmayan bir aktarımı beyan eder. Bilerek
    // kırmızıdır.
    test('WhatsApp Business aktarımının hukuki dayanağı yazılmış olmalı', () {
      expect(SirketBilgileri.whatsappAktarimDayanagi.contains('['), isFalse,
          reason: 'WhatsApp hattının WhatsApp Business hesabı olduğu teyit '
              'edilip standart sözleşme (Veri Sorumlusundan Veri İşleyene) '
              'Kurum\'a bildirildikten sonra '
              'SirketBilgileri.whatsappAktarimDayanagi alanı doldurulmalıdır.');
    });

    test('yasal metinler boş değil', () {
      expect(LegalTexts.aydinlatmaMetni.trim().length, greaterThan(500));
      expect(LegalTexts.gizlilikMetni.trim().length, greaterThan(300));
      expect(LegalTexts.kullanimKosullariMetni.trim().length, greaterThan(500));
      expect(LegalTexts.saklamaImhaPolitikasiMetni.trim().length,
          greaterThan(1000));
      expect(LegalTexts.acikRizaMetni.trim().length, greaterThan(800));
    });

    // Şirket kararı: WhatsApp zorunlu kanal. Tek kanal rızaya bağlanırsa rıza
    // "hizmet şartı" olur ve geçersizdir (avukat analizi 02). Açık rıza
    // YALNIZCA isteğe bağlı kampanya iletişiminde kullanılır; üyelik,
    // rezervasyon ve kiralama hiçbir koşulda rızaya bağlanmamalı ve eski
    // "rıza vermezseniz rezervasyon gönderemezsiniz" kurgusu geri gelmemeli.
    test('açık rıza yalnızca isteğe bağlı kampanya iletişimine dayanmalı', () {
      final rizali = KvkkEnvanter.faaliyetler
          .where((f) => f.hukukiSebep.toLowerCase().contains('rıza'))
          .map((f) => f.surec)
          .toList();
      expect(rizali, ['Kampanya iletişimi']);
      for (final f in KvkkEnvanter.faaliyetler) {
        expect(f.acikRizayaDayali,
            f.hukukiSebep.toLowerCase().contains('rıza'),
            reason: f.surec);
      }
      expect(LegalTexts.aydinlatmaMetni, contains('AÇIK RIZAYA DAYANMAZ'));
      expect(LegalTexts.acikRizaMetni, contains('ZORUNLU DEĞİLDİR'));
      expect(LegalTexts.acikRizaMetni,
          contains('WhatsApp hattımız üzerinden araç kiralayabilirsiniz'));
      for (final m in tumMetinler()) {
        expect(m, isNot(contains('gönderemezsiniz')));
      }
    });

    // 6563 sayılı Kanun ve KVKK m.3/1-a: onay isteğe bağlı olmalı, geri alma
    // yolları ve İYS açıkça yazmalı; ekran metinleri de aynı şeyi söylemeli.
    // Kurul 18.02.2026 tarihli ve 2026/347 sayılı ilke kararı: aydınlatma
    // için onay/rıza istenmez, yalnızca okunduğu bildirilir; açık rıza metni
    // aydınlatmadan ayrı başlıkta ve ayrı beyanla düzenlenir.
    test('aydınlatma için onay istenmemeli, açık rıza ayrı beyan olmalı', () {
      expect(LegalTexts.acikRizaMetni,
          isNot(contains("Aydınlatma Metni'ni okuduğumu")));
      for (final m in tumMetinler()) {
        expect(m, isNot(contains('Aydınlatma Metni ve Kullanım Koşulları onay')));
        expect(m, isNot(contains("Aydınlatma Metni'ni onaylıyorum")));
      }
      expect(LegalTexts.acikRizaBaslik, isNot(LegalTexts.aydinlatmaBaslik));
    });

    test('kampanya onayı isteğe bağlı ve geri alınabilir anlatılmalı', () {
      expect(LegalTexts.kampanyaOnayAciklama, contains('İsteğe bağlıdır'));
      expect(LegalTexts.kampanyaProfilKapali, contains('etkilenmez'));
      for (final m in [
        LegalTexts.aydinlatmaMetni,
        LegalTexts.acikRizaMetni,
        LegalTexts.gizlilikMetni,
      ]) {
        expect(m, contains('İYS'));
        expect(m, contains('Profilim'));
        expect(m, contains('3 iş günü'));
      }
    });

    test('rezervasyonun yalnızca WhatsApp\'tan alındığı açıkça yazmalı', () {
      expect(LegalTexts.kullanimKosullariMetni,
          contains('YALNIZCA ${SirketBilgileri.whatsappHatti}'));
      expect(LegalTexts.gizlilikMetni, contains('YALNIZCA WhatsApp'));
      expect(LegalTexts.aydinlatmaMetni, contains('YALNIZCA Şirket\'in'));
      expect(LegalTexts.rezervasyonKanalBilgisi, contains('yalnızca WhatsApp'));
    });

    // Şirket kararı (14.09.2026): şubede adli sicil kaydı istenmiyor ve
    // hiçbir metinde geçmemeli.
    test('adli sicil kaydı hiçbir metinde geçmemeli', () {
      for (final m in tumMetinler()) {
        for (final ifade in ['Adli sicil', 'adli sicil', 'ADLİ SİCİL',
            'Adli Sicil', 'sabıka', 'Sabıka', 'ceza mahkûmiyeti']) {
          expect(m, isNot(contains(ifade)));
        }
      }
    });

    // Avukat analizindeki usul hataları: toplama yöntemi (m.10/1-ç), amaç-hukuki
    // sebep eşleştirmesi (Tebliğ m.5/1-h), fiziki başvuru kanalı
    // (Başvuru Tebliği m.5) ve periyodik imha (İmha Yönetmeliği m.11).
    test('aydınlatma metni zorunlu usul başlıklarını içermeli', () {
      final t = LegalTexts.aydinlatmaMetni;
      expect(t, contains('KİŞİSEL VERİLERİN TOPLANMA YÖNTEMİ'));
      expect(t, contains('HER AMACIN HUKUKİ SEBEBİ'));
      expect(t, contains('noter'));
      expect(t, contains('6 AYLIK PERİYOTLARLA'));
    });

    test('kanunda olmayan "işlemenin sınırlandırılması" hakkı bulunmamalı', () {
      for (final m in tumMetinler()) {
        expect(m, isNot(contains('sınırlandırılmasını')));
      }
    });

    // Avukat analizi bulgu 11: her faaliyetin hukuki sebebi ve saklama süresi
    // tanımlı olmalı, ve aydınlatma metni envanterle birebir eşleşmeli.
    test('her işleme faaliyetinin hukuki sebebi ve saklama süresi tanımlı', () {
      for (final f in KvkkEnvanter.faaliyetler) {
        expect(f.hukukiSebep, startsWith('KVKK m.'), reason: f.surec);
        expect(SaklamaSureleri.bul(f.saklamaKategorisi), isNotNull,
            reason: '${f.surec}: "${f.saklamaKategorisi}" saklama '
                'kategorisi tanımlı değil');
        expect(LegalTexts.aydinlatmaMetni, contains(f.amac), reason: f.surec);
        expect(LegalTexts.aydinlatmaMetni, contains(f.hukukiSebep),
            reason: f.surec);
      }
      for (final k in SaklamaSureleri.kategoriler) {
        expect(LegalTexts.saklamaImhaPolitikasiMetni, contains(k.kategori));
        expect(LegalTexts.saklamaImhaPolitikasiMetni, contains(k.sure));
      }
    });

    // İmha kodu ile metindeki süre aynı sabitten gelmeli; biri değişip
    // öbürü değişmezse metin gerçeği anlatmaz.
    test('imha kodundaki süreler metinlerdeki sürelerle aynı', () {
      expect(SaklamaSureleri.rezervasyonKaydiGun, 730);
      expect(SaklamaSureleri.bul(SaklamaSureleri.rezervasyonKaydi)!.sure,
          contains('2 yıl'));
      expect(SaklamaSureleri.periyodikImhaAy, lessThanOrEqualTo(6));
      expect(SaklamaSureleri.periyodikImhaGun,
          SaklamaSureleri.periyodikImhaAy * 30);
      expect(SaklamaSureleri.imhaKaydiYil, greaterThanOrEqualTo(3));
    });

    // Hesap silme açıklaması neyin silinmediğini de söylemeli; "tüm
    // verileriniz silinir" demek WhatsApp yazışmaları ve şube belgeleri
    // bakımından yanlış olurdu.
    test('hesap silme metinleri silinmeyen verileri açıkça söylemeli', () {
      expect(LegalTexts.hesapSilmeBilgisi, contains('WhatsApp yazışmalarınız'));
      expect(LegalTexts.aydinlatmaMetni, contains('Hesabımı Sil'));
      expect(LegalTexts.gizlilikMetni, contains('bu işlemle silinmez'));
    });
  });
}
