// ═══════════════════════════════════════════════════════════════════
//  KVKK ve mağaza yükümlülükleri kapsamındaki yasal metinler.
//
//  TEK KAYNAK. Uygulama içi metinler, web sitesine yüklenen sayfalar ve
//  paylaşılan PDF'ler bu dosyadan üretilir:
//
//      dart run tools/metinleri_disa_aktar.dart
//      python tools/belge_uret.py
//
//  Metin elle başka bir yere kopyalanmamalıdır; iki kopya zamanla ayrışır.
//
//  ⚠️  YAYINDAN ÖNCE YAPILMASI ZORUNLU:
//      1. SirketBilgileri'ndeki köşeli parantezli alanların tamamı
//         doldurulmalı (test ile denetlenir).
//      2. Metinler hukuk danışmanına onaylatılmalı. Buradaki içerik teknik
//         bir çalışmadır, hukuki görüş değildir.
// ═══════════════════════════════════════════════════════════════════

import 'kvkk_envanter.dart';

class SirketBilgileri {
  /// Ticaret sicilindeki tam unvan
  static const String unvan =
      'Şenbayrak Otomotiv Petrol Ürünleri San. ve Tic. Ltd. Şti.';

  /// Tebligata elverişli açık adres
  static const String adres =
      'Sakarya Mah. T. Cemal Beriker Blv. No:184 Seyhan / ADANA';

  /// Bağlı olunan vergi dairesi
  static const String vergiDairesi = 'Seyhan V.D.';

  /// Vergi kimlik numarası
  static const String vkn = '803 005 8868';

  /// KVKK başvurularının iletileceği e-posta.
  ///
  /// DİKKAT: Buraya bir YÖNETİCİ HESABININ e-postası yazılmamalıdır. Bu adres
  /// yasal metinlerde ve web sitesinde herkese açık yayımlanır.
  static const String kvkkEposta = 'info@senbayrak.com.tr';

  /// Tebligata esas iletişim telefonu (Merkez Şube).
  static const String telefon = '0 (322) 435 56 36';

  /// VERBİS (Veri Sorumluları Sicili) kayıt durumu.
  ///
  /// Kurul'un istisna kararı: yıllık çalışan sayısı 50'den az VE yıllık mali
  /// bilanço toplamı 100 milyon TL'den az olan, ana faaliyeti özel nitelikli
  /// kişisel veri işlemek olmayan veri sorumluları Sicile kayıtla yükümlü
  /// değildir. Eşikler her yıl yeniden kontrol edilmelidir.
  ///
  /// DİKKAT: Muafiyet YALNIZCA Sicile kayıt yükümlülüğünü kaldırır.
  /// Aydınlatma, veri güvenliği, envanter ve saklama-imha politikası
  /// yükümlülükleri aynen sürer.
  static const String verbis =
      'Kayıt yükümlülüğü bulunmamaktadır. Şirket, yıllık çalışan sayısı '
      "50'den az ve yıllık mali bilanço toplamı 100 milyon TL'den az "
      'olduğundan, Kişisel Verileri Koruma Kurulu kararları uyarınca Veri '
      'Sorumluları Siciline kayıt yükümlülüğünden istisna tutulmuştur.';

  /// KEP (Kayıtlı Elektronik Posta) adresi. Başvuru metnine gömülü kullanılır;
  /// buraya adres dışında bir ifade yazılmamalıdır.
  static const String kep = 'senbayrakpetrol@hs03.kep.tr';

  /// Uyuşmazlıklarda yetkili mahkeme ve icra daireleri.
  static const String yetkiliMahkeme = 'Adana';

  /// Rezervasyon taleplerinin alındığı WhatsApp Business hattı (görünen biçim).
  /// Numaranın kendisi AppConstants.whatsappPhone'dadır; ikisi aynı hattı
  /// göstermelidir.
  static const String whatsappHatti = '0 (532) 385 34 02';

  /// Gizlilik politikasının yayınlandığı herkese açık adres.
  /// Google Play ve App Store bunu şart koşar.
  static const String gizlilikUrl =
      'https://senbayrak.com.tr/gizlilik-politikasi.php';

  /// Aydınlatma metninin yayınlandığı herkese açık adres.
  static const String aydinlatmaUrl =
      'https://senbayrak.com.tr/kvkk-aydinlatma-metni.php';

  /// Google Firebase (yurt dışı) aktarımının KVKK m.9 dayanağı.
  ///
  /// Kurul bugüne kadar HİÇBİR ülke için yeterlilik kararı ilan etmedi;
  /// verinin Belçika'da (AB) durması tek başına dayanak DEĞİLDİR. Firebase
  /// sürekli bir altyapı hizmeti olduğu için m.9/6 "arızi aktarım"
  /// istisnasına girmez; açık rıza bu aktarım için geçerli bir yol değildir.
  ///
  /// Doldurulduğunda seçilen güvencenin adı ve tarihleri yazılır, örn:
  /// 'Kurul'un ilan ettiği standart sözleşme (Veri Sorumlusundan Veri
  /// İşleyene) — imza 01.10.2026, Kurum bildirimi 06.10.2026'.
  static const String firebaseAktarimDayanagi =
      '[DOLDURULACAK — Firebase için seçilen KVKK m.9 güvencesi ve tarihi]';

  /// WhatsApp Business (Meta) aktarımının KVKK m.9 dayanağı.
  ///
  /// 14.09.2026 — Şirket kararı: araç kiralama talepleri YALNIZCA WhatsApp
  /// üzerinden alınır. Bu durumda WhatsApp aktarımı AÇIK RIZAYA DAYANAMAZ:
  /// tek kanal olan bir hizmet rızaya bağlanırsa rıza "hizmet şartı" hâline
  /// gelir ve geçersiz sayılır (avukat KVKK analizi 02 numaralı bulgu;
  /// KVKK m.3/1-a, m.4/2-a, m.4/2-ç). Ayrıca 7499 sonrası m.9/6-a'daki rıza
  /// yalnızca arızi aktarımlar içindir; sürekli rezervasyon kanalı arızi değildir.
  ///
  /// Dayanılacak güvence: WhatsApp Business Veri Aktarım Eki (Data Transfer
  /// Addendum, son güncelleme 22.08.2025) Türkiye bölümü, Kurul'un 04.06.2024
  /// tarihli ve 2024/959 sayılı kararıyla ilan edilen standart sözleşmelerden
  /// "Veri Sorumlusundan Veri İşleyene" modülünü uygular; Şirket veri
  /// sorumlusu/aktaran, WhatsApp veri işleyen/alıcıdır. Ek, WhatsApp Business
  /// Koşulları'nın kabulünü sözleşmenin akdi sayar.
  ///
  /// Doldurmadan önce:
  ///   1. ✓ 14.09.2026 — 0532 385 34 02 hattının WhatsApp BUSINESS hesabı
  ///      olduğu şirket tarafından teyit edildi (kişisel hesapta bu ek
  ///      uygulanmaz; hat değişirse yeniden teyit edilmeli).
  ///   2. Avukat, Koşulların kabulüyle akdedilen standart sözleşmenin
  ///      yönetmelikteki imza şartını karşıladığını teyit etmeli.
  ///   3. Standart sözleşme 5 iş günü içinde Kurum'a bildirilmeli
  ///      (bildirimi aktaran taraf olarak Şirket yapar).
  /// Örnek değer: 'Kurul'un ilan ettiği standart sözleşme (Veri
  /// Sorumlusundan Veri İşleyene), WhatsApp Business Veri Aktarım Eki
  /// kapsamında — Kurum bildirimi 18.09.2026'.
  static const String whatsappAktarimDayanagi =
      '[DOLDURULACAK — WhatsApp Business için standart sözleşme bildirimi ve tarihi]';

  /// Metinlerin son güncellenme tarihi. Onay kayıtlarında metin sürümü olarak
  /// da saklanır.
  static const String sonGuncelleme = '14.09.2026';

  /// Yer tutucuların doldurulup doldurulmadığını anlamak için.
  static bool get eksikBilgiVar => doldurulmamisAlanlar.isNotEmpty;

  /// Doldurulmamış alanların adları — belge üretim betiği ve testler kullanır.
  static List<String> get doldurulmamisAlanlar => [
        for (final e in {
          'unvan': unvan,
          'adres': adres,
          'vergiDairesi': vergiDairesi,
          'vkn': vkn,
          'kvkkEposta': kvkkEposta,
          'telefon': telefon,
          'verbis': verbis,
          'kep': kep,
          'yetkiliMahkeme': yetkiliMahkeme,
          'whatsappHatti': whatsappHatti,
          'gizlilikUrl': gizlilikUrl,
          'aydinlatmaUrl': aydinlatmaUrl,
          'firebaseAktarimDayanagi': firebaseAktarimDayanagi,
          'whatsappAktarimDayanagi': whatsappAktarimDayanagi,
        }.entries)
          if (e.value.contains('[')) e.key,
      ];
}

class LegalTexts {
  // ── Uygulama içindeki kısa bilgilendirmeler ─────────────────────
  // Ekranlarda gösterilen cümleler de burada durur ki metinlerle çelişen
  // bir ifade (ör. eski "rıza vermezseniz rezervasyon gönderemezsiniz")
  // bir ekranda unutulup kalmasın; testler bunları da tarar.

  static const String rezervasyonKanalBilgisi =
      'Rezervasyon talepleri yalnızca WhatsApp hattımız üzerinden alınır. '
      'Düğmeye bastığınızda bilgilerinizle hazırlanmış mesaj WhatsApp\'ta '
      'açılır; mesajı siz gönderirsiniz.';

  static const String tcAlaniBilgisi =
      'Kimlik numaranız uygulamaya HİÇBİR ŞEKİLDE KAYDEDİLMEZ. Yazarsanız '
      'yalnızca sözleşmenizin önceden hazırlanabilmesi için WhatsApp mesajına '
      'eklenir. Şubede zaten kimliğinizle teyit edilecektir.';

  static const String hesapSilmeBilgisi =
      'Hesabınızı sildiğinizde uygulamadaki kişisel verileriniz ve rezervasyon '
      'talep kayıtlarınız kalıcı olarak silinir; bu işlem geri alınamaz. '
      'WhatsApp yazışmalarınız ve şubede alınan belgeler bu işlemle silinmez.';

  // Kampanya iletişimi onayı — uygulamadaki TEK açık rıza ve isteğe bağlı.
  // Kiralama WhatsApp'tan yürüdüğü ve rızaya dayanmadığı için bu onayın
  // verilmemesi hiçbir işlevi kısıtlamamalıdır; cümleler bunu açıkça söyler.
  static const String kampanyaOnayMetni =
      'Kampanya ve fırsatlardan SMS ve WhatsApp ile haberdar olmak istiyorum. '
      'Bu amaçla ad, soyad ve telefon numaramın işlenmesine açık rıza, ticari '
      'elektronik ileti gönderilmesine onay veriyorum.';

  static const String kampanyaOnayAciklama =
      'İsteğe bağlıdır. Onay vermeseniz de uygulamayı ve araç kiralamayı '
      'eksiksiz kullanırsınız. Onayınızı Profilim bölümünden dilediğiniz zaman '
      'geri alabilirsiniz.';

  static const String kampanyaProfilAcik =
      'Onay verdiniz. Kapatırsanız kampanya iletisi gönderilmez; uygulama ve '
      'araç kiralama etkilenmez.';

  static const String kampanyaProfilKapali =
      'Onay vermediniz. Uygulama ve araç kiralama bundan etkilenmez.';

  static List<String> get ekranMetinleri => [
        rezervasyonKanalBilgisi,
        tcAlaniBilgisi,
        hesapSilmeBilgisi,
        kampanyaOnayMetni,
        kampanyaOnayAciklama,
        kampanyaProfilAcik,
        kampanyaProfilKapali,
      ];

  // ── Envanterden türetilen bölümler ──────────────────────────────

  static String get _amacVeHukukiSebepler => KvkkEnvanter.faaliyetler
      .map((f) => '• ${f.amac} (${f.veriler})\n  → ${f.hukukiSebep}')
      .join('\n\n');

  static String get _saklamaSureleri => SaklamaSureleri.kategoriler
      .where((k) => k.kategori != SaklamaSureleri.imhaKaydi)
      .map((k) => '• ${k.kategori}: ${k.sure}')
      .join('\n');

  // ── AYDINLATMA METNİ (KVKK m.10) ───────────────────────────────
  static const String aydinlatmaBaslik =
      'Kişisel Verilerin Korunması Hakkında Aydınlatma Metni';

  static String get aydinlatmaMetni => '''
Son güncelleme: ${SirketBilgileri.sonGuncelleme}

1. VERİ SORUMLUSU

6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") uyarınca kişisel verileriniz, veri sorumlusu sıfatıyla ${SirketBilgileri.unvan} ("Şirket") tarafından aşağıda açıklanan kapsamda işlenmektedir.

Adres: ${SirketBilgileri.adres}
Vergi Dairesi / VKN: ${SirketBilgileri.vergiDairesi} — ${SirketBilgileri.vkn}
E-posta: ${SirketBilgileri.kvkkEposta}
KEP: ${SirketBilgileri.kep}
Telefon: ${SirketBilgileri.telefon}
VERBİS: ${SirketBilgileri.verbis}

2. İŞLENEN KİŞİSEL VERİLER

Uygulama üzerinden aşağıdaki kişisel verileriniz işlenmektedir:

• Kimlik bilgisi: Ad, soyad
• İletişim bilgisi: Cep telefonu numarası, e-posta adresi
• Müşteri işlem bilgisi: Seçtiğiniz araç, kiralama tarihleri, alım yeri, WhatsApp hattımıza yönlendirilen rezervasyon talep kayıtlarınız ve talep tarihi, favori araç listeniz
• Hukuki işlem bilgisi: Kullanım Koşulları'nı kabul beyanınız, Aydınlatma Metni'ni okuduğunuza ilişkin geri bildiriminiz, bunların tarihi ve metin sürümü
• Pazarlama bilgisi: Vermeniz hâlinde kampanya iletişimi onayınız, onay ve geri alma tarihleri, onayladığınız metin sürümü
• Kimlik doğrulama bilgisi: Hesap şifreniz (şifreniz Şirket tarafından görülemez; Firebase Authentication altyapısında geri döndürülemez biçimde saklanır), e-posta doğrulama durumu
• İşlem güvenliği bilgisi: Oturum ve cihaz doğrulama kayıtları (Firebase Authentication ve App Check tarafından üretilir)

Rezervasyon talebinizi WhatsApp hattımıza gönderdiğinizde ayrıca yazışma içeriği ile WhatsApp profil adınız ve telefon numaranız işlenir.

T.C. KİMLİK NUMARASI uygulama veritabanında SAKLANMAZ. Rezervasyon ekranında bu alanı doldurursanız, yalnızca kiralama sözleşmesinin önceden hazırlanabilmesi amacıyla WhatsApp mesajına eklenir. Bu alanı doldurmak ZORUNLU DEĞİLDİR; kimliğiniz şubede belge ibrazıyla teyit edilir.

ÖDEME BİLGİSİ TOPLANMAZ. Uygulama; kart numarası, son kullanma tarihi, CVV, banka hesabı veya IBAN bilgisi toplamaz, işlemez ve saklamaz. Ödeme, teyit sürecinde tarafınıza iletilecek banka ödeme bağlantısı üzerinden, ilgili bankanın kendi güvenli sayfasında gerçekleşir.

KONUM VERİSİ, REKLAM KİMLİĞİ VE ÇEREZ KULLANILMAZ. Uygulama cihaz konumunuza erişmez, reklam kimliği okumaz ve profilleme amacıyla çerez veya benzeri izleyici teknolojiler kullanmaz.

2/A. ŞUBE AŞAMASINDA İŞLENEN VERİLER

Aşağıdaki veriler UYGULAMA ÜZERİNDEN TOPLANMAZ ve uygulama veritabanında saklanmaz. Bunlar yalnızca rezervasyon talebiniz teyit edildikten sonra, araç tesliminde şube süreçleri kapsamında; kiralama sözleşmesinin kurulması ve ifası ile mevzuattan doğan yükümlülüklerin yerine getirilmesi amacıyla işlenir:

• Kimlik belgesi bilgileri (T.C. Kimlik Numarası dâhil)
• Sürücü belgesi bilgileri
• Yerleşim yeri (ikametgâh) belgesi
• Findeks / Kredi Kayıt Bürosu sorgu sonucu
• Kiralama sözleşmesi ve fatura bilgileri

3. KİŞİSEL VERİLERİN TOPLANMA YÖNTEMİ

Kişisel verileriniz KVKK m.10/1-ç ve Aydınlatma Yükümlülüğünün Yerine Getirilmesinde Uyulacak Usul ve Esaslar Hakkında Tebliğ m.5/1-ç uyarınca aşağıdaki yöntemlerle toplanmaktadır:

• Tamamen otomatik yollarla: Mobil uygulamadaki üyelik formu, giriş ve şifre işlemleri, rezervasyon ekranı ve favori işaretleme özelliği aracılığıyla, siz doğrudan girdiğiniz anda elektronik ortamda.
• Kısmen otomatik yollarla: Rezervasyon talebinizi ve sonrasındaki teyit yazışmalarını WhatsApp hattımıza gönderdiğiniz mesajlar aracılığıyla. Kampanya kartlarındaki düğmeyle WhatsApp hattımıza yazmanız hâlinde de bu yöntem geçerlidir.
• Otomatik olmayan yollarla: Araç tesliminde şubede fiziki belge ibrazı, kiralama sözleşmesinin imzalanması ve sözlü ya da telefonla iletişim yoluyla (2/A maddesindeki veriler).
• Üçüncü kaynaklardan: Kredi Kayıt Bürosu / Findeks sorgusu yoluyla, yalnızca şube aşamasında ve risk değerlendirmesi amacıyla.

Uygulama; çerez, piksel, reklam kimliği veya benzeri izleyici teknolojilerle veri toplamaz.

4. İŞLEME AMAÇLARI VE HER AMACIN HUKUKİ SEBEBİ

Aydınlatma Tebliği m.5/1-h uyarınca, işleme amaçları ile hukuki sebepler aşağıda tek tek eşleştirilmiştir. Yalnızca kampanya ve fırsat iletişimi açık rızanıza dayanır; bu faaliyet isteğe bağlıdır ve onay vermemeniz uygulamanın ve araç kiralamanın hiçbir aşamasını etkilemez.

$_amacVeHukukiSebepler

5. AKTARIM

5.1 Yurt içi aktarımlar

Rezervasyon talebiniz teyit edilip kiralama süreci başladığında, verileriniz KVKK m.8'de belirtilen şartlara uygun olarak aşağıdaki taraflara aktarılabilir:

• Ödeme kuruluşu / banka — yalnızca ödeme işleminin gerçekleştirilmesi amacıyla
• Emniyet Genel Müdürlüğü — KABİS kapsamında kiralama işleminin bildirilmesi amacıyla (hukuki yükümlülük)
• Kredi Kayıt Bürosu / Findeks — kiralama öncesi risk değerlendirmesi amacıyla
• Sigorta şirketleri — poliçe düzenlenmesi ve hasar süreçlerinin yürütülmesi amacıyla
• Ekspertiz ve servis firmaları — araç durum tespiti ve bakım-onarım amacıyla
• Yetkili trafik muayene istasyonları — mevzuat gereği muayene süreçlerinin takibi amacıyla
• Yetkili kamu kurum ve kuruluşları, mahkemeler ve icra daireleri — yasal yükümlülüklerin yerine getirilmesi amacıyla
• Avukat, mali müşavir ve bağımsız denetim hizmeti alınan taraflar — hukuki ve mali yükümlülüklerin yerine getirilmesi amacıyla

Bu aktarımların tamamı uygulama üzerinden DEĞİL, kiralama sözleşmesi aşamasında şube süreçleri kapsamında gerçekleşir.

Kampanya iletişimine onay vermeniz hâlinde ayrıca:

• İleti Yönetim Sistemi A.Ş. (İYS) — ticari elektronik ileti onay ve ret kayıtlarınızın 6563 sayılı Kanun uyarınca kaydedilmesi amacıyla (hukuki yükümlülük, KVKK m.5/2-ç)
• SMS hizmet sağlayıcısı — kampanya SMS'lerinin gönderilmesi amacıyla, veri işleyen sıfatıyla

5.2 Yurt dışı aktarımlar (KVKK m.9)

Google Firebase: Uygulamanın teknik altyapısı Google tarafından sunulan Firebase hizmetleri (Firestore veritabanı, Authentication, App Check) üzerinde çalışmaktadır; Google bu hizmetleri veri işleyen sıfatıyla sunar. Veritabanı sunucuları Avrupa Birliği sınırları içinde (Belçika — europe-west1 bölgesi) konumlandırılmıştır. Sunucuların Avrupa Birliği'nde bulunması KVKK bakımından TEK BAŞINA bir hukuki dayanak oluşturmaz; Kişisel Verileri Koruma Kurulu bugüne kadar hiçbir ülke için yeterlilik kararı ilan etmemiştir. Bu nedenle söz konusu barındırma KVKK m.9 kapsamında yurt dışına veri aktarımı sayılır ve aşağıdaki güvenceye dayanılarak yapılmaktadır:

${SirketBilgileri.firebaseAktarimDayanagi}

WhatsApp Business: Rezervasyon talepleri ve teyit yazışmaları YALNIZCA Şirket'in ${SirketBilgileri.whatsappHatti} numaralı WhatsApp Business hattı üzerinden yürütülür. WhatsApp bu hizmeti Şirket'e veri işleyen sıfatıyla sunar; sunucuları yurt dışında bulunduğundan yazışmalarınızdaki kişisel veriler KVKK m.9 kapsamında yurt dışına aktarılır. Bu aktarım AÇIK RIZAYA DAYANMAZ; aşağıdaki uygun güvenceye dayanılarak yapılmaktadır:

${SirketBilgileri.whatsappAktarimDayanagi}

Uygulama WhatsApp mesajını sizin adınıza göndermez. Rezervasyon ekranındaki bilgilerle hazırlanan mesaj WhatsApp uygulamanızda açılır; göndermeden önce içeriğini görebilir, değiştirebilir veya göndermekten vazgeçebilirsiniz. WhatsApp uygulamasını kullanmanız, WhatsApp ile aranızdaki kullanım koşullarına da tabidir.

Kampanya iletişimine onay vermeniz hâlinde size gönderilecek WhatsApp kampanya mesajları da aynı hat üzerinden iletilir; bu mesajların gönderilmesi açık rızanıza, yurt dışına aktarımı ise yukarıdaki güvenceye dayanır.

6. SAKLAMA VE İMHA

Kişisel verileriniz, işlendikleri amaç için gerekli olan süre boyunca ve ilgili mevzuatta öngörülen sürelerden az olmamak üzere aşağıdaki sürelerle saklanır:

$_saklamaSureleri

Hesabınızı uygulama içinden Profilim > Hesabımı Sil adımıyla sildiğinizde, uygulamadaki üyelik verileriniz, onay kayıtlarınız, favori listeniz ve rezervasyon talep kayıtlarınız derhal ve kalıcı olarak silinir.

Hesap silme; WhatsApp hattımızdaki yazışmaları ve şube aşamasında alınan belgeleri kendiliğinden silmez. Bu veriler yukarıdaki süreler sonunda imha edilir; daha önce silinmelerini 9. maddedeki kanallardan başvurarak talep edebilirsiniz.

Kampanya iletişimi onayınız varsa, hesabınızı silmeniz onayınızın geri alınması sayılır ve İYS'de ret olarak işlenir. İYS'deki onay ve ret kayıtları, ilgili mevzuatın öngördüğü süre boyunca İYS'de tutulur.

Saklama süresi dolan veriler, Kişisel Verilerin Silinmesi, Yok Edilmesi veya Anonim Hale Getirilmesi Hakkında Yönetmelik m.11 uyarınca EN GEÇ ${SaklamaSureleri.periyodikImhaAy} AYLIK PERİYOTLARLA yürütülen periyodik imha işlemiyle silinir veya yok edilir. Her imha işlemi kayıt altına alınır ve bu kayıtlar en az ${SaklamaSureleri.imhaKaydiYil} yıl saklanır. Ayrıntılar Şirket'in Kişisel Veri Saklama ve İmha Politikası'nda yer alır.

7. KAMPANYA İLETİŞİMİ VE TİCARİ ELEKTRONİK İLETİ

ONAYINIZ OLMADAN tarafınıza ticari elektronik ileti (SMS, WhatsApp mesajı, e-posta, telefonla arama veya anlık bildirim) GÖNDERİLMEZ. Uygulamada görünen kampanyalar herkese aynı şekilde gösterilir; bunun için kişisel veri işlenmez.

Üyelik sırasında veya daha sonra Profilim bölümünden, ayrıca ve isteğe bağlı olarak onay verirseniz, Şirket'in araç kiralama kampanyaları, indirimleri ve fırsatları hakkında SMS ve WhatsApp ile ticari elektronik ileti gönderilir. Bu onay hem KVKK m.5/1 kapsamında açık rıza hem de 6563 sayılı Elektronik Ticaretin Düzenlenmesi Hakkında Kanun m.6 kapsamında ticari elektronik ileti onayıdır; kapsamı Açık Rıza Metni'nde açıklanmıştır ve İleti Yönetim Sistemi'ne (İYS) kaydedilir. Kampanya iletileri için profilleme yapılmaz.

ONAY VERMEK ZORUNLU DEĞİLDİR. Onay vermemeniz veya onayınızı geri almanız uygulamanın ve araç kiralamanın hiçbir aşamasını etkilemez.

Onayınızı dilediğiniz zaman, gerekçe göstermeden ve ücretsiz olarak Profilim bölümünden, size gönderilen her iletideki ret yolundan veya İYS üzerinden geri alabilirsiniz. Ret bildiriminiz en geç 3 iş günü içinde işleme alınır.

Hesap doğrulama ve şifre sıfırlama e-postaları ile rezervasyon talebinize verilen yanıtlar ticari elektronik ileti değildir; yalnızca sizin işleminiz veya talebiniz üzerine gönderilir.

8. HAKLARINIZ (KVKK m.11)

Kişisel verilerinizle ilgili olarak Şirket'e başvurarak şu haklara sahipsiniz:

a) Kişisel verilerinizin işlenip işlenmediğini öğrenme,
b) İşlenmişse buna ilişkin bilgi talep etme,
c) İşlenme amacını ve amacına uygun kullanılıp kullanılmadığını öğrenme,
ç) Yurt içinde veya yurt dışında aktarıldığı üçüncü kişileri bilme,
d) Eksik veya yanlış işlenmiş olması hâlinde düzeltilmesini isteme,
e) KVKK m.7 çerçevesinde silinmesini veya yok edilmesini isteme,
f) (d) ve (e) bentleri uyarınca yapılan işlemlerin, kişisel verilerin aktarıldığı üçüncü kişilere bildirilmesini isteme,
g) Münhasıran otomatik sistemler vasıtasıyla analiz edilmesi suretiyle aleyhinize bir sonucun ortaya çıkmasına itiraz etme,
ğ) Kanuna aykırı olarak işlenmesi sebebiyle zarara uğramanız hâlinde zararın giderilmesini talep etme.

Silme hakkınızı uygulama içinden Profilim > Hesabımı Sil adımıyla doğrudan kullanabilirsiniz. Kampanya iletişimi onayınızı da Profilim bölümünden tek dokunuşla geri alabilirsiniz.

9. VERİ SORUMLUSUNA BAŞVURU USULÜ

Veri Sorumlusuna Başvuru Usul ve Esasları Hakkında Tebliğ m.5 uyarınca taleplerinizi aşağıdaki kanallardan iletebilirsiniz:

• YAZILI OLARAK: Islak imzalı dilekçenizi ${SirketBilgileri.adres} adresine bizzat elden teslim ederek, noter vasıtasıyla ya da iadeli taahhütlü posta yoluyla göndererek. Şahsen başvuruda kimliğinizi tevsik edici belge ibraz etmeniz gerekir.
• KEP ADRESİ İLE: Kayıtlı elektronik posta adresinizden ${SirketBilgileri.kep} adresine göndererek.
• GÜVENLİ ELEKTRONİK VEYA MOBİL İMZA İLE: ${SirketBilgileri.kvkkEposta} adresine göndererek.
• KAYITLI E-POSTA ADRESİNİZLE: Daha önce Şirket'e bildirdiğiniz ve Şirket sisteminde KAYITLI OLAN e-posta adresinizi kullanarak ${SirketBilgileri.kvkkEposta} adresine göndererek. Sistemde kayıtlı olmayan bir adresten yapılan başvurular Tebliğ uyarınca geçerli sayılmayabilir.

Başvurunuzda; ad, soyad ve yazılı başvurularda imza, T.C. kimlik numarası (yabancılar için uyruk, pasaport numarası veya kimlik numarası), tebligata esas yerleşim yeri veya iş yeri adresi, varsa bildirime esas elektronik posta adresi, telefon ve faks numarası ile talep konusu bulunması zorunludur. Konuya ilişkin bilgi ve belgeler başvuruya eklenmelidir.

Başvurularınız niteliğine göre en kısa sürede ve en geç 30 GÜN içinde sonuçlandırılır. İşlem ayrıca bir maliyet gerektirmiyorsa ücretsizdir; maliyet gerektirmesi hâlinde Kurulca belirlenen tarifedeki ücret alınabilir.

Başvurunuzun reddedilmesi, verilen cevabı yetersiz bulmanız veya süresinde cevap verilmemesi hâlinde; cevabı öğrendiğiniz tarihten itibaren 30 gün ve her hâlde başvuru tarihinden itibaren 60 gün içinde Kişisel Verileri Koruma Kurulu'na şikâyette bulunabilirsiniz.

Gizlilik Politikamıza ${SirketBilgileri.gizlilikUrl} adresinden ulaşabilirsiniz.
''';

  // ── AÇIK RIZA METNİ — KAMPANYA İLETİŞİMİ (KVKK m.5/1, 6563 m.6) ─
  // Uygulamadaki TEK açık rıza. Yalnızca pazarlama iletişimini kapsar;
  // üyelik, rezervasyon, kiralama ve yurt dışı aktarımlar rızaya DAYANMAZ
  // (avukat KVKK analizi 01 ve 02). Rızayı kayıt veya kullanımla "verilmiş
  // sayma" kurgusu geçersizdir; onay ayrı, işaretsiz bir kutuyla alınır.
  static const String acikRizaBaslik = 'Açık Rıza Metni — Kampanya İletişimi';

  static String get acikRizaMetni => '''
Son güncelleme: ${SirketBilgileri.sonGuncelleme}

BU ONAY ZORUNLU DEĞİLDİR VE HİÇBİR HİZMETİN ŞARTI DEĞİLDİR. Onay vermeseniz de üye olabilir, araçları inceleyebilir, favorilerinizi kullanabilir ve WhatsApp hattımız üzerinden araç kiralayabilirsiniz.

Bu metin YALNIZCA kampanya ve fırsat iletişimi içindir. Üyelik, rezervasyon, araç kiralama ve bunlara ilişkin yurt dışı aktarımlar açık rızaya dayanmaz; bunların hukuki sebepleri Aydınlatma Metni'nde açıklanmıştır.

1. VERİ SORUMLUSU

${SirketBilgileri.unvan}
Adres: ${SirketBilgileri.adres}
E-posta: ${SirketBilgileri.kvkkEposta}
KEP: ${SirketBilgileri.kep}

2. RIZANIN KONUSU

Onay vermeniz hâlinde:

• İşlenecek veriler: Ad, soyad, cep telefonu numarası, onay ve geri alma tarihleri, onayladığınız metin sürümü
• Amaç: Şirket'in araç kiralama kampanyaları, indirimleri ve fırsatları hakkında tarafınıza ticari elektronik ileti gönderilmesi
• Kanallar: SMS ve WhatsApp
• Profilleme: Yapılmaz; ileti içerikleri kişisel özelliklerinize veya davranışlarınıza göre belirlenmez
• Alıcılar: İleti Yönetim Sistemi A.Ş. (onay ve ret kayıtlarının kaydedilmesi), SMS hizmet sağlayıcısı ve WhatsApp Business (veri işleyen sıfatıyla iletilerin gönderilmesi)
• Yurt dışına aktarım: WhatsApp ile gönderilen iletiler yurt dışındaki sunucular üzerinden iletilir; bu aktarım açık rızaya değil, Aydınlatma Metni'nin 5.2 maddesindeki standart sözleşme güvencesine dayanır
• Saklama: Onayınız sürdüğü sürece; onayınızı geri aldığınızda kampanya gönderim listesinden derhal çıkarılırsınız

3. BEYAN

Yukarıda açıklanan kapsamda; ad, soyad ve cep telefonu numaramın ${SirketBilgileri.unvan} tarafından araç kiralama kampanyaları, indirimleri ve fırsatları hakkında SMS ve WhatsApp ile ticari elektronik ileti gönderilmesi amacıyla işlenmesine 6698 sayılı Kanun m.5/1 uyarınca AÇIK RIZA verdiğimi ve bu iletilerin gönderilmesine 6563 sayılı Kanun m.6 uyarınca ONAY verdiğimi kabul ederim.

4. ONAYI GERİ ALMA

Onayınızı dilediğiniz zaman, gerekçe göstermeden ve ücretsiz olarak geri alabilirsiniz:

• Uygulama içindeki Profilim bölümünden tek dokunuşla,
• Size gönderilen her iletide yer alan ret yolunu kullanarak,
• İleti Yönetim Sistemi (İYS) üzerinden,
• ${SirketBilgileri.kvkkEposta} adresine veya ${SirketBilgileri.kep} KEP adresine yazılı başvuruyla.

Ret bildiriminiz en geç 3 iş günü içinde işleme alınır. Geri alma, o tarihe kadar hukuka uygun biçimde yapılmış işlemleri etkilemez. Hesabınızı silmeniz de onayınızın geri alınması sayılır.

Kişisel verilerinize ilişkin diğer haklarınız ve başvuru usulü Aydınlatma Metni'nin 8. ve 9. maddelerinde yer alır.
''';

  // ── KULLANIM KOŞULLARI ─────────────────────────────────────────
  static const String kullanimKosullariBaslik = 'Kullanım Koşulları';

  static String get kullanimKosullariMetni => '''
Son güncelleme: ${SirketBilgileri.sonGuncelleme}

1. TARAFLAR VE KONU

Bu koşullar, ${SirketBilgileri.unvan} tarafından sunulan Şenbayrak Araç Kiralama mobil uygulamasının kullanımına ilişkindir. Uygulamayı kullanarak bu koşulları kabul etmiş sayılırsınız.

2. HİZMETİN KAPSAMI

Uygulama, araç kiralama filosunun görüntülenmesini ve rezervasyon TALEBİNİN WhatsApp hattımıza iletilmesini sağlar. Uygulama üzerinden kiralama yapılmaz ve kiralama sözleşmesi kurulmaz.

Rezervasyon talepleri YALNIZCA ${SirketBilgileri.whatsappHatti} numaralı WhatsApp hattımız üzerinden alınır ve teyit edilir. Rezervasyon talebi gönderebilmek için cihazınızda WhatsApp uygulamasının yüklü olması gerekir.

WhatsApp hattımıza iletilen talep bir REZERVASYON GARANTİSİ DEĞİLDİR. Rezervasyonunuz, Şirket tarafından WhatsApp yazışması üzerinden teyit edilmesi ve ödemenin tamamlanmasıyla kesinleşir; kiralama sözleşmesi şubede kimlik ve sürücü belgesi ibrazıyla kurulur. Uygulamada gösterilen günlük fiyatlar bilgilendirme amaçlıdır; nihai fiyat, kiralama süresi, ek hizmetler ve güncel koşullara göre teyit sırasında bildirilir.

3. ÖDEME

Ödeme işlemleri uygulama içinde gerçekleşmez. Ödeme, teyit sürecinde tarafınıza iletilecek banka ödeme bağlantısı üzerinden yapılır. Şirket, kart veya banka hesap bilgilerinizi uygulama üzerinden toplamaz ve saklamaz.

4. KULLANICI YÜKÜMLÜLÜKLERİ

• Verdiğiniz bilgilerin doğru ve güncel olmasından siz sorumlusunuz.
• Hesap şifrenizin gizliliğini korumakla yükümlüsünüz.
• Başkasına ait kimlik veya iletişim bilgileriyle talep iletemezsiniz.
• Araç kiralayabilmek için yasal ehliyet ve yaş şartlarını taşımanız gerekir; bu şartlar teslim sırasında kontrol edilir.

5. HESABIN KAPATILMASI

Hesabınızı dilediğiniz zaman Profilim > Hesabımı Sil adımıyla kalıcı olarak silebilirsiniz. Şirket, bu koşulların ihlali hâlinde hesabınızı askıya alma hakkını saklı tutar.

6. SORUMLULUK SINIRI

Uygulamada yer alan araç bilgileri ve görselleri temsilîdir. Şirket, uygulamanın kesintisiz çalışacağını taahhüt etmez. Şirketin sorumluluğu, yürürlükteki mevzuatın izin verdiği azami ölçüde sınırlıdır.

7. UYGULANACAK HUKUK

Bu koşullara Türkiye Cumhuriyeti hukuku uygulanır. Uyuşmazlıklarda ${SirketBilgileri.yetkiliMahkeme} Mahkemeleri ve İcra Daireleri yetkilidir. Tüketici sıfatını haiz kullanıcılar için tüketici hakem heyetleri ve tüketici mahkemelerinin yetkisi saklıdır.

8. İLETİŞİM

${SirketBilgileri.unvan}
${SirketBilgileri.adres}
${SirketBilgileri.kvkkEposta} • ${SirketBilgileri.telefon}
''';

  // ── GİZLİLİK POLİTİKASI (mağaza şartı) ─────────────────────────
  static const String gizlilikBaslik = 'Gizlilik Politikası';

  static String get gizlilikMetni => '''
Son güncelleme: ${SirketBilgileri.sonGuncelleme}

Bu politika, Şenbayrak Araç Kiralama uygulamasının kişisel verilerinizi nasıl işlediğini özetler. Ayrıntılı bilgi için Aydınlatma Metni'ni uygulama içinden veya ${SirketBilgileri.aydinlatmaUrl} adresinden inceleyiniz.

TOPLADIĞIMIZ VERİLER

• Hesap bilgileri: Ad, soyad, e-posta adresi, telefon numarası
• Kullanım bilgileri: Favori araçlarınız, WhatsApp hattımıza yönlendirilen rezervasyon talep kayıtlarınız
• Üyelik beyanları: Kullanım Koşulları kabulünüz, Aydınlatma Metni'ni okuduğunuza ilişkin geri bildiriminiz, tarihi ve metin sürümü
• Kampanya onayı (isteğe bağlı): Vermeniz hâlinde onay durumu, onay ve geri alma tarihleri
• Güvenlik bilgisi: Oturum ve cihaz doğrulama kayıtları

Konum verisi toplamıyoruz. Reklam kimliği kullanmıyoruz. Üçüncü taraf reklam ağlarına veri aktarmıyoruz. Verilerinizi satmıyoruz.

REZERVASYON NASIL YAPILIR

Rezervasyon talepleri YALNIZCA WhatsApp hattımız üzerinden alınır; uygulama üzerinden kiralama yapılmaz. Rezervasyon ekranındaki düğmeye bastığınızda bilgilerinizle hazırlanmış mesaj WhatsApp'ta açılır ve mesajı siz gönderirsiniz. Talebi takip edebilmemiz için aynı anda yönetim panelimizde bir talep kaydı oluşturulur.

Bu süreç açık rızanıza dayanmaz; WhatsApp aktarımının hukuki dayanağı Aydınlatma Metni'nin 5.2 maddesinde açıklanmıştır.

T.C. KİMLİK NUMARASI

T.C. Kimlik Numaranız veritabanımızda saklanmaz. Girmeniz zorunlu değildir; alanı doldurmanız hâlinde yalnızca sözleşme hazırlığı amacıyla WhatsApp mesajına eklenir.

VERİLERİN SAKLANDIĞI YER VE YURT DIŞINA AKTARIM

• Google Firebase (Firestore, Authentication, App Check): Hesap bilgileriniz ve rezervasyon talep kayıtlarınız, Avrupa Birliği sınırları içindeki sunucularda (Belçika — europe-west1) barındırılır. Dayanılan KVKK m.9 güvencesi: ${SirketBilgileri.firebaseAktarimDayanagi}
• WhatsApp Business: Rezervasyon yazışmalarınız WhatsApp altyapısında, yurt dışındaki sunucularda işlenir. Dayanılan KVKK m.9 güvencesi: ${SirketBilgileri.whatsappAktarimDayanagi}

Araç görselleri Firebase Storage'da tutulur ve kişisel veri içermez.

ÜÇÜNCÜ TARAFLAR

• Google Firebase — teknik altyapı (veri işleyen)
• WhatsApp Business — rezervasyon yazışmaları ve onay vermeniz hâlinde kampanya mesajları (veri işleyen)
• SMS hizmet sağlayıcısı ve İleti Yönetim Sistemi (İYS) — yalnızca kampanya onayı vermeniz hâlinde

Kiralama sözleşmesi aşamasında şubede yapılan yurt içi aktarımlar Aydınlatma Metni'nin 5.1 maddesinde sayılmıştır.

SAKLAMA SÜRELERİ

$_saklamaSureleri

Süresi dolan veriler en geç ${SaklamaSureleri.periyodikImhaAy} ayda bir yapılan periyodik imhayla silinir.

KAMPANYA İLETİŞİMİ

Onayınız olmadan SMS, WhatsApp, e-posta, arama veya anlık bildirim yoluyla pazarlama iletisi göndermiyoruz. Üyelik sırasında veya Profilim bölümünden isteğe bağlı olarak onay verirseniz kampanya ve fırsatlarımızı SMS ve WhatsApp ile iletiriz; onayınız İleti Yönetim Sistemi'ne (İYS) kaydedilir. Onay vermek zorunlu değildir ve araç kiralamayı etkilemez. Onayınızı Profilim bölümünden, iletideki ret yolundan veya İYS üzerinden dilediğiniz zaman geri alabilirsiniz; ret bildiriminiz en geç 3 iş günü içinde işleme alınır.

ÇOCUKLARIN GİZLİLİĞİ

Uygulama 18 yaşın altındaki kişilere yönelik değildir ve bu kişilerden bilerek veri toplanmaz.

HAKLARINIZ VE VERİ SİLME

Hesabınızı uygulama içinden Profilim > Hesabımı Sil adımıyla kalıcı olarak silebilirsiniz. Bu işlem hesabınızı, profil ve onay kayıtlarınızı, favori listenizi ve rezervasyon talep kayıtlarınızı siler. WhatsApp yazışmalarınız ve şubede alınan belgeler bu işlemle silinmez; bunların silinmesini ${SirketBilgileri.kvkkEposta} adresine başvurarak talep edebilirsiniz. Diğer haklarınız ve başvuru kanalları Aydınlatma Metni'nin 8. ve 9. maddelerindedir.

DEĞİŞİKLİKLER

Bu politikada yapılacak değişiklikler uygulama içinde ve ${SirketBilgileri.gizlilikUrl} adresinde yayımlanır; yürürlük tarihi belirtilir.

İLETİŞİM

${SirketBilgileri.unvan}
${SirketBilgileri.adres}
${SirketBilgileri.kvkkEposta}
''';

  // ── KİŞİSEL VERİ SAKLAMA VE İMHA POLİTİKASI ────────────────────
  // Uygulamada gösterilmez; Şirket içi politika belgesidir. Avukata ve talep
  // eden kurumlara iletilir, talep eden ilgili kişiye verilir. Süre tablosu KvkkEnvanter ile
  // SaklamaSureleri'nden gelir.
  static const String saklamaImhaBaslik =
      'Kişisel Veri Saklama ve İmha Politikası';

  static String get _saklamaTablosuMetni => SaklamaSureleri.kategoriler
      .map((k) =>
          '• ${k.kategori}\n  Kayıt ortamı: ${k.kayitOrtami}\n  Saklama süresi: ${k.sure}\n  Dayanak: ${k.dayanak}\n  İmha yöntemi: ${k.imhaYontemi}')
      .join('\n\n');

  static String get saklamaImhaPolitikasiMetni => '''
Yürürlük tarihi: ${SirketBilgileri.sonGuncelleme}

1. AMAÇ VE KAPSAM

Bu politika, ${SirketBilgileri.unvan} ("Şirket") tarafından araç kiralama faaliyeti ve Şenbayrak Araç Kiralama mobil uygulaması kapsamında işlenen kişisel verilerin saklanması ve imhasına ilişkin usul ve esasları, Kişisel Verilerin Silinmesi, Yok Edilmesi veya Anonim Hale Getirilmesi Hakkında Yönetmelik ("Yönetmelik") m.5 ve m.6 uyarınca belirler.

Şirket'in araç satışı, sigorta aracılığı ve akaryakıt istasyonu iş kollarında işlenen veriler bu politikanın kapsamı dışındadır ve Şirket'in kurumsal Kişisel Verilerin Korunması ve İşlenmesi Politikası ile ilgili iş koluna ait belgelere tabidir.

2. TANIMLAR

• Silme: Kişisel verilerin ilgili kullanıcılar için hiçbir şekilde erişilemez ve tekrar kullanılamaz hâle getirilmesi.
• Yok etme: Kişisel verilerin hiç kimse tarafından hiçbir şekilde erişilemez, geri getirilemez ve tekrar kullanılamaz hâle getirilmesi.
• Periyodik imha: Saklama süresi dolan kişisel verilerin, bu politikada belirlenen tekrar eden aralıklarla resen silinmesi veya yok edilmesi.
• Kayıt ortamı: Kişisel verilerin bulunduğu her türlü elektronik veya fiziki ortam.

3. KAYIT ORTAMLARI

• Google Firebase — Cloud Firestore ve Authentication (elektronik; sunucular AB içinde, Belçika)
• Şirket WhatsApp Business hattı (${SirketBilgileri.whatsappHatti}) ve bu hattın kullanıldığı cihaz (elektronik)
• Şube fiziki arşivi (kâğıt)
• Muhasebe kayıtları (fiziki ve elektronik)
• İleti Yönetim Sistemi (İYS) — ticari elektronik ileti onay ve ret kayıtları (elektronik)

Mobil uygulamada T.C. Kimlik Numarası, ödeme bilgisi, konum verisi ve reklam kimliği hiçbir kayıt ortamında saklanmaz.

4. SAKLAMA VE İMHAYI GEREKTİREN SEBEPLER

Kişisel veriler, KVKK m.5'te sayılan işleme şartlarından birinin devam ettiği ve ilgili mevzuatta öngörülen saklama süreleri dolmadığı sürece saklanır. İşleme şartlarının tamamı ortadan kalktığında veya aşağıdaki saklama süresi dolduğunda veriler resen imha edilir. Kişisel Veri İşleme Envanteri'nde her işleme faaliyetinin hukuki sebebi ve bağlı olduğu saklama kategorisi ayrıca gösterilmiştir.

5. SAKLAMA VE İMHA SÜRELERİ

$_saklamaTablosuMetni

6. İMHA YÖNTEMLERİ

• Veritabanı kayıtları: Yönetim panelindeki periyodik imha işlevi veya hesap silme işlevi ile Cloud Firestore'dan kalıcı olarak silinir. Silinen kayıt uygulama üzerinden hiçbir kullanıcı tarafından geri getirilemez.
• Kimlik doğrulama kayıtları: Hesap silme işlevi ile Firebase Authentication'dan kalıcı olarak silinir.
• WhatsApp yazışmaları: Periyodik imhada, saklama süresi dolan sohbetler WhatsApp Business uygulamasında medya dosyalarıyla birlikte silinir. Bu hattın sohbet yedeği harici bulut hizmetlerine (Google Drive, iCloud) alınmaz.
• Fiziki belgeler: Evrak imha makinesiyle geri döndürülemez biçimde yok edilir.

Anonim hâle getirme yöntemi kullanılmamaktadır.

7. PERİYODİK İMHA

Periyodik imha süresi ${SaklamaSureleri.periyodikImhaAy} aydır ve her yıl Ocak ve Temmuz aylarında gerçekleştirilir (Yönetmelik m.11).

Mobil uygulamaya ait rezervasyon talep kayıtları, yönetim panelinin İstatistik sekmesindeki "Periyodik İmha" işleviyle silinir. İşlev, saklama süresi dolan kayıtları siler ve imha tarihini, silinen kayıt sayısını, uygulanan saklama süresini ve işlemi yapan yöneticinin kullanıcı kimliğini, müşteri kişisel verisi içermeyen bir imha kaydı olarak otomatik saklar. Silinecek kayıt bulunmasa da imha kaydı oluşturulur. Panel, son periyodik imhanın üzerinden ${SaklamaSureleri.periyodikImhaAy} ay geçmişse uyarı gösterir.

WhatsApp yazışmaları ve fiziki belgelerin imhası aynı dönemlerde yapılır; imha edilen veri kategorisi, kayıt ortamı, imha yöntemi, tarih ve işlemi yapan kişi imha tutanağına yazılır.

Uygulama kullanıcılarının hesaplarını kendilerinin silmesi hâlinde de imha tarihi ve silinen talep kaydı sayısı, kullanıcıyı tanımlayan hiçbir bilgi içermeyen bir imha kaydı olarak saklanır.

İmha işlemlerine ilişkin kayıtlar, Yönetmelik m.7/3 uyarınca en az ${SaklamaSureleri.imhaKaydiYil} yıl saklanır.

8. İLGİLİ KİŞİNİN SİLME TALEBİ

İlgili kişinin Aydınlatma Metni'nde sayılan kanallardan kişisel verilerinin silinmesini veya yok edilmesini talep etmesi hâlinde Şirket:

• İşleme şartlarının tamamı ortadan kalkmışsa talebe konu verileri 30 gün içinde siler veya yok eder ve ilgili kişiye bilgi verir (Yönetmelik m.12).
• İşleme şartlarından biri devam ediyorsa (ör. saklama süresi dolmamış şube belgeleri) talebi gerekçesini açıklayarak reddeder ve cevabı en geç 30 gün içinde yazılı olarak veya elektronik ortamda bildirir.
• Veriler üçüncü kişilere aktarılmışsa, silme işlemini ilgili üçüncü kişilere de bildirir.

Uygulama kullanıcıları silme hakkını Profilim > Hesabımı Sil adımıyla doğrudan kullanabilir. Kampanya onayı bulunan kullanıcının hesabını silmesi onayın geri alınması sayılır ve en geç 3 iş günü içinde İYS'de ret olarak işlenir.

9. TEKNİK VE İDARİ TEDBİRLER

• Uygulama ile sunucular arasındaki tüm veri trafiği TLS ile şifrelenir; durağan veri sunucu tarafında AES-256 ile şifrelenir.
• Veritabanı erişimi sunucu tarafında zorlanan güvenlik kurallarıyla sınırlandırılır; her kullanıcı yalnızca kendi verisine erişir, rezervasyon kayıtlarını ve imha kayıtlarını yalnızca yöneticiler görür.
• İmha kayıtları değiştirilemez; ${SaklamaSureleri.imhaKaydiYil} yıllık asgari saklama süresi dolmadan silinemez.
• Rezervasyon talebi gönderebilmek için e-posta doğrulaması zorunludur.
• Şube belgelerine yalnızca kiralama işlemini yürüten personel erişir.

10. GÖREV DAĞILIMI

• Şirket yetkilisi: Politikanın yürürlüğe konması, güncellenmesi ve uygulanmasının denetlenmesi.
• Mobil uygulama yöneticisi: Rezervasyon talep kayıtlarının periyodik imhası ve imha kayıtlarının kontrolü.
• WhatsApp hattından sorumlu personel: Saklama süresi dolan yazışmaların silinmesi ve imha tutanağının düzenlenmesi.
• Kiralama şube sorumlusu: Şube belgelerinin saklanması, süresi dolanların yok edilmesi ve imha tutanağının düzenlenmesi.
• Kampanya iletişiminden sorumlu personel: Yeni onayların İYS'ye yüklenmesi, geri alınan onayların ve hesabını silen kullanıcıların en geç 3 iş günü içinde İYS'de ret olarak işlenmesi, onayı bulunmayan kişiye ileti gönderilmemesinin kontrolü.

11. YÜRÜRLÜK VE GÜNCELLEME

Bu politika ${SirketBilgileri.sonGuncelleme} tarihinde yürürlüğe girmiştir. Saklama sürelerinde veya kayıt ortamlarında değişiklik olduğunda güncellenir ve güncel sürüm Aydınlatma Metni ile birlikte yayımlanır.
''';
}
