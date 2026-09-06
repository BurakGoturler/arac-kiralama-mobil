import 'package:car_rental_mvp/data/services/auth_service.dart';
import 'package:car_rental_mvp/ui/screens/auth/register_screen.dart';
import 'package:car_rental_mvp/ui/screens/auth/email_verification_screen.dart';
import 'package:car_rental_mvp/ui/screens/home_screen.dart';
import 'package:car_rental_mvp/ui/screens/admin/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  /// true ise geri butonu ile önceki ekrana dönebilir (misafir → login)
  /// false ise geri butonu yok (splash → login zorunlu)
  final bool canGoBack;

  const LoginScreen({super.key, this.canGoBack = true});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Lütfen tüm alanları doldurun.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Email doğrulanmamışsa doğrulama ekranına gönder
      await _authService.reloadUser();
      if (!_authService.isEmailVerified) {
        if (mounted) {
          context.sayfayiDegistir(const EmailVerificationScreen());
        }
        return;
      }

      // Role'e göre yönlendir
      final isAdmin = await _authService.isCurrentUserAdmin();
      if (!mounted) return;

      context.sayfayaSifirla(
        isAdmin ? const AdminDashboardScreen() : const HomeScreen(),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Giriş başarısız. E-posta veya şifre hatalı.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = 'Önce e-posta adresinizi girin.');
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifre sıfırlama maili gönderildi.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mail gönderilemedi. E-posta doğru mu?')),
        );
      }
    }
  }

  void _goToRegister() {
    context.sayfayaGit(const RegisterScreen());
  }

  void _continueAsGuest() {
    context.sayfayaSifirla(const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        automaticallyImplyLeading: widget.canGoBack,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/images/logo.png', height: 80),
                const SizedBox(height: 24),
                Text('Hoş Geldiniz',
                    style: AppTextStyles.headingLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Hesabınıza giriş yapın',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  onSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Şifremi Unuttum'),
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(_errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center),
                ],
                const SizedBox(height: 16),

                PrimaryButton(
                  label: 'Giriş Yap',
                  icon: Icons.login_rounded,
                  isLoading: _isLoading,
                  onTap: _isLoading ? null : _login,
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Hesabınız yok mu?', style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: _goToRegister,
                      child: const Text('Üye Ol'),
                    ),
                  ],
                ),

                const Divider(),
                const SizedBox(height: 8),

                TextButton.icon(
                  onPressed: _continueAsGuest,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Üye olmadan devam et'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}