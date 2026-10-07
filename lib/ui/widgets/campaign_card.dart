import 'package:car_rental_mvp/data/models/campaign_model.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import 'primary_button.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;

  /// true: Kampanyalar sekmesindeki tam genişlikli, tam metinli biçim.
  /// false: ana sayfadaki yatay şeritte sabit genişlikli, kısaltılmış biçim.
  ///
  /// Eskiden yalnızca kısa biçim vardı ve açıklama 3 satırda kesiliyordu;
  /// "Arkadaşını Getir" kampanyasının ödül listesi hiçbir yerde
  /// okunamıyordu.
  final bool tamMetin;

  const CampaignCard({super.key, required this.campaign, this.tamMetin = false});

  @override
  Widget build(BuildContext context) {
    final aciklama = Text(
      campaign.description,
      style: AppTextStyles.bodyMedium
          .copyWith(color: Colors.white.withValues(alpha: 0.9)),
      maxLines: tamMetin ? null : 3,
      overflow: tamMetin ? null : TextOverflow.ellipsis,
    );

    return Container(
      width: tamMetin ? double.infinity : 280,
      margin: tamMetin ? EdgeInsets.zero : const EdgeInsets.only(right: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: campaign.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Köşede büyük, soluk simge — kartı düz bir renk bloğundan ayırır.
          Positioned(
            right: -18,
            top: -18,
            child: Icon(Icons.local_offer_rounded,
                size: 110, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: tamMetin ? MainAxisSize.min : MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  style: AppTextStyles.headingMedium.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800),
                  maxLines: tamMetin ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (tamMetin) aciklama else Expanded(child: aciklama),
                if (tamMetin) const SizedBox(height: 16),
                SizedBox(
                  width: 140,
                  child: PrimaryButton(
                    label: campaign.buttonText,
                    onTap: () async {
                      final success = await AppHelpers.openWhatsAppWithMessage(
                          campaign.whatsappMessage);
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('WhatsApp bulunamadı veya açılamadı.')),
                        );
                      }
                    },
                    variant: PrimaryButtonVariant.ghost,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
