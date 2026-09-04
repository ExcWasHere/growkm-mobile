sealed class KbliScanResult {
  const KbliScanResult();
}

final class KbliRecommendResult extends KbliScanResult {
  final String kbliCode;
  final String kbliTitle;
  final double confidence;
  final String explanation;

  const KbliRecommendResult({
    required this.kbliCode,
    required this.kbliTitle,
    required this.confidence,
    required this.explanation,
  });

  factory KbliRecommendResult.fromJson(Map<String, dynamic> json) {
    return KbliRecommendResult(
      kbliCode: json['kbli_code'] as String? ?? '',
      kbliTitle: json['kbli_title'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

final class KbliValidateResult extends KbliScanResult {
  final bool isValid;
  final bool mismatchAlert;
  final String explanation;
  final String? suggestedKbli;

  const KbliValidateResult({
    required this.isValid,
    required this.mismatchAlert,
    required this.explanation,
    this.suggestedKbli,
  });

  factory KbliValidateResult.fromJson(Map<String, dynamic> json) {
    return KbliValidateResult(
      isValid: json['is_valid'] as bool? ?? false,
      mismatchAlert: json['mismatch_alert'] as bool? ?? false,
      explanation: json['explanation'] as String? ?? '',
      suggestedKbli: json['suggested_kbli'] as String?,
    );
  }

  bool get hasSuggestion => mismatchAlert && (suggestedKbli ?? '').trim().isNotEmpty;
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