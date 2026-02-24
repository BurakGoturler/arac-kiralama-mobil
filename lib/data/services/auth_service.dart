import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  /// Oturum durumu stream'i
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Kullanıcı giriş yapmış mı?
  bool get isLoggedIn => _auth.currentUser != null;

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

  /// Çıkış yap
  Future<void> signOut() async {
    await _auth.signOut();
  }
}