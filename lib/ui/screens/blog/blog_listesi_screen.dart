import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/blog_post.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/blog_karti.dart';

/// Alt menüdeki "Blog" sekmesi: yayındaki bilgilendirme yazıları.
class BlogListesiScreen extends StatefulWidget {
  const BlogListesiScreen({super.key});

  @override
  State<BlogListesiScreen> createState() => _BlogListesiScreenState();
}

class _BlogListesiScreenState extends State<BlogListesiScreen> {
  late final Stream<List<BlogPost>> _akis =
      FirestoreService().getYayindakiBlogYazilari();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog')),
      body: StreamBuilder<List<BlogPost>>(
        stream: _akis,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const _BosDurum(
              ikon: Icons.cloud_off_rounded,
              metin: 'Yazılar şu an yüklenemedi. Lütfen daha sonra tekrar deneyin.',
            );
          }
          final yazilar = snapshot.data ?? const [];
          if (yazilar.isEmpty) {
            return const _BosDurum(
              ikon: Icons.article_outlined,
              metin: 'Yakında araç kiralama hakkında faydalı yazılar burada olacak.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: yazilar.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) => BlogKarti(yazi: yazilar[i]),
          );
        },
      ),
    );
  }
}

class _BosDurum extends StatelessWidget {
  final IconData ikon;
  final String metin;

  const _BosDurum({required this.ikon, required this.metin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(metin,
                textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
