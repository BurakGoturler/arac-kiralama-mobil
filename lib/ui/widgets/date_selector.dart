import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';

/// Ana ekranın üstündeki kiralama tarihi seçici.
///
/// GÖRÜNÜRLÜK NOTU
/// ---------------
/// Boş kutular eskiden `AppColors.background` ile dolduruluyordu; bu renk
/// sayfanın arka planıyla BİREBİR AYNI (#F7F8FA). Kenarlık da neredeyse
/// görünmez bir gri olunca (#EEF0F4), uygulama ilk açıldığında ekranın ana
/// eylem çağrısı tıklanabilir bir kontrol gibi durmuyordu.
///
/// Artık boş kutular beyaz zeminde, mavi tonlu kenarlıkla ve hafif gölgeyle
/// çiziliyor; sağda bir takvim simgesi dokunulabilirliği belirtiyor. Seçili
/// kutu ise dolu mavi zeminiyle boş kutudan net ayrılıyor.
class DateSelector extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onSelectStart;
  final VoidCallback onSelectEnd;

  const DateSelector({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onSelectStart,
    required this.onSelectEnd,
  });

  @override
  Widget build(BuildContext context) {
    final hasRange = startDate != null && endDate != null;
    final days =
        hasRange ? AppHelpers.daysBetween(startDate!, endDate!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Başlık esnek olmalı: sabit Text + Spacer ile dar ekranlarda
            // "gün" rozetiyle birlikte satır taşıyordu (ölçüldü: 33 piksel).
            // Expanded (Flexible değil): başlık kalan alanı doldurur, böylece
            // "gün" rozeti Spacer'a gerek kalmadan sağa yaslanır.
            Expanded(
              child: Text(
                'Araç Kiralama Süresi',
                style: AppTextStyles.headingMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (hasRange && days != null && days > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  // Eskiden burada `days == 1 ? 'gün' : 'gün'` yazıyordu;
                  // iki dal da aynı olduğu için ölü koddu.
                  '$days gün',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        // DİKKAT: Buraya CrossAxisAlignment.stretch KONULMAMALI. Bu widget
        // kaydırılabilir bir liste içinde yaşıyor; stretch, Row'un çapraz
        // eksenini sonsuz yükseklik kısıtıyla zorluyor ve
        // "BoxConstraints forces an infinite height" ile ekran çöküyor.
        // Kutuların eşit yükseklikte kalması zaten aşağıdaki sabit yükseklikli
        // yıl satırıyla sağlanıyor.
        Row(
          children: [
            Expanded(
              child: _DateTile(
                label: 'Araç Alım',
                date: startDate,
                icon: Icons.flight_land_rounded,
                onTap: onSelectStart,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 22,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DateTile(
                label: 'Araç Teslim',
                date: endDate,
                icon: Icons.flight_takeoff_rounded,
                onTap: onSelectEnd,
                isDisabled: startDate == null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDisabled;

  const _DateTile({
    required this.label,
    required this.date,
    required this.icon,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;

    // Üç durum var ve üçü de birbirinden ayırt edilebilmeli:
    //   seçili  → dolu mavi zemin, koyu metin
    //   boş     → beyaz zemin, mavi tonlu kenarlık, gölge (dokunulabilir)
    //   kapalı  → soluk zemin, gölge yok (dokunulamaz olduğu belli)
    //
    // "kapalı" durumu eskiden "boş" ile aynı görünüyordu: alım tarihi
    // seçilmeden teslim kutusuna dokunmak hiçbir şey yapmıyordu ve kullanıcı
    // bunu anlayamıyordu — sessiz ölü bir kontroldü.
    final Color zemin;
    final Color kenarlik;
    final double kenarKalinligi;
    final Color vurgu;

    if (isDisabled) {
      zemin = AppColors.background;
      kenarlik = AppColors.divider;
      kenarKalinligi = 1;
      vurgu = AppColors.textMuted;
    } else if (hasDate) {
      zemin = AppColors.primaryLight;
      kenarlik = AppColors.primary;
      kenarKalinligi = 1.5;
      vurgu = AppColors.primary;
    } else {
      zemin = AppColors.surface;
      kenarlik = AppColors.primary.withValues(alpha: 0.28);
      kenarKalinligi = 1.5;
      vurgu = AppColors.primary;
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: zemin,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: kenarlik, width: kenarKalinligi),
          // Gölge yalnızca dokunulabilir kutularda; kapalı kutu düz kalır.
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.cardShadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: vurgu),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: vurgu,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Boş kutuda takvim simgesi: "buraya dokunulur" işareti.
                if (!hasDate && !isDisabled)
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              hasDate
                  ? AppHelpers.formatShortDate(date!)
                  : (isDisabled ? 'Önce alım tarihi' : 'Tarih seçin'),
              style: hasDate
                  ? AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    )
                  : AppTextStyles.bodyMedium.copyWith(
                      // Boş kutudaki yazı da eskiden soluk griydi; artık
                      // okunur bir tonda ve yarı kalın.
                      color: isDisabled
                          ? AppColors.textMuted
                          : AppColors.textSecondary,
                      fontWeight:
                          isDisabled ? FontWeight.w400 : FontWeight.w600,
                    ),
            ),
            // Yıl satırı yalnızca tarih seçiliyken vardı; boş kutuda satır
            // olmayınca iki kutu farklı yükseklikte oluyordu. Artık boş
            // kutuda da aynı yüksekliği koruyan bir yer tutucu var.
            SizedBox(
              height: 17,
              child: hasDate
                  ? Text('${date!.year}', style: AppTextStyles.caption)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
