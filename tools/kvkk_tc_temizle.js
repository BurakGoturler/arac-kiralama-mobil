/**
 * ═══════════════════════════════════════════════════════════════════
 *  KVKK — Geçmiş T.C. Kimlik Numarası verilerinin imhası
 * ═══════════════════════════════════════════════════════════════════
 *
 * Uygulama artık T.C. Kimlik Numarası saklamıyor. Ancak bu değişiklikten
 * ÖNCE kayıt olmuş kullanıcıların dokümanlarında ve eski rezervasyon
 * kayıtlarında bu veri hâlâ duruyor olabilir. Bu betik onları siler.
 *
 * Silinen alanlar:
 *   users/{uid}.tcNo
 *   whatsapp_logs/{id}.customerTc
 *
 * ── ÇALIŞTIRMA ─────────────────────────────────────────────────────
 *
 * 1. Servis hesabı anahtarı indirin:
 *      Firebase Console > Proje Ayarları > Hizmet hesapları
 *      > "Yeni özel anahtar oluştur"
 *    İnen JSON dosyasını bu klasöre serviceAccountKey.json olarak kaydedin.
 *
 *    ⚠️  Bu dosya veritabanınızın TAM YETKİLİ anahtarıdır.
 *        Git'e KESİNLİKLE eklenmemelidir (.gitignore'a eklendi).
 *        İşiniz bittiğinde silmeniz önerilir.
 *
 * 2. Bağımlılığı kurun ve önce KURU ÇALIŞTIRMA yapın:
 *      npm install firebase-admin
 *      node kvkk_tc_temizle.js
 *
 *    Bu hâliyle hiçbir şey silmez, yalnızca ne yapacağını raporlar.
 *
 * 3. Raporu onaylıyorsanız gerçek silme için:
 *      node kvkk_tc_temizle.js --uygula
 * ═══════════════════════════════════════════════════════════════════
 */

const admin = require('firebase-admin');
const path = require('path');

const UYGULA = process.argv.includes('--uygula');

let serviceAccount;
try {
  serviceAccount = require(path.join(__dirname, 'serviceAccountKey.json'));
} catch (e) {
  console.error('\n❌ serviceAccountKey.json bulunamadı.');
  console.error('   Yukarıdaki 1. adımı uygulayın.\n');
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

/** Bir koleksiyondaki belirli alanı 500'lük gruplar hâlinde siler. */
async function alaniSil(koleksiyon, alan) {
  const snapshot = await db.collection(koleksiyon).get();

  const hedefler = snapshot.docs.filter(
    (doc) => doc.get(alan) !== undefined
  );

  console.log(
    `\n${koleksiyon}: ${snapshot.size} kayıt tarandı, ` +
      `${hedefler.length} tanesinde "${alan}" alanı var.`
  );

  if (hedefler.length === 0) return 0;

  if (!UYGULA) {
    console.log('   → KURU ÇALIŞTIRMA: hiçbir şey silinmedi.');
    hedefler.slice(0, 5).forEach((d) => console.log(`     • ${d.id}`));
    if (hedefler.length > 5) {
      console.log(`     • ... ve ${hedefler.length - 5} kayıt daha`);
    }
    return hedefler.length;
  }

  let silinen = 0;
  for (let i = 0; i < hedefler.length; i += 500) {
    const batch = db.batch();
    for (const doc of hedefler.slice(i, i + 500)) {
      batch.update(doc.ref, {
        [alan]: admin.firestore.FieldValue.delete(),
      });
      silinen++;
    }
    await batch.commit();
    console.log(`   → ${silinen}/${hedefler.length} tamamlandı`);
  }
  return silinen;
}

(async () => {
  console.log('═'.repeat(60));
  console.log('  KVKK — T.C. Kimlik Numarası imha işlemi');
  console.log(`  Mod: ${UYGULA ? '⚠️  GERÇEK SİLME' : 'kuru çalıştırma (güvenli)'}`);
  console.log('═'.repeat(60));

  try {
    const a = await alaniSil('users', 'tcNo');
    const b = await alaniSil('whatsapp_logs', 'customerTc');

    console.log('\n' + '─'.repeat(60));
    if (UYGULA) {
      console.log(`✅ Tamamlandı. Toplam ${a + b} alan kalıcı olarak silindi.`);
      console.log('   serviceAccountKey.json dosyasını artık silebilirsiniz.');
    } else {
      console.log(`ℹ️  ${a + b} alan silinecek.`);
      console.log('   Onaylıyorsanız: node kvkk_tc_temizle.js --uygula');
    }
    console.log('─'.repeat(60) + '\n');
  } catch (e) {
    console.error('\n❌ Hata:', e.message, '\n');
    process.exit(1);
  }
  process.exit(0);
})();
