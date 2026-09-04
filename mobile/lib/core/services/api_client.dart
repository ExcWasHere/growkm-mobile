import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  ApiClient._();
  static final instance = ApiClient._();

  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  Future<Map<String, String>> _headers({Map<String, String>? extra}) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (extra != null) ...extra,
    };
  }

  Future<http.Response> post(String path, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    return http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(extra: headers),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> patch(String path, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    return http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(extra: headers),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String path) async {
    return http.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
  }

  Future<http.Response> delete(String path) async {
    return http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
  }
}