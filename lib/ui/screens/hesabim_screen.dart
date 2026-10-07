import 'package:flutter/material.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/auth_service.dart';
import '../widgets/giris_gerekli.dart';
import '../widgets/iletisim_sheet.dart';
import 'faq_screen.dart';
import 'legal/legal_document_screen.dart';
import 'profile/profile_screen.dart';

/// Alt menüdeki "Hesabım" sekmesi.
///
/// Üye için profil ekranıdır; misafir için giriş/üyelik kartı ve herkese
/// açık bağlantılar (iletişim, SSS, yasal metinler). Yasal metinler
/// misafire de ulaşılabilir olmalı: üye olmadan önce okunabilmeleri gerekir.
class HesabimScreen extends StatelessWidget {
  const HesabimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AuthService().isLoggedIn) return const ProfileScreen();

    return Scaffold(
      appBar: AppBar(title: const Text('Hesabım')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const GirisGerekli(
            ikon: Icons.person_outline_rounded,
            baslik: 'Şenbayrak\'a hoş geldiniz',
            aciklama: 'Rezervasyon talebi göndermek ve favori araçlarınızı '
                'kaydetmek için giriş yapın ya da üye olun.',
          ),
          const SizedBox(height: 24),
          _Baglanti(
            ikon: Icons.support_agent_rounded,
            baslik: 'Bize Ulaşın',
            onTap: () => IletisimSheet.goster(context),
          ),
          _Baglanti(
            ikon: Icons.help_outline_rounded,
            baslik: 'Sıkça Sorulan Sorular',
            onTap: () => context.sayfayaGit(const FaqScreen()),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Yasal Metinler', style: AppTextStyles.labelMedium),
          ),
          _Baglanti(
            ikon: Icons.privacy_tip_outlined,
            baslik: 'KVKK Aydınlatma Metni',
            onTap: () => LegalDocumentScreen.ac(
                context, LegalDocumentScreen.aydinlatma()),
          ),
          _Baglanti(
            ikon: Icons.shield_outlined,
            baslik: 'Gizlilik Politikası',
            onTap: () =>
                LegalDocumentScreen.ac(context, LegalDocumentScreen.gizlilik()),
          ),
          _Baglanti(
            ikon: Icons.description_outlined,
            baslik: 'Kullanım Koşulları',
            onTap: () => LegalDocumentScreen.ac(
                context, LegalDocumentScreen.kullanimKosullari()),
          ),
        ],
      ),
    );
  }
}

class _Baglanti extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final VoidCallback onTap;

  const _Baglanti({required this.ikon, required this.baslik, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: Icon(ikon, color: AppColors.primary),
          title: Text(baslik, style: AppTextStyles.bodyLarge),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted),
          onTap: onTap,
        ),
      ),
    );
  }
}
