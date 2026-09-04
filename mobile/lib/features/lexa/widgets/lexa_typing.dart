import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/lexa_colors.dart';
import 'lexa_avatar.dart';

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
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
        const LexaAvatar(),
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
        final phase = index * 0.25;
        final wave = math.sin(2 * math.pi * (_controller.value - phase));
        final bounce = wave > 0 ? wave : 0.0;
        return Transform.translate(
          offset: Offset(0, -5 * bounce),
          child: Transform.scale(
            scale: 0.85 + 0.3 * bounce,
            child: Opacity(opacity: 0.5 + 0.5 * bounce, child: child),
          ),
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