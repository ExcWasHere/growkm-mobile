import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/lexa_colors.dart';

class LexaHeader extends StatelessWidget {
  final VoidCallback onToggleHistory;
  final VoidCallback onNewChat;

  const LexaHeader({
    super.key,
    required this.onToggleHistory,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: LexaColors.amber100)),
      ),
      child: Row(
        children: [
          _iconButton(icon: LucideIcons.history, onTap: onToggleHistory, tooltip: 'Riwayat Chat'),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LexaColors.amber400, LexaColors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: LexaColors.amber500.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: const Icon(LucideIcons.messageSquare, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Lexa AI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: LexaColors.gray800)),
                const SizedBox(height: 1),
                Text(
                  'Tanya apa saja soal legalitas usahamu',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: LexaColors.gray500),
                ),
              ],
            ),
          ),
          _iconButton(icon: LucideIcons.plus, onTap: onNewChat, tooltip: 'Chat Baru'),
        ],
      ),
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap, required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: LexaColors.gray100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 16, color: LexaColors.gray500),
        ),
      ),
    );
  }
}