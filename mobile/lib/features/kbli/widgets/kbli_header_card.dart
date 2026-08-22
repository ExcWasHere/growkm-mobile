import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/kbli_colors.dart';

class KbliHeaderCard extends StatelessWidget {
  final bool hasKbli;

  const KbliHeaderCard({super.key, required this.hasKbli});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KbliColors.amber200),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KbliColors.orange, Color(0xFFEF4444)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x33F97316), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: const Icon(LucideIcons.shieldCheck, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KBLI Matcher',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: KbliColors.gray800),
                ),
                const SizedBox(height: 2),
                Text(
                  hasKbli
                      ? 'Validasi kesesuaian KBLI dengan deskripsi usahamu'
                      : 'Deteksi KBLI yang tepat berdasarkan deskripsi usahamu',
                  style: const TextStyle(fontSize: 13, color: KbliColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}