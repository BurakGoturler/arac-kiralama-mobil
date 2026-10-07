import 'package:car_rental_mvp/ui/screens/profile/profile_screen.dart';
import 'package:car_rental_mvp/ui/screens/favorites/favorites_screen.dart';
import 'package:car_rental_mvp/data/models/vehicle.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';
import 'package:car_rental_mvp/data/services/auth_service.dart';
import 'package:car_rental_mvp/ui/screens/faq_screen.dart';
import 'package:car_rental_mvp/ui/screens/vehicle_detail_screen.dart';
import 'package:car_rental_mvp/ui/screens/auth/login_screen.dart';
import 'package:car_rental_mvp/ui/screens/admin/admin_dashboard_screen.dart';
import 'package:car_rental_mvp/ui/widgets/campaign_bottom_sheet.dart';
import 'package:car_rental_mvp/ui/widgets/campaign_section.dart';
import 'package:car_rental_mvp/ui/widgets/date_selector.dart';
import 'package:car_rental_mvp/ui/widgets/filter_bottom_sheet.dart';
import 'package:car_rental_mvp/ui/widgets/vehicle_card.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final Stream<List<Vehicle>> _vehiclesStream;

  DateTime? _startDate;
  DateTime? _endDate;

  String _selectedCategory = AppConstants.allCategory;
  RangeValues _priceRange = const RangeValues(
      FilterBottomSheet.minPrice, FilterBottomSheet.maxPrice);
  String _selectedTransmission = 'Hepsi';

  String _searchQuery = '';

  int _currentPage = 1;
  static const int _itemsPerPage = 4;

  // Firestore'dan gelen tüm araçlar
  List<Vehicle> _allVehicles = [];
  List<Vehicle> _filteredVehicles = [];
  List<Vehicle> _paginatedVehicles = [];

  // Auth durumu
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _vehiclesStream = _firestoreService.getVehiclesStream();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    if (_authService.isLoggedIn) {
      final isAdmin = await _authService.isCurrentUserAdmin();
      if (mounted) setState(() => _isAdmin = isAdmin);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Kategori, fiyat, vites ve arama süzgecini uygular.
  ///
  /// Eskiden aynı mantık iki yerde (burada ve build içinde) ayrı ayrı
  /// yazılıydı; birinde yapılan düzeltme diğerine yansımıyordu.
  List<Vehicle> _suz(List<Vehicle> araclar) {
    final searchTerm = _searchQuery.toLowerCase().replaceAll(' ', '');
    return araclar.where((v) {
      final categoryMatch = _selectedCategory == AppConstants.allCategory ||
          v.category == _selectedCategory;
      final priceMatch = FilterBottomSheet.fiyatUygun(v.dailyPrice, _priceRange);
      final transmissionMatch = _selectedTransmission == 'Hepsi' ||
          v.transmission == _selectedTransmission;
      if (!(categoryMatch && priceMatch && transmissionMatch)) return false;
      if (searchTerm.isEmpty) return true;
      final vehicleName = v.name.toLowerCase().replaceAll(' ', '');
      final vehicleBrand = v.brand.toLowerCase().replaceAll(' ', '');
      return vehicleName.contains(searchTerm) || vehicleBrand.contains(searchTerm);
    }).toList();
  }

  void _applyFilters() {
    final tempVehicles = _suz(_allVehicles);

    setState(() {
      _filteredVehicles = tempVehicles;
      _currentPage = 1;
      _updatePaginatedVehicles();
    });
  }

  void _onSearchChanged(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFilters();
    }
  }

  void _onSearchSubmitted(String query) {
    _applyFilters();
    if (_filteredVehicles.isEmpty && query.isNotEmpty) {
      _showNoResultsDialog();
    }
  }

  void _updatePaginatedVehicles() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    if (startIndex >= _filteredVehicles.length) {
      _paginatedVehicles = [];
      return;
    }
    _paginatedVehicles = _filteredVehicles.sublist(
      startIndex,
      endIndex > _filteredVehicles.length ? _filteredVehicles.length : endIndex,
    );
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void _onVehicleTap(Vehicle vehicle) {
    FocusScope.of(context).unfocus();
    context
        .sayfayaGit(VehicleDetailScreen(
      vehicle: vehicle,
      startDate: _startDate,
      endDate: _endDate,
    ))
        .then((_) {
      if (mounted) FocusScope.of(context).unfocus();
    });
  }

  void _openFilter() {
    FocusScope.of(context).requestFocus(FocusNode());
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
          _selectedCategory = category;
          _priceRange = priceRange;
          _selectedTransmission = transmission;
          _applyFilters();

          if (_filteredVehicles.isEmpty) {
            _showNoResultsDialog();
          }
        },
      ),
    ).then((_) {
      if (mounted) FocusScope.of(context).unfocus();
    });
  }

  void _showAllCampaigns() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CampaignBottomSheet(),
    );
  }

  void _openFaqScreen() {
    FocusScope.of(context).unfocus();
    context.sayfayaGit(const FaqScreen());
  }

  void _goToLogin() {
    context.sayfayaGit(const LoginScreen()).then((_) {
      // Login ekranından döndüğünde admin rolünü tekrar kontrol et
      _checkAdminRole();
      if (mounted) setState(() {});
    });
  }

  void _goToAdminDashboard() {
    context.sayfayaGit(const AdminDashboardScreen());
  }

  void _goToProfile() {
    context.sayfayaGit(const ProfileScreen());
  }

  void _goToFavorites() {
    context.sayfayaGit(const FavoritesScreen());
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      setState(() => _isAdmin = false);
      context.sayfayaSifirla(const LoginScreen());
    }
  }

  void _showNoResultsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sonuç Bulunamadı'),
          content: const Text(
              'Filtrelerinize uygun bir araç bulunamadı. Lütfen kriterlerinizi değiştirip tekrar deneyin.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  int get _totalPages => (_filteredVehicles.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 120,
          titleSpacing: 16.0,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: Image.asset(
                          'assets/images/logo-uzun.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                    // ── Auth durumuna göre ikonlar ──
                    if (!_authService.isLoggedIn)
                      GestureDetector(
                        onTap: _goToLogin,
                        child: const Icon(
                          Icons.login_rounded,
                          size: 22,
                          color: Colors.grey,
                        ),
                      )
                    else ...[
                      if (_isAdmin)
                        GestureDetector(
                          onTap: _goToAdminDashboard,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 22,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: _goToFavorites,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.favorite_border,
                            size: 22,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _goToProfile,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.person_outline,
                            size: 22,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _logout,
                        child: const Icon(
                          Icons.logout_rounded,
                          size: 22,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onSubmitted: _onSearchSubmitted,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                          hintText: 'Araç ara...',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _openFilter,
                    icon: const Icon(Icons.filter_list_rounded),
                    tooltip: 'Filtrele',
                  ),
                ],
              ),
            ],
          ),
          actions: const [],
        ),
        // ── BODY: StreamBuilder ile Firestore'dan veri çekiyoruz ──
        body: StreamBuilder<List<Vehicle>>(
          stream: _vehiclesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _allVehicles.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Hata: ${snapshot.error}'));
            }

            // Stream'den gelen yeni veriyi al
            if (snapshot.hasData) {
              _allVehicles = snapshot.data!;
              // Filtre uygula ama setState çağırmadan (build içindeyiz)
              _filteredVehicles = _suz(_allVehicles);
              _updatePaginatedVehicles();
            }

            return ListView(
              controller: _scrollController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DateSelector(
                    startDate: _startDate,
                    endDate: _endDate,
                    onSelectStart: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        // Detay ekranındaki seçiciyle aynı kural: yeni alım
                        // tarihi teslim tarihini geçerse teslim temizlenir.
                        // Eskiden teslim alımdan önce kalabiliyor, detay
                        // ekranına negatif süre gidiyordu.
                        setState(() {
                          _startDate = date;
                          if (_endDate != null && !_endDate!.isAfter(date)) {
                            _endDate = null;
                          }
                        });
                      }
                    },
                    onSelectEnd: () async {
                      // Teslim en erken alımın ertesi günüdür; aynı gün
                      // seçilince süre 0 çıkıyor ve rezervasyon düğmesi
                      // açıklamasız kilitleniyordu.
                      final ilkGun = (_startDate ?? DateTime.now())
                          .add(const Duration(days: 1));
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate != null && !_endDate!.isBefore(ilkGun)
                            ? _endDate!
                            : ilkGun,
                        firstDate: ilkGun,
                        lastDate: DateTime.now().add(const Duration(days: 366)),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                      }
                    },
                  ),
                ),
                // ── Favorilerim Kartı (sadece giriş yapmış kullanıcıya) ──
                if (_authService.isLoggedIn)
                  StreamBuilder<List<String>>(
                    stream: _firestoreService.getFavoriteIdsStream(
                        _authService.currentUser!.uid),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: InkWell(
                          onTap: _goToFavorites,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade400,
                                  Colors.pink.shade400,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.favorite,
                                      color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Favorilerim',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        count == 0
                                            ? 'Henüz favori aracınız yok'
                                            : '$count araç',
                                        style: TextStyle(
                                          color:
                                          Colors.white.withValues(alpha: 0.9),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                if (_authService.isLoggedIn) const SizedBox(height: 16),
                CampaignSection(onViewAll: _showAllCampaigns),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: OutlinedButton.icon(
                    onPressed: _openFaqScreen,
                    icon: const Icon(Icons.help_outline_rounded),
                    label: const Text('Sıkça Sorulan Sorular'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: AppTextStyles.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_paginatedVehicles.isEmpty && _allVehicles.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('Filtrelerinize uygun araç bulunamadı.')),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _paginatedVehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = _paginatedVehicles[index];
                      return _ListItemAnimation(
                        index: index,
                        child: VehicleCard(
                          vehicle: vehicle,
                          onTap: () => _onVehicleTap(vehicle),
                        ),
                      );
                    },
                  ),
                _buildPaginationControls(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 1
                ? () {
              setState(() {
                _currentPage--;
                _updatePaginatedVehicles();
                _scrollToTop();
              });
            }
                : null,
            child: const Text('Önceki'),
          ),
          Text('Sayfa $_currentPage / $_totalPages'),
          ElevatedButton(
            onPressed: _currentPage < _totalPages
                ? () {
              setState(() {
                _currentPage++;
                _updatePaginatedVehicles();
                _scrollToTop();
              });
            }
                : null,
            child: const Text('Sonraki'),
          ),
        ],
      ),
    );
  }
}

// ── Animasyon widget'ı (değişmedi) ──
class _ListItemAnimation extends StatefulWidget {
  final int index;
  final Widget child;

  const _ListItemAnimation({required this.index, required this.child});

  @override
  State<_ListItemAnimation> createState() => _ListItemAnimationState();
}

class _ListItemAnimationState extends State<_ListItemAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
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
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}