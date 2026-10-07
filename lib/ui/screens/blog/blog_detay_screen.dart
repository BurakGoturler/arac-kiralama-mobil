import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/blog_post.dart';
import '../../widgets/blog_karti.dart';

class BlogDetayScreen extends StatelessWidget {
  final BlogPost yazi;

  const BlogDetayScreen({super.key, required this.yazi});

  @override
  Widget build(BuildContext context) {
    // Yönetici paragrafları boş satırla ayırır; tek satır sonları paragraf
    // içinde korunur.
    final paragraflar = yazi.content
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.textPrimary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: BlogKapak(url: yazi.coverImageUrl),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(BlogKarti.tarihMetni(yazi),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(yazi.title,
                      style: AppTextStyles.headingLarge.copyWith(fontSize: 26)),
                  if (yazi.summary.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(yazi.summary.trim(),
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 8),
                  for (final p in paragraflar)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: SelectableText(
                        p,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w400,
                          height: 1.65,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
