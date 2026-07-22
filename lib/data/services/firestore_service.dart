import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';
import '../models/campaign_model.dart';
import '../models/user_model.dart';
import '../models/pickup_location_model.dart';

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

  // ═══════════════════════════════════════════════════════
  // WHATSAPP LOG
  // ═══════════════════════════════════════════════════════

  /// Yeni WhatsApp log kaydı ekle.
  ///
  /// DİKKAT: T.C. Kimlik Numarası bilinçli olarak KAYDEDİLMEZ. Kullanıcıdan
  /// rezervasyon anında alınır, yalnızca WhatsApp mesajına eklenir ve
  /// hiçbir yere yazılmaz (KVKK — veri minimizasyonu).
  Future<void> addWhatsAppLog({
    required String customerName,
    required String customerSurname,
    required String customerPhone,
    required String vehicleName,
    required String startDate,
    required String endDate,
    required String phoneNumber,
    required String phoneLabel,
    required String pickupLocation,
    required String userId,
  }) async {
    await _db.collection('whatsapp_logs').add({
      'customerName': customerName,
      'customerSurname': customerSurname,
      'customerPhone': customerPhone,
      'vehicleName': vehicleName,
      'startDate': startDate,
      'endDate': endDate,
      'phoneNumber': phoneNumber,
      'phoneLabel': phoneLabel,
      'pickupLocation': pickupLocation,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// WhatsApp loglarını getir (admin paneli için).
  ///
  /// [limit] ile sınırlandırılır; aksi hâlde koleksiyon büyüdükçe her açılışta
  /// tüm kayıtlar indirilir ve hem performans hem Firestore maliyeti bozulur.
  Stream<List<Map<String, dynamic>>> getWhatsAppLogsStream({int limit = 300}) {
    return _db
        .collection('whatsapp_logs')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList());
  }

  /// Saklama süresi dolmuş rezervasyon kayıtlarını siler (KVKK — imha).
  /// Yönetim panelinden elle tetiklenir; ileride bir Cloud Function ile
  /// otomatikleştirilebilir.
  Future<int> deleteExpiredWhatsAppLogs({int saklamaSuresiGun = 730}) async {
    final sinir = DateTime.now().subtract(Duration(days: saklamaSuresiGun));

    final snapshot = await _db
        .collection('whatsapp_logs')
        .where('createdAt', isLessThan: Timestamp.fromDate(sinir))
        .limit(500)
        .get();

    if (snapshot.docs.isEmpty) return 0;

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    return snapshot.docs.length;
  }


  // ═══════════════════════════════════════════════════════
  // KULLANICILAR (USERS)
  // ═══════════════════════════════════════════════════════

  /// Tüm kullanıcıları stream olarak getir (admin paneli için)
  Stream<List<AppUser>> getUsersStream() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList());
  }

  /// Tek bir kullanıcı getir
  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) return AppUser.fromFirestore(doc);
    return null;
  }

  /// Kullanıcı profil bilgilerini güncelle (isim, soyisim, TC, telefon)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('users').doc(uid).update(data);
  }

  /// Favorilere ekle/çıkar (toggle)
  Future<void> toggleFavorite(String uid, String vehicleId) async {
    final userRef = _db.collection('users').doc(uid);
    final doc = await userRef.get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    final currentFavorites =
    List<String>.from(data['favoriteVehicleIds'] ?? []);

    if (currentFavorites.contains(vehicleId)) {
      currentFavorites.remove(vehicleId);
    } else {
      currentFavorites.add(vehicleId);
    }

    await userRef.update({
      'favoriteVehicleIds': currentFavorites,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Kullanıcının favori araçlarının güncel listesini stream olarak getir
  /// Not: user dokümanını dinliyoruz, favori değişince otomatik tetiklenir
  Stream<List<String>> getFavoriteIdsStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>;
      return List<String>.from(data['favoriteVehicleIds'] ?? []);
    });
  }

  /// Verilen ID listesindeki araçları getir
  Future<List<Vehicle>> getVehiclesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    // Firestore 'whereIn' query'si 30 item limit, büyük listeler için parçala
    final List<Vehicle> results = [];
    for (int i = 0; i < ids.length; i += 30) {
      final chunk = ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30);
      final snapshot = await _db
          .collection('vehicles')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)));
    }
    return results;
  }

  // ═══════════════════════════════════════════════════════
  // ALIM YERLERİ (PICKUP LOCATIONS)
  // ═══════════════════════════════════════════════════════

  /// Aktif alım yerlerini stream olarak getir (müşteri tarafı için)
  Stream<List<PickupLocation>> getPickupLocationsStream() {
    return _db
        .collection('pickup_locations')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PickupLocation.fromFirestore(doc))
        .where((loc) => loc.isActive)
        .toList());
  }

  /// Tüm alım yerlerini getir (admin paneli için, pasifler dahil)
  Stream<List<PickupLocation>> getAllPickupLocationsStream() {
    return _db
        .collection('pickup_locations')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PickupLocation.fromFirestore(doc))
        .toList());
  }

  /// Yeni alım yeri ekle
  Future<String> addPickupLocation(PickupLocation location) async {
    final docRef = await _db
        .collection('pickup_locations')
        .add(location.toFirestore());
    return docRef.id;
  }

  /// Alım yeri güncelle
  Future<void> updatePickupLocation(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('pickup_locations').doc(id).update(data);
  }

  /// Alım yeri sil
  Future<void> deletePickupLocation(String id) async {
    await _db.collection('pickup_locations').doc(id).delete();
  }

}