import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'home_screen.dart';

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
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
        Future.delayed(const Duration(milliseconds: 3600), () {
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
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionDuration: Duration.zero,
            ),
          );
        }
      }
    });

    debugPrint('SPLASH: forward() çağrılıyor');
    _logoController.forward();
    debugPrint('SPLASH: forward() çağrıldı');
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 28),
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
            ],
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