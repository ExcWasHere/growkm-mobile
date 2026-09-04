import 'dart:convert';
import '../../core/services/api_client.dart';
import 'models/roadmap_models.dart';

class RoadmapRepository {
  RoadmapRepository._();
  static final instance = RoadmapRepository._();

  Future<RoadmapOverview> fetchOverview() async {
    final response = await ApiClient.instance.get('/api/users/me');
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat roadmap (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return RoadmapOverview.fromMeJson(data);
  }

  Future<ActionPlan> generateActionPlan(String stepType) async {
    final response = await ApiClient.instance.post('/api/users/roadmap/$stepType/action-plan', const {});
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 404) throw RoadmapBusinessProfileMissingException();
    if (response.statusCode == 400) throw RoadmapInvalidStepException();
    if (response.statusCode != 200) {
      throw Exception(decoded['message'] as String? ?? 'HTTP ${response.statusCode}');
    }
    return ActionPlan.fromJson(decoded['data'] as Map<String, dynamic>? ?? {});
  }

  Future<UpdateStepStatusResult> updateStepStatus({
    required String stepType,
    required RoadmapStepStatus status,
  }) async {
    final response = await ApiClient.instance.patch('/api/users/roadmap/status', {
      'step_type': stepType,
      'status': status.wireValue,
    });
    if (response.statusCode == 400) throw RoadmapStepLockedException();
    if (response.statusCode == 404) throw RoadmapBusinessProfileMissingException();
    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui status step (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return UpdateStepStatusResult.fromJson(decoded['data'] as Map<String, dynamic>? ?? {});
  }
}

class RoadmapBusinessProfileMissingException implements Exception {}
class RoadmapInvalidStepException implements Exception {}
class RoadmapStepLockedException implements Exception {}