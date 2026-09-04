import 'dart:convert';
import '../../../core/services/api_client.dart';
import '../models/market_models.dart';

class MarketRepository {
  MarketRepository._();
  static final instance = MarketRepository._();
  Future<OpportunitiesResult> fetchOpportunities({MatchStatus? status, OpportunityCategory? category}) async {
    final query = <String, String>{
      if (status != null) 'status': status.wireValue,
      if (category != null) 'category': category.wireValue,
    };
    final path = query.isEmpty
        ? '/api/opportunities'
        : '/api/opportunities?${Uri(queryParameters: query).query}';

    final response = await ApiClient.instance.get(path);
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat peluang (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? {};
    return OpportunitiesResult.fromJson(data);
  }

  Future<AdvisorResult> fetchAdvisor() async {
    final response = await ApiClient.instance.get('/api/opportunities/advisor');
    if (response.statusCode == 404) {
      throw AdvisorProfileIncompleteException();
    }
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat rekomendasi AI (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? {};
    return AdvisorResult.fromJson(data);
  }

  Future<MatchTriggerResult> triggerMatch() async {
    final response = await ApiClient.instance.post('/api/opportunities/match', const {});
    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui status peluang (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? {};
    return MatchTriggerResult.fromJson(data);
  }

  Future<List<Opportunity>> fetchUnlockedSince(DateTime since) async {
    final iso = since.toUtc().toIso8601String();
    final response = await ApiClient.instance.get('/api/opportunities/unlocked?since=$iso');
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat peluang baru (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? {};
    final list = data['newly_unlocked'] as List<dynamic>? ?? [];
    return list.map((o) => Opportunity.fromJson(o as Map<String, dynamic>)).toList();
  }

  Future<Opportunity> fetchDetail(String id) async {
    final response = await ApiClient.instance.get('/api/opportunities/$id');
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat detail peluang (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>? ?? {};
    return Opportunity.fromJson(data);
  }
}

class AdvisorProfileIncompleteException implements Exception {}