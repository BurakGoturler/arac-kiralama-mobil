// ═══════════════════════════════════════════════════════════════════
//  Kişisel veri işleme envanteri ve saklama süreleri — TEK KAYNAK.
//
//  Neden ayrı ve yapılandırılmış:
//  Dış avukatın KVKK analizindeki 11 numaralı bulgu, saklama sürelerinin
//  veri kategorisi bazında belirsiz olmasıydı. Süreler eskiden üç yerde
//  ayrı ayrı yazılıyordu (aydınlatma metni, site politikası, imha kodu);
//  biri değişip öbürü değişmediğinde metin ile uygulama birbirinden
//  sessizce ayrışıyordu.
//
//  Artık:
//    • Aydınlatma metninin 4. ve 6. bölümleri,
//    • Kişisel Veri Saklama ve İmha Politikası,
//    • Kişisel Veri İşleme Envanteri,
//    • FirestoreService.deleteExpiredWhatsAppLogs (imha kodu)
//  hepsi bu dosyadan beslenir. Süre burada değişirse hepsi birlikte değişir.
//
//  Bu dosya saf Dart'tır (Flutter içe aktarmaz); tools/metinleri_disa_aktar.dart
//  onu doğrudan çalıştırıp site sayfalarını ve PDF belgelerini üretir.
// ═══════════════════════════════════════════════════════════════════

/// Envanterdeki tek bir işleme faaliyeti.
class IslemeFaaliyeti {
  /// Faaliyetin kısa adı (envanter tablosunun ilk sütunu).
  final String surec;

  /// Faaliyetin yürüdüğü yer: 'Mobil uygulama', 'WhatsApp Business hattı', 'Şube'.
  final String ortam;

  /// Aydınlatma metninde kullanıcıya gösterilen amaç cümlesi.
  final String amac;

  /// İşlenen veriler.
  final String veriler;

  /// KVKK m.5 kapsamındaki hukuki sebep; "KVKK m." ile başlamalıdır.
  final String hukukiSebep;

  /// Toplama yöntemi (KVKK m.10/1-ç).
  final String toplamaYontemi;

  /// Alıcı / alıcı grupları. Yoksa 'Aktarılmaz'.
  final String alicilar;

  /// Yurt dışına aktarım durumu.
  final String yurtDisi;

  /// [SaklamaSureleri.kategoriler] içindeki kategori adı.
  final String saklamaKategorisi;

  /// Faaliyet açık rızaya dayanıyorsa true. Yalnızca İSTEĞE BAĞLI
  /// faaliyetlerde olabilir; üyelik, rezervasyon ve kiralama asla rızaya
  /// bağlanmaz (test ile denetlenir).
  final bool acikRizayaDayali;

  const IslemeFaaliyeti({
    required this.surec,
    required this.ortam,
    required this.amac,
    required this.veriler,
    required this.hukukiSebep,
    required this.toplamaYontemi,
    required this.alicilar,
    required this.yurtDisi,
    required this.saklamaKategorisi,
    this.acikRizayaDayali = false,
  });
}

/// Tek bir veri kategorisinin saklama kuralı.
class SaklamaSuresi {
  final String kategori;
  final String kayitOrtami;
  final String sure;
  final String dayanak;
  final String imhaYontemi;

  const SaklamaSuresi({
    required this.kategori,
    required this.kayitOrtami,
    required this.sure,
    required this.dayanak,
    required this.imhaYontemi,
  });
}

class SaklamaSureleri {
  /// Rezervasyon talep kayıtlarının azami saklama süresi (gün).
  /// FirestoreService.deleteExpiredWhatsAppLogs doğrudan bunu kullanır;
  /// metindeki "2 yıl" ifadesiyle eşleştiği test ile denetlenir.
  static const int rezervasyonKaydiGun = 730;

  /// Periyodik imha aralığı. İmha Yönetmeliği m.11 en geç 6 ay öngörür.
  static const int periyodikImhaAy = 6;

  /// Yönetim panelinin "imha gecikti" uyarısı için gün karşılığı.
  static const int periyodikImhaGun = 180;

  /// İmha işlemlerine ilişkin kayıtların (tutanakların) saklama süresi.
  /// İmha Yönetmeliği m.7/3: diğer hukuki yükümlülükler hariç en az 3 yıl.
  static const int imhaKaydiYil = 3;

  // Kategori adları — faaliyetler bu sabitlerle bağlanır ki yazım farkı
  // yüzünden bir faaliyet süresiz kalmasın (test ile denetlenir).
  static const String uyelik = 'Üyelik hesabı verileri';
  static const String kimlikDogrulama = 'Kimlik doğrulama ve işlem güvenliği kayıtları';
  static const String onayKaydi = 'Üyelik beyan kayıtları';
  static const String kampanyaOnayi = 'Kampanya iletişimi onay ve ret kayıtları';
  static const String rezervasyonKaydi = 'Rezervasyon talep kayıtları';
  static const String whatsappYazisma = 'WhatsApp yazışmaları';
  static const String subeBelgeleri = 'Şube aşamasında alınan belgeler';
  static const String muhasebe = 'Fatura ve muhasebe kayıtları';
  static const String imhaKaydi = 'İmha kayıtları';

  static const List<SaklamaSuresi> kategoriler = [
    SaklamaSuresi(
      kategori: uyelik,
      kayitOrtami: 'Google Firebase — Cloud Firestore (elektronik)',
      sure: 'Hesap açık kaldığı sürece; hesap silindiğinde derhal',
      dayanak: 'Üyelik sözleşmesinin devamı (KVKK m.5/2-c)',
      imhaYontemi: 'Veritabanından kalıcı silme',
    ),
    SaklamaSuresi(
      kategori: kimlikDogrulama,
      kayitOrtami: 'Google Firebase — Authentication ve App Check (elektronik)',
      sure: 'Hesap açık kaldığı sürece; hesap silindiğinde derhal',
      dayanak: 'Veri güvenliği yükümlülüğü (KVKK m.12)',
      imhaYontemi: 'Kimlik doğrulama kaydının kalıcı silinmesi',
    ),
    SaklamaSuresi(
      kategori: onayKaydi,
      kayitOrtami: 'Google Firebase — Cloud Firestore (elektronik)',
      sure: 'Hesap açık kaldığı sürece; hesap silindiğinde derhal',
      dayanak: 'Aydınlatma yükümlülüğünün ispatı (KVKK m.10)',
      imhaYontemi: 'Veritabanından kalıcı silme',
    ),
    SaklamaSuresi(
      kategori: kampanyaOnayi,
      kayitOrtami: 'Google Firebase — Cloud Firestore (elektronik); İleti Yönetim Sistemi (İYS)',
      sure: 'Uygulamada onay geri alınana veya hesap silinene kadar; İYS\'deki kayıtlar ilgili mevzuatın öngördüğü süre boyunca',
      dayanak: '6563 sayılı Kanun ve Ticari İletişim ve Ticari Elektronik İletiler Hakkında Yönetmelik',
      imhaYontemi: 'Onay geri alındığında gönderim listesinden derhal çıkarma; hesap silindiğinde veritabanından kalıcı silme',
    ),
    SaklamaSuresi(
      kategori: rezervasyonKaydi,
      kayitOrtami: 'Google Firebase — Cloud Firestore (elektronik)',
      sure: 'Kayıt tarihinden itibaren 2 yıl; hesap daha önce silinirse derhal',
      dayanak: 'Talebin takibi ve olası uyuşmazlıkta ispat (KVKK m.5/2-c, m.5/2-e)',
      imhaYontemi: 'Periyodik imhada yönetim panelinden kalıcı silme',
    ),
    SaklamaSuresi(
      kategori: whatsappYazisma,
      kayitOrtami: 'Şirket WhatsApp Business hattı (elektronik)',
      sure: 'Son yazışma tarihinden itibaren 2 yıl',
      dayanak: 'Talebin takibi ve olası uyuşmazlıkta ispat (KVKK m.5/2-c, m.5/2-e)',
      imhaYontemi: 'Periyodik imhada ilgili sohbetin medya dosyalarıyla birlikte silinmesi',
    ),
    SaklamaSuresi(
      kategori: subeBelgeleri,
      kayitOrtami: 'Şube fiziki arşivi',
      sure: 'Kiralama sözleşmesinin sona ermesinden itibaren 10 yıl',
      dayanak: '6098 sayılı Türk Borçlar Kanunu m.146 genel zamanaşımı',
      imhaYontemi: 'Evrak imha makinesiyle geri döndürülemez biçimde yok etme',
    ),
    SaklamaSuresi(
      kategori: muhasebe,
      kayitOrtami: 'Muhasebe kayıtları (fiziki ve elektronik)',
      sure: 'İlgili yılı izleyen takvim yılı başından itibaren 10 yıl',
      dayanak: '6102 sayılı Türk Ticaret Kanunu m.82; 213 sayılı Vergi Usul Kanunu m.253',
      imhaYontemi: 'Evrak imha makinesiyle yok etme / elektronik kaydın kalıcı silinmesi',
    ),
    SaklamaSuresi(
      kategori: imhaKaydi,
      kayitOrtami: 'Google Firebase — Cloud Firestore (elektronik); müşteri kişisel verisi içermez',
      sure: 'İmha tarihinden itibaren en az 3 yıl',
      dayanak: 'Kişisel Verilerin Silinmesi, Yok Edilmesi veya Anonim Hale Getirilmesi Hakkında Yönetmelik m.7/3',
      imhaYontemi: 'Süre sonunda kalıcı silme',
    ),
  ];

  static SaklamaSuresi? bul(String kategori) {
    for (final k in kategoriler) {
      if (k.kategori == kategori) return k;
    }
    return null;
  }
}

class KvkkEnvanter {
  static const String _firebase =
      'Google Firebase (veri işleyen) — sunucular AB içinde (Belçika). '
      'Dayanak: Firebase için belirlenen KVKK m.9 güvencesi';

  static const String _whatsapp =
      'WhatsApp Business (veri işleyen) — sunucular yurt dışında. '
      'Dayanak: Kurul standart sözleşmesi (Veri Sorumlusundan Veri İşleyene)';

  static const List<IslemeFaaliyeti> faaliyetler = [
    IslemeFaaliyeti(
      surec: 'Üyelik',
      ortam: 'Mobil uygulama',
      amac: 'Üyelik hesabınızın oluşturulması, yönetilmesi ve kimliğinizin doğrulanması',
      veriler: 'Ad, soyad, e-posta, telefon, şifre, e-posta doğrulama durumu',
      hukukiSebep: 'KVKK m.5/2-c — sözleşmenin kurulması ve ifası için gerekli olması',
      toplamaYontemi: 'Tamamen otomatik — uygulamadaki üyelik formu',
      alicilar: 'Aktarılmaz',
      yurtDisi: _firebase,
      saklamaKategorisi: SaklamaSureleri.uyelik,
    ),
    IslemeFaaliyeti(
      surec: 'Üyelik beyanları',
      ortam: 'Mobil uygulama',
      amac: 'Aydınlatma yükümlülüğünün yerine getirildiğinin ve Kullanım Koşulları kabulünün ispatı',
      veriler: 'Aydınlatma Metni\'nin okunduğuna ilişkin geri bildirim, Kullanım Koşulları kabulü, tarih, metin sürümü',
      hukukiSebep: 'KVKK m.5/2-ç — hukuki yükümlülüğün yerine getirilmesi ve KVKK m.5/2-c — sözleşmenin kurulması',
      toplamaYontemi: 'Tamamen otomatik — üyelik formundaki iki ayrı beyan kutusu',
      alicilar: 'Aktarılmaz',
      yurtDisi: _firebase,
      saklamaKategorisi: SaklamaSureleri.onayKaydi,
    ),
    IslemeFaaliyeti(
      surec: 'Kampanya iletişimi',
      ortam: 'Mobil uygulama, SMS ve WhatsApp Business hattı',
      amac: 'Onay vermeniz hâlinde araç kiralama kampanyaları, indirimleri ve fırsatları hakkında SMS ve WhatsApp ile ticari elektronik ileti gönderilmesi',
      veriler: 'Ad, soyad, cep telefonu numarası, onay ve geri alma tarihleri, onaylanan metin sürümü',
      hukukiSebep: 'KVKK m.5/1 — açık rıza (isteğe bağlıdır; 6563 sayılı Kanun m.6 uyarınca ticari elektronik ileti onayı ile birlikte alınır)',
      toplamaYontemi: 'Tamamen otomatik — üyelik formundaki ve Profilim bölümündeki isteğe bağlı onay',
      alicilar: 'İleti Yönetim Sistemi A.Ş. (onay ve ret kayıtları — KVKK m.5/2-ç), SMS hizmet sağlayıcısı (veri işleyen)',
      yurtDisi: '$_whatsapp (yalnızca WhatsApp ile gönderilen iletiler)',
      saklamaKategorisi: SaklamaSureleri.kampanyaOnayi,
      acikRizayaDayali: true,
    ),
    IslemeFaaliyeti(
      surec: 'Hesap güvenliği',
      ortam: 'Mobil uygulama',
      amac: 'Hesap güvenliğinin sağlanması, yetkisiz erişimin ve sahte istemcilerin engellenmesi',
      veriler: 'Oturum ve cihaz doğrulama kayıtları',
      hukukiSebep: 'KVKK m.5/2-ç — veri güvenliğine ilişkin hukuki yükümlülük (m.12) ve KVKK m.5/2-f — meşru menfaat',
      toplamaYontemi: 'Tamamen otomatik — Firebase Authentication ve App Check',
      alicilar: 'Aktarılmaz',
      yurtDisi: _firebase,
      saklamaKategorisi: SaklamaSureleri.kimlikDogrulama,
    ),
    IslemeFaaliyeti(
      surec: 'Favori araçlar',
      ortam: 'Mobil uygulama',
      amac: 'Favori araç listenizin tutulması',
      veriler: 'Favori araç kimlikleri',
      hukukiSebep: 'KVKK m.5/2-f — temel hak ve özgürlüklerinize zarar vermemek kaydıyla meşru menfaat',
      toplamaYontemi: 'Tamamen otomatik — favori işaretleme',
      alicilar: 'Aktarılmaz',
      yurtDisi: _firebase,
      saklamaKategorisi: SaklamaSureleri.uyelik,
    ),
    IslemeFaaliyeti(
      surec: 'Rezervasyon talep kaydı',
      ortam: 'Mobil uygulama',
      amac: 'WhatsApp hattımıza yönlendirilen rezervasyon taleplerinin yönetim panelinde takip edilmesi',
      veriler: 'Ad, soyad, telefon, araç, kiralama tarihleri, alım yeri, talep tarihi',
      hukukiSebep: 'KVKK m.5/2-c — sözleşmenin kurulmasıyla doğrudan ilgili olması',
      toplamaYontemi: 'Tamamen otomatik — rezervasyon ekranı',
      alicilar: 'Aktarılmaz',
      yurtDisi: _firebase,
      saklamaKategorisi: SaklamaSureleri.rezervasyonKaydi,
    ),
    IslemeFaaliyeti(
      surec: 'WhatsApp üzerinden rezervasyon',
      ortam: 'WhatsApp Business hattı',
      amac: 'Rezervasyon talebinizin WhatsApp hattımızdan alınması, değerlendirilmesi, fiyat ve koşulların teyit edilmesi',
      veriler: 'Ad, soyad, telefon, araç, kiralama tarihleri, alım yeri, yazmanız hâlinde T.C. Kimlik Numarası, yazışma içeriği',
      hukukiSebep: 'KVKK m.5/2-c — sözleşmenin kurulmasıyla doğrudan ilgili olması',
      toplamaYontemi: 'Kısmen otomatik — tarafınızca gönderilen WhatsApp mesajları',
      alicilar: 'Aktarılmaz (WhatsApp veri işleyen sıfatıyla hizmet verir)',
      yurtDisi: _whatsapp,
      saklamaKategorisi: SaklamaSureleri.whatsappYazisma,
    ),
    IslemeFaaliyeti(
      surec: 'Kampanya bilgi talebi',
      ortam: 'WhatsApp Business hattı',
      amac: 'Kampanya kartlarındaki düğmeyle WhatsApp hattımıza yazmanız hâlinde talebinize yanıt verilmesi',
      veriler: 'Telefon, WhatsApp profil adı, yazışma içeriği',
      hukukiSebep: 'KVKK m.5/2-c — sözleşmenin kurulmasıyla doğrudan ilgili olması',
      toplamaYontemi: 'Kısmen otomatik — tarafınızca gönderilen WhatsApp mesajları',
      alicilar: 'Aktarılmaz (WhatsApp veri işleyen sıfatıyla hizmet verir)',
      yurtDisi: _whatsapp,
      saklamaKategorisi: SaklamaSureleri.whatsappYazisma,
    ),
    IslemeFaaliyeti(
      surec: 'Kiralama sözleşmesi',
      ortam: 'Şube',
      amac: 'Kiralama sözleşmesinin kurulması ve ifası, kimlik ve sürücü belgesinin kontrolü',
      veriler: 'Kimlik belgesi bilgileri (T.C. Kimlik Numarası dâhil), sürücü belgesi bilgileri, yerleşim yeri belgesi, sözleşme bilgileri',
      hukukiSebep: 'KVKK m.5/2-c — sözleşmenin kurulması ve ifası için gerekli olması',
      toplamaYontemi: 'Otomatik olmayan — şubede fiziki belge ibrazı ve sözleşme imzası',
      alicilar: 'Sigorta şirketleri, ekspertiz ve servis firmaları, yetkili trafik muayene istasyonları, ödeme kuruluşu / banka',
      yurtDisi: 'Yok',
      saklamaKategorisi: SaklamaSureleri.subeBelgeleri,
    ),
    IslemeFaaliyeti(
      surec: 'KABİS bildirimi',
      ortam: 'Şube',
      amac: 'Kiralama işleminin Emniyet Genel Müdürlüğü Kiralık Araç Bildirim Sistemi\'ne (KABİS) bildirilmesi',
      veriler: 'Kimlik, sürücü belgesi, araç ve kiralama bilgileri',
      hukukiSebep: 'KVKK m.5/2-a — kanunlarda açıkça öngörülmesi ve KVKK m.5/2-ç — hukuki yükümlülüğün yerine getirilmesi',
      toplamaYontemi: 'Otomatik olmayan — şubede sözleşme bilgilerinden',
      alicilar: 'Emniyet Genel Müdürlüğü',
      yurtDisi: 'Yok',
      saklamaKategorisi: SaklamaSureleri.subeBelgeleri,
    ),
    IslemeFaaliyeti(
      surec: 'Risk değerlendirmesi',
      ortam: 'Şube',
      amac: 'Kiralama öncesi risk değerlendirmesi yapılması',
      veriler: 'Findeks / Kredi Kayıt Bürosu sorgu sonucu',
      hukukiSebep: 'KVKK m.5/2-f — meşru menfaat',
      toplamaYontemi: 'Üçüncü kaynak — Kredi Kayıt Bürosu / Findeks sorgusu',
      alicilar: 'Kredi Kayıt Bürosu / Findeks',
      yurtDisi: 'Yok',
      saklamaKategorisi: SaklamaSureleri.subeBelgeleri,
    ),
    IslemeFaaliyeti(
      surec: 'Fatura ve muhasebe',
      ortam: 'Şube',
      amac: 'Fatura düzenlenmesi ve muhasebe kayıtlarının tutulması',
      veriler: 'Ad, soyad, T.C. Kimlik Numarası, adres, fatura ve ödeme tutarı bilgileri',
      hukukiSebep: 'KVKK m.5/2-ç — hukuki yükümlülüğün yerine getirilmesi (213 sayılı VUK, 6102 sayılı TTK)',
      toplamaYontemi: 'Otomatik olmayan — sözleşme ve ödeme bilgilerinden',
      alicilar: 'Yetkili kamu kurumları, mali müşavir ve bağımsız denetim',
      yurtDisi: 'Yok',
      saklamaKategorisi: SaklamaSureleri.muhasebe,
    ),
    IslemeFaaliyeti(
      surec: 'Uyuşmazlık yönetimi',
      ortam: 'Şube',
      amac: 'Uyuşmazlık hâlinde delil sağlanması ve hukuki taleplerin takibi',
      veriler: 'Sözleşme, yazışma ve işlem kayıtları',
      hukukiSebep: 'KVKK m.5/2-e — bir hakkın tesisi, kullanılması veya korunması için zorunlu olması',
      toplamaYontemi: 'Otomatik olmayan — mevcut kayıtlardan',
      alicilar: 'Avukatlar, mahkemeler ve icra daireleri',
      yurtDisi: 'Yok',
      saklamaKategorisi: SaklamaSureleri.subeBelgeleri,
    ),
  ];
}
