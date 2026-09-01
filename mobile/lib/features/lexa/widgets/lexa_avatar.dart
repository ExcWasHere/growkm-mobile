import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/lexa_colors.dart';

class LexaAvatar extends StatelessWidget {
  final bool isUser;
  final double size;

  const LexaAvatar({super.key, this.isUser = false, this.size = 30});

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: LexaColors.gray200, shape: BoxShape.circle),
        child: Icon(LucideIcons.user, size: size * 0.47, color: LexaColors.gray600),
      );
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.16),
      decoration: BoxDecoration(
      color: LexaColors.orange,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: LexaColors.amber200.withOpacity(0.6), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ClipOval(
        child: Image.asset('assets/images/Logo_GrowKM.png', fit: BoxFit.contain),
      ),
    );
  }
}