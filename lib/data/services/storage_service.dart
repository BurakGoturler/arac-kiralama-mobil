import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Araç görseli yükle ve URL döndür
  /// [vehicleId]: Araç ID'si
  /// [fileName]: Dosya adı (ör: 'main.jpg', 'gallery_1.jpg')
  /// [fileBytes]: Dosya byte verileri
  Future<String> uploadVehicleImage({
    required String vehicleId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final ref = _storage.ref('vehicles/$vehicleId/$fileName');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      cacheControl: 'public, max-age=31536000', // 1 yıl cache
    );

    await ref.putData(fileBytes, metadata);
    return await ref.getDownloadURL();
  }

  /// Bir araç klasöründeki tüm görselleri sil.
  ///
  /// Silmeler paralel yapılır; tek tek beklemek 10+ görselli bir araçta
  /// gözle görülür bir gecikme yaratıyordu.
  Future<void> deleteVehicleImages(String vehicleId) async {
    try {
      final listResult = await _storage.ref('vehicles/$vehicleId').listAll();
      await Future.wait(listResult.items.map((item) => item.delete()));
    } catch (e) {
      // Klasör yoksa ya da bir dosya zaten silinmişse akış bozulmamalı.
      debugPrint('Araç görselleri silinemedi ($vehicleId): $e');
    }
  }

  /// İndirme URL'inden tek bir dosyayı siler.
  ///
  /// Yönetici, araç düzenlerken galeriden bir görseli çıkardığında eskiden
  /// yalnızca Firestore'daki URL listesinden düşüyordu; dosyanın kendisi
  /// Storage'da öksüz kalıyordu.
  Future<void> deleteByUrl(String url) async {
    if (url.isEmpty) return;
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      debugPrint('Görsel silinemedi ($url): $e');
    }
  }

  /// Verilen URL listesindeki dosyaları paralel siler.
  Future<void> deleteByUrls(Iterable<String> urls) async {
    await Future.wait(urls.map(deleteByUrl));
  }
}
