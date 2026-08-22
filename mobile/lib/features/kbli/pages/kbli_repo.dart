import 'dart:convert';
import '../../../core/services/api_client.dart';
import '../models/kbli_models.dart';

class KbliRepository {
  KbliRepository._();
  static final instance = KbliRepository._();

  Future<KbliBusinessSnapshot> fetchBusinessSnapshot() async {
    final response = await ApiClient.instance.get('/api/users/me');
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat data (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? {};
    final bpJson = data['business_profile'] as Map<String, dynamic>?;
    return KbliBusinessSnapshot.fromJson(bpJson);
  }

  Future<KbliRecommendResult> recommend() async {
    final data = await _postAndUnwrap('/api/users/business-profile/kbli/recommend');
    return KbliRecommendResult.fromJson(data);
  }

  Future<KbliValidateResult> validate() async {
    final data = await _postAndUnwrap('/api/users/business-profile/kbli/validate');
    return KbliValidateResult.fromJson(data);
  }

  Future<void> confirmKbli(String kbliCode) async {
    final response = await ApiClient.instance.patch(
      '/api/users/business-profile/kbli',
      {'kbli_code': kbliCode},
    );
    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response.body) ?? 'HTTP ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _postAndUnwrap(String path) async {
    final response = await ApiClient.instance.post(path, const {});
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(decoded['message'] as String? ?? 'HTTP ${response.statusCode}');
    }
    return decoded['data'] as Map<String, dynamic>? ?? {};
  }

  String? _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      return decoded['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}