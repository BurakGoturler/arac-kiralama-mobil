import 'package:car_rental_mvp/data/models/campaign_model.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'campaign_card.dart';

class CampaignSection extends StatelessWidget {
  final VoidCallback onViewAll;

  const CampaignSection({super.key, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kampanyalar', style: AppTextStyles.headingMedium),
              TextButton(
                onPressed: onViewAll,
                child: Text('Hepsini Gör', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: CampaignsMock.campaigns.length,
            itemBuilder: (context, index) {
              return CampaignCard(campaign: CampaignsMock.campaigns[index]);
            },
          ),
        ),
      ],
    );
  }
}
