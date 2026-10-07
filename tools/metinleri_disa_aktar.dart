// Yasal metinleri ve envanteri, uygulamanın kendi kodunu ÇALIŞTIRARAK
// JSON'a döker. Belge üretim betiği (tools/belge_uret.py) bu çıktıyı kullanır.
//
// Neden Dart'ta: Metinler `${SirketBilgileri.x}` yerleştirmeleri ve
// envanterden türetilen bölümler içeriyor. Bunları Python'da düzenli ifadeyle
// yeniden çözmek, uygulamanın gösterdiği metinle üretilen belgenin ayrışma
// riskini geri getirirdi. Burada getter'lar doğrudan çağrılır; belgeye giden
// metin, uygulamanın ekranda gösterdiği metnin ta kendisidir.
//
//     dart run tools/metinleri_disa_aktar.dart
import 'dart:convert';
import 'dart:io';

import 'package:car_rental_mvp/core/constants/kvkk_envanter.dart';
import 'package:car_rental_mvp/core/constants/legal_texts.dart';

void main() {
  final veri = {
    'sonGuncelleme': SirketBilgileri.sonGuncelleme,
    'eksikAlanlar': SirketBilgileri.doldurulmamisAlanlar,
    'sirket': {
      'unvan': SirketBilgileri.unvan,
      'adres': SirketBilgileri.adres,
      'vergiDairesi': SirketBilgileri.vergiDairesi,
      'vkn': SirketBilgileri.vkn,
      'kvkkEposta': SirketBilgileri.kvkkEposta,
      'telefon': SirketBilgileri.telefon,
      'kep': SirketBilgileri.kep,
      'gizlilikUrl': SirketBilgileri.gizlilikUrl,
      'aydinlatmaUrl': SirketBilgileri.aydinlatmaUrl,
    },
    'belgeler': [
      {
        'kod': 'gizlilik',
        'baslik': LegalTexts.gizlilikBaslik,
        'metin': LegalTexts.gizlilikMetni,
        'site': 'gizlilik-politikasi.php',
        'pdf': 'Senbayrak_Gizlilik_Politikasi.pdf',
      },
      {
        'kod': 'aydinlatma',
        'baslik': LegalTexts.aydinlatmaBaslik,
        'metin': LegalTexts.aydinlatmaMetni,
        'site': 'kvkk-aydinlatma-metni.php',
        'pdf': 'Senbayrak_KVKK_Aydinlatma_Metni.pdf',
      },
      {
        'kod': 'acikRiza',
        'baslik': LegalTexts.acikRizaBaslik,
        'metin': LegalTexts.acikRizaMetni,
        'site': 'acik-riza-metni.php',
        'pdf': 'Senbayrak_Acik_Riza_Metni_Kampanya.pdf',
      },
      {
        'kod': 'kullanim',
        'baslik': LegalTexts.kullanimKosullariBaslik,
        'metin': LegalTexts.kullanimKosullariMetni,
        'site': 'kullanim-kosullari.php',
        'pdf': 'Senbayrak_Kullanim_Kosullari.pdf',
      },
      {
        'kod': 'saklama',
        'baslik': LegalTexts.saklamaImhaBaslik,
        'metin': LegalTexts.saklamaImhaPolitikasiMetni,
        'site': null,
        'pdf': 'Senbayrak_Saklama_ve_Imha_Politikasi.pdf',
      },
    ],
    'envanter': [
      for (final f in KvkkEnvanter.faaliyetler)
        {
          'surec': f.surec,
          'ortam': f.ortam,
          'amac': f.amac,
          'veriler': f.veriler,
          'hukukiSebep': f.hukukiSebep,
          'toplamaYontemi': f.toplamaYontemi,
          'alicilar': f.alicilar,
          'yurtDisi': f.yurtDisi,
          'saklama': SaklamaSureleri.bul(f.saklamaKategorisi)?.sure ?? '',
        },
    ],
    'saklama': [
      for (final k in SaklamaSureleri.kategoriler)
        {
          'kategori': k.kategori,
          'kayitOrtami': k.kayitOrtami,
          'sure': k.sure,
          'dayanak': k.dayanak,
          'imhaYontemi': k.imhaYontemi,
        },
    ],
  };

  final dosya = File('build/yasal/metinler.json')
    ..createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(veri));
  stdout.writeln('Yazıldı: ${dosya.path}');
  stdout.writeln('Doldurulmamış alanlar: ${SirketBilgileri.doldurulmamisAlanlar}');
}
