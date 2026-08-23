import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_client.dart';
import '../models/lexa_models.dart';

class LexaRepository {
  LexaRepository._();
  static final instance = LexaRepository._();

  static const _localTitlesKey = 'lexa_local_session_titles';

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
    final localTitles = await _loadLocalTitles();

    return list.map((raw) {
      final json = Map<String, dynamic>.from(raw as Map<String, dynamic>);
      final id = json['id'] as String?;
      final hasBackendTitle = (json['title'] as String?)?.trim().isNotEmpty == true ||
          (json['preview'] as String?)?.trim().isNotEmpty == true;
      if (!hasBackendTitle && id != null && localTitles.containsKey(id)) {
        json['preview'] = localTitles[id];
      }
      return ChatSessionSummary.fromJson(json);
    }).toList();
  }

  Future<ChatSessionDetail> fetchSessionDetail(String id) async {
    final response = await ApiClient.instance.get('/api/chat/sessions/$id');
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat sesi ($id)');
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
    await _removeLocalTitle(id);
  }
  Future<void> saveLocalSessionTitle(String sessionId, String firstMessage) async {
    final prefs = await SharedPreferences.getInstance();
    final titles = await _loadLocalTitles(prefs: prefs);
    final trimmed = firstMessage.trim();
    titles[sessionId] = trimmed.length > 60 ? '${trimmed.substring(0, 60)}…' : trimmed;
    await prefs.setString(_localTitlesKey, jsonEncode(titles));
  }

  Future<void> _removeLocalTitle(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final titles = await _loadLocalTitles(prefs: prefs);
    if (titles.remove(sessionId) != null) {
      await prefs.setString(_localTitlesKey, jsonEncode(titles));
    }
  }

  Future<Map<String, String>> _loadLocalTitles({SharedPreferences? prefs}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final raw = p.getString(_localTitlesKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return {};
    }
  }
}