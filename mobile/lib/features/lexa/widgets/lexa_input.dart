import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/lexa_colors.dart';

class LexaInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool loading;
  final VoidCallback onSend;

  const LexaInputBar({
    super.key,
    required this.controller,
    required this.loading,
    required this.onSend,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: LexaColors.amber100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: !loading,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Tanya soal perizinan usahamu...',
                hintStyle: const TextStyle(color: LexaColors.gray400, fontSize: 13.5),
                filled: true,
                fillColor: LexaColors.gray50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: LexaColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: LexaColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: LexaColors.amber400, width: 1.4),
                ),
              ),
              style: const TextStyle(fontSize: 13.5, color: LexaColors.gray800),
            ),
          ),
          const SizedBox(width: 10),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final canSend = value.text.trim().isNotEmpty && !loading;
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: canSend ? onSend : null,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LexaColors.amber400.withOpacity(canSend ? 1 : 0.4),
                        LexaColors.orange.withOpacity(canSend ? 1 : 0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(LucideIcons.send, size: 18, color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}