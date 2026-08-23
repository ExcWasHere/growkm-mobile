import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../theme/lexa_colors.dart';
import '../models/lexa_models.dart';
import 'lexa_avatar.dart';

class LexaMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const LexaMessageBubble({super.key, required this.message});

  bool get _isUser => message.role == ChatRole.user;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isUser) ...[const LexaAvatar(), const SizedBox(width: 8)],
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _isUser ? null : LexaColors.gray50,
              gradient: _isUser
                  ? const LinearGradient(
                      colors: [LexaColors.amber500, LexaColors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: _isUser ? null : Border.all(color: LexaColors.gray200),
              borderRadius: BorderRadius.circular(18),
            ),
            child: _isUser
                ? Text(
                    message.content,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.45),
                  )
                : MarkdownBody(
                    data: message.content,
                    selectable: true,
                    styleSheet: _assistantMarkdownStyle(context),
                  ),
          ),
        ),
        if (_isUser) ...[const SizedBox(width: 8), const LexaAvatar(isUser: true)],
      ],
    );
  }

  MarkdownStyleSheet _assistantMarkdownStyle(BuildContext context) {
    final base = const TextStyle(fontSize: 13.5, height: 1.45, color: LexaColors.gray800);
    return MarkdownStyleSheet(
      p: base,
      strong: base.copyWith(fontWeight: FontWeight.w700, color: LexaColors.gray900),
      em: base.copyWith(fontStyle: FontStyle.italic, color: LexaColors.gray700),
      h1: base.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
      h2: base.copyWith(fontWeight: FontWeight.w700, fontSize: 14.5),
      h3: base.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
      listBullet: base.copyWith(color: LexaColors.amber500),
      blockquote: base.copyWith(color: LexaColors.gray600, fontStyle: FontStyle.italic),
      blockquoteDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: LexaColors.amber400, width: 2)),
      ),
      blockquotePadding: const EdgeInsets.only(left: 10),
      code: base.copyWith(
        fontFamily: 'monospace',
        fontSize: 12,
        backgroundColor: LexaColors.amber100,
        color: LexaColors.amber700,
      ),
      codeblockDecoration: BoxDecoration(
        color: LexaColors.gray100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LexaColors.gray200),
      ),
      a: base.copyWith(color: LexaColors.amber600, decoration: TextDecoration.underline),
      tableBorder: TableBorder.all(color: LexaColors.gray200),
      tableHead: base.copyWith(fontWeight: FontWeight.w700),
      tableBody: base,
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(top: BorderSide(color: LexaColors.gray200)),
      ),
    );
  }
}