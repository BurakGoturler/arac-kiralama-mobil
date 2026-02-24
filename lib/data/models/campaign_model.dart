import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Campaign {
  final String id;
  final String title;
  final String description;
  final String? code;
  final List<Color> gradientColors;
  final String buttonText;
  final String whatsappMessage;
  final bool isActive;
  final int order;

  const Campaign({
    this.id = '',
    required this.title,
    required this.description,
    this.code,
    required this.gradientColors,
    required this.buttonText,
    required this.whatsappMessage,
    this.isActive = true,
    this.order = 0,
  });

  // ── Firestore'dan oku ──
  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Gradient renkleri int listesi olarak Firestore'da tutuluyor
    final colorList = List<int>.from(data['gradientColors'] ?? [0xFF6A1B9A, 0xFF42A5F5]);

    return Campaign(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      code: data['code'],
      gradientColors: colorList.map((c) => Color(c)).toList(),
      buttonText: data['buttonText'] ?? 'Bize Ulaşın',
      whatsappMessage: data['whatsappMessage'] ?? '',
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
    );
  }

  // ── Firestore'a yaz ──
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'code': code,
      'gradientColors': gradientColors.map((c) => c.value).toList(),
      'buttonText': buttonText,
      'whatsappMessage': whatsappMessage,
      'isActive': isActive,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}