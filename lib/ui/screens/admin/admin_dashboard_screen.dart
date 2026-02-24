import 'package:car_rental_mvp/data/models/campaign_model.dart';
import 'package:car_rental_mvp/data/models/vehicle.dart';
import 'package:car_rental_mvp/data/services/auth_service.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';
import 'package:car_rental_mvp/ui/screens/admin/admin_vehicle_form_screen.dart';
import 'package:car_rental_mvp/ui/screens/admin/admin_campaign_form_screen.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
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
              } else {
                await _firestoreService.deleteCampaign(id);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"$name" silindi.')),
                );
              }
            },
            child: Text('Sil',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.directions_car), text: 'Araçlar'),
            Tab(icon: Icon(Icons.campaign), text: 'Kampanyalar'),
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AdminVehicleFormScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AdminCampaignFormScreen()),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Ekle'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ── Araçlar sekmesi ──
class _VehiclesTab extends StatelessWidget {
  final FirestoreService firestoreService;
  final void Function(String id, String name) onDelete;

  const _VehiclesTab({required this.firestoreService, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Vehicle>>(
      stream: firestoreService.getVehiclesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
                  child: Image.network(
                    v.imagePath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminVehicleFormScreen(vehicle: v),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: () => onDelete(v.id, v.fullName),
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
class _CampaignsTab extends StatelessWidget {
  final FirestoreService firestoreService;
  final void Function(String id, String name) onDelete;

  const _CampaignsTab({required this.firestoreService, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Campaign>>(
      stream: firestoreService.getAllCampaignsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminCampaignFormScreen(campaign: c),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: () => onDelete(c.id, c.title),
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