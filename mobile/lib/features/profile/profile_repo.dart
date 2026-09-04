import 'dart:convert';
import '../../core/services/api_client.dart';
import 'models/profile_models.dart';

class ProfileRepository {
  ProfileRepository._();
  static final instance = ProfileRepository._();

  Future<ProfileOverview> fetchProfile() async {
    final response = await ApiClient.instance.get('/api/users/me');
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat profil (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return ProfileOverview.fromMeJson(data);
  }

  Future<void> saveBusinessProfile(UpsertBusinessProfileInput input) async {
    final response = await ApiClient.instance.post('/api/users/business-profile', input.toJson());
    if (response.statusCode != 200 && response.statusCode != 201) {
      String? message;
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        message = decoded['message'] as String?;
      } catch (_) {}
      throw Exception(message ?? 'HTTP ${response.statusCode}');
    }
  }
}