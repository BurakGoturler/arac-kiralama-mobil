import 'package:car_rental_mvp/data/models/campaign_model.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'campaign_card.dart';

class CampaignBottomSheet extends StatefulWidget {
  const CampaignBottomSheet({super.key});

  @override
  State<CampaignBottomSheet> createState() => _CampaignBottomSheetState();
}

class _CampaignBottomSheetState extends State<CampaignBottomSheet> {
  late final Stream<List<Campaign>> _campaignsStream;

  @override
  void initState() {
    super.initState();
    _campaignsStream = FirestoreService().getCampaignsStream();
  }

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
                child:
                Text('Tüm Kampanyalar', style: AppTextStyles.headingLarge),
              ),
              Expanded(
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
                      controller: controller,
                      itemCount: campaigns.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: SizedBox(
                            height: 200,
                            child: CampaignCard(campaign: campaigns[index]),
                          ),
                        );
                      },
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