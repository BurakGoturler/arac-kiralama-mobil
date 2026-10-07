import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// "Bize Ulaşın" penceresi: arama numaraları ve WhatsApp hatları.
///
/// Numaralar AppConstants'tan gelir; ekranda yazan ile aranan numara aynı
/// listeden okunur.
class IletisimSheet extends StatelessWidget {
  const IletisimSheet({super.key});

  static Future<void> goster(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => const IletisimSheet(),
    );
  }

  Future<void> _ac(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    var acildi = false;
    try {
      acildi = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!acildi) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Bağlantı açılamadı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Bize Ulaşın', style: AppTextStyles.headingMedium),
            const SizedBox(height: 4),
            Text(
              'Rezervasyon talepleri WhatsApp hatlarımızdan alınır.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 12),
            for (final n in AppConstants.aramaNumaralari)
              _Satir(
                ikon: Icons.call_rounded,
                renk: AppColors.primary,
                baslik: n['label']!,
                deger: n['gorunum']!,
                eylem: 'Ara',
                onTap: () => _ac(context, Uri(scheme: 'tel', path: n['phone'])),
              ),
            for (final n in AppConstants.whatsappNumbers)
              _Satir(
                ikon: Icons.chat_rounded,
                renk: AppColors.whatsappDark,
                baslik: 'WhatsApp — ${n['label']}',
                deger: n['gorunum']!,
                eylem: 'Yaz',
                onTap: () => _ac(
                  context,
                  Uri.parse('https://wa.me/${n['phone']}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Satir extends StatelessWidget {
  final IconData ikon;
  final Color renk;
  final String baslik;
  final String deger;
  final String eylem;
  final VoidCallback onTap;

  const _Satir({
    required this.ikon,
    required this.renk,
    required this.baslik,
    required this.deger,
    required this.eylem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: renk.withValues(alpha: 0.12),
                  child: Icon(ikon, color: renk, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(baslik, style: AppTextStyles.bodySmall),
                      Text(deger,
                          style: AppTextStyles.bodyLarge
                              .copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Text(eylem,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: renk, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
