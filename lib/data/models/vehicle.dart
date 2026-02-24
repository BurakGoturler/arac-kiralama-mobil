import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String imagePath;       // Artık URL tutacak
  final List<String> galleryPaths; // Artık URL listesi tutacak
  final double dailyPrice;
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

  String get transmissionShort =>
      transmission == 'Automatic' || transmission == 'Otomatik'
          ? 'Auto'
          : 'Manual';

  String get fuelIcon {
    switch (fuelType) {
      case 'Electric':
        return '⚡';
      case 'Hybrid':
        return '🌿';
      case 'Diesel':
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
      transmission: data['transmission'] ?? 'Otomatik',
      fuelType: data['fuelType'] ?? 'Gasoline',
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
      'transmission': transmission,
      'fuelType': fuelType,
      'seats': seats,
      'engineSize': engineSize,
      'year': year,
      'features': features,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}