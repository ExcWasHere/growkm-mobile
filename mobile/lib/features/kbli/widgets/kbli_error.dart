import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/kbli_colors.dart';

class KbliErrorBox extends StatelessWidget {
  final String message;

  const KbliErrorBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KbliColors.red50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KbliColors.red200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.xCircle, size: 20, color: KbliColors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 13, color: KbliColors.red700)),
          ),
        ],
      ),
    );
  }
}