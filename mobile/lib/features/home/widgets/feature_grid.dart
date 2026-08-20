import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import './bottom_navbar.dart';
import './coming_soon.dart';
import '../../../core/widgets/section_header.dart';

class FeatureGrid extends StatelessWidget {
  final ValueChanged<AppPage> onNavigateTab;
  const FeatureGrid({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureData(
        icon: LucideIcons.map,
        title: 'Guide to Grow',
        subtitle: 'Roadmap legalitas usahamu',
        colors: const [Color(0xFF60A5FA), Color(0xFF3B82F6)],
        onTap: () {
          // TODO: arahkan ke RoadmapPage begitu udah dibuat
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const ComingSoonPage(
              title: 'Guide to Grow',
              emoji: '🗺️',
              description: 'Roadmap step-by-step legalitas usahamu segera hadir.',
            ),
          ));
        },
      ),
      _FeatureData(
        icon: LucideIcons.shieldCheck,
        title: 'KBLI Matcher',
        subtitle: 'Cari kode KBLI usahamu',
        colors: const [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        onTap: () => onNavigateTab(AppPage.scanner),
      ),
      _FeatureData(
        icon: LucideIcons.wallet,
        title: 'Snap Cash',
        subtitle: 'Catat kas usaha harian',
        colors: const [Color(0xFF34D399), Color(0xFF059669)],
        onTap: () => onNavigateTab(AppPage.finance),
      ),
      _FeatureData(
        icon: LucideIcons.store,
        title: 'Market Gate',
        subtitle: 'Buka akses pasar produkmu',
        colors: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
        onTap: () => onNavigateTab(AppPage.market),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
          const SectionHeader(icon: LucideIcons.layoutGrid, title: 'Fitur Utama'),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.98,
            children: features.map((f) => _FeatureCard(data: f)).toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;
  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: data.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: Colors.white, size: 21),
            ),
            const SizedBox(height: 10),
            Text(data.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
            const SizedBox(height: 3),
            Expanded(
              child: Text(
                data.subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.35),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });
}