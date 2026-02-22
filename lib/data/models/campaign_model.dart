import 'package:flutter/material.dart';

class Campaign {
  final String title;
  final String description;
  final String? code;
  final List<Color> gradientColors;
  final String buttonText;
  final String whatsappMessage;

  const Campaign({
    required this.title,
    required this.description,
    this.code,
    required this.gradientColors,
    required this.buttonText,
    required this.whatsappMessage,
  });
}

class CampaignsMock {
  static const List<Campaign> campaigns = [
    Campaign(
      title: 'Ağustos Ayına Özel Fırsat',
      description: 'Tüm SUV modellerinde %15 indirim ve ek gün avantajları.',
      gradientColors: [Color(0xFF6A1B9A), Color(0xFF42A5F5)],
      buttonText: 'Bize Ulaşın',
      whatsappMessage: 'Merhaba, Ağustos ayına özel SUV indirimi hakkında bilgi almak istiyorum.',
    ),
    Campaign(
      title: 'Bayram Tatili Kampanyası',
      description: 'Bayram süresince yapacağınız 3 gün ve üzeri kiralamalarda geçerli özel fiyatlar.',
      gradientColors: [Color(0xFF00BFA5), Color(0xFF00ACC1)],
      buttonText: 'Bize Ulaşın',
      whatsappMessage: 'Merhaba, Bayram Tatili kampanyanızla ilgili özel fiyatlarınızı öğrenebilir miyim?',
    ),
    Campaign(
      title: 'Lüks Araçlarda Hafta Sonu',
      description: 'Seçili lüks segment araçlarda hafta sonuna özel %25 indirim.',
      gradientColors: [Color(0xFFEF6C00), Color(0xFFF4511E)],
      buttonText: 'Bize Ulaşın',
      whatsappMessage: 'Merhaba, hafta sonuna özel lüks araç kampanyanızla ilgileniyorum.',
    ),
    Campaign(
      title: 'Elektrikli Araç Deneyimi',
      description: 'Tüm elektrikli araç kiralamalarında ilk şarj bizden hediye.',
      gradientColors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
      buttonText: 'Bize Ulaşın',
      whatsappMessage: 'Merhaba, elektrikli araçlardaki ilk şarj hediye kampanyanız hakkında bilgi almak istiyorum.',
    ),
  ];
}
