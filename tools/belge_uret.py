# -*- coding: utf-8 -*-
"""Uygulamanın kaynak kodundaki aydınlatma metninden belge üretir.

Belgeyi elle yazmak yerine koddan üretmenin sebebi: iki metnin zamanla
birbirinden ayrışmasını imkânsız kılmak. Uygulamadaki metin değişince bu
betik yeniden çalıştırılır ve belge kendiliğinden güncellenir.
"""
import io
import re
import html as H

KOK = r"C:\Users\burak\Desktop\Burak\Projeler\rent-a-car-mobil-app\car-yedek-24\car_rental_mvp"
CIKTI = r"C:\Users\burak\Desktop\Burak\Projeler\rent-a-car-mobil-app\Şenbayrak"

src = io.open(KOK + r"\lib\core\constants\legal_texts.dart", encoding="utf-8").read()


def tirnakli_parcalari_birlestir(ham):
    """Dart'ta bitişik yazılmış string parçalarını tek metne çevirir."""
    sonuc = []
    i = 0
    while i < len(ham):
        c = ham[i]
        if c in ("'", '"'):
            kapanis = c
            i += 1
            parca = []
            while i < len(ham) and ham[i] != kapanis:
                if ham[i] == "\\" and i + 1 < len(ham):
                    parca.append(ham[i + 1])
                    i += 2
                    continue
                parca.append(ham[i])
                i += 1
            sonuc.append("".join(parca))
            i += 1
        else:
            i += 1
    return "".join(sonuc)


def alan(ad):
    m = re.search("static const String " + ad + r"\s*=(.*?);", src, re.S)
    return tirnakli_parcalari_birlestir(m.group(1))


ADLAR = ["unvan", "adres", "vergiDairesi", "vkn", "kvkkEposta",
         "telefon", "kep", "verbis", "sonGuncelleme", "gizlilikUrl",
         "firebaseAktarimDayanagi"]
alanlar = {a: alan(a) for a in ADLAR}

m = re.search(r"static String get aydinlatmaMetni => '''(.*?)''';", src, re.S)
metin = m.group(1)
for k, v in alanlar.items():
    metin = metin.replace("${SirketBilgileri." + k + "}", v)
assert "${" not in metin, "cozulmemis degisken kaldi"

bloklar = []
for satir in metin.strip().split("\n"):
    b = satir.strip()
    if not b:
        continue
    if re.match(r"^\d+(/[A-Z])?\.\s+[A-ZÇĞİÖŞÜ]", b):
        bloklar.append("<h2>" + H.escape(b) + "</h2>")
    elif re.match(r"^\d+\.\d+\s+", b):
        bloklar.append("<h3>" + H.escape(b) + "</h3>")
    elif b.startswith("\u2022"):
        bloklar.append("<li>" + H.escape(b[1:].strip()) + "</li>")
    elif b.startswith("\u2192") and bloklar and bloklar[-1].startswith("<li>"):
        # "-> hukuki sebep" satiri bir onceki maddenin devamidir; ayri
        # paragrafa dusurulurse <ul> tam ortasindan ikiye bolunur.
        bloklar[-1] = (bloklar[-1][:-len("</li>")]
                       + "<br><i>" + H.escape(b) + "</i></li>")
    else:
        bloklar.append("<p>" + H.escape(b) + "</p>")

govde = []
i = 0
while i < len(bloklar):
    if bloklar[i].startswith("<li>"):
        j = i
        while j < len(bloklar) and bloklar[j].startswith("<li>"):
            j += 1
        govde.append("<ul>" + "".join(bloklar[i:j]) + "</ul>")
        i = j
    else:
        govde.append(bloklar[i])
        i += 1

sablon = io.open(CIKTI + r"\gizlilik-politikasi.html", encoding="utf-8").read()
stil = re.search(r"<style>(.*?)</style>", sablon, re.S).group(1)

sayfa = """<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>KVKK Aydinlatma Metni | Senbayrak Arac Kiralama</title>
<style>%s
  @page{ margin:14mm 12mm; }
  @media print{ .ust{-webkit-print-color-adjust:exact; print-color-adjust:exact;} }
</style>
</head>
<body>
<header class="ust">
  <div class="ic">
    <h1>Ki&#351;isel Verilerin Korunmas&#305; Hakk&#305;nda Ayd&#305;nlatma Metni</h1>
    <p>&#350;enbayrak Ara&#231; Kiralama Mobil Uygulamas&#305;</p>
  </div>
</header>
<main class="ic">
  <div class="kunye">
    <div><b>Veri Sorumlusu:</b> %s</div>
    <div><b>Adres:</b> %s</div>
    <div><b>Vergi Dairesi / VKN:</b> %s &mdash; %s</div>
    <div><b>E-posta:</b> %s</div>
    <div><b>Telefon:</b> %s</div>
    <div><b>KEP:</b> %s</div>
    <div><b>Y&#252;r&#252;rl&#252;k Tarihi:</b> %s</div>
  </div>
  <div class="onemli">
    <p>Bu belge, <b>uygulama i&#231;inde g&#246;sterilen ayd&#305;nlatma metninin birebir ayn&#305;s&#305;d&#305;r</b> ve uygulaman&#305;n kaynak kodundan &#252;retilmi&#351;tir. Uygulamadaki metin de&#287;i&#351;ti&#287;inde bu belge yeniden &#252;retilerek g&#252;ncellenir; iki metnin birbirinden ayr&#305;&#351;mas&#305; m&#252;mk&#252;n de&#287;ildir.</p>
  </div>
%s
  <div class="alt">
    <p>Bu belge teknik bir &#231;al&#305;&#351;mad&#305;r ve hukuki g&#246;r&#252;&#351; de&#287;ildir; yay&#305;mlanmadan &#246;nce hukuk dan&#305;&#351;man&#305; onay&#305;ndan ge&#231;melidir.</p>
    <p>%s &mdash; %s</p>
  </div>
</main>
</body>
</html>""" % (
    stil,
    H.escape(alanlar["unvan"]), H.escape(alanlar["adres"]),
    H.escape(alanlar["vergiDairesi"]), H.escape(alanlar["vkn"]),
    H.escape(alanlar["kvkkEposta"]), H.escape(alanlar["telefon"]),
    H.escape(alanlar["kep"]), H.escape(alanlar["sonGuncelleme"]),
    "\n".join("  " + g for g in govde),
    H.escape(alanlar["unvan"]), H.escape(alanlar["adres"]),
)

io.open(CIKTI + r"\aydinlatma_metni.html", "w", encoding="utf-8", newline="\n").write(sayfa)
print("HTML uretildi. Blok sayisi:", len(govde))
print("VERBIS alani:", alanlar["verbis"][:60])
print("Kalan yer tutucu:", sayfa.count("["))
