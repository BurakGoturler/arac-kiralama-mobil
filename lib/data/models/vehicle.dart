import 'package:cloud_firestore/cloud_firestore.dart';

/// Müşterinin ana sayfada seçtiği fiyat görünümü.
enum FiyatTuru {
  gunluk('Günlük'),
  aylik('Aylık'),
  yillik('Yıllık');

  const FiyatTuru(this.etiket);
  final String etiket;
}

class Vehicle {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String imagePath;       // Artık URL tutacak
  final List<String> galleryPaths; // Artık URL listesi tutacak
  final double dailyPrice;

  /// Aylık kiralama fiyatı. 0 ise aylık fiyat tanımlı değildir.
  final double monthlyPrice;

  /// Yıllık kiralama fiyatı. 0 ise tanımlı değildir.
  final double yearlyPrice;
  final String transmission;
  final String fuelType;
  final int seats;
  final String engineSize;
  final int year;
  final List<String> features;
  final bool isAvailable;
  final bool isFeatured;

  const Vehicle({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.imagePath,
    required this.galleryPaths,
    required this.dailyPrice,
    this.monthlyPrice = 0,
    this.yearlyPrice = 0,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.engineSize,
    required this.year,
    required this.features,
    this.isAvailable = true,
    this.isFeatured = false,
  });

  String get fullName => '$brand $name';

  /// Seçilen türdeki fiyat; tanımlı değilse 0 ("Teklif alın" gösterilir).
  double fiyat(FiyatTuru tur) => switch (tur) {
        FiyatTuru.gunluk => dailyPrice,
        FiyatTuru.aylik => monthlyPrice,
        FiyatTuru.yillik => yearlyPrice,
      };

  /// Yönetim formundaki yakıt seçenekleri. Kayıtlar bu değerlerle tutulur.
  static const List<String> yakitTurleri = [
    'Benzin',
    'Dizel',
    'Hibrit',
    'Elektrik',
    'LPG',
  ];

  /// Eski İngilizce kayıtları Türkçe karşılığına çevirir.
  ///
  /// Veritabanında iki dil karışıktı ('Diesel' ve 'Dizel'). Müşteri
  /// kartında "Diesel" görünüyordu; yönetim formundaki açılır liste de
  /// listede olmayan değerle açılıp alanı boş gösteriyordu.
  static String yakitNormal(String? deger) {
    switch ((deger ?? '').trim().toLowerCase()) {
      case 'diesel':
      case 'dizel':
        return 'Dizel';
      case 'gasoline':
      case 'petrol':
      case 'benzin':
        return 'Benzin';
      case 'hybrid':
      case 'hibrit':
        return 'Hibrit';
      case 'electric':
      case 'elektrik':
        return 'Elektrik';
      case 'lpg':
        return 'LPG';
      default:
        return 'Benzin';
    }
  }

  String get transmissionShort =>
      transmission == 'Automatic' || transmission == 'Otomatik'
          ? 'Oto'
          : 'Manuel';

  /// Yakıt tipine göre simge.
  ///
  /// Türkçe karşılıklar da tanınır: veriler artık 'Dizel' / 'Benzin' olarak
  /// giriliyor ve yalnızca İngilizce karşılaştırma yapıldığında tüm araçlar
  /// varsayılan benzin simgesine düşüyordu.
  String get fuelIcon {
    switch (fuelType) {
      case 'Electric':
      case 'Elektrik':
        return '⚡';
      case 'Hybrid':
      case 'Hibrit':
        return '🌿';
      case 'Diesel':
      case 'Dizel':
        return '🛢️';
      default:
        return '⛽';
    }
  }

  // ── Firestore'dan oku ──
  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      category: data['category'] ?? '',
      imagePath: data['imagePath'] ?? '',
      galleryPaths: List<String>.from(data['galleryPaths'] ?? []),
      dailyPrice: (data['dailyPrice'] ?? 0).toDouble(),
      // İçe aktarılan kayıtlarda alan adı 'aylikFiyat'.
      monthlyPrice:
          ((data['monthlyPrice'] ?? data['aylikFiyat'] ?? 0) as num).toDouble(),
      yearlyPrice: ((data['yearlyPrice'] ?? 0) as num).toDouble(),
      transmission: data['transmission'] ?? 'Otomatik',
      fuelType: yakitNormal(data['fuelType']),
      seats: data['seats'] ?? 5,
      engineSize: data['engineSize'] ?? '',
      year: data['year'] ?? 2024,
      features: List<String>.from(data['features'] ?? []),
      isAvailable: data['isAvailable'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
    );
  }

  // ── Firestore'a yaz ──
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'brand': brand,
      'category': category,
      'imagePath': imagePath,
      'galleryPaths': galleryPaths,
      'dailyPrice': dailyPrice,
      'monthlyPrice': monthlyPrice,
      'yearlyPrice': yearlyPrice,
      'transmission': transmission,
      'fuelType': fuelType,
      'seats': seats,
      'engineSize': engineSize,
      'year': year,
      'features': features,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
    };
  }
}