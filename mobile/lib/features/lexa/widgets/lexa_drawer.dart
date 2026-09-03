import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/lexa_colors.dart';
import '../models/lexa_models.dart';
import 'lexa_item.dart';

class LexaSessionDrawer extends StatelessWidget {
  final bool loading;
  final List<ChatSessionSummary> sessions;
  final String? activeSessionId;
  final VoidCallback onNewChat;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onDelete;

  const LexaSessionDrawer({
    super.key,
    required this.loading,
    required this.sessions,
    required this.activeSessionId,
    required this.onNewChat,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(LucideIcons.history, size: 16, color: LexaColors.amber500),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Riwayat Chat', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: LexaColors.gray700)),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: LexaColors.gray100, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(LucideIcons.x, size: 14, color: LexaColors.gray500),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: LexaColors.amber100),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onNewChat,
                  icon: const Icon(LucideIcons.plus, size: 14, color: LexaColors.amber500),
                  label: const Text('Chat Baru'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LexaColors.amber50,
                    foregroundColor: LexaColors.orangeDark,
                    elevation: 0,
                    side: const BorderSide(color: LexaColors.amber200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                  ),
                ),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: List.generate(
          3,
          (i) => Container(
            height: 56,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: LexaColors.gray100, borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.messageSquare, size: 28, color: LexaColors.gray200),
              const SizedBox(height: 8),
              const Text(
                'Belum ada riwayat chat',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: LexaColors.gray400),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return LexaSessionItem(
          session: session,
          isActive: session.id == activeSessionId,
          onSelect: () => onSelect(session.id),
          onDelete: () => onDelete(session.id),
        );
      },
    );
  }
}