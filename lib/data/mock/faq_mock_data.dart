import '../models/faq_model.dart';

class FaqMockData {
  static const List<FaqItemModel> faqItems = [
    FaqItemModel(
      question: 'Nasıl araç kiralayabilirim?',
      answer: 'Rezervasyon talepleri yalnızca WhatsApp hattımızdan alınır. Uygulamada aracı ve tarihleri seçip "WhatsApp üzerinden rezervasyon yapın" düğmesine bastığınızda talebiniz hazır mesaj olarak WhatsApp\'ta açılır. Teyit ve ödemenin ardından kiralama sözleşmesi şubede, kimlik ve sürücü belgenizle kurulur.',
    ),
    FaqItemModel(
      question: 'Kiralama için hangi belgeler gerekli?',
      answer: 'Kiralama yapabilmek için geçerli bir sürücü belgesi, kimlik kartı ve adınıza kayıtlı bir kredi kartı gerekmektedir.',
    ),
    FaqItemModel(
      question: 'Minimum kiralama süresi ne kadar?',
      answer: 'Minimum kiralama süresi 24 saattir. Daha uzun süreli kiralamalar için özel indirimlerimiz mevcuttur.',
    ),
    FaqItemModel(
      question: 'Kaza veya arıza durumunda ne yapmalıyım?',
      answer: 'Kaza veya arıza durumunda, aracınızı güvenli bir yere çekerek derhal 7/24 hizmet veren acil durum hattımızı aramanız gerekmektedir.',
    ),
    FaqItemModel(
      question: 'Aracı farklı bir lokasyona bırakabilir miyim?',
      answer: 'Evet, ek bir ücret karşılığında aracınızı farklı bir şehirdeki ofisimize bırakabilirsiniz. Detaylı bilgi için bizimle iletişime geçebilirsiniz.',
    ),
    FaqItemModel(
      question: 'İptal ve değişiklik politikası nedir?',
      answer: 'Rezervasyonunuzu kiralamadan 48 saat öncesine kadar ücretsiz olarak iptal edebilir veya değiştirebilirsiniz. Daha geç yapılan iptallerde bir günlük kiralama bedeli kesintisi uygulanır.',
    ),
  ];
}
