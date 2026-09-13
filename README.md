# Premium Car Rental — Mobil Uygulama

> **Durum:** MVP · **Tür:** Kişisel proje · **Teknoloji:** Flutter (Dart)

Araç kiralama için mobil uygulama denemesi. Kullanıcı araçları inceliyor ve
rezervasyonunu **WhatsApp üzerinden** tamamlıyor — böylece ödeme altyapısı ve
üyelik sistemi kurmadan çalışan bir akış elde ediliyor.

---

## Neden WhatsApp

Küçük filolarda rezervasyonlar zaten telefon ve mesajla ilerliyor. Uygulama
araç seçimini ve tarih bilgisini hazırlayıp hazır bir mesaj olarak WhatsApp'a
aktarıyor; işletme tarafında yeni bir panel öğrenme yükü doğmuyor.

---

## Kurulum

Gereken: [Flutter SDK](https://docs.flutter.dev/get-started/install)

```bash
flutter pub get
flutter run
```

## Yapı

| Yol | İş |
| --- | --- |
| `lib/` | Uygulama kodu |
| `assets/` | Görseller ve statik dosyalar |
| `android/` · `ios/` | Platform projeleri |
| `firebase.json` | Firebase yapılandırması |
