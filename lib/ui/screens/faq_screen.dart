import 'package:car_rental_mvp/data/mock/faq_mock_data.dart';
import 'package:flutter/material.dart';

import '../widgets/faq_item.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sıkça Sorulan Sorular'),
      ),
      body: ListView.builder(
        itemCount: FaqMockData.faqItems.length,
        itemBuilder: (context, index) {
          return FaqItem(item: FaqMockData.faqItems[index]);
        },
      ),
    );
  }
}
