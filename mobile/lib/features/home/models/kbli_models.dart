/// Models untuk fitur KBLI Matcher.
/// Port 1:1 dari struktur response backend yang sama dipakai di web (ScannerPage.tsx).

class KbliWarning {
  final String wrongKbli;
  final String reason;

  const KbliWarning({required this.wrongKbli, required this.reason});

  factory KbliWarning.fromJson(Map<String, dynamic> json) {
    return KbliWarning(
      wrongKbli: json['wrong_kbli'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class KbliMismatchAlert {
  final String userKbli;
  final String recommendedKbli;
  final String reason;

  const KbliMismatchAlert({
    required this.userKbli,
    required this.recommendedKbli,
    required this.reason,
  });

  factory KbliMismatchAlert.fromJson(Map<String, dynamic> json) {
    return KbliMismatchAlert(
      userKbli: json['user_kbli'] as String? ?? '',
      recommendedKbli: json['recommended_kbli'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

/// Mode hasil scan: 'recommend' (belum ada KBLI) atau 'validate' (KBLI sudah ada, dicek kesesuaiannya)
enum KbliScanMode { recommend, validate }

class KbliScanResult {
  final KbliScanMode mode;
  final String kbliCode;

  // recommend-only
  final String? kbliTitle;
  final double? confidence;

  // validate-only
  final String? kbliName;
  final List<KbliWarning> warnings;
  final KbliMismatchAlert? mismatchAlert;

  final String explanation;

  const KbliScanResult._({
    required this.mode,
    required this.kbliCode,
    required this.explanation,
    this.kbliTitle,
    this.confidence,
    this.kbliName,
    this.warnings = const [],
    this.mismatchAlert,
  });

  factory KbliScanResult.recommend(Map<String, dynamic> data) {
    return KbliScanResult._(
      mode: KbliScanMode.recommend,
      kbliCode: data['kbli_code'] as String? ?? '',
      kbliTitle: data['kbli_title'] as String?,
      confidence: (data['confidence'] as num?)?.toDouble(),
      explanation: data['explanation'] as String? ?? '',
    );
  }

  factory KbliScanResult.validate(Map<String, dynamic> data) {
    final warningsJson = data['warnings'] as List<dynamic>? ?? [];
    final mismatchJson = data['mismatch_alert'] as Map<String, dynamic>?;
    return KbliScanResult._(
      mode: KbliScanMode.validate,
      kbliCode: data['kbli_code'] as String? ?? '',
      kbliName: data['kbli_name'] as String?,
      explanation: data['explanation'] as String? ?? '',
      warnings: warningsJson
          .map((w) => KbliWarning.fromJson(w as Map<String, dynamic>))
          .toList(),
      mismatchAlert:
          mismatchJson != null ? KbliMismatchAlert.fromJson(mismatchJson) : null,
    );
  }

  bool get hasMismatch => mismatchAlert != null;
}

enum KbliConfirmState { idle, loading, success, error }
class KbliBusinessSnapshot {
  final String? kbliCode;
  final String? description;

  const KbliBusinessSnapshot({this.kbliCode, this.description});

  bool get hasKbli => (kbliCode ?? '').trim().isNotEmpty;

  factory KbliBusinessSnapshot.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const KbliBusinessSnapshot();
    return KbliBusinessSnapshot(
      kbliCode: json['kbli_code'] as String?,
      description: json['description'] as String?,
    );
  }
}