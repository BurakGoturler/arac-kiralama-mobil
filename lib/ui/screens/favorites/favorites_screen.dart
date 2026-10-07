import 'package:car_rental_mvp/data/models/vehicle.dart';
import 'package:car_rental_mvp/data/services/auth_service.dart';
import 'package:car_rental_mvp/data/services/firestore_service.dart';
import 'package:car_rental_mvp/ui/screens/vehicle_detail_screen.dart';
import 'package:car_rental_mvp/ui/widgets/giris_gerekli.dart';
import 'package:car_rental_mvp/ui/widgets/vehicle_card.dart';
import 'package:flutter/material.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  /// Araç sorgusu, favori ID listesi gerçekten değiştiğinde yeniden yapılır.
  /// Daha önce sorgu doğrudan build() içinde oluşturuluyordu; bu yüzden her
  /// yeniden çizimde Firestore'a yeni bir istek gidiyordu.
  Future<List<Vehicle>>? _vehiclesFuture;

  /// Favori kimlikleri akışı bir kez kurulur. Eskiden build() içinde
  /// kuruluyordu; her yeniden çizimde abonelik kapanıp yeniden açılıyor ve
  /// liste bir an yükleme göstergesine dönüyordu.
  late final Stream<List<String>>? _favoriAkisi = _authService.currentUser == null
      ? null
      : _firestoreService.getFavoriteIdsStream(_authService.currentUser!.uid);
  List<String> _sonFavoriIds = const [];

  Future<List<Vehicle>> _araclariGetir(List<String> favoriteIds) {
    final degisti = favoriteIds.length != _sonFavoriIds.length ||
        !favoriteIds.every(_sonFavoriIds.contains);

    if (degisti || _vehiclesFuture == null) {
      _sonFavoriIds = List<String>.from(favoriteIds);
      _vehiclesFuture = _firestoreService.getVehiclesByIds(favoriteIds);
    }
    return _vehiclesFuture!;
  }

  @override
  Widget build(BuildContext context) {
    final uid = _authService.currentUser?.uid;

    if (uid == null || _favoriAkisi == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorilerim')),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: GirisGerekli(
            ikon: Icons.favorite_border_rounded,
            baslik: 'Favorilerinizi kaydedin',
            aciklama: 'Beğendiğiniz araçları kalp simgesiyle kaydetmek ve '
                'buradan kolayca ulaşmak için giriş yapın.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favorilerim')),
      body: StreamBuilder<List<String>>(
        stream: _favoriAkisi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteIds = snapshot.data ?? [];

          if (favoriteIds.isEmpty) {
            return _buildEmptyState();
          }

          return FutureBuilder<List<Vehicle>>(
            future: _araclariGetir(favoriteIds),
            builder: (context, vSnapshot) {
              if (vSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vSnapshot.hasError) {
                return Center(child: Text('Hata: ${vSnapshot.error}'));
              }

              final vehicles = vSnapshot.data ?? [];

              if (vehicles.isEmpty) {
                return _buildEmptyState();
              }

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    color: AppColors.primary.withValues(alpha: 0.05),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          '${vehicles.length} favori araç',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return VehicleCard(
                          vehicle: vehicle,
                          onTap: () => context.sayfayaGit(
                              VehicleDetailScreen(vehicle: vehicle)),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border,
                size: 80, color: AppColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('Henüz favori aracınız yok',
                style: AppTextStyles.headingMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Beğendiğiniz araçlarda kalp ikonuna dokunarak favorilerinize ekleyebilirsiniz.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}