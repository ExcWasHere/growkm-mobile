import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/kbli_colors.dart';
import '../models/kbli_models.dart';

class KbliContextInfo extends StatelessWidget {
  final KbliBusinessSnapshot snapshot;

  const KbliContextInfo({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KbliColors.amber50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KbliColors.amber200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.info, size: 16, color: KbliColors.amber500),
          ),
          const SizedBox(width: 10),
          Expanded(child: snapshot.hasKbli ? _buildHasKbli() : _buildNoKbli()),
        ],
      ),
    );
  }

  Widget _buildHasKbli() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13.5, color: KbliColors.gray700),
            children: [
              const TextSpan(text: 'KBLI saat ini: '),
              TextSpan(
                text: snapshot.kbliCode,
                style: const TextStyle(fontWeight: FontWeight.w900, color: KbliColors.amber700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'AI akan memvalidasi apakah KBLI ini sesuai dengan deskripsi usahamu.',
          style: TextStyle(fontSize: 11.5, color: KbliColors.gray500),
        ),
      ],
    );
  }

  Widget _buildNoKbli() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Belum ada KBLI yang tersimpan.',
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: KbliColors.gray700),
        ),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 11.5, color: KbliColors.gray500),
            children: [
              const TextSpan(text: 'AI akan merekomendasikan KBLI berdasarkan deskripsi usahamu: '),
              TextSpan(
                text: '"${snapshot.description ?? '—'}"',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ],
    );
  }
}