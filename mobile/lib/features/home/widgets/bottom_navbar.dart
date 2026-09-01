import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum AppPage { beranda, scanner, chatbot, finance, market }

class AppBottomNavBar extends StatelessWidget {
  final AppPage currentPage;
  final ValueChanged<AppPage> onNavigate;

  const AppBottomNavBar({
    super.key,
    required this.currentPage,
    required this.onNavigate,
  });

  static const _tabs = [
    _NavTab(page: AppPage.beranda, label: 'Beranda', icon: LucideIcons.home),
    _NavTab(page: AppPage.scanner, label: 'KBLI Matcher', icon: LucideIcons.shield),
    _NavTab(page: AppPage.chatbot, label: 'Lexa AI', icon: LucideIcons.messageCircle),
    _NavTab(page: AppPage.finance, label: 'Snap Cash', icon: LucideIcons.dollarSign),
    _NavTab(page: AppPage.market, label: 'Market Gate', icon: LucideIcons.barChart2),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFFDE68A), width: 1)),
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _tabs.map((tab) {
              final active = currentPage == tab.page;
              final isChatbot = tab.page == AppPage.chatbot;

              if (isChatbot) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onNavigate(tab.page),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -14),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF97316).withOpacity(active ? 0.5 : 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(tab.icon, color: Colors.white, size: 24),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -8),
                          child: Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: active ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => onNavigate(tab.page),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: active ? const Color(0xFFF97316) : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tab.icon, size: 20, color: active ? Colors.white : const Color(0xFF64748B)),
                        const SizedBox(height: 3),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: active ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final AppPage page;
  final String label;
  final IconData icon;
  const _NavTab({required this.page, required this.label, required this.icon});
}