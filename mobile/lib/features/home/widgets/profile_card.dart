import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/business_profile.dart';
import '../../profile/pages/profile_page.dart';
import '../../../core/widgets/section_header.dart';

class ProfileCard extends StatelessWidget {
  final BusinessProfile businessProfile;
  const ProfileCard({super.key, required this.businessProfile});

  @override
  Widget build(BuildContext context) {
    final p = businessProfile;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          const SectionHeader(icon: LucideIcons.store, title: 'Profil Usaha'),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ProfilePage(),
              ));
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  p.businessName.isNotEmpty ? p.businessName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(p.businessName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(
            '${p.formatBusinessType()} • ${p.city}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              children: [
                const Text('Level Usaha', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFD97706))),
                const SizedBox(height: 2),
                Text(
                  kLevelConfig[p.level]!.label,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}