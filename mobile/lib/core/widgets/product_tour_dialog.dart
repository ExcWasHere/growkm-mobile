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
    _showStep(context, store, tourKey, steps, 0);
  }

  static void _showStep(
    BuildContext context,
    ProductTourService store,
    String tourKey,
    List<ProductTourStep> steps,
    int index,
  ) {
    final step = steps[index];
    final isLast = index == steps.length - 1;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(step.icon, color: AppColors.white, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                step.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                step.description,
                style: TextStyle(color: AppColors.inkMuted.withOpacity(0.8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (index == 0)
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          store.markTourSeen(tourKey);
                          Navigator.of(dialogContext).pop();
                        },
                        child: const Text('Lewati'),
                      ),
                    ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        if (isLast) {
                          store.markTourSeen(tourKey);
                        } else {
                          _showStep(context, store, tourKey, steps, index + 1);
                        }
                      },
                      child: Text(isLast ? 'Selesai' : 'Lanjut'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}