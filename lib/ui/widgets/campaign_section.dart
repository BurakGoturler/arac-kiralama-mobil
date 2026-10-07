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
    return StreamBuilder<List<Campaign>>(
      stream: _campaignsStream,
      builder: (context, snapshot) {
        final campaigns = snapshot.data ?? const <Campaign>[];
        final yukleniyor = snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData;

        // Hata veya boş liste: bölüm hiç gösterilmez. Eskiden ham hata metni
        // ("Hata: [cloud_firestore/...]") müşteriye gösteriliyordu.
        if (snapshot.hasError || (!yukleniyor && campaigns.isEmpty)) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kampanyalar', style: AppTextStyles.headingMedium),
                  TextButton(
                    onPressed: widget.onViewAll,
                    child: Text('Tümü',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 190,
              child: yukleniyor
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16),
                      itemCount: campaigns.length,
                      itemBuilder: (context, index) =>
                          CampaignCard(campaign: campaigns[index]),
                    ),
            ),
          ],
        );
      },
    );
  }
}
