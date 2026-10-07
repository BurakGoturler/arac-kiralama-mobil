#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Şenbayrak — eski (kişisel hesaptaki) Firebase projesinden yeni şirket
projesine içerik taşıma.

NE TAŞINIR
----------
  vehicles          eski projeden, olduğu gibi (görsel alanları boşaltılır)
  pickup_locations  eski projeden, olduğu gibi
  campaigns         eski projeden DEĞİL, tools/kampanyalar.json'dan

NE TAŞINMAZ (bilerek)
---------------------
  users, whatsapp_logs, imha_kayitlari — kişisel veri ve test kayıtları.
  Uygulama yayında değilken oluşmuş kayıtlar yeni projeye kopyalanmaz;
  eski projeyle birlikte silinir (KVKK — veri minimizasyonu). Yöneticiler
  yeni projede uygulamadan yeniden üye olur.

KAYNAK VE HEDEF
---------------
Hedef proje lib/firebase_options.dart'tan okunur (flutterfire configure ile
yeni projeye bağlandıktan sonra çalıştırılmalı). Kaynak varsayılan olarak
eski proje kimliğidir; araç ve şube koleksiyonları herkese açık okunduğu
için kaynakta giriş gerekmez.

Yazma, hedef projede YÖNETİCİ hesabıyla giriş yapılarak REST API üzerinden
yapılır; yani güvenlik kurallarından geçer. Servis hesabı anahtarı gerekmez.

KULLANIM
--------
    python tools/projeye_tasi.py            # önizleme, hiçbir şey yazılmaz
    python tools/projeye_tasi.py --uygula   # yaz

Hedefte zaten bulunan araçların ÜZERİNE YAZILMAZ: fotoğraflar yüklendikten
sonra betik yanlışlıkla yeniden çalıştırılırsa görseller silinmesin diye.
Bilerek üzerine yazmak için --uzerine-yaz eklenir.
"""

import argparse
import datetime
import getpass
import json
import os
import sys
import urllib.error
import urllib.request

from firebase_ayar import proje_ayari

for _akis in (sys.stdout, sys.stderr):
    try:
        _akis.reconfigure(encoding="utf-8")
    except (AttributeError, OSError):
        pass

ESKI_PROJE = "senbayrak-arac-kiralama"
HEDEF_PROJE, API_ANAHTARI = proje_ayari()
KAMPANYA_DOSYASI = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "kampanyalar.json")


def _kok(proje):
    return (f"https://firestore.googleapis.com/v1/projects/{proje}"
            "/databases/(default)/documents")


def _istek(url, veri=None, yontem="GET", jeton=None, yok_ise=False):
    """HTTP isteği. yok_ise=True iken 404, None olarak döner."""
    basliklar = {"Content-Type": "application/json"}
    if jeton:
        basliklar["Authorization"] = f"Bearer {jeton}"
    govde = json.dumps(veri).encode("utf-8") if veri is not None else None
    istek = urllib.request.Request(url, data=govde, headers=basliklar,
                                   method=yontem)
    try:
        with urllib.request.urlopen(istek) as yanit:
            ham = yanit.read().decode("utf-8")
            return json.loads(ham) if ham else {}
    except urllib.error.HTTPError as e:
        if yok_ise and e.code == 404:
            return None
        detay = e.read().decode("utf-8", "replace")
        raise SystemExit(f"\n✗ HTTP {e.code} — {url}\n{detay}\n")


def koleksiyonu_oku(proje, koleksiyon):
    """Koleksiyondaki tüm dokümanları (kimlik, alanlar) olarak döndürür."""
    sonuc, sayfa = [], None
    while True:
        url = f"{_kok(proje)}/{koleksiyon}?pageSize=300"
        if sayfa:
            url += f"&pageToken={sayfa}"
        yanit = _istek(url)
        for dok in yanit.get("documents", []):
            sonuc.append((dok["name"].rsplit("/", 1)[-1], dok.get("fields", {})))
        sayfa = yanit.get("nextPageToken")
        if not sayfa:
            return sonuc


def _deger(v):
    if isinstance(v, bool):
        return {"booleanValue": v}
    if isinstance(v, int):
        return {"integerValue": str(v)}
    if isinstance(v, float):
        return {"doubleValue": v}
    if isinstance(v, list):
        return {"arrayValue": {"values": [_deger(x) for x in v]}}
    return {"stringValue": str(v)}


def _simdi():
    an = datetime.datetime.now(datetime.timezone.utc)
    return {"timestampValue": an.strftime("%Y-%m-%dT%H:%M:%S.%fZ")}


def kampanyalari_oku():
    with open(KAMPANYA_DOSYASI, encoding="utf-8") as f:
        veri = json.load(f)
    sonuc = []
    for k in veri["kampanyalar"]:
        alanlar = {a: _deger(d) for a, d in k.items() if a != "kimlik"}
        alanlar["createdAt"] = _simdi()
        alanlar["updatedAt"] = _simdi()
        sonuc.append((k["kimlik"], alanlar))
    return sonuc


def _metin(alanlar, ad):
    alan = alanlar.get(ad, {})
    return next(iter(alan.values()), "") if alan else ""


def main():
    ayr = argparse.ArgumentParser(description="Eski projeden yeni projeye taşıma")
    ayr.add_argument("--uygula", action="store_true", help="gerçekten yaz")
    ayr.add_argument("--uzerine-yaz", action="store_true",
                     help="hedefte var olan araçların da üzerine yaz")
    ayr.add_argument("--kaynak", default=ESKI_PROJE, help="kaynak proje kimliği")
    arg = ayr.parse_args()

    if arg.kaynak == HEDEF_PROJE:
        raise SystemExit(
            f"✗ Hedef proje kaynakla aynı ({HEDEF_PROJE}). Önce uygulamayı yeni\n"
            "  projeye bağlayın: flutterfire configure --project <yeni-proje>")

    print(f"Kaynak : {arg.kaynak}")
    print(f"Hedef  : {HEDEF_PROJE}\n")

    araclar = koleksiyonu_oku(arg.kaynak, "vehicles")
    subeler = koleksiyonu_oku(arg.kaynak, "pickup_locations")
    kampanyalar = kampanyalari_oku()

    # Eski projenin Storage adresine işaret eden görseller yeni projede
    # çalışmaz (eski proje silinince kırık görsele döner). Boşaltılır,
    # fotoğraflar yeni projede panelden yüklenir.
    for _, alanlar in araclar:
        if _metin(alanlar, "imagePath") or alanlar.get("galleryPaths", {}).get(
                "arrayValue", {}).get("values"):
            print(f"  ! {_metin(alanlar, 'brand')} {_metin(alanlar, 'name')}: "
                  "eski projedeki görsel bağlantısı boşaltılıyor")
        alanlar["imagePath"] = {"stringValue": ""}
        alanlar["galleryPaths"] = {"arrayValue": {}}

    print(f"Araç    : {len(araclar)}")
    for _, a in araclar:
        print(f"  - {_metin(a, 'brand')} {_metin(a, 'name')} "
              f"({_metin(a, 'dailyPrice')} TL)")
    print(f"Şube    : {len(subeler)}")
    for _, a in subeler:
        print(f"  - {_metin(a, 'name')}")
    print(f"Kampanya: {len(kampanyalar)} (kampanyalar.json)")
    for _, a in kampanyalar:
        durum = "aktif" if a["isActive"]["booleanValue"] else "PASİF"
        print(f"  - {_metin(a, 'title')} [{durum}]")

    if not arg.uygula:
        print("\nÖnizleme — hiçbir şey yazılmadı. Yazmak için: --uygula")
        return

    print(f"\n{HEDEF_PROJE} projesinde YÖNETİCİ hesabıyla giriş:")
    eposta = input("E-posta: ").strip()
    parola = getpass.getpass("Parola (ekranda görünmez): ")
    giris = _istek(
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword"
        f"?key={API_ANAHTARI}",
        {"email": eposta, "password": parola, "returnSecureToken": True},
        yontem="POST")
    jeton, uid = giris["idToken"], giris["localId"]

    profil = _istek(f"{_kok(HEDEF_PROJE)}/users/{uid}", jeton=jeton, yok_ise=True)
    if not profil or _metin(profil.get("fields", {}), "role") != "admin":
        raise SystemExit(
            "✗ Bu hesap hedef projede yönetici değil. Firebase Konsolu →\n"
            "  Firestore → users → hesabın dokümanı → role: admin yapın.")

    hedef = _kok(HEDEF_PROJE)
    yazilan = atlanan = 0
    for koleksiyon, dokumanlar, koru in (
            ("vehicles", araclar, not arg.uzerine_yaz),
            ("pickup_locations", subeler, False),
            ("campaigns", kampanyalar, False)):
        for kimlik, alanlar in dokumanlar:
            url = f"{hedef}/{koleksiyon}/{kimlik}"
            if koru and _istek(url, jeton=jeton, yok_ise=True) is not None:
                atlanan += 1
                print(f"  = {koleksiyon}/{kimlik} hedefte var, atlandı")
                continue
            _istek(url, {"fields": alanlar}, yontem="PATCH", jeton=jeton)
            yazilan += 1
            print(f"  ✓ {koleksiyon}/{kimlik}")

    print(f"\nTamam: {yazilan} doküman yazıldı, {atlanan} atlandı.")


if __name__ == "__main__":
    main()
