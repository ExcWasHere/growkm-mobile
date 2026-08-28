enum OpportunityCategory { pembiayaan, vendorSupplyChain, marketplace, programPemerintah, eventPameran }

extension OpportunityCategoryX on OpportunityCategory {
  String get wireValue => switch (this) {
        OpportunityCategory.pembiayaan => 'pembiayaan',
        OpportunityCategory.vendorSupplyChain => 'vendor_supply_chain',
        OpportunityCategory.marketplace => 'marketplace',
        OpportunityCategory.programPemerintah => 'program_pemerintah',
        OpportunityCategory.eventPameran => 'event_pameran',
      };

  String get label => switch (this) {
        OpportunityCategory.pembiayaan => 'Pembiayaan',
        OpportunityCategory.vendorSupplyChain => 'Vendor / Supply Chain',
        OpportunityCategory.marketplace => 'Marketplace',
        OpportunityCategory.programPemerintah => 'Program Pemerintah',
        OpportunityCategory.eventPameran => 'Event / Pameran',
      };

  static OpportunityCategory fromWire(String? value) {
    return switch (value) {
      'vendor_supply_chain' => OpportunityCategory.vendorSupplyChain,
      'marketplace' => OpportunityCategory.marketplace,
      'program_pemerintah' => OpportunityCategory.programPemerintah,
      'event_pameran' => OpportunityCategory.eventPameran,
      _ => OpportunityCategory.pembiayaan,
    };
  }
}

enum MatchStatus { eligible, almost, locked }

extension MatchStatusX on MatchStatus {
  String get wireValue => switch (this) {
        MatchStatus.eligible => 'eligible',
        MatchStatus.almost => 'almost',
        MatchStatus.locked => 'locked',
      };

  String get label => switch (this) {
        MatchStatus.eligible => 'Eligible',
        MatchStatus.almost => 'Hampir',
        MatchStatus.locked => 'Terkunci',
      };

  static MatchStatus fromWire(String? value) {
    return switch (value) {
      'eligible' => MatchStatus.eligible,
      'locked' => MatchStatus.locked,
      _ => MatchStatus.almost,
    };
  }
}

/// Jenis syarat perizinan (dari formalization_steps.step_type di backend).
enum StepType { nib, sppIrt, halal, bpom, merek, sertifikatStandar }

extension StepTypeX on StepType {
  String get wireValue => switch (this) {
        StepType.nib => 'nib',
        StepType.sppIrt => 'spp_irt',
        StepType.halal => 'halal',
        StepType.bpom => 'bpom',
        StepType.merek => 'merek',
        StepType.sertifikatStandar => 'sertifikat_standar',
      };

  String get label => switch (this) {
        StepType.nib => 'NIB',
        StepType.sppIrt => 'SPP-IRT / PIRT',
        StepType.halal => 'Sertifikat Halal',
        StepType.bpom => 'BPOM',
        StepType.merek => 'Merek',
        StepType.sertifikatStandar => 'Sertifikat Standar',
      };

  static StepType fromWire(String value) {
    return switch (value) {
      'spp_irt' => StepType.sppIrt,
      'halal' => StepType.halal,
      'bpom' => StepType.bpom,
      'merek' => StepType.merek,
      'sertifikat_standar' => StepType.sertifikatStandar,
      _ => StepType.nib,
    };
  }

  static List<StepType> listFromWire(List<dynamic>? raw) {
    return (raw ?? []).map((e) => StepTypeX.fromWire(e as String)).toList();
  }
}

class Opportunity {
  final String id;
  final String title;
  final OpportunityCategory category;
  final String provider;
  final String? description;
  final String? estimatedValue;
  final String? valueDescription;
  final String region;
  final List<StepType> requiredSteps;
  final List<StepType> niceToHaveSteps;
  final List<String> additionalRequirements;
  final DateTime? deadline;
  final String? sourceUrl;
  final MatchStatus matchStatus;
  final List<StepType> missingSteps;
  final double matchScore;

  const Opportunity({
    required this.id,
    required this.title,
    required this.category,
    required this.provider,
    required this.region,
    required this.requiredSteps,
    required this.niceToHaveSteps,
    required this.additionalRequirements,
    required this.matchStatus,
    required this.missingSteps,
    required this.matchScore,
    this.description,
    this.estimatedValue,
    this.valueDescription,
    this.deadline,
    this.sourceUrl,
  });

  bool get isLocked => matchStatus == MatchStatus.locked;

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: OpportunityCategoryX.fromWire(json['category'] as String?),
      provider: json['provider'] as String? ?? '',
      description: json['description'] as String?,
      estimatedValue: json['estimated_value'] as String?,
      valueDescription: json['value_description'] as String?,
      region: json['region'] as String? ?? 'nasional',
      requiredSteps: StepTypeX.listFromWire(json['required_steps'] as List<dynamic>?),
      niceToHaveSteps: StepTypeX.listFromWire(json['nice_to_have_steps'] as List<dynamic>?),
      additionalRequirements: (json['additional_requirements'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline'] as String) : null,
      sourceUrl: json['source_url'] as String?,
      matchStatus: MatchStatusX.fromWire(json['match_status'] as String?),
      missingSteps: StepTypeX.listFromWire(json['missing_steps'] as List<dynamic>?),
      matchScore: (json['match_score'] as num?)?.toDouble() ?? 0,
    );
  }
}

class OpportunitySummary {
  final int eligibleCount;
  final int almostCount;
  final int lockedCount;

  const OpportunitySummary({
    required this.eligibleCount,
    required this.almostCount,
    required this.lockedCount,
  });

  int get total => eligibleCount + almostCount + lockedCount;

  factory OpportunitySummary.fromJson(Map<String, dynamic> json) {
    return OpportunitySummary(
      eligibleCount: json['eligible_count'] as int? ?? 0,
      almostCount: json['almost_count'] as int? ?? 0,
      lockedCount: json['locked_count'] as int? ?? 0,
    );
  }
}

class OpportunitiesResult {
  final OpportunitySummary summary;
  final List<Opportunity> opportunities;

  const OpportunitiesResult({required this.summary, required this.opportunities});

  factory OpportunitiesResult.fromJson(Map<String, dynamic> json) {
    final oppsJson = json['opportunities'] as List<dynamic>? ?? [];
    return OpportunitiesResult(
      summary: OpportunitySummary.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      opportunities: oppsJson.map((o) => Opportunity.fromJson(o as Map<String, dynamic>)).toList(),
    );
  }
}

class AdvisorRecommendation {
  final String opportunityId;
  final String title;
  final int priorityRank;
  final MatchStatus matchStatus;
  final List<StepType> missingSteps;
  final String whyThisFits;
  final String whyNow;
  final String nextStep;
  final String? caveats;
  final String? sourceUrl;

  const AdvisorRecommendation({
    required this.opportunityId,
    required this.title,
    required this.priorityRank,
    required this.matchStatus,
    required this.missingSteps,
    required this.whyThisFits,
    required this.whyNow,
    required this.nextStep,
    this.caveats,
    this.sourceUrl,
  });

  factory AdvisorRecommendation.fromJson(Map<String, dynamic> json) {
    return AdvisorRecommendation(
      opportunityId: json['opportunity_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      priorityRank: json['priority_rank'] as int? ?? 0,
      matchStatus: MatchStatusX.fromWire(json['match_status'] as String?),
      missingSteps: StepTypeX.listFromWire(json['missing_steps'] as List<dynamic>?),
      whyThisFits: json['why_this_fits'] as String? ?? '',
      whyNow: json['why_now'] as String? ?? '',
      nextStep: json['next_step'] as String? ?? '',
      caveats: json['caveats'] as String?,
      sourceUrl: json['source_url'] as String?,
    );
  }
}

class AdvisorResult {
  final String userContextSummary;
  final List<AdvisorRecommendation> recommendations;
  final DateTime? generatedAt;

  const AdvisorResult({
    required this.userContextSummary,
    required this.recommendations,
    this.generatedAt,
  });

  factory AdvisorResult.fromJson(Map<String, dynamic> json) {
    final recsJson = json['recommendations'] as List<dynamic>? ?? [];
    return AdvisorResult(
      userContextSummary: json['user_context_summary'] as String? ?? '',
      recommendations: recsJson.map((r) => AdvisorRecommendation.fromJson(r as Map<String, dynamic>)).toList(),
      generatedAt: json['generated_at'] != null ? DateTime.tryParse(json['generated_at'] as String) : null,
    );
  }
}

class MatchTriggerResult {
  final int eligible;
  final int almost;
  final int locked;
  final int total;
  final List<String> newlyUnlockedIds;

  const MatchTriggerResult({
    required this.eligible,
    required this.almost,
    required this.locked,
    required this.total,
    required this.newlyUnlockedIds,
  });

  factory MatchTriggerResult.fromJson(Map<String, dynamic> json) {
    return MatchTriggerResult(
      eligible: json['eligible'] as int? ?? 0,
      almost: json['almost'] as int? ?? 0,
      locked: json['locked'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      newlyUnlockedIds: (json['newly_unlocked'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
    );
  }
}