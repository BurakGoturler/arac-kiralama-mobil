import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';

class DateSelector extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onSelectStart;
  final VoidCallback onSelectEnd;

  const DateSelector({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onSelectStart,
    required this.onSelectEnd,
  });

  @override
  Widget build(BuildContext context) {
    final hasRange = startDate != null && endDate != null;
    final days = hasRange
        ? AppHelpers.daysBetween(startDate!, endDate!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Araç Kiralama Süresi', style: AppTextStyles.headingMedium),
            const Spacer(),
            if (hasRange && days != null && days > 0)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius:
                  BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  '$days ${days == 1 ? 'gün' : 'gün'}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _DateTile(
                label: 'Araç Alım',
                date: startDate,
                icon: Icons.flight_land_rounded,
                onTap: onSelectStart,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DateTile(
                label: 'Araç Teslİm',
                date: endDate,
                icon: Icons.flight_takeoff_rounded,
                onTap: onSelectEnd,
                isDisabled: startDate == null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDisabled;

  const _DateTile({
    required this.label,
    required this.date,
    required this.icon,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasDate ? AppColors.primaryLight : AppColors.background,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: hasDate ? AppColors.primary : AppColors.divider,
            width: hasDate ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: hasDate
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: hasDate
                        ? AppColors.primary
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              hasDate
                  ? AppHelpers.formatShortDate(date!)
                  : 'Tarih seçin',
              style: hasDate
                  ? AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              )
                  : AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            if (hasDate)
              Text(
                '${date!.year}',
                style: AppTextStyles.caption,
              ),
          ],
        ),
      ),
    );
  }
}