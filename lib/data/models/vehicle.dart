class Vehicle {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String imagePath;
  final List<String> galleryPaths;
  final double dailyPrice;
  final String transmission; // 'Automatic' | 'Manual'
  final String fuelType; // 'Gasoline' | 'Diesel' | 'Electric' | 'Hybrid'
  final int seats;
  final String engineSize; // e.g. '2.0L' or '200 kW'
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
      transmission == 'Automatic' ? 'Auto' : 'Manual';

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
}