import 'package:car_rental_mvp/data/mock/vehicles_data.dart';
import 'package:car_rental_mvp/data/models/vehicle.dart';
import 'package:car_rental_mvp/ui/screens/faq_screen.dart';
import 'package:car_rental_mvp/ui/screens/vehicle_detail_screen.dart';
import 'package:car_rental_mvp/ui/widgets/campaign_bottom_sheet.dart';
import 'package:car_rental_mvp/ui/widgets/campaign_section.dart';
import 'package:car_rental_mvp/ui/widgets/date_selector.dart';
import 'package:car_rental_mvp/ui/widgets/filter_bottom_sheet.dart';
import 'package:car_rental_mvp/ui/widgets/vehicle_card.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller'lar
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  // Filtreleme ve Tarih Durumları
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCategory = AppConstants.allCategory;
  RangeValues _priceRange = const RangeValues(500, 5000);
  String _selectedTransmission = 'Hepsi';

  // Arama Durumları
  String _searchQuery = '';

  // Sayfalama Durumları
  int _currentPage = 1;
  static const int _itemsPerPage = 4;

  // Araç Listeleri
  late List<Vehicle> _filteredVehicles = [];
  late List<Vehicle> _paginatedVehicles = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    var tempVehicles = VehiclesMock.vehicles.where((v) {
      final categoryMatch = _selectedCategory == AppConstants.allCategory || v.category == _selectedCategory;
      final priceMatch = v.dailyPrice >= _priceRange.start && v.dailyPrice <= _priceRange.end;
      final transmissionMatch = _selectedTransmission == 'Hepsi' || v.transmission == _selectedTransmission;
      return categoryMatch && priceMatch && transmissionMatch;
    }).toList();

    if (_searchQuery.isNotEmpty) {
      tempVehicles = tempVehicles.where((vehicle) {
        final searchTerm = _searchQuery.toLowerCase().replaceAll(' ', '');
        final vehicleName = vehicle.name.toLowerCase().replaceAll(' ', '');
        final vehicleBrand = vehicle.brand.toLowerCase().replaceAll(' ', '');
        return vehicleName.contains(searchTerm) || vehicleBrand.contains(searchTerm);
      }).toList();
    }

    setState(() {
      _filteredVehicles = tempVehicles;
      _currentPage = 1;
      _updatePaginatedVehicles();
    });
  }

  void _onSearchChanged(String query) {
    if (_searchQuery != query) {
      setState(() {
        _searchQuery = query;
        _applyFilters();
      });
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
      setState(() {
        _paginatedVehicles = [];
      });
      return;
    }
    setState(() {
      _paginatedVehicles = _filteredVehicles.sublist(
          startIndex,
          endIndex > _filteredVehicles.length ? _filteredVehicles.length : endIndex);
    });
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onVehicleTap(Vehicle vehicle) {
    FocusScope.of(context).requestFocus(FocusNode());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleDetailScreen(
          vehicle: vehicle,
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    ).then((_) {
      FocusScope.of(context).requestFocus(FocusNode());
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
        onApply: ({required String category, required RangeValues priceRange, required String transmission}) {
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
      FocusScope.of(context).requestFocus(FocusNode());
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FaqScreen()),
    );
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                child: SizedBox(
                  height: 40,
                  child: Image.asset(
                    'assets/images/logo-uzun.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
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
        body: ListView(
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
                    setState(() {
                      _startDate = date;
                    });
                  }
                },
                onSelectEnd: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? _startDate ?? DateTime.now(),
                    firstDate: _startDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _endDate = date;
                    });
                  }
                },
              ),
            ),
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
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    if (_totalPages <= 1) {
      return const SizedBox.shrink();
    }

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

class _ListItemAnimation extends StatefulWidget {
  final int index;
  final Widget child;

  const _ListItemAnimation({required this.index, required this.child});

  @override
  State<_ListItemAnimation> createState() => _ListItemAnimationState();
}

class _ListItemAnimationState extends State<_ListItemAnimation> with TickerProviderStateMixin {
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

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Kademeli animasyon için gecikme
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
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
