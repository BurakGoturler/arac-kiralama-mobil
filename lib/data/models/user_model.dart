import 'package:cloud_firestore/cloud_firestore.dart';

/// Uygulama kullanıcısı.
///
/// NOT: T.C. Kimlik Numarası bilinçli olarak BU MODELDE YER ALMAZ ve
/// veritabanında saklanmaz. Rezervasyon ekranında isteğe bağlı olarak
/// yazılırsa yalnızca WhatsApp mesajına eklenir ve hiçbir yere yazılmaz.
/// Bu karar KVKK kapsamındaki veri minimizasyonu ilkesi gereğidir.
///
/// 14.09.2026 — `acikRizaVerildi` / `acikRizaTarihi` alanları kaldırıldı.
/// Kiralama yalnızca WhatsApp'tan yürüdüğü için o aktarım açık rızaya değil
/// Kurul standart sözleşmesine dayanır; uygulamada hiçbir işleme rızaya
/// bağlı değildir. Eski dokümanlarda kalan bu alanlar okunmaz.
class AppUser {
  final String uid;
  final String email;
  final String name;
  final String surname;
  final String phone;
  final String role; // 'admin' veya 'customer'
  final List<String> favoriteVehicleIds;
  final DateTime? createdAt;

  // ── KVKK onay kaydı ──
  // Aydınlatma yükümlülüğünün ispatı veri sorumlusundadır; onayın verildiği
  // an ve onaylanan metnin sürümü birlikte saklanır.

  /// Kullanım Koşulları'nın kabulü. Üyelik için zorunludur.
  final bool sozlesmeOnayi;

  /// Aydınlatma Metni'nin okunduğuna ilişkin geri bildirim — onay/rıza DEĞİL
  /// (Kurul 2026/347 ilke kararı). Üyelik için zorunludur ve sözleşme
  /// kabulünden ayrı tutulur.
  final bool aydinlatmaOkundu;

  final DateTime? onayTarihi;

  /// Onaylanan yasal metinlerin sürümü.
  final String onayMetinSurumu;

  // ── Kampanya iletişimi onayı (isteğe bağlı) ──
  // Uygulamadaki TEK açık rıza: KVKK m.5/1 açık rızası + 6563 m.6 ticari
  // elektronik ileti onayı. Verilmemesi hiçbir işlevi kısıtlamaz. Verildiği
  // ve geri alındığı an ayrı tutulur: ispat yükü Şirket'tedir ve onaylar
  // İYS'ye bu tarihlerle yüklenir.
  final bool kampanyaOnayi;
  final DateTime? kampanyaOnayTarihi;
  final DateTime? kampanyaRetTarihi;
  final String kampanyaMetinSurumu;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.surname,
    required this.phone,
    this.role = 'customer',
    this.favoriteVehicleIds = const [],
    this.createdAt,
    this.sozlesmeOnayi = false,
    this.aydinlatmaOkundu = false,
    this.onayTarihi,
    this.onayMetinSurumu = '',
    this.kampanyaOnayi = false,
    this.kampanyaOnayTarihi,
    this.kampanyaRetTarihi,
    this.kampanyaMetinSurumu = '',
  });

  String get fullName => '$name $surname';
  bool get isAdmin => role == 'admin';

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'customer',
      favoriteVehicleIds: List<String>.from(data['favoriteVehicleIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      sozlesmeOnayi: data['sozlesmeOnayi'] ?? false,
      aydinlatmaOkundu: data['aydinlatmaOkundu'] ?? false,
      onayTarihi: (data['onayTarihi'] as Timestamp?)?.toDate(),
      onayMetinSurumu: data['onayMetinSurumu'] ?? '',
      kampanyaOnayi: data['kampanyaOnayi'] ?? false,
      kampanyaOnayTarihi: (data['kampanyaOnayTarihi'] as Timestamp?)?.toDate(),
      kampanyaRetTarihi: (data['kampanyaRetTarihi'] as Timestamp?)?.toDate(),
      kampanyaMetinSurumu: data['kampanyaMetinSurumu'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'surname': surname,
      'phone': phone,
      'role': role,
      'favoriteVehicleIds': favoriteVehicleIds,
      'createdAt': FieldValue.serverTimestamp(),
      'sozlesmeOnayi': sozlesmeOnayi,
      'aydinlatmaOkundu': aydinlatmaOkundu,
      'onayTarihi': FieldValue.serverTimestamp(),
      'onayMetinSurumu': onayMetinSurumu,
      'kampanyaOnayi': kampanyaOnayi,
      if (kampanyaOnayi) ...{
        'kampanyaOnayTarihi': FieldValue.serverTimestamp(),
        'kampanyaMetinSurumu': kampanyaMetinSurumu,
      },
    };
  }
}
