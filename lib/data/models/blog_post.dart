import 'package:cloud_firestore/cloud_firestore.dart';

/// Yönetim panelinden yazılan bilgilendirme yazısı.
///
/// Yazılar kişisel veri içermez; herkes (misafir dâhil) yayındaki yazıları
/// okuyabilir. Taslaklar ([isPublished] false) yalnızca yöneticiye görünür;
/// bunu istemci değil güvenlik kuralı garanti eder.
class BlogPost {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String coverImageUrl;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime? updatedAt;

  const BlogPost({
    this.id = '',
    required this.title,
    required this.summary,
    required this.content,
    this.coverImageUrl = '',
    this.isPublished = false,
    this.publishedAt,
    this.updatedAt,
  });

  /// Ortalama okuma hızı dakikada ~200 kelime kabul edilir; en az 1 dk.
  int get okumaSuresiDk {
    final kelime = content.trim().split(RegExp(r'\s+')).where((k) => k.isNotEmpty).length;
    return (kelime / 200).ceil().clamp(1, 60);
  }

  /// Listelerde gösterilen kısa metin. Özet boşsa içeriğin başı kullanılır.
  String get kisaMetin {
    if (summary.trim().isNotEmpty) return summary.trim();
    final duz = content.trim().replaceAll(RegExp(r'\s+'), ' ');
    return duz.length <= 140 ? duz : '${duz.substring(0, 140).trimRight()}…';
  }

  factory BlogPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlogPost(
      id: doc.id,
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      content: data['content'] ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
      isPublished: data['isPublished'] ?? false,
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Tarih alanları burada yazılmaz; servis sunucu saatiyle ekler.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'coverImageUrl': coverImageUrl,
      'isPublished': isPublished,
    };
  }
}
