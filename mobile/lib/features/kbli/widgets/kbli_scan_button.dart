import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/kbli_colors.dart';

class KbliScanButton extends StatelessWidget {
  final bool hasKbli;
  final bool loading;
  final VoidCallback onPressed;

  const KbliScanButton({
    super.key,
    required this.hasKbli,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final label = loading
        ? (hasKbli ? 'Memvalidasi KBLI...' : 'Menganalisis usahamu...')
        : (hasKbli ? 'Validasi KBLI Saya' : 'Rekomendasikan KBLI');

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: KbliColors.amber500,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              const Icon(LucideIcons.search, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}