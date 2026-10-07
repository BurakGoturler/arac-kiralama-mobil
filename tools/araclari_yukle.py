#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Şenbayrak Araç Kiralama — filo içe aktarma betiği.

arac_verisi.json dosyasındaki araçları Firestore'daki `vehicles`
koleksiyonuna yazar.

NEDEN BU YOL SEÇİLDİ
--------------------
Servis hesabı anahtarı (service account key) ÜRETİLMEDİ. O anahtar tüm
güvenlik kurallarını atlayan sınırsız bir yetkidir; tek seferlik bir veri
girişi için oluşturulup diskte bırakılması gereksiz bir risktir.

Bunun yerine betik, normal bir yönetici hesabıyla giriş yapar ve Firestore
REST API'sini o hesabın kimliğiyle kullanır. Yani yazma işlemleri
firestore.rules içindeki `yonetici()` kontrolünden geçer — uygulamanın
kendisiyle tamamen aynı yetki sınırları içinde çalışır.

Dış bağımlılık yoktur; yalnızca Python standart kütüphanesi kullanılır.

KULLANIM
--------
    # 1) Önce ne olacağını göster (hiçbir şey yazılmaz):
    python tools/araclari_yukle.py

    # 2) Onayladıktan sonra gerçekten yaz:
    python tools/araclari_yukle.py --uygula

    # 3) Dosyada olmayan (eski/yer tutucu) araçları da sil:
    python tools/araclari_yukle.py --uygula --temizle

Parola sorulur, hiçbir yere kaydedilmez.
"""

import argparse
import getpass
import json
import os
import sys
import urllib.error
import urllib.request

from firebase_ayar import proje_ayari

# Proje ve genel web anahtarı uygulamanın yapılandırmasından okunur.
# Anahtar bir SIR DEĞİLDİR; projeyi tanımlar, tek başına hiçbir veriye
# erişim vermez. Erişim güvenliği güvenlik kurallarıyla sağlanır.
PROJE, API_ANAHTARI = proje_ayari()

GIRIS_URL = (
    "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword"
    f"?key={API_ANAHTARI}"
)
FIRESTORE_KOK = (
    f"https://firestore.googleapis.com/v1/projects/{PROJE}"
    "/databases/(default)/documents"
)

VERI_DOSYASI = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            "arac_verisi.json")


def _cikti_kodlamasini_duzelt():
    """Windows'ta Türkçe çıktının betiği düşürmesini engeller.

    Python, çıktı bir konsola bağlıyken UTF-8 kullanır; ancak çıktı bir
    dosyaya yönlendirildiğinde veya boru hattına verildiğinde sistemin ANSI
    kod sayfasına (Türkçe Windows'ta cp1252) düşer. Bu betikteki "Şenbayrak",
    "Değişiklikleri", "✓" ve "→" gibi karakterler cp1252'de yoktur; yazma
    denemesi UnicodeEncodeError fırlatır ve betik daha giriş yapmadan,
    yaptığı işi söylemeden çöker.

    Bu, betiğin çıktısı kaydedilmek istendiğinde (ki bir veri aktarımında
    doğal bir istektir) her seferinde oluyordu. Akışlar UTF-8'e çevrilerek
    hem konsolda hem yönlendirmede aynı davranış sağlanır.
    """
    for akis in (sys.stdout, sys.stderr):
        try:
            akis.reconfigure(encoding="utf-8")
        except (AttributeError, OSError):
            # Çok eski Python veya alışılmadık bir akış: sessizce geç.
            # Konsolda zaten çalışıyor; burada durmak için sebep yok.
            pass


_cikti_kodlamasini_duzelt()


# ── HTTP yardımcıları ────────────────────────────────────────────────

def _istek(url, veri=None, yontem="GET", jeton=None):
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
        detay = e.read().decode("utf-8", "replace")
        raise SystemExit(f"\n✗ HTTP {e.code} — {url}\n{detay}\n")


def giris_yap(eposta, parola):
    yanit = _istek(GIRIS_URL, {
        "email": eposta,
        "password": parola,
        "returnSecureToken": True,
    }, yontem="POST")
    return yanit["idToken"]


# ── Firestore tip dönüşümü ───────────────────────────────────────────
# REST API değerleri tiplenmiş bekler: {"stringValue": "..."} gibi.

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


def _alanlar(sozluk):
    return {k: _deger(v) for k, v in sozluk.items()}


def _oku_string(alan):
    """Firestore alanından düz Python değeri çıkarır (yalnızca gösterim için)."""
    if not isinstance(alan, dict):
        return ""
    for anahtar in ("stringValue", "integerValue", "doubleValue",
                    "booleanValue"):
        if anahtar in alan:
            return alan[anahtar]
    return ""


# ── Veri dönüşümü ────────────────────────────────────────────────────

def _ozellikler(arac):
    """Araç kartında gösterilecek doğrulanmış teknik özellikler.

    Yalnızca arac_verisi.json içinde gerçekten bulunan alanlardan üretilir:
    vites, yakıt, koltuk sayısı ve gövde tipi. Hiçbir donanım bilgisi
    tahmin edilmez veya uydurulmaz.
    """
    ozellikler = []

    if arac.get("vites"):
        ozellikler.append(f"{arac['vites']} vites")
    if arac.get("yakit"):
        ozellikler.append(arac["yakit"])
    if arac.get("koltuk"):
        ozellikler.append(f"{arac['koltuk']} koltuk")
    if arac.get("kasaTipi"):
        ozellikler.append(arac["kasaTipi"])
    if arac.get("yil"):
        ozellikler.append(f"{arac['yil']} model")

    return ozellikler


def firestore_belgesi(arac):
    """arac_verisi.json kaydını Vehicle modelinin beklediği alanlara çevirir."""
    return {
        "brand": arac["marka"],
        "name": arac["model"],
        "category": arac["kategori"],
        "dailyPrice": float(arac["gunlukFiyat"]),
        "transmission": arac["vites"],
        "fuelType": arac["yakit"],
        "seats": int(arac["koltuk"]),
        # motorHacmi YAZILMIYOR — kaynak veri güvenilir değil.
        #
        # İlanlardan çıkarılan bu alan gerçek motor hacmi değil, sahibinden'in
        # ARAMA FİLTRESİ ARALIĞI: 19 aracın 14'ünde aynı değer ("1.4 - 1.6 L")
        # görünüyor ve bazıları açıkça yanlış — BMW 520i (gerçekte 2.0 L) ve
        # Mitsubishi L200 pickup (gerçekte 2.4 L) de "1.4 - 1.6 L" olarak
        # geliyor. Renault Taliant'ta ise değer "1.0 L'ye kadar", yani bir
        # spec değil doğrudan filtre etiketi.
        #
        # Bu alan hem araç kartında hem detay ekranında "Motor" başlığıyla
        # müşteriye gösteriliyor. Yanlış bir teknik özellik yayımlamaktansa
        # boş bırakılıyor.
        #
        # DİKKAT: Doğru motor hacimleri yönetim panelinden girilebilir, ancak
        # bu betik dokümanı updateMask'siz PATCH ile TÜMÜYLE değiştiriyor —
        # yani panelden girilen değerleri EZER. Betik yeniden çalıştırılacaksa
        # önce elle girilen veriler yedeklenmeli ya da veri dosyasına
        # işlenmelidir.
        "engineSize": "",
        "year": int(arac["yil"]),

        # Görseller yönetim panelinden yüklenir; Storage'a yazma yetkisi
        # yalnızca yöneticide ve ilan görselleri dışarıdan çekilemiyor.
        "imagePath": "",
        "galleryPaths": [],

        # Ekipman listesi, YALNIZCA ilandan doğrulanmış teknik
        # özelliklerden üretilir.
        #
        # İlanlardaki "özellikler" bölümü dâhil olan donanımı değil ücretli
        # opsiyonları listeliyordu; oraya bakıp "klima, navigasyon" yazmak
        # müşteriye yanlış beyan olurdu. Bu yüzden liste önce tamamen boş
        # bırakılmıştı.
        #
        # Ancak boş liste uygulamada araç kartını çökertiyordu
        # (features.first → "Bad state: No element"). Kart tarafı boş listeye
        # dayanıklı hâle getirildi; buradaki liste de uydurma bilgi
        # eklemeden, zaten elimizdeki doğrulanmış alanlardan dolduruluyor.
        # Böylece kartın alt satırı anlamlı bir bilgi gösterir.
        "features": _ozellikler(arac),

        "isAvailable": True,
        "isFeatured": False,

        # İzlenebilirlik: kaydın hangi ilandan geldiği ve gövde tipi.
        # Uygulama bu alanları okumaz, yönetim tarafında referans içindir.
        "kaynakIlanNo": arac["ilanNo"],
        "kasaTipi": arac.get("kasaTipi", ""),
        "aylikFiyat": float(arac["aylikFiyat"]),
    }


def belge_kimligi(arac):
    """İlan numarası kimlik olur; betik tekrar çalışınca kopya oluşmaz."""
    return f"ilan-{arac['ilanNo']}"


# ── Firestore işlemleri ──────────────────────────────────────────────

def mevcut_araclar(jeton):
    """vehicles koleksiyonundaki tüm dokümanları (kimlik, ad) getirir."""
    sonuc = {}
    sayfa = None
    while True:
        url = f"{FIRESTORE_KOK}/vehicles?pageSize=300"
        if sayfa:
            url += f"&pageToken={sayfa}"
        yanit = _istek(url, jeton=jeton)
        for belge in yanit.get("documents", []):
            kimlik = belge["name"].rsplit("/", 1)[-1]
            alanlar = belge.get("fields", {})
            ad = "{} {}".format(
                _oku_string(alanlar.get("brand", {})),
                _oku_string(alanlar.get("name", {})),
            ).strip()
            sonuc[kimlik] = ad or "(adsız)"
        sayfa = yanit.get("nextPageToken")
        if not sayfa:
            break
    return sonuc


def yaz(jeton, kimlik, alanlar):
    # updateMask verilmezse PATCH tüm dokümanı değiştirir — istediğimiz bu.
    url = f"{FIRESTORE_KOK}/vehicles/{kimlik}"
    _istek(url, {"fields": _alanlar(alanlar)}, yontem="PATCH", jeton=jeton)


def sil(jeton, kimlik):
    _istek(f"{FIRESTORE_KOK}/vehicles/{kimlik}", yontem="DELETE", jeton=jeton)


# ── Ana akış ─────────────────────────────────────────────────────────

def main():
    ayrıştırıcı = argparse.ArgumentParser(
        description="Şenbayrak filo içe aktarma")
    ayrıştırıcı.add_argument("--uygula", action="store_true",
                             help="Değişiklikleri gerçekten yaz "
                                  "(verilmezse yalnızca önizleme)")
    ayrıştırıcı.add_argument("--temizle", action="store_true",
                             help="Veri dosyasında olmayan araçları sil")
    arg = ayrıştırıcı.parse_args()

    with open(VERI_DOSYASI, encoding="utf-8") as f:
        veri = json.load(f)
    araclar = veri["araclar"]

    print(f"\nVeri dosyası : {VERI_DOSYASI}")
    print(f"Araç sayısı  : {len(araclar)}")
    print(f"Proje        : {PROJE}")
    print(f"Mod          : {'YAZMA' if arg.uygula else 'ÖNİZLEME (yazma yok)'}\n")

    eposta = input("Yönetici e-postası: ").strip()
    parola = getpass.getpass("Parola (ekranda görünmez): ")
    if not eposta or not parola:
        raise SystemExit("E-posta ve parola gerekli.")

    print("\n→ Giriş yapılıyor...")
    jeton = giris_yap(eposta, parola)
    print("  ✓ Giriş başarılı")

    print("→ Mevcut araçlar okunuyor...")
    mevcut = mevcut_araclar(jeton)
    print(f"  ✓ {len(mevcut)} kayıt bulundu")

    yeni_kimlikler = {belge_kimligi(a) for a in araclar}
    fazlalik = {k: v for k, v in mevcut.items() if k not in yeni_kimlikler}

    print("\n── Yazılacak araçlar ──")
    for a in araclar:
        kimlik = belge_kimligi(a)
        durum = "güncelle" if kimlik in mevcut else "YENİ     "
        print(f"  {durum}  {a['marka']:<11} {a['model']:<16} "
              f"{a['gunlukFiyat']:>5} TL  {a['kategori']}")

    if fazlalik:
        baslik = "── Silinecek" if arg.temizle else "── Dosyada olmayan"
        print(f"\n{baslik} kayıtlar ({len(fazlalik)}) ──")
        for kimlik, ad in fazlalik.items():
            print(f"  {ad}   [{kimlik}]")
        if not arg.temizle:
            print("  (silmek için --temizle ekleyin)")

    if not arg.uygula:
        print("\nÖnizleme modu — hiçbir değişiklik yapılmadı.")
        print("Uygulamak için: python tools/araclari_yukle.py --uygula")
        return

    if arg.temizle and fazlalik:
        print(f"\n⚠  {len(fazlalik)} kayıt KALICI olarak silinecek.")
        if input("   Onaylamak için 'SIL' yazın: ").strip() != "SIL":
            print("   Silme iptal edildi; yalnızca yazma yapılacak.")
            arg.temizle = False

    print("\n→ Yazılıyor...")
    for a in araclar:
        kimlik = belge_kimligi(a)
        yaz(jeton, kimlik, firestore_belgesi(a))
        print(f"  ✓ {a['marka']} {a['model']}")

    if arg.temizle:
        print("\n→ Fazlalık kayıtlar siliniyor...")
        for kimlik, ad in fazlalik.items():
            sil(jeton, kimlik)
            print(f"  ✓ silindi: {ad}")

    print(f"\n✓ Tamamlandı. {len(araclar)} araç yazıldı"
          + (f", {len(fazlalik)} kayıt silindi." if arg.temizle else "."))
    print("\nSIRADAKİ ADIM: Yönetim panelinden her araca fotoğraf yükleyin —")
    print("görselsiz araçlar listede yer tutucu simgeyle görünür.")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit("\nİptal edildi.")
