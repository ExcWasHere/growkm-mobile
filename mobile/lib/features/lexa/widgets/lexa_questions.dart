import 'package:flutter/material.dart';
import '../theme/lexa_colors.dart';

class LexaQuickQuestions extends StatelessWidget {
  final ValueChanged<String> onTap;

  const LexaQuickQuestions({super.key, required this.onTap});

  static const _questions = [
    'Apa syarat SPP-IRT?',
    'Bagaimana cara daftar halal gratis?',
    'Apa itu KBLI dan gimana pilih yang benar?',
    'Syarat KUR apa saja?',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _questions.map((q) {
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onTap(q),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: LexaColors.amber50,
                border: Border.all(color: LexaColors.amber200),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                q,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: LexaColors.amber700),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}