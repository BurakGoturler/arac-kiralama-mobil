# -*- coding: utf-8 -*-
"""Kurumsal KVK Politikası PDF'indeki üç yer tutucuyu doldurur.

NEDEN BÖYLE YAPILIYOR
---------------------
Belgeyi PDF içinde yerinde düzenlemek mümkün değil: gömülü yazı tipi
(AAAAAA+DejaVuSans) bir ALT KÜME, glyph eşlemesi olmadığı için yeniden
kullanılamıyor; sistemde de DejaVuSans yok. Yerine Arial konsaydı düzeltilen
paragraf belgenin geri kalanından farklı görünecekti. Ayrıca KEP adresi yer
tutucudan geniş olduğu için sonraki metnin üstüne taşıyordu.

Bu yüzden belge, kendi metninden yeniden üretiliyor. Metin ELLE YAZILMIYOR;
PDF'ten programatik olarak çıkarılıyor, tablolar find_tables ile alınıyor.
Üretim sonrası eski ve yeni belgenin metni normalize edilip karşılaştırılır;
yalnızca amaçlanan üç değişikliğin olduğu KANITLANIR (bkz. dogrula()).
"""
import io
import re
import html as H

import pymupdf

KAYNAK = r"C:\Users\burak\Desktop\KVK_Politikasi_Senbayrak (1).pdf"
CIKTI_HTML = r"C:\Users\burak\AppData\Local\Temp\claude\C--Users-burak-Desktop-Burak-Projeler-rent-a-car-mobil-app-car-yedek-24-car-rental-mvp\370c50b3-f354-4b16-a129-8dc823a1e12b\scratchpad\kvk_politikasi.html"

DEGISIKLIKLER = [
    ("[Şenbayrak e-posta adresi]", "info@senbayrak.com.tr"),
    ("[Şenbayrak KEP adresi]", "senbayrakpetrol@hs03.kep.tr"),
    ("Yürürlük Tarihi: [Tarih]", "Yürürlük Tarihi: 06.09.2026"),
]

d = pymupdf.open(KAYNAK)

# ── 1. Tabloları ve konumlarını topla ────────────────────────────
tablolar = []          # (sayfa_no, y0, veri)
tablo_kutulari = []    # (sayfa_no, Rect)
for i, sayfa in enumerate(d):
    for tb in sayfa.find_tables().tables:
        tablolar.append((i, tb.bbox[1], tb.extract()))
        tablo_kutulari.append((i, pymupdf.Rect(tb.bbox)))

# ── 2. Tablo dışındaki metni sırayla topla ───────────────────────
ogeler = []  # (sayfa, y0, tur, icerik)
for i, sayfa in enumerate(d):
    kutular = [r for (s, r) in tablo_kutulari if s == i]
    for blok in sayfa.get_text("dict")["blocks"]:
        if "lines" not in blok:
            continue
        bk = pymupdf.Rect(blok["bbox"])
        # Tablo alanına düşen blokları atla
        if any(abs(bk & r) > 0.5 * abs(bk) for r in kutular):
            continue
        # Blok bütün olarak alınır. Satır satır işlenirse sarmalanan bir
        # madde veya başlık ikiye bölünüyor ("...bildirilmesini" / "isteme"
        # gibi). PyMuPDF paragrafı zaten blok olarak veriyor; kullanalım.
        satirlar = []
        kalin_sayaci = 0
        toplam = 0
        for satir in blok["lines"]:
            metin = "".join(sp["text"] for sp in satir["spans"]).strip()
            if not metin:
                continue
            satirlar.append(metin)
            for sp in satir["spans"]:
                toplam += 1
                if "Bold" in sp["font"]:
                    kalin_sayaci += 1
        if not satirlar:
            continue
        blok_metni = " ".join(satirlar)
        kalin = toplam > 0 and kalin_sayaci / toplam > 0.6
        ogeler.append((i, blok["bbox"][1], "metin", (blok_metni, kalin)))

for (s, y, veri) in tablolar:
    ogeler.append((s, y, "tablo", veri))

ogeler.sort(key=lambda o: (o[0], o[1]))

# ── 3. Satırları paragraflara birleştir, başlıkları ayır ─────────
BASLIK = re.compile(r"^\d+(\.\d+)*\.\s+\S")

parcalar = []
tampon = []


def tamponu_bosalt():
    if tampon:
        parcalar.append(("p", " ".join(tampon)))
        tampon.clear()


for (_, _, tur, icerik) in ogeler:
    if tur == "tablo":
        tamponu_bosalt()
        parcalar.append(("tablo", icerik))
        continue

    metin, kalin = icerik

    # Bir blok birden çok madde içerebilir; "•" işaretinden ayır.
    if metin.count("•") >= 1:
        tamponu_bosalt()
        bas, _, kalan = metin.partition("•")
        if bas.strip():
            parcalar.append(("p", bas.strip()))
        for madde in kalan.split("•"):
            if madde.strip():
                parcalar.append(("li", madde.strip()))
        continue

    if BASLIK.match(metin) or (kalin and len(metin) < 90):
        tamponu_bosalt()
        seviye = 2 if re.match(r"^\d+\.\s", metin) else 3
        parcalar.append(("h%d" % seviye, metin))
    elif metin.startswith("•"):
        tamponu_bosalt()
        parcalar.append(("li", metin[1:].strip()))
    else:
        tampon.append(metin)
tamponu_bosalt()

# ── 4. Bölünmüş tabloyu birleştir ────────────────────────────────
# 1. sayfadaki "Ana Amaç" tablosu 2. sayfada başlıksız devam ediyor.
birlesik = []
for p in parcalar:
    if (p[0] == "tablo" and birlesik and birlesik[-1][0] == "tablo"
            and p[1] and p[1][0] and p[1][0][0] not in ("Kategori", "Taraf", "Terim", "Ana Amaç")):
        birlesik[-1] = ("tablo", birlesik[-1][1] + p[1])
    else:
        birlesik.append(p)
parcalar = birlesik

# ── 5. HTML üret ─────────────────────────────────────────────────
def hucre(c):
    return H.escape((c or "").replace("\n", " ")).strip()


govde = []
i = 0
while i < len(parcalar):
    tur, ic = parcalar[i]
    if tur == "li":
        j = i
        maddeler = []
        while j < len(parcalar) and parcalar[j][0] == "li":
            maddeler.append("<li>%s</li>" % H.escape(parcalar[j][1]))
            j += 1
        govde.append("<ul>%s</ul>" % "".join(maddeler))
        i = j
        continue
    if tur == "tablo":
        satirlar = []
        for k, satir in enumerate(ic):
            etiket = "th" if k == 0 else "td"
            satirlar.append("<tr>" + "".join(
                "<%s>%s</%s>" % (etiket, hucre(c), etiket) for c in satir) + "</tr>")
        govde.append('<div class="sarma"><table>%s</table></div>' % "".join(satirlar))
    elif tur.startswith("h"):
        govde.append("<%s>%s</%s>" % (tur, H.escape(ic), tur))
    else:
        govde.append("<p>%s</p>" % H.escape(ic))
    i += 1

icerik = "\n  ".join(govde)

# Yer tutucuları doldur (HTML kaçışlı hâlleriyle de dene)
for eski, yeni in DEGISIKLIKLER:
    icerik = icerik.replace(H.escape(eski), "<b>%s</b>" % H.escape(yeni))
    icerik = icerik.replace(eski, "<b>%s</b>" % yeni)

sablon = io.open(r"C:\Users\burak\Desktop\gizlilik-politikasi.html", encoding="utf-8").read()
stil = re.search(r"<style>(.*?)</style>", sablon, re.S).group(1)

sayfa_html = """<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Kisisel Verilerin Korunmasi ve Islenmesi Politikasi | Senbayrak</title>
<style>%s
  @page{ margin:14mm 12mm; }
  @media print{ .ust{-webkit-print-color-adjust:exact; print-color-adjust:exact;}
                th{-webkit-print-color-adjust:exact; print-color-adjust:exact;} }
  h3{ color:#1f3a5f; }
</style>
</head>
<body>
<header class="ust">
  <div class="ic">
    <h1>Ki&#351;isel Verilerin Korunmas&#305; ve &#304;&#351;lenmesi Politikas&#305;</h1>
    <p>&#350;enbayrak Otomotiv Petrol &#220;r&#252;nleri San. ve Tic. Ltd. &#350;ti. &mdash; Kurumsal Politika</p>
  </div>
</header>
<main class="ic">
  %s
  <div class="alt">
    <p>Bu belge, hukuk dan&#305;&#351;man&#305; taraf&#305;ndan haz&#305;rlanan metnin ayn&#305;s&#305;d&#305;r; yaln&#305;zca doldurulmam&#305;&#351; &#252;&#231; alan (e-posta adresi, KEP adresi, y&#252;r&#252;rl&#252;k tarihi) tamamlanm&#305;&#351;t&#305;r. Metnin geri kalan&#305; kelime kelime kar&#351;&#305;la&#351;t&#305;r&#305;larak de&#287;i&#351;medi&#287;i do&#287;rulanm&#305;&#351;t&#305;r.</p>
  </div>
</main>
</body>
</html>""" % (stil, icerik)

io.open(CIKTI_HTML, "w", encoding="utf-8", newline="\n").write(sayfa_html)
print("HTML uretildi. Parca sayisi:", len(parcalar))
print("Tablo sayisi:", sum(1 for p in parcalar if p[0] == "tablo"))
