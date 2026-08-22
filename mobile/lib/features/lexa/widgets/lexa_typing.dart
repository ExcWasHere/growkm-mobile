import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/lexa_colors.dart';

class LexaTypingIndicator extends StatefulWidget {
  const LexaTypingIndicator({super.key});

  @override
  State<LexaTypingIndicator> createState() => _LexaTypingIndicatorState();
}

class _LexaTypingIndicatorState extends State<LexaTypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [LexaColors.amber400, LexaColors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: LexaColors.amber200.withOpacity(0.6), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: const Icon(LucideIcons.bot, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: LexaColors.gray50,
            border: Border.all(color: LexaColors.gray200),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => _buildDot(i)),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = (_controller.value + index * 0.15) % 1.0;
        final bounce = (t < 0.4) ? (1 - (t / 0.4 - 1).abs()) : 0.0;
        return Transform.translate(
          offset: Offset(0, -6 * bounce),
          child: Opacity(opacity: 0.5 + 0.5 * bounce, child: child),
        );
      },
      child: Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: const BoxDecoration(color: LexaColors.amber500, shape: BoxShape.circle),
      ),
    );
  }
}