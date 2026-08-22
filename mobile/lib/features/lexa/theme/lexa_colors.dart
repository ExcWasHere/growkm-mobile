import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LexaColors {
  LexaColors._();
  static const amber50 = Color(0xFFFFFBEB);
  static const amber100 = AppColors.primaryLight;
  static const amber200 = AppColors.accentLight;
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = AppColors.primary;
  static const amber600 = AppColors.primaryDark;
  static const amber700 = Color(0xFFB45309);
  static const amber800 = Color(0xFF92400E);

  static const orange = AppColors.secondary;
  static const orangeDark = AppColors.secondaryDark;

  static const red = AppColors.error;
  static const red50 = AppColors.errorLight;
  static const red100 = Color(0xFFFEE2E2);
  static const red500 = Color(0xFFEF4444);

  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = AppColors.inkMuted;
  static const gray700 = AppColors.inkMuted;
  static const gray800 = AppColors.ink;
  static const gray900 = Color(0xFF111827);
}

String formatRelativeTime(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari lalu';
  const bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${date.day} ${bulan[date.month - 1]}';
}