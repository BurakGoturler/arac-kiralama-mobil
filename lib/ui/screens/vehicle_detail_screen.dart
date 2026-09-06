import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';
import 'package:car_rental_mvp/data/models/vehicle.dart';
import 'package:car_rental_mvp/ui/widgets/date_selector.dart';
import 'package:car_rental_mvp/ui/widgets/primary_button.dart';
import 'package:flutter/material.dart';

import 'package:car_rental_mvp/data/models/user_model.dart';
import 'package:car_rental_mvp/data/models/pickup_location_model.dart';
import 'package:car_rental_mvp/data/services/auth_service.dart';
import 'package:car_rental_mvp/ui/screens/auth/login_screen.dart';
import 'package:car_rental_mvp/ui/screens/legal/legal_document_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/legal_texts.dart';
import '../../core/navigation/app_page_route.dart';
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

    // ── Login kontrolü ──
    final authService = AuthService();
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    // Buradan sonrası ağ çağrısı içerir. Buton kilitlenmezse kullanıcı
    // yavaş bağlantıda üst üste dokunur ve birden fazla onay akışı açılır.
    setState(() => _isReserving = true);
    try {
      // Email doğrulama kontrolü.
      // reloadUser ağ ister; bağlantı yoksa istisna fırlatır. Eskiden
      // yakalanmadığı için buton hiçbir geri bildirim vermeden ölüyordu.
      try {
        await authService.reloadUser();
      } catch (_) {
        if (!mounted) return;
        _uyariGoster(
            'Bağlantı kurulamadı. İnternetinizi kontrol edip tekrar deneyin.');
        return;
      }

      if (!mounted) return;
      if (!authService.isEmailVerified) {
        _uyariGoster(
            'Rezervasyon için e-posta adresinizi doğrulamanız gerekiyor.');
        return;
      }

      // Kullanıcı profil bilgilerini çek
      final AppUser? userProfile;
      try {
        userProfile = await authService.getCurrentUserProfile();
      } catch (_) {
        if (!mounted) return;
        _uyariGoster('Kullanıcı bilgileri alınamadı. Tekrar deneyin.');
        return;
      }

      if (!mounted) return;
      if (userProfile == null) {
        _uyariGoster('Kullanıcı bilgileri alınamadı.');
        return;
      }

    // ── KVKK açık rıza kontrolü ──
    // Rezervasyon bilgileri WhatsApp (yurt dışı) üzerinden aktarıldığı için
    // açık rıza olmadan gönderim yapılamaz. Rıza yoksa burada istenir.
      if (!userProfile.acikRizaVerildi) {
        final rizaVerildi = await _showAcikRizaDialog();
        if (rizaVerildi != true) return;

        try {
          await FirestoreService().updateUser(userProfile.uid, {
            'acikRizaVerildi': true,
            'acikRizaTarihi': FieldValue.serverTimestamp(),
            'onayMetinSurumu': SirketBilgileri.sonGuncelleme,
          });
        } catch (e) {
          if (!mounted) return;
          _uyariGoster('Onay kaydedilemedi. Tekrar deneyin.');
          return;
        }
      }

      if (!mounted) return;

      // Bottom sheet aç — alım yeri seçimi + onay
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _ReservationFormSheet(
          vehicleName: v.fullName,
          startDate: _startDate!,
          endDate: _endDate!,
          user: userProfile!,
        ),
      );
    } finally {
      if (mounted) setState(() => _isReserving = false);
    }
  }

  /// Ekranın altında tek tip uyarı gösterir.
  void _uyariGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mesaj,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  /// Açık rıza alınmamışsa gönderim öncesi sorar.
  /// KVKK gereği rıza önceden işaretli sunulamaz ve reddedilebilir olmalıdır.
  Future<bool?> _showAcikRizaDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Onayınız Gerekiyor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rezervasyon talebiniz WhatsApp üzerinden iletilecektir. Bu '
              'sırada ad, soyad, telefon ve T.C. Kimlik Numaranız sunucuları '
              'yurt dışında bulunan WhatsApp altyapısı üzerinden aktarılır.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => LegalDocumentScreen.ac(
                  ctx, LegalDocumentScreen.acikRiza()),
              child: Text(
                'Açık Rıza Metni\'ni oku',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Onaylıyorum'),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Giriş Gerekli'),
        content: const Text(
          'Rezervasyon yapabilmek için üye girişi yapmanız gerekiyor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.sayfayaGit(const LoginScreen());
            },
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
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
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: _DetailFavoriteButton(vehicleId: vehicle.id),
        ),
      ],
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
                    onTap: () => context.sayfayaGit(
                      FullScreenImageViewer(
                        imagePaths: vehicle.galleryPaths,
                        initialIndex: i,
                      ),
                      tamEkranDiyalog: true,
                    ),
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

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppConstants.paddingM, AppConstants.paddingM, AppConstants.paddingM, 0),
      padding: const EdgeInsets.all(AppConstants.paddingM),
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: specs.map((s) => SizedBox(
              width: (MediaQuery.of(context).size.width - 80) / 2,
              child: _SpecGridCell(spec: s),
            )).toList(),
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

class _ReservationFormSheet extends StatefulWidget {
  final String vehicleName;
  final DateTime startDate;
  final DateTime endDate;
  final AppUser user;

  const _ReservationFormSheet({
    required this.vehicleName,
    required this.startDate,
    required this.endDate,
    required this.user,
  });

  @override
  State<_ReservationFormSheet> createState() => _ReservationFormSheetState();
}

class _ReservationFormSheetState extends State<_ReservationFormSheet> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  /// T.C. Kimlik No yalnızca burada, gönderim anında istenir.
  /// Hiçbir yere kaydedilmez; sadece WhatsApp mesajına eklenir.
  final _tcController = TextEditingController();

  int _selectedNumberIndex = 0;
  PickupLocation? _selectedPickupLocation;
  bool _isSending = false;

  @override
  void dispose() {
    _tcController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPickupLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen alım yeri seçin.')),
      );
      return;
    }

    setState(() => _isSending = true);

    final selectedNumber = AppConstants.whatsappNumbers[_selectedNumberIndex];
    final tcNo = _tcController.text.trim();

    try {
      // 1. Firestore'a talep kaydı (T.C. Kimlik No KAYDEDİLMEZ).
      //
      // Bu kayıt yönetim panelinin takip listesidir; müşteri açısından asıl
      // işlem WhatsApp'ın açılmasıdır. Bu yüzden kayıt YAZILAMAZSA AKIŞ
      // DURDURULMAZ. Eskiden kayıt önce ve zorunlu olarak yazılıyordu:
      // geçici bir bağlantı sorununda müşteri ham bir Firebase hatası görüp
      // WhatsApp'a hiç ulaşamıyordu.
      //
      // Zaman aşımı, zayıf bağlantıda gönderimin kilitlenmemesi içindir.
      bool kayitYazildi = true;
      try {
        await _firestoreService
            .addWhatsAppLog(
              customerName: widget.user.name,
              customerSurname: widget.user.surname,
              customerPhone: widget.user.phone,
              vehicleName: widget.vehicleName,
              startDate: AppHelpers.formatDate(widget.startDate),
              endDate: AppHelpers.formatDate(widget.endDate),
              phoneNumber: selectedNumber['phone']!,
              phoneLabel: selectedNumber['label']!,
              pickupLocation: _selectedPickupLocation!.name,
              userId: widget.user.uid,
            )
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        kayitYazildi = false;
        debugPrint('Rezervasyon kaydı yazılamadı: $e');
      }

      // 2. WhatsApp aç — kayıt yazılsın ya da yazılmasın.
      final success = await AppHelpers.openWhatsAppWithDetails(
        vehicleName: widget.vehicleName,
        startDate: widget.startDate,
        endDate: widget.endDate,
        customerName: widget.user.name,
        customerSurname: widget.user.surname,
        customerTc: tcNo,
        customerPhone: widget.user.phone,
        pickupLocation: _selectedPickupLocation!.name,
        phoneNumber: selectedNumber['phone']!,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context); // bottom sheet'i kapat
        if (!kayitYazildi) {
          // Müşteri WhatsApp'a ulaştı; yalnızca panel kaydı düşmedi.
          // Suçlayıcı değil, bilgilendirici bir mesaj yeterli.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Talebiniz WhatsApp üzerinden iletiliyor.'),
            ),
          );
        }
      } else {
        // Sheet AÇIK BIRAKILIR: kullanıcı başka bir numara seçip
        // yeniden deneyebilsin.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'WhatsApp açılamadı. Cihazınızda WhatsApp yüklü değilse '
              'yükleyip tekrar deneyin.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Beklenmeyen durum — ham hata log'a, okunabilir mesaj ekrana.
      debugPrint('Rezervasyon gönderimi başarısız: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Talep gönderilemedi. Lütfen tekrar deneyin.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 20, 20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Rezervasyon Onayı',
                style: AppTextStyles.headingMedium, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(widget.vehicleName,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),

            // ── Kullanıcı Bilgileri (salt okunur) ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Kişi Bilgileri', style: AppTextStyles.labelMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Ad Soyad', value: widget.user.fullName),
                  _InfoRow(label: 'Telefon', value: widget.user.phone),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── T.C. Kimlik No (yalnızca bu gönderim için) ──
            Row(
              children: [
                const Icon(Icons.badge_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('T.C. Kimlik No', style: AppTextStyles.labelMedium),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tcController,
              keyboardType: TextInputType.number,
              maxLength: 11,
              decoration: InputDecoration(
                hintText: '11 haneli kimlik numaranız',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
              validator: (v) {
                final tc = (v ?? '').trim();
                if (tc.isEmpty) return 'Kiralama sözleşmesi için gereklidir';
                if (!AppHelpers.isValidTcNo(tc)) {
                  return 'Geçersiz T.C. Kimlik Numarası';
                }
                return null;
              },
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Kimlik numaranız uygulamaya KAYDEDİLMEZ. Yalnızca kiralama '
                    'sözleşmesinin hazırlanabilmesi için oluşturulan WhatsApp '
                    'mesajına eklenir.',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Alım Yeri Seçimi ──
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Alım Yeri', style: AppTextStyles.labelMedium),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<PickupLocation>>(
              stream: _firestoreService.getPickupLocationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final locations = snapshot.data ?? [];

                if (locations.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Text(
                      'Henüz alım yeri tanımlanmamış. Lütfen yönetim ile iletişime geçin.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  );
                }

                // İlk yüklendiğinde ilk alım yerini otomatik seç
                if (_selectedPickupLocation == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _selectedPickupLocation = locations.first);
                    }
                  });
                }

                return Column(
                  children: locations.map((loc) {
                    final isSelected = _selectedPickupLocation?.id == loc.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.08)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: loc.id,
                        groupValue: _selectedPickupLocation?.id,
                        onChanged: (v) {
                          setState(() => _selectedPickupLocation = loc);
                        },
                        title: Text(loc.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600)),
                        subtitle: loc.address.isNotEmpty
                            ? Text(loc.address, style: AppTextStyles.caption)
                            : null,
                        activeColor: AppColors.primary,
                        dense: true,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),

            // ── İletişim Numarası Seçimi (tek numara varsa göstermiyoruz) ──
            if (AppConstants.whatsappNumbers.length > 1) ...[
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('İletişim Numarası', style: AppTextStyles.labelMedium),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(AppConstants.whatsappNumbers.length, (index) {
                final number = AppConstants.whatsappNumbers[index];
                return RadioListTile<int>(
                  value: index,
                  groupValue: _selectedNumberIndex,
                  onChanged: (v) => setState(() => _selectedNumberIndex = v!),
                  title: Text(number['label']!, style: AppTextStyles.bodyMedium),
                  activeColor: AppColors.primary,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const SizedBox(height: 8),
            ],

            // ── Gönder butonu ──
            SizedBox(
              height: AppConstants.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _send,
                icon: _isSending
                    ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.send_rounded),
                label: Text(_isSending ? 'Gönderiliyor...' : 'WhatsApp ile Gönder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ── Salt okunur bilgi satırı ──
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Favori Kalp Butonu (Detail SliverAppBar için) ──
class _DetailFavoriteButton extends StatelessWidget {
  final String vehicleId;

  const _DetailFavoriteButton({required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final uid = authService.currentUser?.uid;

    // Giriş yapmamışsa gösterme
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<List<String>>(
      stream: firestoreService.getFavoriteIdsStream(uid),
      builder: (context, snapshot) {
        final favoriteIds = snapshot.data ?? [];
        final isFavorite = favoriteIds.contains(vehicleId);

        return GestureDetector(
          onTap: () async {
            await firestoreService.toggleFavorite(uid, vehicleId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isFavorite
                      ? 'Favorilerden çıkarıldı'
                      : 'Favorilere eklendi'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              );
            }
          },
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
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}
