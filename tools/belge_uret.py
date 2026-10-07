# -*- coding: utf-8 -*-
"""Yasal metinlerden web sitesi sayfalarını ve banka PDF'lerini üretir.

NEDEN KODDAN ÜRETİLİYOR
-----------------------
Uygulamada gösterilen metin, sitede yayımlanan sayfa ve bankaya giden PDF
AYNI metin olmak zorunda. Elle yazılan kopyalar zamanla ayrıştı (eski site
sayfası uygulamadan farklı tarih, eski T.C. Kimlik No cümlesi ve yer tutucu
taşıyordu). Bu betik metni elle hiç yazmaz:

  1. `dart run tools/metinleri_disa_aktar.dart` — uygulamanın kendi
     getter'larını çalıştırıp metinleri JSON'a döker.
  2. JSON'dan site sayfaları (.php) ve banka PDF'leri üretilir.
  3. DOĞRULAMA: kaynak metnin her satırı, üretilen sayfanın ve PDF'in
     metninde birebir aranır. Tek satır eksikse betik hata verir.

Doldurulmamış yer tutucu varsa belgelere görünür bir TASLAK uyarısı basılır
ve betik bunu raporlar. Taslak belge siteye yüklenmemeli, bankaya
gönderilmemelidir.

    python tools/belge_uret.py
"""
import html as H
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import pymupdf

KOK = Path(__file__).resolve().parent.parent
JSON_YOLU = KOK / "build" / "yasal" / "metinler.json"
CIKTI = Path(r"C:\Users\burak\Desktop\Burak\Projeler\rent-a-car-mobil-app\Şenbayrak\Yayın Paketi")
TARAYICILAR = [
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
]

STIL = """
  :root{
    --lacivert:#1f3a5f; --metin:#20262e; --soluk:#5a6672;
    --cizgi:#dde3e9; --zemin:#f6f8fa; --uyari:#8a1c1c; --uyariZemin:#fbeaea;
  }
  *{box-sizing:border-box;}
  body{margin:0; background:#fff; color:var(--metin);
       font:16px/1.7 -apple-system,"Segoe UI",Roboto,Arial,sans-serif;}
  .ust{background:var(--lacivert); color:#fff; padding:28px 20px;}
  .ic{max-width:860px; margin:0 auto;}
  .ust h1{margin:0 0 6px; font-size:26px; letter-spacing:-.3px; line-height:1.25;}
  .ust p{margin:0; opacity:.85; font-size:15px;}
  nav{background:var(--zemin); border-bottom:1px solid var(--cizgi); padding:10px 20px; font-size:14.5px;}
  nav a{color:var(--lacivert); margin-right:18px; text-decoration:none; white-space:nowrap;}
  nav a.aktif{font-weight:700; text-decoration:underline;}
  main{padding:30px 20px 60px;}
  h2{font-size:19px; margin:34px 0 10px; padding-bottom:7px;
     border-bottom:2px solid var(--lacivert); color:var(--lacivert); page-break-after:avoid;}
  h3{font-size:16px; margin:22px 0 8px; color:var(--lacivert); page-break-after:avoid;}
  p,li{text-align:justify;}
  ul{padding-left:22px;} ul.harfli{list-style:none; padding-left:6px;}
  li{margin-bottom:7px;}
  .sebep{color:var(--lacivert);}
  .meta{color:var(--soluk); font-size:14.5px;}
  .kunye{background:var(--zemin); border-left:4px solid var(--lacivert);
         padding:14px 18px; margin:12px 0 18px; font-size:15px;}
  .kunye div{margin-bottom:3px;}
  .taslak{background:var(--uyariZemin); border:2px solid var(--uyari); color:var(--uyari);
          padding:14px 18px; margin:0 0 22px; font-size:15px;}
  mark{background:#ffe08a; padding:0 3px;}
  a{color:var(--lacivert);}
  table{border-collapse:collapse; width:100%; margin:14px 0; font-size:12.5px;}
  th{background:var(--lacivert); color:#fff; text-align:left; padding:7px 8px; vertical-align:top;}
  td{border:1px solid var(--cizgi); padding:7px 8px; vertical-align:top;}
  tr:nth-child(even) td{background:var(--zemin);}
  tr{page-break-inside:avoid;}
  .sarma{overflow-x:auto;}
  .alt{margin-top:40px; padding-top:18px; border-top:1px solid var(--cizgi); font-size:13.5px; color:var(--soluk);}
  @media(max-width:600px){ .ust h1{font-size:21px;} body{font-size:15px;} }
  @page{ margin:14mm 12mm; }
  @media print{ .ust,th,.taslak,mark{-webkit-print-color-adjust:exact; print-color-adjust:exact;} nav{display:none;}
                /* overflow:auto olan kutu yazdırmada bölünemez blok sayılır; tablo ilk sayfaya
                   hiç başlamıyor, tümüyle sonraki sayfaya itiliyordu. */
                .sarma{overflow:visible;} thead{display:table-header-group;} }
"""

BASLIK2 = re.compile(r"^\d+(/[A-Z])?\.\s+[A-ZÇĞİÖŞÜ]")
BASLIK3 = re.compile(r"^\d+\.\d+\s+\S")
HARF = re.compile(r"^[a-zçğıöşü]\)\s")
KUCUK = re.compile(r"[a-zçğıöşü]")
KUNYE = re.compile(r"^(Adres|Vergi Dairesi / VKN|E-posta|KEP|Telefon|VERBİS):\s")
YER_TUTUCU = re.compile(r"\[DOLDURULACAK[^\]]*\]")


# ── Satır içi biçim ───────────────────────────────────────────────
def satir_ici(metin):
    s = H.escape(metin, quote=False)
    s = YER_TUTUCU.sub(lambda m: "<mark>%s</mark>" % m.group(0), s)
    s = re.sub(r"(https://[^\s<]+?)(?=[.,;)]?(\s|$))",
               lambda m: '<a href="%s">%s</a>' % (m.group(1), m.group(1)), s)
    s = re.sub(r"(?<![\w.@/>])([\w.+-]+@[\w-]+(?:\.[\w-]+)+)",
               r'<a href="mailto:\1">\1</a>', s)
    return s


def vurgulu(metin):
    """Madde başındaki 'Etiket: ' kısmını kalın yazar."""
    m = re.match(r"^([^:→]{2,48}):\s(.*)$", metin)
    if m and "http" not in m.group(1):
        return "<b>%s:</b> %s" % (satir_ici(m.group(1)), satir_ici(m.group(2)))
    return satir_ici(metin)


def paragraf(metin):
    """Büyük harfle başlayan uyarı cümlesini kalın yazar."""
    m = re.match(r"^([A-ZÇĞİÖŞÜ0-9 ,./'()-]{10,}?[A-ZÇĞİÖŞÜ][.:])\s(.*)$", metin)
    if m:
        return "<b>%s</b> %s" % (satir_ici(m.group(1)), satir_ici(m.group(2)))
    return satir_ici(metin)


# ── Düz metin → HTML ──────────────────────────────────────────────
def metni_html(metin):
    bloklar = []  # [tur, html]
    for ham in metin.strip("\n").split("\n"):
        b = ham.strip()
        if not b:
            bloklar.append(["bos", ""])
            continue
        if ham.startswith("  ") and bloklar and bloklar[-1][0] in ("li", "harf"):
            parca = satir_ici(b)
            if b.startswith("→"):
                parca = '<span class="sebep">%s</span>' % parca
            bloklar[-1][1] += "<br>" + parca
        elif b.startswith("• "):
            bloklar.append(["li", vurgulu(b[2:])])
        elif HARF.match(b):
            bloklar.append(["harf", satir_ici(b)])
        elif re.match(r"^(Son güncelleme|Yürürlük tarihi):", b):
            bloklar.append(["meta", satir_ici(b)])
        elif KUNYE.match(b):
            bloklar.append(["kunye", vurgulu(b)])
        elif BASLIK2.match(b) or (not KUCUK.search(b) and len(b) < 70):
            bloklar.append(["h2", satir_ici(b)])
        elif BASLIK3.match(b):
            bloklar.append(["h3", satir_ici(b)])
        else:
            bloklar.append(["p", paragraf(b)])

    cikti = []
    i = 0
    while i < len(bloklar):
        tur = bloklar[i][0]
        if tur in ("li", "harf", "kunye"):
            j = i
            while j < len(bloklar) and bloklar[j][0] == tur:
                j += 1
            ogeler = [bloklar[k][1] for k in range(i, j)]
            if tur == "kunye":
                cikti.append('<div class="kunye">%s</div>' % "".join("<div>%s</div>" % o for o in ogeler))
            else:
                sinif = ' class="harfli"' if tur == "harf" else ""
                cikti.append("<ul%s>%s</ul>" % (sinif, "".join("<li>%s</li>" % o for o in ogeler)))
            i = j
            continue
        if tur == "meta":
            cikti.append('<p class="meta">%s</p>' % bloklar[i][1])
        elif tur in ("h2", "h3", "p"):
            cikti.append("<%s>%s</%s>" % (tur, bloklar[i][1], tur))
        i += 1
    return "\n".join(cikti)


def tablo(basliklar, satirlar):
    bas = "".join("<th>%s</th>" % H.escape(b) for b in basliklar)
    govde = "".join(
        "<tr>%s</tr>" % "".join("<td>%s</td>" % satir_ici(h) for h in satir) for satir in satirlar)
    return '<div class="sarma"><table><thead><tr>%s</tr></thead><tbody>%s</tbody></table></div>' % (bas, govde)


def taslak_uyarisi(eksik):
    if not eksik:
        return ""
    return ('<div class="taslak"><b>TASLAK — YAYIMLANMAMALI.</b> Şu alanlar henüz doldurulmadı: '
            '%s. Bu belge bu hâliyle siteye yüklenmemeli ve dışarıyla paylaşılmamalıdır.</div>'
            % H.escape(", ".join(eksik)))


def sayfa(baslik, alt_baslik, govde, eksik, nav="", yatay=False, alt=""):
    sayfa_kurali = "@page{ size:A4 landscape; margin:10mm; }" if yatay else ""
    return """<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>%s | Şenbayrak Araç Kiralama</title>
<style>%s%s</style>
</head>
<body>
<header class="ust"><div class="ic"><h1>%s</h1><p>%s</p></div></header>
%s
<main class="ic">
%s
%s
<div class="alt">%s</div>
</main>
</body>
</html>
""" % (H.escape(baslik), STIL, sayfa_kurali, H.escape(baslik), H.escape(alt_baslik), nav,
       taslak_uyarisi(eksik), govde, alt)


# ── Doğrulama ─────────────────────────────────────────────────────
def duz(s):
    s = s.replace("\u00ad", "").replace("•", " ")
    return re.sub(r"\s+", " ", s).strip()


def html_duz_metin(html):
    govde = html.split("<main", 1)[1]
    govde = re.sub(r"<(br|/p|/li|/h\d|/div|/td|/th|/tr)[^>]*>", " ", govde)
    govde = re.sub(r"<[^>]+>", "", govde)
    return duz(H.unescape(govde))


def dogrula(kaynak_satirlar, hedef_metin, ad, bosluksuz=False):
    """Kaynak metnin her satırını hedefte birebir arar.

    PDF'te [bosluksuz] kullanılır: Chrome uzun bir adresi satır sonunda
    bölebiliyor ve PDF'ten çıkarılan metinde adresin ortasına boşluk giriyor
    ("...senbayrak.com.tr/ gizlilik-politikasi.php"). Boşluklar atılarak
    karşılaştırılır; karakterlerin kendisi ve sırası yine birebir denetlenir.
    """
    if bosluksuz:
        hedef = re.sub(r"\s+", "", duz(hedef_metin))
        eksik = [s for s in kaynak_satirlar if s.strip() and re.sub(r"\s+", "", duz(s)) not in hedef]
    else:
        hedef = duz(hedef_metin)
        eksik = [s for s in kaynak_satirlar if s.strip() and duz(s) not in hedef]
    if eksik:
        print("HATA — %s içinde bulunamayan %d satır:" % (ad, len(eksik)))
        for s in eksik[:10]:
            print("   ", s[:120])
        sys.exit(1)
    return len([s for s in kaynak_satirlar if s.strip()])


def pdf_metni(yol, sirali=True):
    # sirali=True (düz metin belgeleri): Chrome, başlığın alt satırını içerik
    # akışının ortasına yazabiliyor; sıralamasız çıkarımda bu satır bir
    # paragrafın içine karışıp doğrulamayı düşürüyordu. Metin sayfadaki
    # konumuna göre sıralanır.
    #
    # sirali=False (tablolar): konuma göre sıralama, çok satırlı hücrelerin
    # satırlarını sütunlar arasında iç içe geçiriyor; tabloda içerik akışı
    # sırası hücre metnini bütün tutar.
    with pymupdf.open(str(yol)) as d:
        return "\n".join(p.get_text(sort=sirali) for p in d)


def pdf_uret(html_icerik, hedef, gecici):
    tarayici = next((t for t in TARAYICILAR if os.path.exists(t)), None)
    if not tarayici:
        sys.exit("Chrome veya Edge bulunamadı.")
    kaynak = gecici / (hedef.stem + ".html")
    kaynak.write_text(html_icerik, encoding="utf-8")
    ara_pdf = gecici / (hedef.stem + ".pdf")
    profil = gecici / "profil"
    subprocess.run([tarayici, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                    "--user-data-dir=%s" % profil, "--print-to-pdf=%s" % ara_pdf, kaynak.as_uri()],
                   check=True, capture_output=True, timeout=180)
    if not ara_pdf.exists():
        sys.exit("PDF üretilemedi: %s" % hedef.name)
    shutil.move(str(ara_pdf), str(hedef))


# ── Ana akış ──────────────────────────────────────────────────────
def main():
    r = subprocess.run("dart run tools/metinleri_disa_aktar.dart", cwd=KOK, shell=True,
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    if r.returncode != 0:
        print(r.stdout, r.stderr)
        sys.exit("Metinler dışa aktarılamadı.")
    veri = json.loads(JSON_YOLU.read_text(encoding="utf-8"))
    eksik = veri["eksikAlanlar"]
    sirket = veri["sirket"]

    site_dizini = CIKTI / "site"
    banka_dizini = CIKTI / "banka"
    for d in (site_dizini, banka_dizini):
        if d.exists():
            shutil.rmtree(d)
        d.mkdir(parents=True)

    alt = "%s — %s<br>Son güncelleme: %s" % (
        H.escape(sirket["unvan"]), H.escape(sirket["adres"]), H.escape(veri["sonGuncelleme"]))
    site_belgeleri = [b for b in veri["belgeler"] if b["site"]]
    rapor = []

    with tempfile.TemporaryDirectory() as g:
        gecici = Path(g)
        for belge in veri["belgeler"]:
            satirlar = belge["metin"].split("\n")
            govde = metni_html(belge["metin"])
            alt_baslik = "Şenbayrak Araç Kiralama Mobil Uygulaması"
            if belge["kod"] == "saklama":
                alt_baslik = sirket["unvan"] + " — Araç Kiralama Faaliyeti"

            # Site sayfası
            if belge["site"]:
                nav = "<nav><div class='ic'>%s</div></nav>" % "".join(
                    '<a href="%s"%s>%s</a>' % (b["site"], ' class="aktif"' if b is belge else "", H.escape(b["baslik"]))
                    for b in site_belgeleri)
                html_site = sayfa(belge["baslik"], alt_baslik, govde, eksik, nav=nav, alt=alt)
                n = dogrula(satirlar, html_duz_metin(html_site), belge["site"])
                (site_dizini / belge["site"]).write_text(html_site, encoding="utf-8", newline="\n")
                rapor.append("site/%s — %d satır birebir doğrulandı" % (belge["site"], n))

            # Banka PDF'i
            html_pdf = sayfa(belge["baslik"], alt_baslik, govde, eksik, alt=alt)
            hedef = banka_dizini / belge["pdf"]
            pdf_uret(html_pdf, hedef, gecici)
            n = dogrula(satirlar, pdf_metni(hedef), belge["pdf"], bosluksuz=True)
            rapor.append("banka/%s — %d satır birebir doğrulandı" % (belge["pdf"], n))

        # Envanter PDF'i (yapılandırılmış veriden)
        env = veri["envanter"]
        govde = (
            '<p class="meta">Yürürlük tarihi: %s</p>'
            "<p>Bu envanter, araç kiralama faaliyeti ve mobil uygulama kapsamındaki kişisel veri işleme "
            "faaliyetlerini gösterir. Aydınlatma Metni'nin 4. maddesi ve Kişisel Veri Saklama ve İmha "
            "Politikası bu tablodan üretilmiştir.</p>"
            "<h2>1. İşleme Faaliyetleri</h2>%s"
            "<h2>2. Saklama ve İmha Süreleri</h2>%s"
        ) % (
            H.escape(veri["sonGuncelleme"]),
            tablo(["Süreç", "Ortam", "Amaç", "Veriler", "Hukuki sebep", "Toplama yöntemi",
                   "Alıcılar", "Yurt dışı aktarım", "Saklama süresi"],
                  [[f["surec"], f["ortam"], f["amac"], f["veriler"], f["hukukiSebep"],
                    f["toplamaYontemi"], f["alicilar"], f["yurtDisi"], f["saklama"]] for f in env]),
            tablo(["Veri kategorisi", "Kayıt ortamı", "Saklama süresi", "Dayanak", "İmha yöntemi"],
                  [[k["kategori"], k["kayitOrtami"], k["sure"], k["dayanak"], k["imhaYontemi"]]
                   for k in veri["saklama"]]),
        )
        html_env = sayfa("Kişisel Veri İşleme Envanteri",
                         sirket["unvan"] + " — Araç Kiralama Faaliyeti", govde, eksik, yatay=True, alt=alt)
        hedef = banka_dizini / "Senbayrak_Kisisel_Veri_Isleme_Envanteri.pdf"
        pdf_uret(html_env, hedef, gecici)
        hucreler = [v for f in env for v in f.values()] + [v for k in veri["saklama"] for v in k.values()]
        pdf_duz = re.sub(r"\s+", "", pdf_metni(hedef, sirali=False))
        kayip = [h for h in hucreler if re.sub(r"\s+", "", h) not in pdf_duz]
        if kayip:
            print("HATA — envanter PDF'inde bulunamayan hücreler:", kayip[:5])
            sys.exit(1)
        rapor.append("banka/%s — %d hücre doğrulandı" % (hedef.name, len(hucreler)))

    durum = "TASLAK (doldurulmamış: %s)" % ", ".join(eksik) if eksik else "YAYINA HAZIR"
    oku = """ŞENBAYRAK YAYIN PAKETİ
Üretim: tools/belge_uret.py — elle düzenlemeyin; metin değişikliği
lib/core/constants/legal_texts.dart ve kvkk_envanter.dart'ta yapılır.

DURUM: %s

site/  → senbayrak.com.tr kök dizinine yüklenecek sayfalar
         gizlilik-politikasi.php     (uygulamadaki Gizlilik Politikası)
         kvkk-aydinlatma-metni.php   (uygulamadaki Aydınlatma Metni)
         acik-riza-metni.php         (kampanya iletişimi Açık Rıza Metni)
         kullanim-kosullari.php      (uygulamadaki Kullanım Koşulları)

banka/ → bankaya iletilecek belgeler (hepsi aynı kaynaktan)

Doğrulama:
  %s
""" % (durum, "\n  ".join(rapor))
    (CIKTI / "OKU_BENI.txt").write_text(oku, encoding="utf-8")
    print(oku)


if __name__ == "__main__":
    main()
