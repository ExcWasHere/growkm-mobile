enum RoadmapStepType { nib, sppIrt, halal, bpom, merek, sertifikatStandar }

extension RoadmapStepTypeX on RoadmapStepType {
  String get wireValue => switch (this) {
        RoadmapStepType.nib => 'nib',
        RoadmapStepType.sppIrt => 'spp_irt',
        RoadmapStepType.halal => 'halal',
        RoadmapStepType.bpom => 'bpom',
        RoadmapStepType.merek => 'merek',
        RoadmapStepType.sertifikatStandar => 'sertifikat_standar',
      };

  String get label => switch (this) {
        RoadmapStepType.nib => 'NIB',
        RoadmapStepType.sppIrt => 'SPP-IRT',
        RoadmapStepType.halal => 'Sertifikat Halal',
        RoadmapStepType.bpom => 'BPOM',
        RoadmapStepType.merek => 'Merek',
        RoadmapStepType.sertifikatStandar => 'Sertifikat Standar',
      };

  String get description => switch (this) {
        RoadmapStepType.nib => 'Nomor Induk Berusaha — identitas legal usahamu',
        RoadmapStepType.sppIrt => 'Izin edar pangan olahan rumahan',
        RoadmapStepType.halal => 'Sertifikasi kehalalan produk',
        RoadmapStepType.bpom => 'Izin edar dari BPOM',
        RoadmapStepType.merek => 'Perlindungan nama & logo usaha',
        RoadmapStepType.sertifikatStandar => 'Standar kelayakan usaha',
      };

  static RoadmapStepType fromWire(String value) {
    return switch (value) {
      'spp_irt' => RoadmapStepType.sppIrt,
      'halal' => RoadmapStepType.halal,
      'bpom' => RoadmapStepType.bpom,
      'merek' => RoadmapStepType.merek,
      'sertifikat_standar' => RoadmapStepType.sertifikatStandar,
      _ => RoadmapStepType.nib,
    };
  }
}

enum RoadmapStepStatus { locked, unlocked, inProgress, completed }

extension RoadmapStepStatusX on RoadmapStepStatus {
  String get wireValue => switch (this) {
        RoadmapStepStatus.locked => 'locked',
        RoadmapStepStatus.unlocked => 'unlocked',
        RoadmapStepStatus.inProgress => 'in_progress',
        RoadmapStepStatus.completed => 'completed',
      };

  String get label => switch (this) {
        RoadmapStepStatus.locked => 'Terkunci',
        RoadmapStepStatus.unlocked => 'Bisa Dikerjakan',
        RoadmapStepStatus.inProgress => 'Sedang Dikerjakan',
        RoadmapStepStatus.completed => 'Selesai',
      };

  static RoadmapStepStatus fromWire(String? value) {
    return switch (value) {
      'unlocked' => RoadmapStepStatus.unlocked,
      'in_progress' => RoadmapStepStatus.inProgress,
      'completed' => RoadmapStepStatus.completed,
      _ => RoadmapStepStatus.locked,
    };
  }
}

class RoadmapStep {
  final String id;
  final RoadmapStepType stepType;
  final int stepOrder;
  final bool isRequired;
  final RoadmapStepStatus status;
  final int currentSubstep;
  final int? totalSubsteps;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const RoadmapStep({
    required this.id,
    required this.stepType,
    required this.stepOrder,
    required this.isRequired,
    required this.status,
    required this.currentSubstep,
    this.totalSubsteps,
    this.startedAt,
    this.completedAt,
  });

  factory RoadmapStep.fromJson(Map<String, dynamic> json) {
    return RoadmapStep(
      id: json['id'] as String? ?? '',
      stepType: RoadmapStepTypeX.fromWire(json['step_type'] as String? ?? 'nib'),
      stepOrder: json['step_order'] as int? ?? 0,
      isRequired: json['is_required'] as bool? ?? true,
      status: RoadmapStepStatusX.fromWire(json['status'] as String?),
      currentSubstep: json['current_substep'] as int? ?? 0,
      totalSubsteps: json['total_substeps'] as int?,
      startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
    );
  }
}

class RoadmapOverview {
  final String businessName;
  final String city;
  final List<RoadmapStep> steps;

  const RoadmapOverview({required this.businessName, required this.city, required this.steps});

  int get totalSteps => steps.length;
  int get completedSteps => steps.where((s) => s.status == RoadmapStepStatus.completed).length;
  double get progressPct => totalSteps == 0 ? 0 : (completedSteps / totalSteps) * 100;

  factory RoadmapOverview.fromMeJson(Map<String, dynamic> data) {
    final bp = data['business_profile'] as Map<String, dynamic>?;
    final roadmapJson = data['roadmap'] as List<dynamic>? ?? [];
    return RoadmapOverview(
      businessName: bp?['business_name'] as String? ?? 'Usahamu',
      city: bp?['city'] as String? ?? '',
      steps: roadmapJson.map((s) => RoadmapStep.fromJson(s as Map<String, dynamic>)).toList()
        ..sort((a, b) => a.stepOrder.compareTo(b.stepOrder)),
    );
  }
}

class UpdateStepStatusResult {
  final List<RoadmapStep> steps;
  final int progressPercentage;

  const UpdateStepStatusResult({required this.steps, required this.progressPercentage});

  factory UpdateStepStatusResult.fromJson(Map<String, dynamic> json) {
    final stepsJson = json['steps'] as List<dynamic>? ?? [];
    return UpdateStepStatusResult(
      steps: stepsJson.map((s) => RoadmapStep.fromJson(s as Map<String, dynamic>)).toList(),
      progressPercentage: json['progress_percentage'] as int? ?? 0,
    );
  }
}

class ActionPlanTask {
  final int day;
  final String task;
  final String duration;
  final String? tip;
  final String? tag;

  const ActionPlanTask({required this.day, required this.task, required this.duration, this.tip, this.tag});

  factory ActionPlanTask.fromJson(Map<String, dynamic> json) {
    return ActionPlanTask(
      day: json['day'] as int? ?? 0,
      task: json['task'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      tip: json['tip'] as String?,
      tag: json['tag'] as String?,
    );
  }
}

class ActionPlanWeek {
  final int week;
  final String title;
  final List<ActionPlanTask> tasks;

  const ActionPlanWeek({required this.week, required this.title, required this.tasks});

  factory ActionPlanWeek.fromJson(Map<String, dynamic> json) {
    final tasksJson = json['tasks'] as List<dynamic>? ?? [];
    return ActionPlanWeek(
      week: json['week'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      tasks: tasksJson.map((t) => ActionPlanTask.fromJson(t as Map<String, dynamic>)).toList(),
    );
  }
}

class ActionPlanPrerequisiteCheck {
  final bool passed;
  final String notes;

  const ActionPlanPrerequisiteCheck({required this.passed, required this.notes});

  factory ActionPlanPrerequisiteCheck.fromJson(Map<String, dynamic> json) {
    return ActionPlanPrerequisiteCheck(
      passed: json['passed'] as bool? ?? true,
      notes: json['notes'] as String? ?? '',
    );
  }
}

class ActionPlan {
  final RoadmapStepType stepType;
  final String businessName;
  final String city;
  final String estimatedDuration;
  final String estimatedCost;
  final ActionPlanPrerequisiteCheck prerequisiteCheck;
  final List<ActionPlanWeek> weeks;
  final List<String> importantNotes;

  const ActionPlan({
    required this.stepType,
    required this.businessName,
    required this.city,
    required this.estimatedDuration,
    required this.estimatedCost,
    required this.prerequisiteCheck,
    required this.weeks,
    required this.importantNotes,
  });

  factory ActionPlan.fromJson(Map<String, dynamic> json) {
    final weeksJson = json['weeks'] as List<dynamic>? ?? [];
    final notesJson = json['important_notes'] as List<dynamic>? ?? [];
    return ActionPlan(
      stepType: RoadmapStepTypeX.fromWire(json['step_type'] as String? ?? 'nib'),
      businessName: json['business_name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      estimatedDuration: json['estimated_duration'] as String? ?? '',
      estimatedCost: json['estimated_cost'] as String? ?? '',
      prerequisiteCheck: ActionPlanPrerequisiteCheck.fromJson(json['prerequisite_check'] as Map<String, dynamic>? ?? {}),
      weeks: weeksJson.map((w) => ActionPlanWeek.fromJson(w as Map<String, dynamic>)).toList(),
      importantNotes: notesJson.map((n) => n as String).toList(),
    );
  }
}