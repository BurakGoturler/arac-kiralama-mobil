import 'package:flutter/material.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_theme.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

/// Misafir kullanıcıya, üyelik gerektiren bir sekmede gösterilen kart.
class GirisGerekli extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String aciklama;

  const GirisGerekli({
    super.key,
    required this.ikon,
    required this.baslik,
    required this.aciklama,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryLight,
            child: Icon(ikon, size: 30, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(baslik,
              style: AppTextStyles.headingMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(aciklama,
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.sayfayaGit(const LoginScreen()),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Giriş Yap'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.sayfayaGit(const RegisterScreen()),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text('Üye Ol'),
            ),
          ),
        ],
      ),
    );
  }
}
