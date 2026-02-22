import 'package:car_rental_mvp/data/models/campaign_model.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'campaign_card.dart';

class CampaignBottomSheet extends StatelessWidget {
  const CampaignBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Tüm Kampanyalar', style: AppTextStyles.headingLarge),
              ),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: CampaignsMock.campaigns.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: SizedBox(
                        height: 200,
                        child: CampaignCard(campaign: CampaignsMock.campaigns[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
