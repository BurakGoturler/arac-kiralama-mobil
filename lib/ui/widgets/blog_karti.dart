import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/blog_post.dart';
import '../screens/blog/blog_detay_screen.dart';

/// Blog yazısı kartı. [yatay] true ise ana sayfadaki dar şerit biçimi.
class BlogKarti extends StatelessWidget {
  final BlogPost yazi;
  final bool yatay;

  const BlogKarti({super.key, required this.yazi, this.yatay = false});

  static String tarihMetni(BlogPost y) {
    final t = y.publishedAt ?? y.updatedAt;
    final tarih = t == null ? '' : DateFormat('d MMMM y', 'tr_TR').format(t);
    return [if (tarih.isNotEmpty) tarih, '${y.okumaSuresiDk} dk okuma']
        .join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () => context.sayfayaGit(BlogDetayScreen(yazi: yazi)),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: yatay ? 16 / 8 : 16 / 9,
                child: BlogKapak(url: yazi.coverImageUrl),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yazi.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headingMedium.copyWith(fontSize: 16),
                    ),
                    if (!yatay) ...[
                      const SizedBox(height: 6),
                      Text(
                        yazi.kisaMetin,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(tarihMetni(yazi), style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kapak görseli; görsel yoksa marka renginde bir yer tutucu.
class BlogKapak extends StatelessWidget {
  final String url;

  const BlogKapak({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final yerTutucu = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.article_outlined, color: Colors.white70, size: 40),
      ),
    );
    if (url.isEmpty) return yerTutucu;
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: AppColors.primaryLight),
      errorWidget: (_, __, ___) => yerTutucu,
    );
  }
}
