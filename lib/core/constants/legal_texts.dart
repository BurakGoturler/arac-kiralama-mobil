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

  /// KVKK başvurularının iletileceği e-posta
  // TODO(şirket): KVKK başvuru e-postası belirlenip yazılmalı.
  static const String kvkkEposta = '[KVKK@ORNEK.COM]';

  /// İletişim telefonu
  // TODO(şirket): Tebligata esas sabit/GSM numarası yazılmalı.
  static const String telefon = '[TELEFON]';

  /// VERBİS kaydı varsa sicil numarası, yoksa "Kayıt yükümlülüğü
  /// bulunmamaktadır" ifadesi bırakılabilir.
  // TODO(şirket): VERBİS kaydı sorgulanıp sicil no ya da muafiyet beyanı yazılmalı.
  static const String verbis = '[VERBİS SİCİL NO / MUAFİYET BEYANI]';

  /// Gizlilik politikasının yayınlandığı herkese açık adres
  // TODO(şirket): Politika bir web adresinde yayınlanmalı — mağazalar şart koşuyor.
  static const String gizlilikUrl = '[https://ornek.com/gizlilik]';

  /// Metinlerin son güncellenme tarihi
  static const String sonGuncelleme = '27.07.2026';

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

Verileriniz ayrıca, uygulamanın teknik altyapısını sağlayan Google Firebase hizmetlerinde barındırılmaktadır.

Rızanızı vermemeniz hâlinde uygulamaya üye olabilir ve araçları inceleyebilirsiniz; ancak rezervasyon talebi iletemezsiniz. Bu durumda telefon yoluyla doğrudan iletişime geçebilirsiniz.

6. SAKLAMA SÜRESİ

• Üyelik verileriniz: Hesabınız açık kaldığı sürece
• Rezervasyon talep kayıtları: Kayıt tarihinden itibaren 2 yıl
• Hesabınızı sildiğinizde: Verileriniz derhal ve kalıcı olarak silinir

7. HAKLARINIZ (KVKK m.11)

Kişisel verilerinizle ilgili olarak; işlenip işlenmediğini öğrenme, bilgi talep etme, işlenme amacını öğrenme, aktarıldığı üçüncü kişileri bilme, eksik veya yanlış işlenmişse düzeltilmesini isteme, silinmesini veya yok edilmesini isteme, işlemenin sınırlandırılmasını isteme, otomatik sistemlerle analiz sonucu aleyhinize bir sonuç doğmasına itiraz etme ve zarara uğramanız hâlinde tazminat talep etme haklarına sahipsiniz.

Silme hakkınızı uygulama içinden Profilim > Hesabımı Sil adımıyla doğrudan kullanabilirsiniz.

Diğer talepleriniz için ${SirketBilgileri.kvkkEposta} adresine başvurabilirsiniz. Başvurularınız en geç 30 gün içinde sonuçlandırılır.
''';

  // ── AÇIK RIZA METNİ (KVKK m.5/1, m.9) ──────────────────────────
  static const String acikRizaBaslik = 'Açık Rıza Metni';

  static String get acikRizaMetni => '''
Son güncelleme: ${SirketBilgileri.sonGuncelleme}

Aydınlatma Metni'ni okuduğumu ve anladığımı beyan ederim.

Rezervasyon talebimin iletilebilmesi amacıyla ad, soyad, telefon numarası, T.C. Kimlik Numaram ve kiralama bilgilerimin WhatsApp (Meta Platforms) uygulaması üzerinden ${SirketBilgileri.unvan}'ne iletilmesine ve bu kapsamda söz konusu verilerin sunucuları yurt dışında bulunan WhatsApp altyapısı üzerinden aktarılmasına, 6698 sayılı Kanun'un 5. ve 9. maddeleri uyarınca AÇIK RIZAM ile onay veriyorum.

Bu rızayı vermek zorunda değilsiniz. Rıza vermeden de üye olabilir ve araçları inceleyebilirsiniz; yalnızca uygulama üzerinden rezervasyon talebi iletemezsiniz.

Rızanızı dilediğiniz zaman ${SirketBilgileri.kvkkEposta} adresine bildirerek geri alabilirsiniz. Geri alma, o tarihe kadar yapılmış işlemleri etkilemez.
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

Bu koşullara Türkiye Cumhuriyeti hukuku uygulanır. Uyuşmazlıklarda [YETKİLİ MAHKEME VE İCRA DAİRELERİ] yetkilidir. Tüketici sıfatını haiz kullanıcılar için tüketici hakem heyetleri ve tüketici mahkemelerinin yetkisi saklıdır.

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

Verileriniz Google Firebase (Firestore, Authentication, Storage) altyapısında barındırılmaktadır.

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
