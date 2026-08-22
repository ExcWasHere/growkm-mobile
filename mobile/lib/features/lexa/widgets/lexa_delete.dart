import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/lexa_colors.dart';

Future<bool> showLexaDeleteConfirmDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(color: LexaColors.red100, shape: BoxShape.circle),
                child: const Icon(LucideIcons.alertTriangle, size: 24, color: LexaColors.red500),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hapus sesi ini?',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: LexaColors.gray800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Riwayat percakapan ini akan dihapus permanen dan tidak bisa dikembalikan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: LexaColors.gray500, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: LexaColors.gray200),
                        foregroundColor: LexaColors.gray600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LexaColors.red500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}