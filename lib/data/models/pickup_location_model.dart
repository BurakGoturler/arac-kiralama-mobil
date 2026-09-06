import 'package:cloud_firestore/cloud_firestore.dart';

class PickupLocation {
  final String id;
  final String name;
  final String address;
  final bool isActive;
  final int order;
  final DateTime? createdAt;

  const PickupLocation({
    this.id = '',
    required this.name,
    required this.address,
    this.isActive = true,
    this.order = 0,
    this.createdAt,
  });

  factory PickupLocation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PickupLocation(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Zaman damgaları burada yazılmaz; FirestoreService ekleme yolunda
  /// `createdAt`, güncelleme yolunda `updatedAt` koyar. Aksi hâlde her
  /// düzenleme kaydın oluşturulma tarihini eziyordu.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'isActive': isActive,
      'order': order,
    };
  }
}