# -*- coding: utf-8 -*-
"""
Betiklerin bağlanacağı Firebase projesini uygulamanın kendi
yapılandırmasından (lib/firebase_options.dart) okur.

Eskiden proje kimliği ve API anahtarı her betikte elle yazılıydı. Proje
değiştiğinde (ör. kişisel hesaptan şirket hesabına taşıma) uygulama yeni
projeye bağlanırken betikler sessizce ESKİ projeye yazmaya devam ederdi.
Artık `flutterfire configure` çalıştırıldığı anda betikler de yeni projeyi
görür.
"""

import os
import re

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AYAR_DOSYASI = os.path.join(KOK, "lib", "firebase_options.dart")


def _blok(metin, platform):
    eslesme = re.search(
        rf"static const FirebaseOptions {platform} = FirebaseOptions\((.*?)\);",
        metin, re.S)
    if not eslesme:
        return None
    return dict(re.findall(r"(\w+):\s*'([^']*)'", eslesme.group(1)))


def proje_ayari():
    """(proje_kimligi, api_anahtari) döndürür.

    Web anahtarı tercih edilir: Android anahtarı konsolda "yalnızca Android
    uygulamaları" diye kısıtlanmışsa masaüstünden yapılan REST istekleri
    reddedilir. Web bloğu yoksa Android anahtarına düşülür.
    """
    with open(AYAR_DOSYASI, encoding="utf-8") as f:
        metin = f.read()
    for platform in ("web", "android"):
        blok = _blok(metin, platform)
        if blok and blok.get("projectId") and blok.get("apiKey"):
            return blok["projectId"], blok["apiKey"]
    raise SystemExit(f"✗ {AYAR_DOSYASI} içinde proje kimliği/anahtar bulunamadı.")
