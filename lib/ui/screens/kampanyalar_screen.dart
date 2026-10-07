import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/campaign_model.dart';
import '../../data/services/firestore_service.dart';
import '../widgets/campaign_card.dart';

/// Alt menüdeki "Kampanyalar" sekmesi: aktif kampanyaların tam metni.
class KampanyalarScreen extends StatefulWidget {
  const KampanyalarScreen({super.key});

  @override
  State<KampanyalarScreen> createState() => _KampanyalarScreenState();
}

class _KampanyalarScreenState extends State<KampanyalarScreen> {
  late final Stream<List<Campaign>> _akis =
      FirestoreService().getCampaignsStream();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kampanyalar')),
      body: StreamBuilder<List<Campaign>>(
        stream: _akis,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final liste = snapshot.data ?? const <Campaign>[];
          if (snapshot.hasError || liste.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  snapshot.hasError
                      ? 'Kampanyalar şu an yüklenemedi.'
                      : 'Şu an aktif kampanya bulunmuyor.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: liste.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) =>
                CampaignCard(campaign: liste[i], tamMetin: true),
          );
        },
      ),
    );
  }
}
