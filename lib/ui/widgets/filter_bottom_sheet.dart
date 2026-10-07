import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'primary_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final String selectedCategory;
  final RangeValues priceRange;
  final String selectedTransmission;
  final void Function({
  required String category,
  required RangeValues priceRange,
  required String transmission,
  }) onApply;

  const FilterBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.priceRange,
    required this.selectedTransmission,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();

  /// Kaydırıcının uç değerleri. Ana ekranın varsayılan aralığı da budur.
  static const double minPrice = 500;
  static const double maxPrice = 5000;

  /// Günlük fiyatın seçili aralığa uyup uymadığı.
  ///
  /// Kaydırıcı uçtaysa o yön SINIRSIZ sayılır. Eskiden aralık kelimesi
  /// kelimesine uygulanıyordu: günlük fiyatı 5000 ₺'yi aşan (ya da 500 ₺'nin
  /// altında kalan) bir araç, kullanıcı hiçbir filtre seçmemişken bile ana
  /// sayfada hiç görünmüyordu.
  static bool fiyatUygun(double fiyat, RangeValues aralik) {
    final altUygun = aralik.start <= minPrice || fiyat >= aralik.start;
    final ustUygun = aralik.end >= maxPrice || fiyat <= aralik.end;
    return altUygun && ustUygun;
  }
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _category;
  late RangeValues _priceRange;
  late String _transmission;

  static const double _minPrice = FilterBottomSheet.minPrice;
  static const double _maxPrice = FilterBottomSheet.maxPrice;
  static const List<String> _transmissions = ['Hepsi', 'Otomatik', 'Manuel'];

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _priceRange = widget.priceRange;
    _transmission = widget.selectedTransmission;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: AppConstants.paddingL,
            right: AppConstants.paddingL,
            top: AppConstants.paddingM,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.paddingL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppConstants.filterTitle,
                      style: AppTextStyles.headingLarge),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _category = AppConstants.allCategory;
                        _priceRange =
                        const RangeValues(_minPrice, _maxPrice);
                        _transmission = 'Hepsi';
                      });
                    },
                    child: Text(
                      'Temizle',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Category ──────────────────────────────────
              Text('Kategori', style: AppTextStyles.headingMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.categories.map((cat) {
                  final isSelected = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius:
                        BorderRadius.circular(AppConstants.buttonRadius),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Price Range ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Günlük Fiyat', style: AppTextStyles.headingMedium),
                  Text(
                    '₺${_priceRange.start.round()} – ₺${_priceRange.end.round()}'
                    '${_priceRange.end >= _maxPrice ? '+' : ''}',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.divider,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withValues(alpha: 0.12),
                  trackHeight: 3,
                ),
                child: RangeSlider(
                  values: _priceRange,
                  min: _minPrice,
                  max: _maxPrice,
                  divisions: 45,
                  onChanged: (v) => setState(() => _priceRange = v),
                ),
              ),
              const SizedBox(height: 20),

              // ── Transmission ──────────────────────────────
              Text('Vites', style: AppTextStyles.headingMedium),
              const SizedBox(height: 12),
              Row(
                children: _transmissions.map((t) {
                  final isSelected = _transmission == t;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _transmission = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(
                            right: t != _transmissions.last ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryLight
                              : AppColors.surface,
                          borderRadius:
                          BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            t,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // ── Apply Button ──────────────────────────────
              PrimaryButton(
                label: 'Filtreleri Uygula',
                icon: Icons.tune_rounded,
                onTap: () {
                  Navigator.pop(context);
                  widget.onApply(
                    category: _category,
                    priceRange: _priceRange,
                    transmission: _transmission,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
