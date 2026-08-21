import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/business_profile.dart';
import './bottom_navbar.dart';

class GreetingCard extends StatelessWidget {
  final GreetingData greeting;
  final ValueChanged<AppPage> onNavigateTab;

  const GreetingCard({super.key, required this.greeting, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final g = greeting;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: const Icon(LucideIcons.megaphone, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.title ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(g.message ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4)),
                if (g.actionLabel != null) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => onNavigateTab(AppPage.finance),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(g.actionLabel!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.arrowRight, color: Colors.white, size: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}