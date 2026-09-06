import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_rental_mvp/core/navigation/app_page_route.dart';
import 'package:car_rental_mvp/data/models/campaign_model.dart';
import 'package:car_rental_mvp/data/models/vehicle.dart';
import 'package:car_rental_mvp/data/services/auth_service.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';
import 'package:car_rental_mvp/ui/screens/admin/admin_vehicle_form_screen.dart';
import 'package:car_rental_mvp/ui/screens/admin/admin_campaign_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:car_rental_mvp/data/models/user_model.dart';
import 'package:car_rental_mvp/data/models/pickup_location_model.dart';
import 'package:car_rental_mvp/ui/screens/admin/admin_pickup_location_form_screen.dart';

import 'package:car_rental_mvp/ui/screens/auth/login_screen.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  late TabController _tabController;

  /// Yalnızca "Yeni Ekle" butonunun hangi formu açacağını belirler.
  ///
  /// Eskiden bunun yerine `_tabController.addListener(() => setState(() {}))`
  /// vardı. TabController kaydırma animasyonu boyunca HER KAREDE haber verir;
  /// yani panel saniyede 60 kez baştan çiziliyor, beş sekmenin tamamı bu
  /// sırada yeniden kuruluyordu. Panelin "takılıyor" hissi büyük ölçüde
  /// buradan geliyordu. Artık yalnızca sekme gerçekten değiştiğinde ve
  /// yalnızca butonun kendisi yeniden çizilir.
  final ValueNotifier<int> _aktifSekme = ValueNotifier<int>(0);

  /// Yetki doğrulaması tamamlanana kadar panel içeriği çizilmez.
  ///
  /// Panel daha önce kendi kendini korumuyordu: erişim yalnızca ana
  /// ekrandaki butonun gizlenmesine dayanıyordu. Sunucu kuralları yazma
  /// işlemlerini zaten reddediyor, dolayısıyla veri riski yoktu; ancak
  /// yetkisiz bir hesap panele girip her sekmede izin hatası alıyordu.
  /// Burada rol açıkça doğrulanır ve yetkisiz kullanıcı geri gönderilir.
  bool _yetkiDogrulandi = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_sekmeDegisti);
    _yetkiDogrula();
  }

  Future<void> _yetkiDogrula() async {
    bool yetkili;
    try {
      yetkili = await _authService.isCurrentUserAdmin();
    } catch (_) {
      // Ağ hatasında panele sokma; güvenli taraf reddetmektir.
      yetkili = false;
    }

    if (!mounted) return;

    if (yetkili) {
      setState(() => _yetkiDogrulandi = true);
    } else {
      Navigator.of(context).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu hesabın yönetim paneline erişim yetkisi yok.'),
        ),
      );
    }
  }

  void _sekmeDegisti() {
    if (_aktifSekme.value != _tabController.index) {
      _aktifSekme.value = _tabController.index;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_sekmeDegisti);
    _tabController.dispose();
    _aktifSekme.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      context.sayfayaSifirla(const LoginScreen());
    }
  }

  void _confirmDelete(String type, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silme Onayı'),
        content: Text('"$name" silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (type == 'vehicle') {
                await _firestoreService.deleteVehicle(id);
              } else if (type == 'campaign') {
                await _firestoreService.deleteCampaign(id);
              } else if (type == 'pickup') {
                await _firestoreService.deletePickupLocation(id);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"$name" silindi.')),
                );
              }
            },
            child: Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rol doğrulanana kadar hiçbir yönetim verisi istenmez ve çizilmez.
    if (!_yetkiDogrulandi) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yönetim Paneli'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Çıkış Yap',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.directions_car), text: 'Araçlar'),
            Tab(icon: Icon(Icons.campaign), text: 'Kampanyalar'),
            Tab(icon: Icon(Icons.location_on), text: 'Alım Yerleri'),
            Tab(icon: Icon(Icons.people), text: 'Üyeler'),
            Tab(icon: Icon(Icons.bar_chart), text: 'İstatistik'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _VehiclesTab(
            firestoreService: _firestoreService,
            onDelete: (id, name) => _confirmDelete('vehicle', id, name),
          ),
          _CampaignsTab(
            firestoreService: _firestoreService,
            onDelete: (id, name) => _confirmDelete('campaign', id, name),
          ),
          _PickupLocationsTab(
            firestoreService: _firestoreService,
            onDelete: (id, name) => _confirmDelete('pickup', id, name),
          ),
          _UsersTab(firestoreService: _firestoreService),
          _StatsTab(firestoreService: _firestoreService),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<int>(
        valueListenable: _aktifSekme,
        builder: (context, sekme, _) {
          // Üyeler ve İstatistik sekmelerinde ekleme yapılmaz.
          if (sekme == 3 || sekme == 4) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () {
              switch (sekme) {
                case 0:
                  context.sayfayaGit(const AdminVehicleFormScreen());
                case 1:
                  context.sayfayaGit(const AdminCampaignFormScreen());
                case 2:
                  context.sayfayaGit(const AdminPickupLocationFormScreen());
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Yeni Ekle'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
//  Sekme içerikleri.
//
//  Hepsi aynı iki kurala uyar:
//
//  1. Firestore akışı `initState`'te BİR KEZ kurulur. Sekmeler eskiden
//     `StatelessWidget`'tı ve `firestoreService.getVehiclesStream()` çağrısı
//     `build()` içindeydi. Her build yeni bir Stream nesnesi üretiyor,
//     StreamBuilder bunu farklı bir kaynak sanıp aboneliği kapatıp yeniden
//     açıyor, bağlantı durumu `waiting`'e döndüğü için de ekranda bir anlık
//     dönen çember beliriyordu — "her sekmeye girince orası yenileniyor gibi
//     oluyor" şikâyetinin kaynağı buydu.
//
//  2. `AutomaticKeepAliveClientMixin` ile sekme canlı tutulur; ileri geri
//     gidildiğinde abonelik, kaydırma konumu ve sayfa numarası korunur.
//     Mixin'in sözleşmesi gereği `build` içinde `super.build(context)`
//     çağrılmalıdır.
// ─────────────────────────────────────────────────────────────────────

// ── Araçlar sekmesi ──
class _VehiclesTab extends StatefulWidget {
  final FirestoreService firestoreService;
  final void Function(String id, String name) onDelete;

  const _VehiclesTab({required this.firestoreService, required this.onDelete});

  @override
  State<_VehiclesTab> createState() => _VehiclesTabState();
}

class _VehiclesTabState extends State<_VehiclesTab>
    with AutomaticKeepAliveClientMixin {
  late final Stream<List<Vehicle>> _stream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _stream = widget.firestoreService.getVehiclesStream();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<Vehicle>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Araçlar yüklenemedi: ${snapshot.error}'));
        }
        final vehicles = snapshot.data ?? [];
        if (vehicles.isEmpty) {
          return const Center(child: Text('Henüz araç eklenmemiş.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final v = vehicles[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: v.imagePath.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  // Image.network her kaydırmada görseli yeniden indiriyordu;
                  // CachedNetworkImage zaten projede kullanılıyor.
                  child: CachedNetworkImage(
                    imageUrl: v.imagePath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    memCacheWidth: 180,
                    errorWidget: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.background,
                      child: const Icon(Icons.directions_car),
                    ),
                  ),
                )
                    : Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.directions_car),
                ),
                title: Text(v.fullName, style: AppTextStyles.headingMedium),
                subtitle: Text(
                  '${v.category} • ${AppHelpers.formatPrice(v.dailyPrice)}/gün',
                  style: AppTextStyles.bodySmall,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.primary),
                      onPressed: () => context
                          .sayfayaGit(AdminVehicleFormScreen(vehicle: v)),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: () => widget.onDelete(v.id, v.fullName),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Kampanyalar sekmesi ──
class _CampaignsTab extends StatefulWidget {
  final FirestoreService firestoreService;
  final void Function(String id, String name) onDelete;

  const _CampaignsTab({required this.firestoreService, required this.onDelete});

  @override
  State<_CampaignsTab> createState() => _CampaignsTabState();
}

class _CampaignsTabState extends State<_CampaignsTab>
    with AutomaticKeepAliveClientMixin {
  late final Stream<List<Campaign>> _stream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _stream = widget.firestoreService.getAllCampaignsStream();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<Campaign>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Kampanyalar yüklenemedi: ${snapshot.error}'));
        }
        final campaigns = snapshot.data ?? [];
        if (campaigns.isEmpty) {
          return const Center(child: Text('Henüz kampanya eklenmemiş.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: campaigns.length,
          itemBuilder: (context, index) {
            final c = campaigns[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: c.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.campaign, color: Colors.white, size: 24),
                ),
                title: Text(c.title, style: AppTextStyles.headingMedium),
                subtitle: Text(
                  c.isActive ? 'Aktif' : 'Pasif',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.isActive ? AppColors.success : AppColors.textMuted,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.primary),
                      onPressed: () => context
                          .sayfayaGit(AdminCampaignFormScreen(campaign: c)),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: () => widget.onDelete(c.id, c.title),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Alım Yerleri sekmesi ──
class _PickupLocationsTab extends StatefulWidget {
  final FirestoreService firestoreService;
  final void Function(String id, String name) onDelete;

  const _PickupLocationsTab({
    required this.firestoreService,
    required this.onDelete,
  });

  @override
  State<_PickupLocationsTab> createState() => _PickupLocationsTabState();
}

class _PickupLocationsTabState extends State<_PickupLocationsTab>
    with AutomaticKeepAliveClientMixin {
  late final Stream<List<PickupLocation>> _stream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _stream = widget.firestoreService.getAllPickupLocationsStream();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<PickupLocation>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Alım yerleri yüklenemedi: ${snapshot.error}'));
        }
        final locations = snapshot.data ?? [];
        if (locations.isEmpty) {
          return const Center(child: Text('Henüz alım yeri eklenmemiş.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final l = locations[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: l.isActive
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: l.isActive ? AppColors.primary : AppColors.textMuted,
                    size: 24,
                  ),
                ),
                title: Text(l.name, style: AppTextStyles.headingMedium),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (l.address.isNotEmpty)
                      Text(l.address,
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    Text(
                      l.isActive ? 'Aktif' : 'Pasif',
                      style: AppTextStyles.caption.copyWith(
                        color: l.isActive
                            ? AppColors.success
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.primary),
                      onPressed: () => context.sayfayaGit(
                          AdminPickupLocationFormScreen(location: l)),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => widget.onDelete(l.id, l.name),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Üyeler sekmesi (sayfalı liste) ──
class _UsersTab extends StatefulWidget {
  final FirestoreService firestoreService;

  const _UsersTab({required this.firestoreService});

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab>
    with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

  late final Stream<List<AppUser>> _stream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _stream = widget.firestoreService.getUsersStream();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<AppUser>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(child: Text('Henüz üye yok.'));
        }

        // Sayfalama hesaplamaları
        final totalPages = (users.length / _itemsPerPage).ceil();
        if (_currentPage > totalPages) _currentPage = totalPages;
        if (_currentPage < 1) _currentPage = 1;

        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage) > users.length
            ? users.length
            : startIndex + _itemsPerPage;
        final pagedUsers = users.sublist(startIndex, endIndex);

        return Column(
          children: [
            // Özet bilgi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primary.withValues(alpha: 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Toplam ${users.length} üye',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.primary),
                  ),
                  Text(
                    'Sayfa $_currentPage / $totalPages',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // Kullanıcı listesi
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pagedUsers.length,
                itemBuilder: (context, index) {
                  final u = pagedUsers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: u.isAdmin
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          u.isAdmin
                              ? Icons.admin_panel_settings
                              : Icons.person,
                          color: u.isAdmin ? Colors.white : AppColors.primary,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              u.fullName.trim().isEmpty ? '—' : u.fullName,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (u.isAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ADMIN',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          if (u.email.isNotEmpty)
                            _UserInfoLine(icon: Icons.email_outlined, text: u.email),
                          if (u.phone.isNotEmpty)
                            _UserInfoLine(icon: Icons.phone_outlined, text: u.phone),
                          // T.C. Kimlik No artık saklanmadığı için burada
                          // gösterilecek bir veri de yok (KVKK — minimizasyon).
                          _UserInfoLine(
                            icon: u.acikRizaVerildi
                                ? Icons.verified_user_outlined
                                : Icons.privacy_tip_outlined,
                            text: u.acikRizaVerildi
                                ? 'Açık rıza verildi'
                                : 'Açık rıza yok',
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),

            // Sayfalama kontrolleri
            if (totalPages > 1)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.textMuted.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPage > 1
                          ? () => setState(() => _currentPage--)
                          : null,
                      child: const Text('Önceki'),
                    ),
                    Text('$_currentPage / $totalPages'),
                    ElevatedButton(
                      onPressed: _currentPage < totalPages
                          ? () => setState(() => _currentPage++)
                          : null,
                      child: const Text('Sonraki'),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// Kullanıcı bilgi satırı (icon + text)
class _UserInfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _UserInfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── İstatistikler sekmesi ──
class _StatsTab extends StatefulWidget {
  final FirestoreService firestoreService;

  const _StatsTab({required this.firestoreService});

  @override
  State<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<_StatsTab>
    with AutomaticKeepAliveClientMixin {
  int _currentPage = 1;
  static const int _itemsPerPage = 5;

  DateTime? _filterStart;
  DateTime? _filterEnd;

  late final Stream<List<Map<String, dynamic>>> _stream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _stream = widget.firestoreService.getWhatsAppLogsStream();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_filterStart ?? now)
          : (_filterEnd ?? _filterStart ?? now),
      firstDate: DateTime(2024),
      lastDate: now,
      builder: (context, child) => Theme(
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
          _filterStart = picked;
          // Bitiş tarihi başlangıçtan önceyse sıfırla
          if (_filterEnd != null && _filterEnd!.isBefore(picked)) {
            _filterEnd = null;
          }
        } else {
          _filterEnd = picked;
        }
        _currentPage = 1;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _filterStart = null;
      _filterEnd = null;
      _currentPage = 1;
    });
  }

  List<Map<String, dynamic>> _applyDateFilter(List<Map<String, dynamic>> logs) {
    if (_filterStart == null && _filterEnd == null) return logs;

    return logs.where((log) {
      final ts = log['createdAt'];
      if (ts == null || ts is! Timestamp) return false;
      final logDate = ts.toDate();

      if (_filterStart != null) {
        final startOfDay = DateTime(_filterStart!.year, _filterStart!.month, _filterStart!.day);
        if (logDate.isBefore(startOfDay)) return false;
      }
      if (_filterEnd != null) {
        final endOfDay = DateTime(_filterEnd!.year, _filterEnd!.month, _filterEnd!.day, 23, 59, 59);
        if (logDate.isAfter(endOfDay)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final dateFormat = DateFormat('dd.MM.yyyy', 'tr_TR');

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Kayıtlar yüklenemedi: ${snapshot.error}'));
        }

        final allLogs = snapshot.data ?? [];

        if (allLogs.isEmpty) {
          return const Center(child: Text('Henüz mesaj kaydı yok.'));
        }

        // Tarih filtresi uygula
        final logs = _applyDateFilter(allLogs);

        // Numara bazlı sayım
        final Map<String, int> phoneCounts = {};
        for (final log in logs) {
          final label = log['phoneLabel'] as String? ?? 'Bilinmeyen';
          phoneCounts[label] = (phoneCounts[label] ?? 0) + 1;
        }

        // Sayfalama hesaplamaları
        final totalPages = logs.isEmpty ? 1 : (logs.length / _itemsPerPage).ceil();
        if (_currentPage > totalPages) _currentPage = totalPages;
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage) > logs.length
            ? logs.length
            : startIndex + _itemsPerPage;
        final pagedLogs = logs.isEmpty ? <Map<String, dynamic>>[] : logs.sublist(startIndex, endIndex);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Tarih Filtresi ──
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tarih Filtresi', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                        if (_filterStart != null || _filterEnd != null)
                          GestureDetector(
                            onTap: _clearFilter,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.close, size: 16, color: AppColors.error),
                                const SizedBox(width: 4),
                                Text('Temizle',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(isStart: true),
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    _filterStart != null
                                        ? dateFormat.format(_filterStart!)
                                        : 'Başlangıç',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: _filterStart != null
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward, size: 16, color: AppColors.textMuted),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(isStart: false),
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    _filterEnd != null
                                        ? dateFormat.format(_filterEnd!)
                                        : 'Bitiş',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: _filterEnd != null
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_filterStart != null || _filterEnd != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Toplam ${allLogs.length} kayıttan ${logs.length} tanesi gösteriliyor',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Özet Tablo ──
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Numara Bazlı İstatistik',
                        style: AppTextStyles.headingMedium),
                    const SizedBox(height: 12),
                    if (logs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text('Seçilen tarih aralığında kayıt yok.',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                        ),
                      )
                    else
                      Table(
                        border: TableBorder.all(
                          color: AppColors.textMuted.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8)),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text('Numara',
                                    style: AppTextStyles.labelMedium
                                        .copyWith(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text('Mesaj',
                                    style: AppTextStyles.labelMedium
                                        .copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                          ...phoneCounts.entries.map((entry) => TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(entry.key,
                                    style: AppTextStyles.bodyMedium),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text('${entry.value}',
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center),
                              ),
                            ],
                          )),
                          TableRow(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text('TOPLAM',
                                    style: AppTextStyles.labelMedium
                                        .copyWith(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text('${logs.length}',
                                    style: AppTextStyles.labelMedium
                                        .copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Son Mesajlar Başlık + Sayfa Bilgisi ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Son Mesajlar', style: AppTextStyles.headingMedium),
                Text('$_currentPage / $totalPages',
                    style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 12),

            if (logs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text('Bu tarih aralığında mesaj bulunamadı.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                ),
              )
            else ...[
              // ── Mesaj Listesi (sayfalı) ──
              ...pagedLogs.map((log) {
                final ts = log['createdAt'];
                String dateStr = '';
                if (ts != null && ts is Timestamp) {
                  dateStr = DateFormat('dd.MM.yyyy HH:mm', 'tr_TR')
                      .format(ts.toDate());
                }
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    title: Text(
                      '${log['customerName'] ?? ''} ${log['customerSurname'] ?? ''}',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${log['vehicleName'] ?? ''} • ${log['phoneLabel'] ?? ''}\n$dateStr',
                      style: AppTextStyles.caption,
                    ),
                    isThreeLine: true,
                  ),
                );
              }),

              // ── Sayfalama Kontrolleri ──
              if (totalPages > 1) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPage > 1
                          ? () => setState(() => _currentPage--)
                          : null,
                      child: const Text('Önceki'),
                    ),
                    Text('Sayfa $_currentPage / $totalPages'),
                    ElevatedButton(
                      onPressed: _currentPage < totalPages
                          ? () => setState(() => _currentPage++)
                          : null,
                      child: const Text('Sonraki'),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}