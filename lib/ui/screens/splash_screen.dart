import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'home_screen.dart';

import 'package:car_rental_mvp/data/services/auth_service.dart';
import 'package:car_rental_mvp/ui/screens/auth/email_verification_screen.dart';
import 'package:car_rental_mvp/ui/screens/admin/admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _exitController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();
    debugPrint('SPLASH: initState başladı');
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _textFade = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _logoController.addStatusListener((status) {
      debugPrint('LOGO ANIMATION: $status');
      if (status == AnimationStatus.completed) {
        _textController.forward();
      }
    });

    _textController.addStatusListener((status) {
      debugPrint('TEXT ANIMATION: $status');
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) {
            _exitController.forward();
          }
        });
      }
    });

    _exitController.addStatusListener((status) {
      debugPrint('EXIT ANIMATION: $status');
      if (status == AnimationStatus.completed) {
        if (mounted) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
          _navigateBasedOnAuth();
        }
      }
    });

    debugPrint('SPLASH: forward() çağrılıyor');
    _logoController.forward();
    debugPrint('SPLASH: forward() çağrıldı');
  }

  /// Açılıştaki ağ çağrıları için üst sınır.
  /// Bu süre aşılırsa kullanıcı bekletilmez, misafir modunda ana sayfaya alınır.
  static const Duration _agZamanAsimi = Duration(seconds: 8);

  void _git(Widget ekran) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ekran,
        transitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> _navigateBasedOnAuth() async {
    final authService = AuthService();

    // Giriş yapılmamışsa → HomeScreen (misafir modu, görüntüleme serbest)
    if (!authService.isLoggedIn) {
      _git(const HomeScreen());
      return;
    }

    // Buradan sonrası ağ erişimi gerektirir. Bağlantı yoksa veya yavaşsa
    // uygulamanın açılış ekranında takılı kalmaması için tüm çağrılar
    // hem zaman aşımına hem hata yakalamaya bağlanır.
    try {
      // Email doğrulanmamışsa → Doğrulama ekranı
      await authService.reloadUser().timeout(_agZamanAsimi);
      if (!mounted) return;

      if (!authService.isEmailVerified) {
        _git(const EmailVerificationScreen());
        return;
      }

      // Admin mi? Role'e göre yönlendir
      final isAdmin =
          await authService.isCurrentUserAdmin().timeout(_agZamanAsimi);
      if (!mounted) return;

      _git(isAdmin ? const AdminDashboardScreen() : const HomeScreen());
    } catch (e) {
      // Ağ hatası, zaman aşımı veya oturumun sunucuda geçersiz kılınması.
      // Kullanıcıyı kilitlemek yerine uygulamayı açıyoruz; oturumu varsa
      // ana sayfada normal şekilde kullanmaya devam eder.
      debugPrint('SPLASH: yönlendirme sırasında hata — $e');
      _git(const HomeScreen());
    }
  }




  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          // Çıkış animasyonu tüm içeriği kapsar.
          child: FadeTransition(
            opacity: _exitFade,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo: yumuşak bir belirme + büyüme
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Başlık: aşağıdan kayarak belirir
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FadeTransition(
        opacity: _exitFade,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: FadeTransition(
            opacity: _textFade,
            child: Center(
              child: Text(
                'Hızlı • Üstün Kalite • Sorunsuz',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}