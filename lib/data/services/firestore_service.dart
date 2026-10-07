import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/kvkk_envanter.dart';
import '../models/vehicle.dart';
import '../models/blog_post.dart';
import '../models/campaign_model.dart';
import '../models/user_model.dart';
import '../models/pickup_location_model.dart';
import 'storage_service.dart';

class FirestoreService {
  // Tek örnek (singleton). Ekranlar `FirestoreService()` yazmaya devam eder
  // ama hepsi aynı nesneyi paylaşır; her ekranın kendi kopyasını tutması
  // gereksiz nesne yaratıyordu.
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final StorageService _storage = StorageService();

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

  /// Henüz yazılmamış bir araç için doküman kimliği üretir.
  ///
  /// Görseller Storage'a `vehicles/{id}/...` altına yüklendiği için kimliğe
  /// yazma işleminden ÖNCE ihtiyaç var. Eskiden bu yüzden önce boş bir
  /// doküman oluşturuluyor, sonra görseller yüklenip doküman güncelleniyordu;
  /// yükleme ortada başarısız olursa geriye görselsiz bir hayalet araç
  /// kalıyordu. Kimliği baştan üretmek tek ve atomik bir yazma sağlar.
  String yeniAracKimligi() => _db.collection('vehicles').doc().id;

  /// Aracı tek yazmada oluşturur.
  ///
  /// [data] çağıranın map'idir ve DEĞİŞTİRİLMEZ; zaman damgaları kopyaya
  /// eklenir.
  Future<void> createVehicle(String id, Map<String, dynamic> data) async {
    await _db.collection('vehicles').doc(id).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Araç güncelle
  Future<void> updateVehicle(String id, Map<String, dynamic> data) async {
    await _db.collection('vehicles').doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Aracı ve Storage'daki görsellerini birlikte siler.
  ///
  /// Eskiden yalnızca doküman siliniyordu; `vehicles/{id}/` altındaki
  /// görseller Storage'da öksüz kalıp yer işgal etmeye devam ediyordu.
  /// Görsel silme başarısız olsa bile doküman silinmiş sayılır — kullanıcı
  /// açısından araç listeden kalkmalıdır.
  Future<void> deleteVehicle(String id) async {
    await _db.collection('vehicles').doc(id).delete();
    await _storage.deleteVehicleImages(id);
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
    final docRef = await _db.collection('campaigns').add({
      ...campaign.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Kampanya güncelle. `createdAt` bilinçli olarak yazılmaz — kaydın
  /// oluşturulma tarihi düzenlemeyle değişmemelidir.
  Future<void> updateCampaign(String id, Map<String, dynamic> data) async {
    await _db.collection('campaigns').doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Kampanya sil
  Future<void> deleteCampaign(String id) async {
    await _db.collection('campaigns').doc(id).delete();
  }

  // ═══════════════════════════════════════════════════════
  // BLOG (bilgilendirme yazıları)
  // ═══════════════════════════════════════════════════════

  /// Yayındaki yazılar, en yeni önce.
  ///
  /// Sorgudaki `isPublished == true` şartı ZORUNLUDUR: güvenlik kuralı
  /// taslakları misafire kapatıyor ve Firestore, kuralın reddedebileceği
  /// dokümanları kapsayan bir sorguyu bütünüyle reddeder. Sıralama Dart
  /// tarafında yapılır; böylece bileşik dizin gerekmez.
  Stream<List<BlogPost>> getYayindakiBlogYazilari() {
    return _db
        .collection('blog_posts')
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) => _yeniOnce(
            snapshot.docs.map((doc) => BlogPost.fromFirestore(doc)).toList()));
  }

  /// Yönetim paneli: taslaklar dâhil tüm yazılar.
  Stream<List<BlogPost>> getTumBlogYazilari() {
    return _db.collection('blog_posts').snapshots().map((snapshot) =>
        _yeniOnce(
            snapshot.docs.map((doc) => BlogPost.fromFirestore(doc)).toList()));
  }

  static List<BlogPost> _yeniOnce(List<BlogPost> yazilar) {
    DateTime tarih(BlogPost y) =>
        y.publishedAt ?? y.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return yazilar..sort((a, b) => tarih(b).compareTo(tarih(a)));
  }

  /// Kapak görseli kimliğe göre yüklendiği için kimlik yazmadan önce üretilir.
  String yeniBlogKimligi() => _db.collection('blog_posts').doc().id;

  /// Yazıyı oluşturur veya günceller.
  ///
  /// [ilkYayin] true ise yayın tarihi sunucu saatiyle atanır. Yazı sonradan
  /// taslağa alınıp yeniden yayınlanırsa ilk yayın tarihi korunur.
  Future<void> blogKaydet(
    String id,
    BlogPost yazi, {
    required bool yeni,
    required bool ilkYayin,
  }) async {
    final veri = {
      ...yazi.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (yeni) 'createdAt': FieldValue.serverTimestamp(),
      if (ilkYayin) 'publishedAt': FieldValue.serverTimestamp(),
    };
    final ref = _db.collection('blog_posts').doc(id);
    if (yeni) {
      await ref.set(veri);
    } else {
      await ref.update(veri);
    }
  }

  /// Yazıyı ve kapak görselini siler.
  Future<void> blogSil(String id) async {
    await _db.collection('blog_posts').doc(id).delete();
    await _storage.deleteBlogImages(id);
  }

  // ═══════════════════════════════════════════════════════
  // WHATSAPP LOG
  // ═══════════════════════════════════════════════════════

  /// WhatsApp'a yönlendirilen rezervasyon talebinin takip kaydını ekler.
  ///
  /// 14.09.2026 — Şirket kararı: kiralama talepleri YALNIZCA WhatsApp'tan
  /// alınır. 12 Eylül'de eklenen 'uygulama' kanalı kaldırıldı; 'kanal' alanı
  /// panelin eski kayıtları ayırt edebilmesi için 'whatsapp' olarak yazılmaya
  /// devam eder ve firestore.rules bu değeri zorunlu tutar. Aktarımın
  /// dayanağı açık rıza değil standart sözleşmedir
  /// (SirketBilgileri.whatsappAktarimDayanagi).
  ///
  /// DİKKAT: T.C. Kimlik Numarası bilinçli olarak KAYDEDİLMEZ. İsteğe bağlı
  /// olarak yalnızca WhatsApp mesajına eklenir, hiçbir yere yazılmaz
  /// (KVKK m.4/2-ç — veri minimizasyonu).
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
    const kanal = 'whatsapp';
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
      'kanal': kanal,
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

  /// Saklama süresi dolmuş rezervasyon kayıtlarını siler ve imha kaydı
  /// oluşturur (KVKK — periyodik imha, İmha Yönetmeliği m.7/3 ve m.11).
  ///
  /// Yönetim panelinin İstatistik sekmesindeki "Periyodik İmha" kartından
  /// tetiklenir. Süre [SaklamaSureleri.rezervasyonKaydiGun]'den gelir; yasal
  /// metinlerdeki "2 yıl" ile aynı sabittir (test ile denetlenir).
  ///
  /// Eskiden tek seferde en fazla 500 kayıt siliyordu ve fazlası sessizce
  /// kalıyordu; artık süresi dolan kayıt kalmayana kadar parça parça siler.
  /// Silinecek kayıt olmasa da imha kaydı yazılır: periyodik imhanın
  /// yapıldığı, silinecek bir şey bulunmadığında da ispat edilebilmelidir.
  Future<int> deleteExpiredWhatsAppLogs({
    int saklamaSuresiGun = SaklamaSureleri.rezervasyonKaydiGun,
  }) async {
    final sinir = DateTime.now().subtract(Duration(days: saklamaSuresiGun));
    var toplam = 0;

    while (true) {
      final snapshot = await _db
          .collection('whatsapp_logs')
          .where('createdAt', isLessThan: Timestamp.fromDate(sinir))
          .limit(500)
          .get();

      if (snapshot.docs.isEmpty) break;

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      toplam += snapshot.docs.length;

      if (snapshot.docs.length < 500) break;
    }

    await _db.collection('imha_kayitlari').add({
      'tur': 'periyodik',
      'tarih': FieldValue.serverTimestamp(),
      'kategori': SaklamaSureleri.rezervasyonKaydi,
      'saklamaSuresiGun': saklamaSuresiGun,
      'sinirTarihi': Timestamp.fromDate(sinir),
      'silinenKayitSayisi': toplam,
      'yapanUid': FirebaseAuth.instance.currentUser?.uid,
    });

    return toplam;
  }

  /// Son periyodik imhanın tarihi (hiç yapılmadıysa null).
  ///
  /// Sorgu yalnızca 'tur' eşitliğiyle yapılır ve en yeni tarih istemcide
  /// seçilir: eşitlik + farklı alanda sıralama bileşik dizin ister, periyodik
  /// kayıtlar ise yılda iki tane olduğu için istemcide seçmek maliyetsizdir.
  /// Sunucu zaman damgası henüz yazılmamış (bekleyen) kayıtlar atlanır.
  Stream<DateTime?> getSonPeriyodikImhaTarihiStream() {
    return _db
        .collection('imha_kayitlari')
        .where('tur', isEqualTo: 'periyodik')
        .snapshots()
        .map((snapshot) {
      DateTime? enYeni;
      for (final doc in snapshot.docs) {
        final tarih = (doc.data()['tarih'] as Timestamp?)?.toDate();
        if (tarih != null && (enYeni == null || tarih.isAfter(enYeni))) {
          enYeni = tarih;
        }
      }
      return enYeni;
    });
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

  /// Kullanıcı profil bilgilerini güncelle (isim, soyisim, telefon)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Favorilere ekle/çıkar (toggle).
  ///
  /// Transaction içinde yapılır: eskiden "oku → listeyi değiştir → yaz"
  /// şeklindeydi ve iki hızlı dokunuş arasında okuma/yazma iç içe geçtiğinde
  /// favorilerden biri sessizce kayboluyordu.
  Future<void> toggleFavorite(String uid, String vehicleId) async {
    final userRef = _db.collection('users').doc(uid);

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(userRef);
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final favoriler = List<String>.from(data['favoriteVehicleIds'] ?? []);

      if (favoriler.contains(vehicleId)) {
        favoriler.remove(vehicleId);
      } else {
        favoriler.add(vehicleId);
      }

      transaction.update(userRef, {
        'favoriteVehicleIds': favoriler,
        'updatedAt': FieldValue.serverTimestamp(),
      });
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
    final docRef = await _db.collection('pickup_locations').add({
      ...location.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Alım yeri güncelle. `createdAt` korunur.
  Future<void> updatePickupLocation(String id, Map<String, dynamic> data) async {
    await _db.collection('pickup_locations').doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Alım yeri sil
  Future<void> deletePickupLocation(String id) async {
    await _db.collection('pickup_locations').doc(id).delete();
  }

}