import 'package:flutter/material.dart';
import '../theme/profile_colors.dart';
import '../models/profile_models.dart';

class ProfileAvatarHeader extends StatelessWidget {
  final ProfileOverview overview;

  const ProfileAvatarHeader({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    final business = overview.business;
    final user = overview.user;
    final initial = business.businessName.isNotEmpty
        ? business.businessName[0].toUpperCase()
        : (user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ProfileColors.amber200),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
             color: ProfileColors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            business.businessName.isNotEmpty ? business.businessName : 'Usaha Belum Diisi',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: ProfileColors.gray800),
          ),
          const SizedBox(height: 3),
          Text(
            '${business.businessTypeLabel} · ${business.city.isNotEmpty ? business.city : 'Kota belum diisi'}',
            style: const TextStyle(fontSize: 12, color: ProfileColors.gray500),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.name} · ${user.email}',
            style: const TextStyle(fontSize: 11, color: ProfileColors.gray400),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip('Level', business.level[0].toUpperCase() + business.level.substring(1)),
              const SizedBox(width: 10),
              _buildStatChip('Skor', '${business.score}'),
              const SizedBox(width: 10),
              _buildStatChip('Streak', '${business.streakDays} hari'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: ProfileColors.amber50, borderRadius: BorderRadius.circular(12), border: Border.all(color: ProfileColors.amber200)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: ProfileColors.orangeDark)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: ProfileColors.amber700)),
        ],
      ),
    );
  }
}