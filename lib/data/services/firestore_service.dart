import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';
import '../models/campaign_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════
  // ARAÇLAR
  // ═══════════════════════════════════════════════════════

  /// Tüm araçları gerçek zamanlı stream olarak getir
  Stream<List<Vehicle>> getVehiclesStream() {
    return _db
        .collection('vehicles')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList());
  }

  /// Tek bir araç getir
  Future<Vehicle?> getVehicle(String id) async {
    final doc = await _db.collection('vehicles').doc(id).get();
    if (doc.exists) return Vehicle.fromFirestore(doc);
    return null;
  }

  /// Yeni araç ekle — direkt Map kabul eder
  Future<String> addVehicleData(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    final docRef = await _db.collection('vehicles').add(data);
    return docRef.id;
  }

  /// Araç güncelle
  Future<void> updateVehicle(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('vehicles').doc(id).update(data);
  }

  /// Araç sil
  Future<void> deleteVehicle(String id) async {
    await _db.collection('vehicles').doc(id).delete();
  }

  // ═══════════════════════════════════════════════════════
  // KAMPANYALAR
  // ═══════════════════════════════════════════════════════

  /// Tüm kampanyaları getir — filtreleme Dart tarafında yapılacak
  /// Bu sayede composite index gerekmez!
  Stream<List<Campaign>> getCampaignsStream() {
    return _db
        .collection('campaigns')
        .snapshots()
        .map((snapshot) {
      final allCampaigns = snapshot.docs
          .map((doc) => Campaign.fromFirestore(doc))
          .toList();

      // isActive filtresini Dart tarafında yap
      final activeCampaigns = allCampaigns
          .where((c) => c.isActive)
          .toList();

      // order'a göre sırala
      activeCampaigns.sort((a, b) => a.order.compareTo(b.order));

      return activeCampaigns;
    });
  }

  /// Tüm kampanyaları getir (admin paneli için, aktif olmayanlar dahil)
  Stream<List<Campaign>> getAllCampaignsStream() {
    return _db
        .collection('campaigns')
        .snapshots()
        .map((snapshot) {
      final campaigns = snapshot.docs
          .map((doc) => Campaign.fromFirestore(doc))
          .toList();
      campaigns.sort((a, b) => a.order.compareTo(b.order));
      return campaigns;
    });
  }

  /// Yeni kampanya ekle
  Future<String> addCampaign(Campaign campaign) async {
    final docRef =
    await _db.collection('campaigns').add(campaign.toFirestore());
    return docRef.id;
  }

  /// Kampanya güncelle
  Future<void> updateCampaign(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('campaigns').doc(id).update(data);
  }

  /// Kampanya sil
  Future<void> deleteCampaign(String id) async {
    await _db.collection('campaigns').doc(id).delete();
  }
}