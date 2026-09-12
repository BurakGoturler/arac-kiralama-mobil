// ═══════════════════════════════════════════════════════════════════
//  KVKK ve mağaza yükümlülükleri kapsamındaki yasal metinler.
//
//  ⚠️  YAYINDAN ÖNCE YAPILMASI ZORUNLU:
//      1. Aşağıdaki SirketBilgileri sınıfındaki TÜM alanlar doldurulmalı.
//         Şu hâlleriyle köşeli parantezli yer tutucular kullanıcıya görünür.
//      2. Metinler bir hukuk danışmanına kontrol ettirilmeli. Buradaki
//         içerik teknik bir taslaktır, hukuki görüş değildir.
//      3. Gizlilik politikası ayrıca herkese açık bir web adresinde
//         yayınlanmalıdır — Google Play ve App Store bunu şart koşar,
//         uygulama içi metin tek başına yeterli değildir.
// ═══════════════════════════════════════════════════════════════════

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
  /// Şirketin web sitesinde yayımlanan genel iletişim adresi kullanılıyor.
  /// DİKKAT: Buraya bir YÖNETİCİ HESABININ e-postası yazılmamalıdır. Bu adres
  /// yasal metinlerde ve web sitesinde herkese açık yayımlanır; yönetim
  /// paneline giriş yapan bir hesabın adresi olursa o hesap hedefli saldırı
  /// için doğrudan tarif edilmiş olur.
  static const String kvkkEposta = 'info@senbayrak.com.tr';

  /// Tebligata esas iletişim telefonu (Merkez Şube).
  static const String telefon = '0 (322) 435 56 36';

  /// VERBİS (Veri Sorumluları Sicili) kayıt durumu.
  ///
  /// Şirket muafiyet kapsamındadır: Kişisel Verileri Koruma Kurulu'nun
  /// istisna kararları uyarınca, yıllık çalışan sayısı 50'den az VE yıllık
  /// mali bilanço toplamı 100 milyon TL'den az olan veri sorumluları Sicile
  /// kayıtla yükümlü değildir. İki şart birlikte aranır. Ana faaliyeti özel
  /// nitelikli kişisel veri işlemek olanlar eşiğe bakılmaksızın kayıtlıdır;
  /// araç kiralama bu kapsamda değildir (sürücü belgesi KVKK m.6 anlamında
  /// özel nitelikli veri sayılmaz).
  ///
  /// Eşik değerleri şirket tarafından beyan edilmiştir; muafiyetin sürüp
  /// sürmediği her yıl bilanço ve çalışan sayısı üzerinden yeniden kontrol
  /// edilmelidir. Eşik aşılırsa Sicile kayıt zorunlu hâle gelir.
  ///
  /// DİKKAT: Muafiyet YALNIZCA Sicile kayıt yükümlülüğünü kaldırır.
  /// Aydınlatma yükümlülüğü, veri güvenliği tedbirleri, kişisel veri işleme
  /// envanteri ve saklama/imha politikası yükümlülükleri aynen sürer.
  static const String verbis =
      'Kayıt yükümlülüğü bulunmamaktadır. Şirket, yıllık çalışan sayısı '
      "50'den az ve yıllık mali bilanço toplamı 100 milyon TL'den az "
      'olduğundan, Kişisel Verileri Koruma Kurulu kararları uyarınca Veri '
      'Sorumluları Siciline kayıt yükümlülüğünden istisna tutulmuştur.';

  /// KEP (Kayıtlı Elektronik Posta) adresi.
  /// KVKK başvuruları yazılı olarak veya KEP üzerinden yapılabilir;
  /// avukat metinlerinde başvuru kanalı olarak sayıldığı için burada da yer alır.
  ///
  /// Bu alan başvuru metninin içine gömülü olarak kullanılıyor
  /// ("KEP kullanıyorsanız ... adresine"), bu yüzden buraya adres dışında
  /// bir ifade yazılmamalıdır; KEP yoksa o cümle metinden çıkarılmalıdır.
  static const String kep = 'senbayrakpetrol@hs03.kep.tr';

  /// Uyuşmazlıklarda yetkili mahkeme ve icra daireleri.
  ///
  /// Bu alan eskiden doğrudan Kullanım Koşulları metninin içine gömülü bir
  /// yer tutucuydu ve [eksikBilgiVar] denetiminin DIŞINDA kalıyordu; yani
  /// yayın öncesi testi geçtiği hâlde kullanıcı metinde köşeli parantezli
  /// bir ifade görebiliyordu. Alan hâline getirilip denetime dâhil edildi.
  static const String yetkiliMahkeme = 'Adana';

  /// Gizlilik politikasının yayınlandığı herkese açık adres.
  /// Google Play ve App Store bunu şart koşar; uygulama içi metin tek
  /// başına yeterli değildir. Banka uyum ekibi de bu adresi istemektedir.
  static const String gizlilikUrl =
      'https://senbayrak.com.tr/gizlilik-politikasi.php';

  /// Google Firebase (yurt dışı) aktarımının KVKK m.9 dayanağı.
  ///
  /// 7499 sayılı Kanun'la değişik m.9 rejiminde yurt dışı aktarımı üç yoldan
  /// birine dayanmak zorundadır: Kurul'un yeterlilik kararı, uygun güvence
  /// (Kurul'un ilan ettiği standart sözleşme / Kurul onaylı taahhütname /
  /// bağlayıcı şirket kuralları) veya m.9/6 istisnaları.
  ///
  /// Kurul bugüne kadar HİÇBİR ülke için yeterlilik kararı ilan etmedi;
  /// verinin Belçika'da (AB) durması tek başına dayanak DEĞİLDİR.
  /// Firebase sürekli bir altyapı hizmeti olduğu için m.9/6'daki "arızi
  /// aktarım" istisnasına da girmez — yani AÇIK RIZA bu aktarım için
  /// geçerli bir yol değildir.
  ///
  /// Bu alan doldurulmadan uygulama YAYINA ALINMAMALIDIR: aksi hâlde
  /// aydınlatma metni, hukuki dayanağı olmayan bir aktarımı beyan eder.
  /// Doldurulduğunda buraya seçilen güvencenin adı ve tarihi yazılır,
  /// örn: 'Kurul'un ilan ettiği standart sözleşme — imza 01.10.2026,
  /// Kurum bildirimi 06.10.2026'.
  static const String firebaseAktarimDayanagi =
      '[DOLDURULACAK — Firebase için seçilen KVKK m.9 güvencesi ve tarihi]';

  /// Metinlerin son güncellenme tarihi
  static const String sonGuncelleme = '12.09.2026';

  /// Yer tutucuların doldurulup doldurulmadığını anlamak için.
  /// Yayın öncesi kontrol listesinde ve testlerde kullanılır.
  static bool get eksikBilgiVar =>
      unvan.contains('[') ||
      adres.contains('[') ||
      vergiDairesi.contains('[') ||
      vkn.contains('[') ||
      kvkkEposta.contains('[') ||
      telefon.contains('[') ||
      verbis.contains('[') ||
      kep.contains('[') ||
      yetkiliMahkeme.contains('[') ||
      firebaseAktarimDayanagi.contains('[') ||
      gizlilikUrl.contains('[');
}

class LegalTexts {
  // ── AYDINLATMA METNİ (KVKK m.10) ───────────────────────────────
  static const String aydinlatmaBaslik = 'Kişisel Verilerin Korunması Hakkında Aydınlatma Metni';

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
• Müşteri işlem bilgisi: Seçtiğiniz araç, kiralama tarihleri, alım yeri, rezervasyon talep kayıtlarınız, favori araç listeniz
• Kimlik doğrulama bilgisi: Hesap şifreniz (şifreniz Şirket tarafından görülemez; Firebase Authentication altyapısında geri döndürülemez biçimde saklanır), e-posta doğrulama durumu
• İşlem güvenliği bilgisi: Oturum ve cihaz doğrulama kayıtları (Firebase Authentication ve App Check tarafından üretilir)

T.C. Kimlik Numaranız uygulama veritabanında SAKLANMAZ. Rezervasyon talebinizi WhatsApp üzerinden iletmeyi seçerseniz ve bu alanı doldurursanız, yalnızca kiralama sözleşmesinin önceden hazırlanabilmesi amacıyla oluşturulan WhatsApp mesajına eklenir ve mesaj tarafınızca gönderilir. Bu alanı doldurmak ZORUNLU DEĞİLDİR.

ÖDEME BİLGİSİ TOPLANMAZ. Uygulama; kart numarası, son kullanma tarihi, CVV, banka hesabı veya IBAN bilgisi toplamaz, işlemez ve saklamaz. Ödeme, teyit sürecinde tarafınıza iletilecek banka ödeme bağlantısı üzerinden, ilgili bankanın kendi güvenli sayfasında gerçekleşir.

KONUM VERİSİ, REKLAM KİMLİĞİ VE ÇEREZ KULLANILMAZ. Uygulama cihaz konumunuza erişmez, reklam kimliği okumaz ve profilleme amacıyla çerez veya benzeri izleyici teknolojiler kullanmaz.

2/A. ŞUBE AŞAMASINDA İŞLENEN VERİLER

Aşağıdaki veriler UYGULAMA ÜZERİNDEN TOPLANMAZ ve uygulama veritabanında saklanmaz. Bunlar yalnızca rezervasyon talebiniz teyit edildikten sonra, araç tesliminde şube süreçleri kapsamında; kiralama sözleşmesinin kurulması ve ifası ile mevzuattan doğan yükümlülüklerin yerine getirilmesi amacıyla işlenir:

• Kimlik belgesi bilgileri (T.C. Kimlik Numarası dâhil)
• Sürücü belgesi bilgileri
• Yerleşim yeri (ikametgâh) belgesi
• Adli sicil kaydı
• Findeks / kredi kayıt bürosu sorgu sonucu

ADLİ SİCİL KAYDI ÖZEL NİTELİKLİ KİŞİSEL VERİDİR. KVKK m.6 uyarınca bu veri, ancak kanunlarda öngörülen hâllerde veya açık rızanıza dayanılarak işlenebilir. Bu veri bakımından Kişisel Verileri Koruma Kurulu tarafından belirlenen ek idari ve teknik tedbirler uygulanır. Söz konusu veri şube aşamasında, ayrıca bilgilendirilmeniz ve gerekli hukuki sebebin sağlanması suretiyle işlenir; uygulama bu veriye hiçbir aşamada erişmez.

3. KİŞİSEL VERİLERİN TOPLANMA YÖNTEMİ

Kişisel verileriniz KVKK m.10/1-ç ve Aydınlatma Yükümlülüğünün Yerine Getirilmesinde Uyulacak Usul ve Esaslar Hakkında Tebliğ m.5/1-ç uyarınca aşağıdaki yöntemlerle toplanmaktadır:

• Tamamen otomatik yollarla: Mobil uygulamadaki üyelik formu, giriş ve şifre işlemleri, rezervasyon talep formu ve favori işaretleme özelliği aracılığıyla, siz doğrudan girdiğiniz anda elektronik ortamda.
• Kısmen otomatik yollarla: Rezervasyon talebinizi WhatsApp üzerinden iletmeyi seçmeniz hâlinde, tarafınızca gönderilen mesaj aracılığıyla.
• Otomatik olmayan yollarla: Araç tesliminde şubede fiziki belge teslimi, kiralama sözleşmesinin imzalanması ve sözlü ya da telefonla iletişim yoluyla (2/A maddesindeki veriler).
• Üçüncü kaynaklardan: Kredi Kayıt Bürosu / Findeks sorgusu yoluyla, yalnızca şube aşamasında ve risk değerlendirmesi amacıyla.

Uygulama; çerez, piksel, reklam kimliği veya benzeri izleyici teknolojilerle veri toplamaz.

4. İŞLEME AMAÇLARI VE HER AMACIN HUKUKİ SEBEBİ

Aydınlatma Tebliği m.5/1-h uyarınca, işleme amaçları ile hukuki sebepler aşağıda tek tek eşleştirilmiştir:

• Üyelik hesabınızın oluşturulması, yönetilmesi ve kimliğinizin doğrulanması (ad, soyad, e-posta, telefon, şifre)
  → Sözleşmenin kurulması ve ifası için gerekli olması — KVKK m.5/2-c

• Rezervasyon talebinizin alınması, kaydedilmesi, değerlendirilmesi ve teyit için sizinle iletişime geçilmesi (ad, soyad, telefon, araç, tarih, alım yeri)
  → Sözleşmenin kurulması ve ifası için gerekli olması — KVKK m.5/2-c

• Rezervasyon talebinizin WhatsApp üzerinden iletilmesi ve bu kapsamda verilerin yurt dışına aktarılması
  → AÇIK RIZANIZ — KVKK m.5/1 ve m.9. Bu amaç yalnızca WhatsApp kanalını seçmeniz hâlinde geçerlidir; zorunlu değildir. Uygulama içi gönderim yolu açık rıza gerektirmez.

• Favori araç listesi tutulması ve kullanıcı deneyiminin iyileştirilmesi (favori araç kimlikleri)
  → Temel hak ve özgürlüklerinize zarar vermemek kaydıyla meşru menfaat — KVKK m.5/2-f

• Hesap güvenliğinin sağlanması, yetkisiz erişimin ve sahte istemcilerin engellenmesi (oturum ve cihaz doğrulama kayıtları)
  → Veri güvenliğine ilişkin hukuki yükümlülük — KVKK m.5/2-ç ve meşru menfaat — KVKK m.5/2-f

• Kiralama işleminin Emniyet Genel Müdürlüğü Kiralık Araç Bildirim Sistemi'ne (KABİS) bildirilmesi (kimlik, sürücü belgesi, araç ve kiralama bilgileri)
  → Kanunlarda açıkça öngörülmesi — KVKK m.5/2-a ve hukuki yükümlülüğün yerine getirilmesi — KVKK m.5/2-ç

• Kiralama öncesi risk değerlendirmesi yapılması (Findeks / Kredi Kayıt Bürosu sorgusu)
  → Meşru menfaat — KVKK m.5/2-f

• Kiralama sözleşmesinin ifası, fatura düzenlenmesi ve muhasebe kayıtlarının tutulması
  → Hukuki yükümlülüğün yerine getirilmesi — KVKK m.5/2-ç (213 sayılı Vergi Usul Kanunu, 6102 sayılı Türk Ticaret Kanunu)

• Uyuşmazlık hâlinde delil sağlanması ve hukuki taleplerin takibi
  → Bir hakkın tesisi, kullanılması veya korunması için veri işlemenin zorunlu olması — KVKK m.5/2-e

• Adli sicil kaydının şube aşamasında işlenmesi (2/A)
  → KVKK m.6 kapsamında; kanunlarda öngörülen hâller veya açık rızanız

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

5.2 Yurt dışı aktarımlar (KVKK m.9)

Uygulamanın teknik altyapısı Google tarafından sunulan Firebase hizmetleri (Firestore veritabanı, Authentication, Storage, App Check) üzerinde çalışmaktadır. Veritabanı sunucuları Avrupa Birliği sınırları içinde (Belçika — europe-west1 bölgesi) konumlandırılmıştır.

Sunucuların Avrupa Birliği'nde bulunması KVKK bakımından TEK BAŞINA bir hukuki dayanak oluşturmaz; Kişisel Verileri Koruma Kurulu bugüne kadar hiçbir ülke için yeterlilik kararı ilan etmemiştir. Bu nedenle söz konusu barındırma KVKK m.9 kapsamında yurt dışına veri aktarımı sayılır ve aşağıdaki güvenceye dayanılarak yapılmaktadır:

${SirketBilgileri.firebaseAktarimDayanagi}

Rezervasyon talebinizi WhatsApp üzerinden iletmeyi seçerseniz; ad, soyad, telefon numarası, kiralama bilgileriniz ve doldurmanız hâlinde T.C. Kimlik Numaranız, WhatsApp (Meta Platforms) altyapısı üzerinden geçer. WhatsApp sunucuları yurt dışında bulunduğundan bu da KVKK m.9 kapsamında yurt dışına veri aktarımıdır ve YALNIZCA AÇIK RIZANIZLA gerçekleştirilir.

WhatsApp KULLANMAK ZORUNDA DEĞİLSİNİZ. Uygulamadaki "Talebi Gönder" seçeneğiyle rezervasyon talebinizi doğrudan Şirket'e iletebilirsiniz; bu yol açık rıza gerektirmez ve talebiniz WhatsApp'a hiç uğramaz. Açık rıza vermemeniz veya rızanızı geri almanız, uygulamanın hiçbir işlevini kısıtlamaz.

6. SAKLAMA VE İMHA

Kişisel verileriniz, işlendikleri amaç için gerekli olan süre boyunca ve ilgili mevzuatta öngörülen asgari sürelerden az olmamak üzere saklanır:

• Üyelik hesabı verileri (ad, soyad, e-posta, telefon): Hesabınız açık kaldığı sürece
• Rezervasyon talep kayıtları: Kayıt tarihinden itibaren 2 yıl
• Açık rıza ve onay kayıtları: İspat yükümlülüğü kapsamında, hesabınız açık kaldığı sürece
• Favori araç listesi: Hesabınız açık kaldığı sürece veya siz kaldırana kadar
• Şube aşamasında alınan belgeler (2/A): Kiralama sözleşmesinin sona ermesinden itibaren 10 yıl (6098 sayılı Türk Borçlar Kanunu m.146 genel zamanaşımı süresi)
• Fatura ve muhasebe kayıtları: 213 sayılı Vergi Usul Kanunu uyarınca 5 yıl, 6102 sayılı Türk Ticaret Kanunu uyarınca 10 yıl
• KABİS bildirim kayıtları: İlgili mevzuatta öngörülen süre boyunca

Hesabınızı uygulama içinden sildiğinizde, uygulamadaki üyelik verileriniz ve rezervasyon talep kayıtlarınız derhal ve kalıcı olarak silinir.

Saklama süresi dolan veriler, Kişisel Verilerin Silinmesi, Yok Edilmesi veya Anonim Hale Getirilmesi Hakkında Yönetmelik m.11 uyarınca EN GEÇ 6 AYLIK PERİYOTLARLA yürütülen periyodik imha işlemiyle silinir, yok edilir veya anonim hâle getirilir.

Uygulama içinden hesabınızı silmeniz, şube aşamasında kiralama sözleşmesi kapsamında alınmış belgelerin silinmesi sonucunu doğurmaz; bu belgeler mevzuattan doğan saklama yükümlülüğüne tabidir.

7. TİCARİ ELEKTRONİK İLETİ

Uygulama üzerinden tarafınıza ticari elektronik ileti (SMS, e-posta, telefonla arama, WhatsApp mesajı veya anlık bildirim) GÖNDERİLMEZ. Uygulamada görünen kampanyalar yalnızca uygulama içinde görüntülenir; bunun için ayrıca kişisel veri işlenmez ve profilleme yapılmaz.

Şirket'in uygulama dışındaki kanallardan pazarlama amaçlı ticari elektronik ileti göndermesi hâlinde, 6563 sayılı Elektronik Ticaretin Düzenlenmesi Hakkında Kanun ve İleti Yönetim Sistemi (İYS) mevzuatı uyarınca ayrıca ve önceden onayınız alınır. Bu onayı vermemeniz, uygulamayı kullanmanıza engel değildir.

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

Silme hakkınızı uygulama içinden Profilim > Hesabımı Sil adımıyla doğrudan kullanabilirsiniz. Açık rızanızı da Profilim bölümünden tek dokunuşla geri alabilirsiniz.

9. VERİ SORUMLUSUNA BAŞVURU USULÜ

Veri Sorumlusuna Başvuru Usul ve Esasları Hakkında Tebliğ m.5 uyarınca taleplerinizi aşağıdaki kanallardan iletebilirsiniz:

• YAZILI OLARAK: Islak imzalı dilekçenizi ${SirketBilgileri.adres} adresine bizzat elden teslim ederek, noter vasıtasıyla ya da iadeli taahhütlü posta yoluyla göndererek. Şahsen başvuruda kimliğinizi tevsik edici belge ibraz etmeniz gerekir.
• KEP ADRESİ İLE: Kayıtlı elektronik posta adresinizden ${SirketBilgileri.kep} adresine göndererek.
• GÜVENLİ ELEKTRONİK VEYA MOBİL İMZA İLE: ${SirketBilgileri.kvkkEposta} adresine göndererek.
• KAYITLI E-POSTA ADRESİNİZLE: Daha önce Şirket'e bildirdiğiniz ve Şirket sisteminde KAYITLI OLAN e-posta adresinizi kullanarak ${SirketBilgileri.kvkkEposta} adresine göndererek. Sistemde kayıtlı olmayan bir adresten yapılan başvurular Tebliğ uyarınca geçerli sayılmayabilir.

Başvurunuzda; ad, soyad ve yazılı başvurularda imza, T.C. kimlik numarası (yabancılar için uyruk, pasaport numarası veya kimlik numarası), tebligata esas yerleşim yeri veya iş yeri adresi, varsa bildirime esas elektronik posta adresi, telefon ve faks numarası ile talep konusu bulunması zorunludur. Konuya ilişkin bilgi ve belgeler başvuruya eklenmelidir.

Başvurularınız niteliğine göre en kısa sürede ve en geç 30 GÜN içinde sonuçlandırılır. İşlem ayrıca bir maliyet gerektirmiyorsa ücretsizdir; maliyet gerektirmesi hâlinde Kurulca belirlenen tarifedeki ücret alınabilir.

Başvurunuzun reddedilmesi, verilen cevabı yetersiz bulmanız veya süresinde cevap verilmemesi hâlinde; cevabı öğrendiğiniz tarihten itibaren 30 gün ve her hâlde başvuru tarihinden itibaren 60 gün içinde Kişisel Verileri Koruma Kurulu'na şikâyette bulunabilirsiniz.

Şirketimizin kişisel verilerin korunmasına ilişkin genel politikasına ${SirketBilgileri.gizlilikUrl} adresinden ulaşabilirsiniz.
''';

  // ── AÇIK RIZA METNİ (KVKK m.5/1, m.9) ──────────────────────────
  static const String acikRizaBaslik = 'Açık Rıza Metni';

  static String get acikRizaMetni => '''
Son güncelleme: ${SirketBilgileri.sonGuncelleme}

BU RIZA ZORUNLU DEĞİLDİR VE HİÇBİR HİZMETİN ŞARTI DEĞİLDİR.

Rezervasyon talebinizi uygulama içinden, doğrudan ${SirketBilgileri.unvan} sistemlerine iletebilirsiniz. Bu yol için hiçbir açık rıza gerekmez ve verileriniz WhatsApp'a hiç uğramaz. Aşağıdaki rıza, YALNIZCA talebinizi ayrıca WhatsApp üzerinden iletmeyi tercih etmeniz hâlinde gereklidir.

RIZANIN KONUSU

Aydınlatma Metni'ni okuduğumu ve anladığımı beyan ederim.

Rezervasyon talebimin WhatsApp üzerinden iletilebilmesi amacıyla; ad, soyad, telefon numaram, kiralama bilgilerim ve tarafımca doldurulması hâlinde T.C. Kimlik Numaramın, WhatsApp (Meta Platforms) uygulaması üzerinden ${SirketBilgileri.unvan}'ne iletilmesine ve bu kapsamda söz konusu verilerin sunucuları yurt dışında bulunan WhatsApp altyapısı üzerinden aktarılmasına, 6698 sayılı Kanun'un 5. ve 9. maddeleri uyarınca AÇIK RIZAM ile onay veriyorum.

Rıza yalnızca bu aktarımı kapsar. Reklam, pazarlama, ticari elektronik ileti gönderimi veya profilleme için kullanılmaz.

RIZA VERMEZSENİZ NE OLUR

Hiçbir şey kısıtlanmaz. Üye olabilir, araçları inceleyebilir, favorilerinize ekleyebilir ve rezervasyon talebinizi uygulama içinden gönderebilirsiniz. Ayrıca telefon veya şube kanallarını da kullanabilirsiniz. Yalnızca WhatsApp kanalı kapalı kalır.

RIZAYI GERİ ALMA

Rızanızı dilediğiniz zaman, herhangi bir gerekçe göstermeksizin geri alabilirsiniz:

• Uygulama içindeki "Profilim" bölümünden tek dokunuşla,
• ${SirketBilgileri.kvkkEposta} adresine yazılı başvuruyla,
• ${SirketBilgileri.kep} KEP adresine yazılı başvuruyla,
• ${SirketBilgileri.adres} adresine ıslak imzalı dilekçeyle.

Geri alma, geri alma tarihinden sonraki aktarımları etkiler; o tarihe kadar hukuka uygun biçimde yapılmış işlemleri etkilemez. Rızanızı geri aldığınızda uygulama içi gönderim yolunu kullanmaya devam edebilirsiniz.
''';

  // ── KULLANIM KOŞULLARI ─────────────────────────────────────────
  static const String kullanimKosullariBaslik = 'Kullanım Koşulları';

  static String get kullanimKosullariMetni => '''
Son güncelleme: ${SirketBilgileri.sonGuncelleme}

1. TARAFLAR VE KONU

Bu koşullar, ${SirketBilgileri.unvan} tarafından sunulan Şenbayrak Araç Kiralama mobil uygulamasının kullanımına ilişkindir. Uygulamayı kullanarak bu koşulları kabul etmiş sayılırsınız.

2. HİZMETİN KAPSAMI

Uygulama, araç kiralama filosunun görüntülenmesini ve rezervasyon TALEBİ iletilmesini sağlar. Talebinizi uygulama içinden doğrudan gönderebilir veya dilerseniz WhatsApp kanalını kullanabilirsiniz; seçim sizindir.

Uygulama üzerinden iletilen talep bir REZERVASYON GARANTİSİ DEĞİLDİR. Rezervasyonunuz, Şirket tarafından telefon veya WhatsApp yoluyla teyit edilmesi ve ödemenin tamamlanmasıyla kesinleşir. Uygulamada gösterilen günlük fiyatlar bilgilendirme amaçlıdır; nihai fiyat, kiralama süresi, ek hizmetler ve güncel koşullara göre teyit sırasında bildirilir.

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

Bu politika, Şenbayrak Araç Kiralama uygulamasının kişisel verilerinizi nasıl işlediğini özetler. Ayrıntılı bilgi için Aydınlatma Metni'ni inceleyiniz.

TOPLADIĞIMIZ VERİLER

• Hesap bilgileri: Ad, soyad, e-posta adresi, telefon numarası
• Kullanım bilgileri: Favori araçlarınız, ilettiğiniz rezervasyon talepleri

Konum verisi toplamıyoruz. Reklam kimliği kullanmıyoruz. Üçüncü taraf reklam ağlarına veri aktarmıyoruz. Verilerinizi satmıyoruz.

REZERVASYON TALEBİNİ NASIL İLETİRSİNİZ

İki yol vardır ve seçim sizindir:

• Uygulama içinden gönderim (varsayılan): Talebiniz doğrudan Şirket sistemlerine kaydedilir. Açık rıza gerekmez, veriniz WhatsApp'a uğramaz.
• WhatsApp ile gönderim (isteğe bağlı): Yalnızca açık rıza vermeniz hâlinde kullanılabilir. Rıza vermemeniz uygulamanın hiçbir işlevini kısıtlamaz.

T.C. KİMLİK NUMARASI

T.C. Kimlik Numaranız veritabanımızda saklanmaz. Girmeniz zorunlu değildir; yalnızca WhatsApp ile gönderimi seçip alanı doldurmanız hâlinde, sözleşme hazırlığı amacıyla mesaja eklenir.

VERİLERİN SAKLANDIĞI YER

Verileriniz Google Firebase (Firestore, Authentication, Storage) altyapısında, Avrupa Birliği sınırları içindeki sunucularda (Belçika — europe-west1) barındırılmaktadır. Bu, KVKK m.9 kapsamında yurt dışına aktarım sayılır; dayanılan güvence: ${SirketBilgileri.firebaseAktarimDayanagi}

ÜÇÜNCÜ TARAFLAR

• Google Firebase — teknik altyapı
• WhatsApp (Meta Platforms) — yalnızca bu kanalı seçmeniz ve açık rıza vermeniz hâlinde

TİCARİ ELEKTRONİK İLETİ

Uygulama üzerinden SMS, e-posta, arama veya anlık bildirim yoluyla pazarlama iletisi göndermiyoruz. Kampanyalar yalnızca uygulama içinde görüntülenir.

ÇOCUKLARIN GİZLİLİĞİ

Uygulama 18 yaşın altındaki kişilere yönelik değildir ve bu kişilerden bilerek veri toplanmaz.

HAKLARINIZ VE VERİ SİLME

Hesabınızı ve tüm kişisel verilerinizi uygulama içinden Profilim > Hesabımı Sil adımıyla kalıcı olarak silebilirsiniz. Diğer talepleriniz için: ${SirketBilgileri.kvkkEposta}

DEĞİŞİKLİKLER

Bu politikada yapılacak değişiklikler uygulama içinde yayımlanır ve yürürlük tarihi belirtilir.

İLETİŞİM

${SirketBilgileri.unvan}
${SirketBilgileri.adres}
${SirketBilgileri.kvkkEposta}
''';
}
