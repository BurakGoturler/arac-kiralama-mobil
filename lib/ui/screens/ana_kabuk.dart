import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'blog/blog_listesi_screen.dart';
import 'favorites/favorites_screen.dart';
import 'hesabim_screen.dart';
import 'home_screen.dart';
import 'kampanyalar_screen.dart';

/// Müşteri tarafının alt menülü iskeleti.
///
/// Sekmeler IndexedStack içinde canlı tutulur: sekme değiştirince kaydırma
/// konumu, seçili tarihler ve Firestore abonelikleri korunur.
class AnaKabuk extends StatefulWidget {
  final int baslangicSekmesi;

  const AnaKabuk({super.key, this.baslangicSekmesi = 0});

  /// Alt ağaçtaki bir ekranın sekme değiştirmesi için (ör. ana sayfadaki
  /// "Kampanyalar → Tümü").
  static void sekmeyeGit(BuildContext context, int sekme) {
    context.findAncestorStateOfType<_AnaKabukState>()?._sec(sekme);
  }

  static const int anaSayfa = 0;
  static const int kampanyalar = 1;
  static const int blog = 2;
  static const int favoriler = 3;
  static const int hesabim = 4;

  @override
  State<AnaKabuk> createState() => _AnaKabukState();
}

class _AnaKabukState extends State<AnaKabuk> {
  late int _sekme = widget.baslangicSekmesi;

  // Sekmeler ilk açıldıklarında kurulur; açılmamış sekme ağ isteği yapmaz.
  final Set<int> _kurulanlar = {};

  void _sec(int sekme) {
    if (sekme == _sekme) return;
    FocusScope.of(context).unfocus();
    setState(() => _sekme = sekme);
  }

  Widget _sekmeIcerigi(int i) {
    switch (i) {
      case AnaKabuk.kampanyalar:
        return const KampanyalarScreen();
      case AnaKabuk.blog:
        return const BlogListesiScreen();
      case AnaKabuk.favoriler:
        return const FavoritesScreen();
      case AnaKabuk.hesabim:
        return const HesabimScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    _kurulanlar.add(_sekme);

    return PopScope(
      // Ana sayfa dışındaki sekmede geri tuşu önce ana sayfaya döner.
      canPop: _sekme == AnaKabuk.anaSayfa,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _sec(AnaKabuk.anaSayfa);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _sekme,
          children: [
            for (var i = 0; i < 5; i++)
              _kurulanlar.contains(i)
                  ? _sekmeIcerigi(i)
                  : const SizedBox.shrink(),
          ],
        ),
        // Araçlar ortada, menü çubuğundaki oyuğa oturan yükseltilmiş
        // yuvarlak düğme. Diğer dört sekme iki yanda.
        floatingActionButton: _OrtaDugme(
          secili: _sekme == AnaKabuk.anaSayfa,
          onTap: () => _sec(AnaKabuk.anaSayfa),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // Klavye açılınca menü çubuğu klavyenin üstüne çıkmasın; sekmelerin
        // kendi Scaffold'ları klavye boşluğunu zaten yönetiyor.
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 7,
          height: 68,
          padding: EdgeInsets.zero,
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black26,
          elevation: 12,
          child: Row(
            children: [
              _MenuOgesi(
                ikon: Icons.local_offer_outlined,
                seciliIkon: Icons.local_offer,
                etiket: 'Kampanyalar',
                secili: _sekme == AnaKabuk.kampanyalar,
                onTap: () => _sec(AnaKabuk.kampanyalar),
              ),
              _MenuOgesi(
                ikon: Icons.article_outlined,
                seciliIkon: Icons.article,
                etiket: 'Blog',
                secili: _sekme == AnaKabuk.blog,
                onTap: () => _sec(AnaKabuk.blog),
              ),
              // Orta düğmenin altındaki etiket.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 38),
                  child: Text(
                    'Araçlar',
                    textAlign: TextAlign.center,
                    style: _MenuOgesi.etiketStili(_sekme == AnaKabuk.anaSayfa),
                  ),
                ),
              ),
              _MenuOgesi(
                ikon: Icons.favorite_border_rounded,
                seciliIkon: Icons.favorite_rounded,
                etiket: 'Favoriler',
                secili: _sekme == AnaKabuk.favoriler,
                onTap: () => _sec(AnaKabuk.favoriler),
              ),
              _MenuOgesi(
                ikon: Icons.person_outline_rounded,
                seciliIkon: Icons.person_rounded,
                etiket: 'Hesabım',
                secili: _sekme == AnaKabuk.hesabim,
                onTap: () => _sec(AnaKabuk.hesabim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrtaDugme extends StatelessWidget {
  final bool secili;
  final VoidCallback onTap;

  const _OrtaDugme({required this.secili, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Araçlar',
      selected: secili,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: secili
                  ? const [AppColors.primary, AppColors.primaryDark]
                  : const [Color(0xFF3D7BE0), AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.directions_car_rounded,
              color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _MenuOgesi extends StatelessWidget {
  final IconData ikon;
  final IconData seciliIkon;
  final String etiket;
  final bool secili;
  final VoidCallback onTap;

  const _MenuOgesi({
    required this.ikon,
    required this.seciliIkon,
    required this.etiket,
    required this.secili,
    required this.onTap,
  });

  /// Tema labelMedium'u harf aralıklı (0.8); "Kampanyalar" dar ekranda iki
  /// satıra bölünüyordu.
  static TextStyle etiketStili(bool secili) => AppTextStyles.caption.copyWith(
        fontSize: 11,
        letterSpacing: 0,
        fontWeight: secili ? FontWeight.w700 : FontWeight.w500,
        color: secili ? AppColors.primary : AppColors.textSecondary,
      );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(secili ? seciliIkon : ikon,
                color: secili ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(etiket,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: etiketStili(secili)),
          ],
        ),
      ),
    );
  }
}
