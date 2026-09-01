import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/product_tour_step.dart';
import '../services/product_tour_service.dart';

class ProductTourDialog {
  static Future<void> showIfNeeded(
    BuildContext context, {
    required String tourKey,
    required ProductTourService store,
    required List<ProductTourStep> steps,
  }) async {
    final alreadySeen = await store.hasSeenTour(tourKey);
    if (alreadySeen || !context.mounted || steps.isEmpty) return;

    await _showOverlay(context, steps);
    await store.markTourSeen(tourKey);
  }

  static Future<void> _showOverlay(
    BuildContext context,
    List<ProductTourStep> steps,
  ) {
    final completer = Completer<void>();
    late OverlayEntry entry;
    int index = 0;

    void close() {
      entry.remove();
      if (!completer.isCompleted) completer.complete();
    }

    void rebuild() => entry.markNeedsBuild();

    entry = OverlayEntry(
      builder: (overlayContext) {
        final step = steps[index];
        final targetRect = _resolveTargetRect(step.targetKey);
        return _TourOverlayContent(
          step: step,
          targetRect: targetRect,
          stepIndex: index,
          totalSteps: steps.length,
          onNext: () {
            if (index < steps.length - 1) {
              index++;
              rebuild();
            } else {
              close();
            }
          },
          onSkip: close,
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(entry);
    return completer.future;
  }

  static Rect? _resolveTargetRect(GlobalKey? key) {
    if (key?.currentContext == null) return null;
    final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return null;
    final position = renderBox.localToGlobal(Offset.zero);
    return position & renderBox.size;
  }
}

class _TourOverlayContent extends StatelessWidget {
  final ProductTourStep step;
  final Rect? targetRect;
  final int stepIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TourOverlayContent({
    required this.step,
    required this.targetRect,
    required this.stepIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLast = stepIndex == totalSteps - 1;

    double? cardTop;
    double? cardBottom;
    if (targetRect != null) {
      final spaceBelow = size.height - targetRect!.bottom;
      if (spaceBelow > 220) {
        cardTop = targetRect!.bottom + 16;
      } else {
        cardBottom = size.height - targetRect!.top + 16;
      }
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onNext,
            child: CustomPaint(
              painter: _SpotlightPainter(targetRect: targetRect),
              size: Size.infinite,
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          top: cardTop,
          bottom: cardTop == null ? (cardBottom ?? size.height / 2 - 100) : null,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(step.icon, color: AppColors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.inkMuted.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: onSkip, child: const Text('Lewati')),
                      Row(
                        children: List.generate(
                          totalSteps,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == stepIndex
                                  ? AppColors.primaryDark
                                  : AppColors.primaryDark.withValues(alpha: 0.25),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(64, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: Text(isLast ? 'Selesai' : 'Lanjut'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  _SpotlightPainter({this.targetRect});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.65);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (targetRect == null) {
      canvas.drawRect(fullRect, overlayPaint);
      return;
    }

    final spotlightRect = targetRect!.inflate(8);
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(spotlightRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);

    final borderPaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(spotlightRect, const Radius.circular(16)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.targetRect != targetRect;
}