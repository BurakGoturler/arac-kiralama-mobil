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

  /// Metinlerin son güncellenme tarihi
  static const String sonGuncelleme = '07.09.2026';

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
Telefon: ${SirketBilgileri.telefon}
VERBİS: ${SirketBilgileri.verbis}

2. İŞLENEN KİŞİSEL VERİLER

Uygulama üzerinden aşağıdaki kişisel verileriniz işlenmektedir:

• Kimlik bilgisi: Ad, soyad
• İletişim bilgisi: Cep telefonu numarası, e-posta adresi
• İşlem bilgisi: Seçtiğiniz araç, kiralama tarihleri, alım yeri, favori araç listeniz
• Kimlik doğrulama bilgisi: Hesap şifreniz (şifreniz Şirket tarafından görülemez; Firebase Authentication altyapısında geri döndürülemez biçimde saklanır)

T.C. Kimlik Numaranız uygulama veritabanında SAKLANMAZ. Rezervasyon talebinizi ilettiğiniz anda, yalnızca kiralama sözleşmesinin hazırlanabilmesi amacıyla oluşturulan WhatsApp mesajına eklenir ve tarafınızca gönderilir.

ÖDEME BİLGİSİ TOPLANMAZ. Uygulama; kart numarası, son kullanma tarihi, CVV, banka hesabı veya IBAN bilgisi toplamaz, işlemez ve saklamaz. Ödeme, teyit sürecinde tarafınıza iletilecek banka ödeme bağlantısı üzerinden, ilgili bankanın kendi güvenli sayfasında gerçekleşir.

3. İŞLEME AMAÇLARI

• Araç kiralama talebinizin alınması ve değerlendirilmesi
• Sizinle iletişime geçilmesi, fiyat ve ödeme bilgisi iletilmesi
• Üyelik hesabınızın oluşturulması ve yönetilmesi
• Favori araç listesi gibi kullanıcı deneyimini iyileştiren özelliklerin sunulması
• Hukuki yükümlülüklerin yerine getirilmesi ve uyuşmazlık hâlinde delil sağlanması

4. HUKUKİ SEBEP

Kişisel verileriniz KVKK m.5 uyarınca;
• Sözleşmenin kurulması veya ifasıyla doğrudan ilgili olması (m.5/2-c),
• Şirketin hukuki yükümlülüğünü yerine getirmesi (m.5/2-ç),
• Meşru menfaat (m.5/2-f) ve
• WhatsApp üzerinden yapılan aktarım bakımından AÇIK RIZANIZ (m.5/1)
hukuki sebeplerine dayanılarak işlenmektedir.

5. AKTARIM

Rezervasyon talebiniz, tarafınızca WhatsApp uygulaması üzerinden Şirket'e iletilir. Bu iletim sırasında ad, soyad, telefon numarası, T.C. Kimlik Numarası ve kiralama bilgileriniz WhatsApp (Meta Platforms) altyapısı üzerinden geçer. WhatsApp sunucuları yurt dışında bulunduğundan bu işlem KVKK m.9 kapsamında YURT DIŞINA VERİ AKTARIMI niteliğindedir ve yalnızca açık rızanız ile gerçekleştirilir.

Verileriniz ayrıca, uygulamanın teknik altyapısını sağlayan Google Firebase hizmetlerinde barındırılmaktadır. Veritabanı sunucuları Avrupa Birliği sınırları içinde (Belçika — europe-west1 bölgesi) konumlandırılmıştır.

Rezervasyon talebiniz teyit edilip kiralama süreci başladığında, kiralama sözleşmesinin ifası kapsamında verileriniz aşağıdaki taraflara KVKK m.8 ve m.9'da belirtilen şartlara uygun olarak aktarılabilir:

• Ödeme kuruluşu / banka — yalnızca ödeme işleminin gerçekleştirilmesi amacıyla
• Sigorta şirketleri — poliçe düzenlenmesi ve hasar süreçlerinin yürütülmesi amacıyla
• Ekspertiz ve servis firmaları — araç durum tespiti ve bakım-onarım amacıyla
• Yetkili trafik muayene istasyonları — mevzuat gereği muayene süreçlerinin takibi amacıyla
• Yetkili kamu kurum ve kuruluşları — yasal yükümlülüklerin yerine getirilmesi amacıyla

Bu aktarımlar uygulama üzerinden DEĞİL, kiralama sözleşmesi aşamasında şube süreçleri kapsamında gerçekleşir.

Rızanızı vermemeniz hâlinde uygulamaya üye olabilir ve araçları inceleyebilirsiniz; ancak rezervasyon talebi iletemezsiniz. Bu durumda telefon yoluyla doğrudan iletişime geçebilirsiniz.

6. SAKLAMA SÜRESİ

• Üyelik verileriniz: Hesabınız açık kaldığı sürece
• Rezervasyon talep kayıtları: Kayıt tarihinden itibaren 2 yıl
• Hesabınızı sildiğinizde: Verileriniz derhal ve kalıcı olarak silinir

7. HAKLARINIZ (KVKK m.11)

Kişisel verilerinizle ilgili olarak; işlenip işlenmediğini öğrenme, bilgi talep etme, işlenme amacını öğrenme, aktarıldığı üçüncü kişileri bilme, eksik veya yanlış işlenmişse düzeltilmesini isteme, silinmesini veya yok edilmesini isteme, işlemenin sınırlandırılmasını isteme, otomatik sistemlerle analiz sonucu aleyhinize bir sonuç doğmasına itiraz etme ve zarara uğramanız hâlinde tazminat talep etme haklarına sahipsiniz.

Silme hakkınızı uygulama içinden Profilim > Hesabımı Sil adımıyla doğrudan kullanabilirsiniz.

Diğer talepleriniz için ${SirketBilgileri.kvkkEposta} adresine, KEP kullanıyorsanız ${SirketBilgileri.kep} adresine yazılı olarak veya güvenli elektronik/mobil imzanızla başvurabilirsiniz. Başvurularınız niteliğine göre en kısa sürede ve en geç 30 gün içinde ücretsiz olarak sonuçlandırılır.

Şirketimizin kişisel verilerin korunmasına ilişkin genel politikasına ${SirketBilgileri.gizlilikUrl} adresinden ulaşabilirsiniz.
''';

  // ── AÇIK RIZA METNİ (KVKK m.5/1, m.9) ──────────────────────────
  static const String acikRizaBaslik = 'Açık Rıza Metni';

  static String get acikRizaMetni => '''
Son güncelleme: ${SirketBilgileri.sonGuncelleme}

Aydınlatma Metni'ni okuduğumu ve anladığımı beyan ederim.

Rezervasyon talebimin iletilebilmesi amacıyla ad, soyad, telefon numarası, T.C. Kimlik Numaram ve kiralama bilgilerimin WhatsApp (Meta Platforms) uygulaması üzerinden ${SirketBilgileri.unvan}'ne iletilmesine ve bu kapsamda söz konusu verilerin sunucuları yurt dışında bulunan WhatsApp altyapısı üzerinden aktarılmasına, 6698 sayılı Kanun'un 5. ve 9. maddeleri uyarınca AÇIK RIZAM ile onay veriyorum.

Bu rızayı vermek zorunda değilsiniz. Rıza vermeden de üye olabilir ve araçları inceleyebilirsiniz; yalnızca uygulama üzerinden rezervasyon talebi iletemezsiniz.

Rızanızı dilediğiniz zaman, herhangi bir gerekçe göstermeksizin geri alabilirsiniz:

• Uygulama içindeki "Profilim" bölümünden tek dokunuşla,
• ${SirketBilgileri.kvkkEposta} adresine yazılı başvuruyla,
• ${SirketBilgileri.kep} KEP adresine yazılı başvuruyla.

Geri alma, geri alma tarihinden sonraki aktarımları etkiler; o tarihe kadar hukuka uygun biçimde yapılmış işlemleri etkilemez.

Rıza vermemeniz hâlinde rezervasyon talebinizi telefon veya şube gibi açık rıza gerektirmeyen kanallarımızdan iletmeniz her zaman mümkündür.
''';

  // ── KULLANIM KOŞULLARI ─────────────────────────────────────────
  static const String kullanimKosullariBaslik = 'Kullanım Koşulları';

  static String get kullanimKosullariMetni => '''
Son güncelleme: ${SirketBilgileri.sonGuncelleme}

1. TARAFLAR VE KONU

Bu koşullar, ${SirketBilgileri.unvan} tarafından sunulan Şenbayrak Araç Kiralama mobil uygulamasının kullanımına ilişkindir. Uygulamayı kullanarak bu koşulları kabul etmiş sayılırsınız.

2. HİZMETİN KAPSAMI

Uygulama, araç kiralama filosunun görüntülenmesini ve rezervasyon TALEBİ iletilmesini sağlar.

Uygulama üzerinden iletilen talep bir REZERVASYON GARANTİSİ DEĞİLDİR. Rezervasyonunuz, Şirket tarafından WhatsApp üzerinden teyit edilmesi ve ödemenin tamamlanmasıyla kesinleşir. Uygulamada gösterilen günlük fiyatlar bilgilendirme amaçlıdır; nihai fiyat, kiralama süresi, ek hizmetler ve güncel koşullara göre teyit sırasında bildirilir.

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

T.C. KİMLİK NUMARASI

T.C. Kimlik Numaranız veritabanımızda saklanmaz. Yalnızca rezervasyon talebinizi ilettiğiniz anda, sözleşme hazırlığı amacıyla WhatsApp mesajına eklenir.

VERİLERİN SAKLANDIĞI YER

Verileriniz Google Firebase (Firestore, Authentication, Storage) altyapısında, Avrupa Birliği sınırları içindeki sunucularda (Belçika — europe-west1) barındırılmaktadır.

ÜÇÜNCÜ TARAFLAR

• Google Firebase — teknik altyapı
• WhatsApp (Meta Platforms) — rezervasyon talebinizin iletilmesi (yalnızca açık rızanızla)

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
