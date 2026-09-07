import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_rental_mvp/data/models/vehicle.dart';
import 'package:flutter/material.dart';

import 'package:car_rental_mvp/data/services/auth_service.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.cardShadow.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────
            _CardImage(vehicle: vehicle),
            // ── Content ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(vehicle: vehicle),
                  const SizedBox(height: 12),
                  _SpecsRow(vehicle: vehicle),
                  const SizedBox(height: 14),
                  _CardFooter(vehicle: vehicle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  final Vehicle vehicle;

  const _CardImage({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'vehicle_image_${vehicle.id}',
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.cardRadius),
        ),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: vehicle.imagePath,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: AppColors.background,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: AppColors.background,
                child: const Icon(Icons.directions_car, size: 48, color: AppColors.textMuted),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.12),
                    ],
                  ),
                ),
              ),
            ),
            // Category badge
            Positioned(
              top: 14,
              left: 14,
              child: _CategoryBadge(category: vehicle.category),
            ),
            // Featured badge
            if (vehicle.isFeatured)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                    BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'En Çok Tercih Edilen',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // ── Favori Kalp İkonu ──
            // Featured olan araçlarda rozetin altında, diğerlerinde sağ üstte
            Positioned(
              top: vehicle.isFeatured ? 48 : 14,
              right: 14,
              child: _FavoriteButton(vehicleId: vehicle.id),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Favori Kalp Butonu ──
class _FavoriteButton extends StatelessWidget {
  final String vehicleId;

  const _FavoriteButton({required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final uid = authService.currentUser?.uid;

    // Giriş yapmamışsa kalp gösterme
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<List<String>>(
      stream: firestoreService.getFavoriteIdsStream(uid),
      builder: (context, snapshot) {
        final favoriteIds = snapshot.data ?? [];
        final isFavorite = favoriteIds.contains(vehicleId);

        return GestureDetector(
          onTap: () async {
            await firestoreService.toggleFavorite(uid, vehicleId);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Text(
        category.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final Vehicle vehicle;

  const _CardHeader({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.brand.toUpperCase(),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                vehicle.name,
                style: AppTextStyles.headingMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppHelpers.formatPrice(vehicle.dailyPrice),
              style: AppTextStyles.priceSmall,
            ),
            Text(
              'Günlük',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }
}

class _SpecsRow extends StatelessWidget {
  final Vehicle vehicle;

  const _SpecsRow({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SpecChip(
          icon: Icons.settings_outlined,
          label: vehicle.transmissionShort,
        ),
        _SpecChip(
          emoji: vehicle.fuelIcon,
          label: vehicle.fuelType,
        ),
        _SpecChip(
          icon: Icons.people_outline_rounded,
          label: '${vehicle.seats} Koltuk',
        ),
        _SpecChip(
          icon: Icons.calendar_today_rounded,
          label: '${vehicle.year}',
        ),
      ],
    );
  }
}

class _SpecChip extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final String label;

  const _SpecChip({this.icon, this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
          ] else if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  final Vehicle vehicle;

  const _CardFooter({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppHelpers.aracOzetSatiri(vehicle.engineSize, vehicle.features),
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aracı İncele',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}