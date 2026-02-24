import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

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

  /// Bir araç klasöründeki tüm görselleri sil
  Future<void> deleteVehicleImages(String vehicleId) async {
    final ref = _storage.ref('vehicles/$vehicleId');
    try {
      final listResult = await ref.listAll();
      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      // Klasör yoksa hata vermesin
    }
  }
}