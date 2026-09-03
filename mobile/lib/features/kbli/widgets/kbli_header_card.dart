import 'package:flutter/material.dart';
import '../theme/kbli_colors.dart';

class KbliHeaderCard extends StatelessWidget {
  final bool hasKbli;

  const KbliHeaderCard({super.key, required this.hasKbli});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KBLI Matcher',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: KbliColors.amber500),
          ),
          const SizedBox(height: 2),
          Text(
            hasKbli
                ? 'Validasi kesesuaian KBLI dengan deskripsi usahamu'
                : 'Deteksi KBLI yang tepat berdasarkan deskripsi usahamu',
            style: const TextStyle(fontSize: 12.5, color: KbliColors.gray500),
          ),
        ],
      ),
    );
  }
}