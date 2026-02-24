import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_rental_mvp/data/models/vehicle.dart';
import 'package:car_rental_mvp/ui/widgets/date_selector.dart';
import 'package:car_rental_mvp/ui/widgets/primary_button.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;
  final DateTime? startDate;
  final DateTime? endDate;

  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
    this.startDate,
    this.endDate,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _activeImageIndex = 0;
  bool _isReserving = false;

  Vehicle get v => widget.vehicle;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  int get _totalDays =>
      _startDate != null && _endDate != null
          ? AppHelpers.daysBetween(_startDate!, _endDate!)
          : 0;

  double get _totalPrice => _totalDays * v.dailyPrice;

  bool get _canReserve =>
      _startDate != null && _endDate != null && _totalDays > 0;

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final firstDate = isStart ? now : (_startDate ?? now);
    final initialDate = isStart
        ? (_startDate ?? now)
        : (_endDate ?? firstDate.add(const Duration(days: 1)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate)
          ? firstDate.add(const Duration(days: 1))
          : initialDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 1),
      builder: (context, child) =>
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
            ),
            child: child!,
          ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && !_endDate!.isAfter(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _reserve() async {
    if (!_canReserve) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen kiralama tarihlerini seçin.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
      return;
    }

    setState(() => _isReserving = true);

    final success = await AppHelpers.openWhatsApp(
      vehicleName: v.fullName,
      startDate: _startDate!,
      endDate: _endDate!,
    );

    if (mounted) setState(() => _isReserving = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WhatsApp açılamadı. Lütfen tekrar deneyin.',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _DetailSliverAppBar(
                vehicle: v,
                activeImageIndex: _activeImageIndex,
                onImageChange: (i) => setState(() => _activeImageIndex = i),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _VehicleInfoSection(vehicle: v),
                    _SpecsGridSection(vehicle: v),
                    _FeaturesSection(vehicle: v),
                    _DateSection(
                      startDate: _startDate,
                      endDate: _endDate,
                      onSelectStart: () => _pickDate(isStart: true),
                      onSelectEnd: () => _pickDate(isStart: false),
                    ),
                    const SizedBox(height: 160), // Alt çubuk için boşluk
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _ReservationBar(
              vehicle: v,
              totalDays: _totalDays,
              totalPrice: _totalPrice,
              canReserve: _canReserve,
              isReserving: _isReserving,
              onReserve: _reserve,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSliverAppBar extends StatelessWidget {
  final Vehicle vehicle;
  final int activeImageIndex;
  final void Function(int) onImageChange;

  const _DetailSliverAppBar({
    required this.vehicle,
    required this.activeImageIndex,
    required this.onImageChange,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: false, // Olası jest çakışmalarını önlemek için false yapıldı
      backgroundColor: AppColors.surface,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          children: [
            PageView.builder(
              itemCount: vehicle.galleryPaths.length,
              onPageChanged: onImageChange,
              itemBuilder: (_, i) {
                final imagePath = vehicle.galleryPaths[i];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return FullScreenImageViewer(
                          imagePaths: vehicle.galleryPaths,
                          initialIndex: i,
                        );
                      }));
                    },
                    child: Hero(
                      tag: imagePath,
                      child: CachedNetworkImage(
                        imageUrl: imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          color: AppColors.background,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.background,
                          child: const Icon(Icons.directions_car, size: 64, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (vehicle.galleryPaths.length > 1)
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(vehicle.galleryPaths.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: activeImageIndex == i ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: activeImageIndex == i
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                boundaryMargin: const EdgeInsets.all(80),
                clipBehavior: Clip.none,
                child: Center(
                  child: Hero(
                    tag: widget.imagePaths[index],
                    child: CachedNetworkImage(
                      imageUrl: widget.imagePaths[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white54, size: 48),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (widget.imagePaths.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imagePaths.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == i ? 12 : 8,
                    height: _currentIndex == i ? 12 : 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == i ? Colors.white : Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _SectionCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppConstants.paddingM, AppConstants.paddingM, AppConstants.paddingM, 0),
      padding: padding ?? const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _VehicleInfoSection extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleInfoSection({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(vehicle.name, style: AppTextStyles.displayMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius:
                            BorderRadius.circular(AppConstants.radiusS),
                          ),
                          child: Text(vehicle.category,
                              style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${vehicle.year}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppHelpers.formatPrice(vehicle.dailyPrice),
                    style: AppTextStyles.price,
                  ),
                  Text(
                    '/ gün',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecsGridSection extends StatelessWidget {
  final Vehicle vehicle;

  const _SpecsGridSection({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final specs = [
      _SpecItem(
          icon: Icons.settings_rounded,
          label: 'Vites',
          value: vehicle.transmission),
      _SpecItem(
          icon: Icons.local_gas_station_rounded,
          label: 'Yakıt',
          value: vehicle.fuelType),
      _SpecItem(
          icon: Icons.people_rounded,
          label: 'Koltuk',
          value: '${vehicle.seats} koltuk'),
      _SpecItem(
          icon: Icons.speed_rounded,
          label: 'Motor',
          value: vehicle.engineSize),
    ];

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Özellikler', style: AppTextStyles.headingMedium),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3.0,
            children: specs.map((s) => _SpecGridCell(spec: s)).toList(),
          ),
        ],
      ),
    );
  }
}

class _SpecItem {
  final IconData icon;
  final String label;
  final String value;

  const _SpecItem({required this.icon, required this.label, required this.value});
}

class _SpecGridCell extends StatelessWidget {
  final _SpecItem spec;

  const _SpecGridCell({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        children: [
          Icon(spec.icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(spec.label, style: AppTextStyles.caption),
                Text(
                  spec.value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  final Vehicle vehicle;

  const _FeaturesSection({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ekipmanlar', style: AppTextStyles.headingMedium),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vehicle.features
                .map(
                  (f) =>
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                      BorderRadius.circular(AppConstants.radiusS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 13, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          f,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DateSection extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onSelectStart;
  final VoidCallback onSelectEnd;

  const _DateSection({
    required this.startDate,
    required this.endDate,
    required this.onSelectStart,
    required this.onSelectEnd,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: DateSelector(
        startDate: startDate,
        endDate: endDate,
        onSelectStart: onSelectStart,
        onSelectEnd: onSelectEnd,
      ),
    );
  }
}

class _ReservationBar extends StatelessWidget {
  final Vehicle vehicle;
  final int totalDays;
  final double totalPrice;
  final bool canReserve;
  final bool isReserving;
  final VoidCallback onReserve;

  const _ReservationBar({
    required this.vehicle,
    required this.totalDays,
    required this.totalPrice,
    required this.canReserve,
    required this.isReserving,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingM,
        AppConstants.paddingM,
        AppConstants.paddingM,
        MediaQuery
            .of(context)
            .padding
            .bottom + AppConstants.paddingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canReserve && totalDays > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalDays ${totalDays == 1 ? 'gün' : 'gün'} için toplam',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      AppHelpers.formatPrice(totalPrice),
                      style: AppTextStyles.price.copyWith(fontSize: 22),
                    ),
                  ],
                ),
                Text(
                  '${AppHelpers.formatPrice(vehicle.dailyPrice)} × $totalDays',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          PrimaryButton(
            label: AppConstants.reserveButtonLabel,
            icon: Icons.message_rounded,
            variant: PrimaryButtonVariant.whatsapp,
            isLoading: isReserving,
            onTap: canReserve ? onReserve : null,
          ),
          if (!canReserve) ...[
            const SizedBox(height: 8),
            Text(
              'Devam etmek için tarih seçin',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}