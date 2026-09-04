import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/profile_colors.dart';
import '../models/profile_models.dart';

class ProfileLegalStatusCard extends StatelessWidget {
  final BusinessProfileData business;

  const ProfileLegalStatusCard({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('NIB', business.hasNib),
      ('SPP-IRT', business.hasPirt),
      ('Sertifikat Halal', business.hasHalal),
      ('BPOM', business.hasBpom),
      ('Merek', business.hasMerek),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ProfileColors.amber200),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.shieldCheck, size: 15, color: ProfileColors.orangeDark),
              SizedBox(width: 8),
              Text('Status Legalitas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ProfileColors.gray800)),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Diperbarui otomatis lewat Guide to Grow :-)',
            style: TextStyle(fontSize: 10.5, color: ProfileColors.gray400),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => _buildBadge(item.$1, item.$2)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, bool has) {
    final color = has ? ProfileColors.green600 : ProfileColors.gray400;
    final bg = has ? ProfileColors.green100 : ProfileColors.gray100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(has ? LucideIcons.checkCircle2 : LucideIcons.circle, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}