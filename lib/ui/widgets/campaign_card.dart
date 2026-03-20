import 'package:car_rental_mvp/data/models/campaign_model.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import 'primary_button.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;

  const CampaignCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: campaign.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.discount_rounded, color: Colors.white.withOpacity(0.5), size: 28),
            const SizedBox(height: 8),
            Text(
              campaign.title,
              style: AppTextStyles.headingMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                campaign.description,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8)),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 120,
              child: PrimaryButton(
                label: campaign.buttonText,
                onTap: () async {
                  final success = await AppHelpers.openWhatsAppWithMessage(campaign.whatsappMessage);
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('WhatsApp bulunamadı veya açılamadı.')),
                    );
                  }
                },
                variant: PrimaryButtonVariant.ghost,
              ),
            ),
          ],
        ),
      ),
    );
  }
}