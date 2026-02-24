import 'package:car_rental_mvp/data/models/campaign_model.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'campaign_card.dart';

class CampaignSection extends StatefulWidget {
  final VoidCallback onViewAll;

  const CampaignSection({super.key, required this.onViewAll});

  @override
  State<CampaignSection> createState() => _CampaignSectionState();
}

class _CampaignSectionState extends State<CampaignSection> {
  late final Stream<List<Campaign>> _campaignsStream;

  @override
  void initState() {
    super.initState();
    _campaignsStream = FirestoreService().getCampaignsStream();
  }

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
                onPressed: widget.onViewAll,
                child: Text('Hepsini Gör',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: StreamBuilder<List<Campaign>>(
            stream: _campaignsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Hata: ${snapshot.error}'));
              }
              final campaigns = snapshot.data ?? [];
              if (campaigns.isEmpty) {
                return const Center(child: Text('Henüz kampanya yok.'));
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: campaigns.length,
                itemBuilder: (context, index) {
                  return CampaignCard(campaign: campaigns[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}