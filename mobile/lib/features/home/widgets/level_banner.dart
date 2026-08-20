import 'package:flutter/material.dart';
import '../models/business_profile.dart';

class LevelBanner extends StatelessWidget {
  final BusinessProfile businessProfile;
  const LevelBanner({super.key, required this.businessProfile});

  @override
  Widget build(BuildContext context) {
    final p = businessProfile;
    final percent = (p.formalizationPercent * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Level Usaha', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    const SizedBox(height: 2),
                    Text(
                      kLevelConfig[p.level]!.label,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.formatBusinessType()} • ${p.city}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    if (p.streakDays > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            '${p.streakDays} hari streak',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFEA580C)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Formalisasi', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  Text(
                    '$percent%',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFF97316)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: p.formalizationPercent,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFF97316)),
            ),
          ),
        ],
      ),
    );
  }
}