import 'package:car_rental_mvp/data/models/blog_post.dart';
import 'package:car_rental_mvp/data/models/vehicle.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';
import 'package:car_rental_mvp/data/services/auth_service.dart';
import 'package:car_rental_mvp/ui/screens/ana_kabuk.dart';
import 'package:car_rental_mvp/ui/screens/faq_screen.dart';
import 'package:car_rental_mvp/ui/screens/vehicle_detail_screen.dart';
import 'package:car_rental_mvp/ui/screens/auth/login_screen.dart';
import 'package:car_rental_mvp/ui/screens/admin/admin_dashboard_screen.dart';
import 'package:car_rental_mvp/ui/widgets/blog_karti.dart';
import 'package:car_rental_mvp/ui/widgets/campaign_section.dart';
import 'package:car_rental_mvp/ui/widgets/date_selector.dart';
import 'package:car_rental_mvp/ui/widgets/filter_bottom_sheet.dart';
import 'package:car_rental_mvp/ui/widgets/iletisim_sheet.dart';
import 'package:car_rental_mvp/ui/widgets/vehicle_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';

/// Ana sayfa sekmesi (AnaKabuk içinde).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  late final TextEditingController _searchController;
  late final Stream<List<Vehicle>> _vehiclesStream;
  late final Stream<List<BlogPost>> _blogStream;

  DateTime? _startDate;
  DateTime? _endDate;

  String _selectedCategory = AppConstants.allCategory;
  RangeValues _priceRange =
      const RangeValues(FilterBottomSheet.minPrice, FilterBottomSheet.maxPrice);
  String _selectedTransmission = 'Hepsi';
  String _searchQuery = '';

  /// Günlük / Aylık / Yıllık fiyat gösterimi.
  FiyatTuru _fiyatTuru = FiyatTuru.gunluk;

  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _vehiclesStream = _firestoreService.getVehiclesStream();
    _blogStream = _firestoreService.getYayindakiBlogYazilari();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    if (!_authService.isLoggedIn) return;
    try {
      final isAdmin = await _authService.isCurrentUserAdmin();
      if (mounted) setState(() => _isAdmin = isAdmin);
    } catch (_) {
      // Rol okunamazsa yönetici simgesi gösterilmez; başka bir etkisi yok.
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Süzgeç ──────────────────────────────────────────────

  /// Kategori, fiyat, vites ve arama süzgecini uygular.
  List<Vehicle> _suz(List<Vehicle> araclar) {
    final searchTerm = _searchQuery.toLowerCase().replaceAll(' ', '');
    return araclar.where((v) {
      final categoryMatch = _selectedCategory == AppConstants.allCategory ||
          v.category == _selectedCategory;
      final priceMatch =
          FilterBottomSheet.fiyatUygun(v.dailyPrice, _priceRange);
      final transmissionMatch = _selectedTransmission == 'Hepsi' ||
          v.transmission == _selectedTransmission;
      if (!(categoryMatch && priceMatch && transmissionMatch)) return false;
      if (searchTerm.isEmpty) return true;
      final vehicleName = v.name.toLowerCase().replaceAll(' ', '');
      final vehicleBrand = v.brand.toLowerCase().replaceAll(' ', '');
      return vehicleName.contains(searchTerm) ||
          vehicleBrand.contains(searchTerm);
    }).toList();
  }

  bool get _ekSuzgecVar =>
      _selectedTransmission != 'Hepsi' ||
      _priceRange.start > FilterBottomSheet.minPrice ||
      _priceRange.end < FilterBottomSheet.maxPrice;

  void _suzgecleriTemizle() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedCategory = AppConstants.allCategory;
      _selectedTransmission = 'Hepsi';
      _priceRange = const RangeValues(
          FilterBottomSheet.minPrice, FilterBottomSheet.maxPrice);
    });
  }

  void _openFilter() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        selectedCategory: _selectedCategory,
        priceRange: _priceRange,
        selectedTransmission: _selectedTransmission,
        onApply: ({
          required String category,
          required RangeValues priceRange,
          required String transmission,
        }) {
          setState(() {
            _selectedCategory = category;
            _priceRange = priceRange;
            _selectedTransmission = transmission;
          });
        },
      ),
    );
  }

  // ── Tarih seçimi ────────────────────────────────────────

  Future<void> _alimSec() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    // Yeni alım tarihi teslim tarihini geçerse teslim temizlenir.
    setState(() {
      _startDate = date;
      if (_endDate != null && !_endDate!.isAfter(date)) _endDate = null;
    });
  }

  Future<void> _teslimSec() async {
    // Teslim en erken alımın ertesi günüdür; aynı gün seçilince süre 0
    // çıkıyor ve rezervasyon düğmesi açıklamasız kilitleniyordu.
    final ilkGun = (_startDate ?? DateTime.now()).add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate:
          _endDate != null && !_endDate!.isBefore(ilkGun) ? _endDate! : ilkGun,
      firstDate: ilkGun,
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (date != null) setState(() => _endDate = date);
  }

  // ── Gezinme ─────────────────────────────────────────────

  void _onVehicleTap(Vehicle vehicle) {
    FocusScope.of(context).unfocus();
    context.sayfayaGit(VehicleDetailScreen(
      vehicle: vehicle,
      startDate: _startDate,
      endDate: _endDate,
    ));
  }

  void _whatsappYaz() async {
    final acildi = await AppHelpers.openWhatsAppWithMessage(
        'Merhaba, araç kiralama hakkında bilgi almak istiyorum.');
    if (!acildi && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp açılamadı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Üst alan mavi; durum çubuğu simgeleri beyaz olmalı.
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: StreamBuilder<List<Vehicle>>(
            stream: _vehiclesStream,
            builder: (context, snapshot) {
              final tumu = snapshot.data ?? const <Vehicle>[];
              final liste = _suz(tumu);
              final yukleniyor =
                  snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData;

              return CustomScrollView(
                slivers: [
                  // Durum çubuğunun arkasında sabit mavi şerit. Olmadan,
                  // aşağı kaydırınca mavi alan yukarı gidiyor ve beyaz saat/
                  // pil simgeleri açık zeminde kayboluyordu.
                  const SliverAppBar(
                    pinned: true,
                    toolbarHeight: 0,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    backgroundColor: AppColors.primary,
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                  ),
                  SliverToBoxAdapter(
                    child: _Karsilama(
                      aramaKontrolcusu: _searchController,
                      aramaVar: _searchQuery.isNotEmpty,
                      ekSuzgecVar: _ekSuzgecVar,
                      girisYapmis: _authService.isLoggedIn,
                      yonetici: _isAdmin,
                      onArama: (q) => setState(() => _searchQuery = q),
                      onAramaTemizle: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      onSuzgec: _openFilter,
                      onGiris: () => context.sayfayaGit(const LoginScreen()),
                      onYonetim: () =>
                          context.sayfayaGit(const AdminDashboardScreen()),
                      tarihKarti: DateSelector(
                        startDate: _startDate,
                        endDate: _endDate,
                        onSelectStart: _alimSec,
                        onSelectEnd: _teslimSec,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _HizliEylemler(
                      onWhatsapp: _whatsappYaz,
                      onAra: () => IletisimSheet.goster(context),
                      onKampanya: () =>
                          AnaKabuk.sekmeyeGit(context, AnaKabuk.kampanyalar),
                      onSss: () => context.sayfayaGit(const FaqScreen()),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: CampaignSection(
                      onViewAll: () =>
                          AnaKabuk.sekmeyeGit(context, AnaKabuk.kampanyalar),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _AracBasligi(
                      adet: liste.length,
                      fiyatTuru: _fiyatTuru,
                      onFiyatTuru: (v) => setState(() => _fiyatTuru = v),
                      kategoriler: [
                        AppConstants.allCategory,
                        ...AppConstants.categories
                            .skip(1)
                            .where((k) => tumu.any((v) => v.category == k)),
                      ],
                      secili: _selectedCategory,
                      onKategori: (k) => setState(() => _selectedCategory = k),
                    ),
                  ),
                  if (yukleniyor)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (snapshot.hasError)
                    const SliverToBoxAdapter(
                      child: _BilgiKutusu(
                        ikon: Icons.cloud_off_rounded,
                        metin: 'Araçlar şu an yüklenemedi. İnternet '
                            'bağlantınızı kontrol edin.',
                      ),
                    )
                  else if (liste.isEmpty)
                    SliverToBoxAdapter(
                      child: _BilgiKutusu(
                        ikon: Icons.search_off_rounded,
                        metin: 'Aramanıza uygun araç bulunamadı.',
                        eylem: 'Filtreleri temizle',
                        onEylem: _suzgecleriTemizle,
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: liste.length,
                      itemBuilder: (context, index) {
                        final vehicle = liste[index];
                        return _ListItemAnimation(
                          key: ValueKey(vehicle.id),
                          index: index,
                          child: VehicleCard(
                            vehicle: vehicle,
                            fiyatTuru: _fiyatTuru,
                            onTap: () => _onVehicleTap(vehicle),
                          ),
                        );
                      },
                    ),
                  SliverToBoxAdapter(
                    child: _BlogSeridi(
                      akis: _blogStream,
                      onTumu: () => AnaKabuk.sekmeyeGit(context, AnaKabuk.blog),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Parçalar
// ═══════════════════════════════════════════════════════════

/// Mavi karşılama alanı: marka, başlık, arama ve üstüne binen tarih kartı.
class _Karsilama extends StatelessWidget {
  final TextEditingController aramaKontrolcusu;
  final bool aramaVar;
  final bool ekSuzgecVar;
  final bool girisYapmis;
  final bool yonetici;
  final ValueChanged<String> onArama;
  final VoidCallback onAramaTemizle;
  final VoidCallback onSuzgec;
  final VoidCallback onGiris;
  final VoidCallback onYonetim;
  final Widget tarihKarti;

  const _Karsilama({
    required this.aramaKontrolcusu,
    required this.aramaVar,
    required this.ekSuzgecVar,
    required this.girisYapmis,
    required this.yonetici,
    required this.onArama,
    required this.onAramaTemizle,
    required this.onSuzgec,
    required this.onGiris,
    required this.onYonetim,
    required this.tarihKarti,
  });

  static const _koyu = AppColors.primaryDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, _koyu],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Arka plandaki soluk daireler — düz mavi bloğu canlandırır.
              Positioned(
                right: -60,
                top: -40,
                child: _Daire(boyut: 200, opaklik: 0.08),
              ),
              Positioned(
                left: -40,
                bottom: -70,
                child: _Daire(boyut: 160, opaklik: 0.06),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset('assets/images/logo.png'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Şenbayrak',
                                  style: AppTextStyles.headingMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800)),
                              Text('Araç Kiralama',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: Colors.white70)),
                            ],
                          ),
                        ),
                        if (yonetici)
                          IconButton(
                            onPressed: onYonetim,
                            tooltip: 'Yönetim Paneli',
                            icon: const Icon(
                                Icons.admin_panel_settings_outlined,
                                color: Colors.white),
                          ),
                        if (!girisYapmis)
                          TextButton.icon(
                            onPressed: onGiris,
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white),
                            icon: const Icon(Icons.login_rounded, size: 18),
                            label: const Text('Giriş'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        'Aracını seç,\nWhatsApp\'tan kirala.',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Günlük, aylık ve yıllık araç kiralama.',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _AramaKutusu(
                        kontrolcu: aramaKontrolcusu,
                        aramaVar: aramaVar,
                        ekSuzgecVar: ekSuzgecVar,
                        onArama: onArama,
                        onTemizle: onAramaTemizle,
                        onSuzgec: onSuzgec,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Tarih kartı mavi alanın altına yarı yarıya biner.
        Stack(
          children: [
            Container(
              height: 48,
              decoration: const BoxDecoration(
                color: _koyu,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: tarihKarti,
            ),
          ],
        ),
      ],
    );
  }
}

class _Daire extends StatelessWidget {
  final double boyut;
  final double opaklik;

  const _Daire({required this.boyut, required this.opaklik});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boyut,
      height: boyut,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opaklik),
      ),
    );
  }
}

class _AramaKutusu extends StatelessWidget {
  final TextEditingController kontrolcu;
  final bool aramaVar;
  final bool ekSuzgecVar;
  final ValueChanged<String> onArama;
  final VoidCallback onTemizle;
  final VoidCallback onSuzgec;

  const _AramaKutusu({
    required this.kontrolcu,
    required this.aramaVar,
    required this.ekSuzgecVar,
    required this.onArama,
    required this.onTemizle,
    required this.onSuzgec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: kontrolcu,
              onChanged: onArama,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Marka veya model ara',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textMuted),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (aramaVar)
            IconButton(
              onPressed: onTemizle,
              icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
              tooltip: 'Temizle',
            ),
          Container(width: 1, height: 28, color: AppColors.divider),
          IconButton(
            onPressed: onSuzgec,
            tooltip: 'Filtrele',
            icon: Badge(
              isLabelVisible: ekSuzgecVar,
              smallSize: 8,
              backgroundColor: AppColors.whatsapp,
              child: const Icon(Icons.tune_rounded, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _HizliEylemler extends StatelessWidget {
  final VoidCallback onWhatsapp;
  final VoidCallback onAra;
  final VoidCallback onKampanya;
  final VoidCallback onSss;

  const _HizliEylemler({
    required this.onWhatsapp,
    required this.onAra,
    required this.onKampanya,
    required this.onSss,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Row(
        children: [
          _Eylem(
            ikon: Icons.chat_rounded,
            renk: AppColors.whatsappDark,
            etiket: 'WhatsApp',
            onTap: onWhatsapp,
          ),
          _Eylem(
            ikon: Icons.call_rounded,
            renk: AppColors.primary,
            etiket: 'Bizi Ara',
            onTap: onAra,
          ),
          _Eylem(
            ikon: Icons.local_offer_rounded,
            renk: const Color(0xFFF57C00),
            etiket: 'Kampanyalar',
            onTap: onKampanya,
          ),
          _Eylem(
            ikon: Icons.help_rounded,
            renk: const Color(0xFF7B1FA2),
            etiket: 'SSS',
            onTap: onSss,
          ),
        ],
      ),
    );
  }
}

class _Eylem extends StatelessWidget {
  final IconData ikon;
  final Color renk;
  final String etiket;
  final VoidCallback onTap;

  const _Eylem({
    required this.ikon,
    required this.renk,
    required this.etiket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: renk.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(ikon, color: renk),
              ),
              const SizedBox(height: 6),
              Text(
                etiket,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AracBasligi extends StatelessWidget {
  final int adet;
  final FiyatTuru fiyatTuru;
  final ValueChanged<FiyatTuru> onFiyatTuru;
  final List<String> kategoriler;
  final String secili;
  final ValueChanged<String> onKategori;

  const _AracBasligi({
    required this.adet,
    required this.fiyatTuru,
    required this.onFiyatTuru,
    required this.kategoriler,
    required this.secili,
    required this.onKategori,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Araçlar', style: AppTextStyles.headingMedium),
                const SizedBox(width: 6),
                Text('($adet)', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Üç seçenek başlıkla aynı satıra dar ekranda sığmıyor; tam
          // genişlikte ayrı satır.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<FiyatTuru>(
                segments: [
                  for (final t in FiyatTuru.values)
                    ButtonSegment(value: t, label: Text(t.etiket)),
                ],
                selected: {fiyatTuru},
                showSelectedIcon: false,
                onSelectionChanged: (s) => onFiyatTuru(s.first),
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  selectedBackgroundColor: AppColors.primary,
                  selectedForegroundColor: Colors.white,
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.divider),
                  textStyle: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: kategoriler.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final k = kategoriler[i];
                final secildi = k == secili;
                return ChoiceChip(
                  label: Text(AppConstants.kategoriAdi(k)),
                  selected: secildi,
                  showCheckmark: false,
                  onSelected: (_) => onKategori(k),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                      color: secildi ? AppColors.primary : AppColors.divider),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: secildi ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BilgiKutusu extends StatelessWidget {
  final IconData ikon;
  final String metin;
  final String? eylem;
  final VoidCallback? onEylem;

  const _BilgiKutusu({
    required this.ikon,
    required this.metin,
    this.eylem,
    this.onEylem,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          Icon(ikon, size: 44, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(metin,
              textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
          if (eylem != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onEylem, child: Text(eylem!)),
          ],
        ],
      ),
    );
  }
}

/// Ana sayfanın altındaki blog şeridi. Yazı yoksa ya da yüklenemezse
/// hiç gösterilmez.
class _BlogSeridi extends StatelessWidget {
  final Stream<List<BlogPost>> akis;
  final VoidCallback onTumu;

  const _BlogSeridi({required this.akis, required this.onTumu});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BlogPost>>(
      stream: akis,
      builder: (context, snapshot) {
        final yazilar = snapshot.data ?? const <BlogPost>[];
        if (snapshot.hasError || yazilar.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bilgilendirme', style: AppTextStyles.headingMedium),
                    TextButton(
                      onPressed: onTumu,
                      child: Text('Tümü',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 236,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: yazilar.length.clamp(0, 6),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => SizedBox(
                    width: 250,
                    child: BlogKarti(yazi: yazilar[i], yatay: true),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Liste öğesi belirme animasyonu ──
class _ListItemAnimation extends StatefulWidget {
  final int index;
  final Widget child;

  const _ListItemAnimation(
      {super.key, required this.index, required this.child});

  @override
  State<_ListItemAnimation> createState() => _ListItemAnimationState();
}

class _ListItemAnimationState extends State<_ListItemAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    // Yalnızca ilk ekrandaki birkaç kart kademeli gelir; aşağı kaydırınca
    // beliren kartlar bekletilmez.
    final gecikme = widget.index < 4 ? widget.index * 80 : 0;
    Future.delayed(Duration(milliseconds: gecikme), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
