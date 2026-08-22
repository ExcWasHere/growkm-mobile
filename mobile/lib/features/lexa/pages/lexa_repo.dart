import 'dart:convert';
import '../../../core/services/api_client.dart';
import '../models/lexa_models.dart';

class LexaRepository {
  LexaRepository._();
  static final instance = LexaRepository._();

  Future<LexaUserSnapshot> fetchUserSnapshot() async {
    final response = await ApiClient.instance.get('/api/users/me');
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat data (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return LexaUserSnapshot.fromJson(data);
  }

  Future<ChatSendResult> sendMessage({
    required String message,
    String? sessionId,
    ChatContextStepType? contextStepType,
  }) async {
    final response = await ApiClient.instance.post('/api/chat', {
      'message': message,
      if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
      if (contextStepType != null) 'context_step_type': contextStepType.wireValue,
    });

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(decoded['message'] as String? ?? 'HTTP ${response.statusCode}');
    }
    final data = decoded['data'] as Map<String, dynamic>? ?? {};
    return ChatSendResult.fromJson(data);
  }

  Future<List<ChatSessionSummary>> fetchSessions() async {
    final response = await ApiClient.instance.get('/api/chat/sessions');
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat riwayat chat (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final list = decoded['data'] as List<dynamic>? ?? [];
    return list
        .map((s) => ChatSessionSummary.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<ChatSessionDetail> fetchSessionDetail(String id) async {
    final response = await ApiClient.instance.get('/api/chat/sessions/$id');
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat sesi (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? {};
    return ChatSessionDetail.fromJson(data);
  }

  Future<void> deleteSession(String id) async {
    final response = await ApiClient.instance.delete('/api/chat/sessions/$id');
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus sesi (${response.statusCode})');
    }
  }
}