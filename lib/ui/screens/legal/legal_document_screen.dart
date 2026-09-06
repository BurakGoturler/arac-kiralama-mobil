import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/legal_texts.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';

/// Yasal metinleri (aydınlatma, açık rıza, gizlilik, kullanım koşulları)
/// tek bir ekranda gösterir.
class LegalDocumentScreen extends StatelessWidget {
  final String baslik;
  final String metin;

  const LegalDocumentScreen({
    super.key,
    required this.baslik,
    required this.metin,
  });

  /// Kısayol kurucular — çağrı yerlerinde metin/başlık eşleşmesi
  /// yanlışlıkla karışmasın diye.
  static LegalDocumentScreen aydinlatma() => LegalDocumentScreen(
        baslik: LegalTexts.aydinlatmaBaslik,
        metin: LegalTexts.aydinlatmaMetni,
      );

  static LegalDocumentScreen acikRiza() => LegalDocumentScreen(
        baslik: LegalTexts.acikRizaBaslik,
        metin: LegalTexts.acikRizaMetni,
      );

  static LegalDocumentScreen kullanimKosullari() => LegalDocumentScreen(
        baslik: LegalTexts.kullanimKosullariBaslik,
        metin: LegalTexts.kullanimKosullariMetni,
      );

  static LegalDocumentScreen gizlilik() => LegalDocumentScreen(
        baslik: LegalTexts.gizlilikBaslik,
        metin: LegalTexts.gizlilikMetni,
      );

  /// Metni ayrı bir sayfa olarak açar.
  static Future<void> ac(BuildContext context, LegalDocumentScreen ekran) {
    return context.sayfayaGit(ekran);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(baslik)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (SirketBilgileri.eksikBilgiVar)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'GELİŞTİRİCİ UYARISI: Şirket bilgileri henüz '
                            'doldurulmamış. Bu metin yayına çıkmadan önce '
                            'lib/core/constants/legal_texts.dart dosyasındaki '
                            'yer tutucular tamamlanmalıdır.',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                SelectableText(
                  metin.trim(),
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
