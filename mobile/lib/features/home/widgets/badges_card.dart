import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/business_profile.dart';
import '../../../core/widgets/section_header.dart';

class BadgesCard extends StatefulWidget {
  final BusinessProfile businessProfile;
  const BadgesCard({super.key, required this.businessProfile});

  @override
  State<BadgesCard> createState() => _BadgesCardState();
}

class _BadgesCardState extends State<BadgesCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final badges = getBadges(widget.businessProfile);
    final visible = _expanded ? badges : badges.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: LucideIcons.award,
            title: 'Pencapaian',
            iconColor: Color(0xFFB45309),
            iconBg: Color(0xFFFEF3C7),
          ),
          const SizedBox(height: 14),
          ...visible.map((b) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: b.earned ? Colors.white : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: b.earned ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
                ),
                child: Opacity(
                  opacity: b.earned ? 1 : 0.5,
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: b.earned ? const Color(0xFFFEF3C7) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          b.icon,
                          size: 17,
                          color: b.earned ? const Color(0xFFD97706) : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(b.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                      ),
                      if (b.earned) const Icon(LucideIcons.check, size: 16, color: Color(0xFF22C55E)),
                    ],
                  ),
                ),
              )),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(_expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16),
              label: Text(_expanded ? 'Sembunyikan' : 'Lihat ${badges.length - 3} lainnya'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFD97706)),
            ),
          ),
        ],
      ),
    );
  }
}