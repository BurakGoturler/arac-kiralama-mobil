import 'package:cloud_firestore/cloud_firestore.dart';

/// Uygulama kullanıcısı.
///
/// NOT: T.C. Kimlik Numarası bilinçli olarak BU MODELDE YER ALMAZ ve
/// veritabanında saklanmaz. Rezervasyon talebi gönderilirken kullanıcıdan
/// o anda istenir, yalnızca WhatsApp mesajına eklenir ve hiçbir yere
/// yazılmaz. Bu karar KVKK kapsamındaki veri minimizasyonu ilkesi gereğidir.
class AppUser {
  final String uid;
  final String email;
  final String name;
  final String surname;
  final String phone;
  final String role; // 'admin' veya 'customer'
  final List<String> favoriteVehicleIds;
  final DateTime? createdAt;

  // ── KVKK onay kayıtları ──
  // İspat yükü veri sorumlusunda olduğu için onayın verildiği an ve
  // onaylanan metnin sürümü birlikte saklanır.

  /// Aydınlatma metni ve kullanım koşullarının okunduğuna dair onay.
  /// Üyelik için zorunludur.
  final bool sozlesmeOnayi;

  /// WhatsApp (yurt dışı) aktarımı için açık rıza.
  /// İSTEĞE BAĞLIDIR — verilmemesi üyeliği engellemez, yalnızca
  /// uygulama üzerinden rezervasyon talebi iletilmesini engeller.
  final bool acikRizaVerildi;

  final DateTime? onayTarihi;
  final DateTime? acikRizaTarihi;

  /// Onaylanan yasal metinlerin sürümü. Metinler güncellendiğinde
  /// kullanıcıdan yeniden onay almak için kullanılır.
  final String onayMetinSurumu;

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
    this.acikRizaVerildi = false,
    this.onayTarihi,
    this.acikRizaTarihi,
    this.onayMetinSurumu = '',
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
      acikRizaVerildi: data['acikRizaVerildi'] ?? false,
      onayTarihi: (data['onayTarihi'] as Timestamp?)?.toDate(),
      acikRizaTarihi: (data['acikRizaTarihi'] as Timestamp?)?.toDate(),
      onayMetinSurumu: data['onayMetinSurumu'] ?? '',
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
      'acikRizaVerildi': acikRizaVerildi,
      'onayTarihi': FieldValue.serverTimestamp(),
      if (acikRizaVerildi) 'acikRizaTarihi': FieldValue.serverTimestamp(),
      'onayMetinSurumu': onayMetinSurumu,
    };
  }
}
