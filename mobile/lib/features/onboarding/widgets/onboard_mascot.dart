import 'package:flutter/material.dart';
import '../theme/onboard_colors.dart';
import '../models/onboard_models.dart';

class OnboardingMascotBubble extends StatelessWidget {
  final MascotPose pose;
  final String message;

  const OnboardingMascotBubble({super.key, required this.pose, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(pose.assetPath, width: 96, height: 96, fit: BoxFit.contain),
        const SizedBox(width: 4),
        Expanded(
          child: CustomPaint(
            painter: _SideTailPainter(color: Colors.white, borderColor: OnboardingColors.amber200),
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OnboardingColors.amber200),
              ),
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: OnboardingColors.gray800, height: 1.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingMascotCentered extends StatelessWidget {
  final MascotPose pose;
  final String message;

  const OnboardingMascotCentered({super.key, required this.pose, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          painter: _DownTailPainter(color: Colors.white, borderColor: OnboardingColors.amber200),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: OnboardingColors.amber200),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: OnboardingColors.gray800, height: 1.4),
            ),
          ),
        ),
        Image.asset(pose.assetPath, width: 220, height: 220, fit: BoxFit.contain),
      ],
    );
  }
}

class _SideTailPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _SideTailPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    const tailHeight = 14.0;
    final centerY = size.height / 2;

    final path = Path()
      ..moveTo(10, centerY - tailHeight / 2)
      ..lineTo(0, centerY)
      ..lineTo(10, centerY + tailHeight / 2)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(path, Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = 1.2);
  }

  @override
  bool shouldRepaint(covariant _SideTailPainter oldDelegate) => false;
}

class _DownTailPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _DownTailPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    const tailWidth = 16.0;
    final centerX = size.width / 2;
    final tipY = size.height;

    final path = Path()
      ..moveTo(centerX - tailWidth / 2, tipY - 10)
      ..lineTo(centerX, tipY)
      ..lineTo(centerX + tailWidth / 2, tipY - 10)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(path, Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = 1.2);
  }

  @override
  bool shouldRepaint(covariant _DownTailPainter oldDelegate) => false;
}