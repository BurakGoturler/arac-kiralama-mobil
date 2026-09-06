import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/legal_texts.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  /// Oturum durumu stream'i
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Kullanıcı giriş yapmış mı?
  bool get isLoggedIn => _auth.currentUser != null;

  /// Email doğrulanmış mı?
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// E-posta ve şifre ile giriş
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Yeni kullanıcı kaydı (Firebase Auth + Firestore users koleksiyonu)
  ///
  /// [sozlesmeOnayi] aydınlatma metni ve kullanım koşulları onayıdır, zorunludur.
  /// [acikRizaVerildi] WhatsApp aktarımı için açık rızadır, isteğe bağlıdır.
  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String phone,
    required bool sozlesmeOnayi,
    required bool acikRizaVerildi,
  }) async {
    // Aydınlatma onayı olmadan kayıt açılamaz. Güvenlik kuralı bunu zaten
    // reddeder; burada da kontrol edilir ki gereksiz bir Auth hesabı
    // oluşturulup hemen silinmek zorunda kalınmasın.
    if (!sozlesmeOnayi) {
      throw Exception('sozlesme-onayi-gerekli');
    }

    // 1. Firebase Auth'ta kullanıcı oluştur
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // 2. Firestore'da users koleksiyonuna ekstra bilgileri yaz.
    //
    // DİKKAT: Bu adım başarısız olursa Auth hesabı geri alınmalıdır.
    // Aksi hâlde kullanıcı, profil dokümanı olmayan bir hesapla baş başa
    // kalır: giriş yapabilir ama profili okunamadığı için rezervasyon
    // gönderemez, profil ekranı boş gelir ve aynı e-postayla yeniden
    // kayıt olamaz ("email-already-in-use"). Kullanıcının kendi başına
    // çıkamayacağı bir kilitlenmedir; yalnızca konsoldan elle çözülür.
    try {
      final user = AppUser(
        uid: credential.user!.uid,
        email: email.trim(),
        name: name.trim(),
        surname: surname.trim(),
        phone: phone.trim(),
        role: 'customer',
        sozlesmeOnayi: sozlesmeOnayi,
        acikRizaVerildi: acikRizaVerildi,
        onayMetinSurumu: SirketBilgileri.sonGuncelleme,
      );
      await _db
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toFirestore());
    } catch (e) {
      // Yarım kalan kaydı geri al, sonra hatayı yukarı ilet.
      try {
        await credential.user?.delete();
      } catch (_) {
        // Silme de başarısız olursa yapacak bir şey yok; asıl hata
        // yine de bildirilir ve kullanıcı tekrar deneyebilir.
      }
      rethrow;
    }

    // 3. Doğrulama maili gönder.
    // Bu adımın başarısız olması kaydı geçersiz kılmaz; kullanıcı
    // doğrulama ekranından yeniden gönderebilir.
    try {
      await credential.user!.sendEmailVerification();
    } catch (_) {}

    return credential;
  }

  /// Email doğrulama mailini tekrar gönder
  Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Kullanıcı bilgisini Firebase'den yenile (email doğrulandı mı kontrolü için)
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Mevcut kullanıcının Firestore'daki profil bilgilerini getir
  Future<AppUser?> getCurrentUserProfile() async {
    if (_auth.currentUser == null) return null;
    final doc = await _db.collection('users').doc(_auth.currentUser!.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  /// Kullanıcı admin mi?
  Future<bool> isCurrentUserAdmin() async {
    final profile = await getCurrentUserProfile();
    return profile?.isAdmin ?? false;
  }

  /// Şifre sıfırlama maili gönder
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Şifre değiştir — kullanıcı mevcut şifresiyle yeniden doğrulandıktan sonra
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Kullanıcı bulunamadı.');
    }

    // Yeniden doğrulama (Firebase bunu güvenlik için istiyor)
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Yeni şifreyi ayarla
    await user.updatePassword(newPassword);
  }

  /// Hesabı ve ilişkili tüm kişisel verileri kalıcı olarak siler.
  ///
  /// KVKK m.7 (silme hakkı) ve App Store Guideline 5.1.1(v) gereğidir.
  /// Sırasıyla rezervasyon kayıtları, profil dokümanı ve Firebase Auth
  /// kaydı silinir. Auth kaydı en sona bırakılır; aksi hâlde oturum
  /// düştüğü için Firestore silme işlemleri yetki hatası verir.
  Future<void> deleteAccount({required String currentPassword}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Kullanıcı bulunamadı.');
    }

    // Firebase, hesap silme gibi hassas işlemler için yakın zamanlı
    // kimlik doğrulaması ister.
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    final uid = user.uid;

    // 1. Kullanıcıya ait rezervasyon kayıtları
    final logs = await _db
        .collection('whatsapp_logs')
        .where('userId', isEqualTo: uid)
        .get();

    if (logs.docs.isNotEmpty) {
      // Firestore tek batch'te en fazla 500 işlem kabul eder.
      for (var i = 0; i < logs.docs.length; i += 500) {
        final batch = _db.batch();
        final chunk = logs.docs.skip(i).take(500);
        for (final doc in chunk) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }

    // 2. Profil dokümanı
    await _db.collection('users').doc(uid).delete();

    // 3. Firebase Auth kaydı
    await user.delete();
  }

  /// Çıkış yap
  Future<void> signOut() async {
    await _auth.signOut();
  }
}