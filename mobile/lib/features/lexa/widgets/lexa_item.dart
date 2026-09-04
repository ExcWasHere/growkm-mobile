import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/lexa_colors.dart';
import '../models/lexa_models.dart';
import 'lexa_delete.dart';

class LexaSessionItem extends StatelessWidget {
  final ChatSessionSummary session;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const LexaSessionItem({
    super.key,
    required this.session,
    required this.isActive,
    required this.onSelect,
    required this.onDelete,
  });

  Future<void> _handleDeleteTap(BuildContext context) async {
    final confirmed = await showLexaDeleteConfirmDialog(context);
    if (confirmed) onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? LexaColors.amber50 : Colors.transparent,
          border: Border.all(color: isActive ? LexaColors.amber200 : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(colors: [LexaColors.amber400, LexaColors.orange])
                    : null,
                color: isActive ? null : LexaColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.messageSquare,
                size: 13,
                color: isActive ? Colors.white : LexaColors.gray400,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.displayPreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? LexaColors.amber800 : LexaColors.gray700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatRelativeTime(session.updatedAt),
                    style: const TextStyle(fontSize: 10, color: LexaColors.gray400),
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _handleDeleteTap(context),
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                child: const Icon(LucideIcons.trash2, size: 13, color: LexaColors.gray400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}