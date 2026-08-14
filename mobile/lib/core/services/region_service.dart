import 'dart:convert';
import 'package:http/http.dart' as http;

class RegionOption {
  final String id;
  final String name;
  const RegionOption({required this.id, required this.name});
}

class RegionService {
  RegionService._();
  static final instance = RegionService._();

  static const _base = 'https://www.emsifa.com/api-wilayah-indonesia/api';

  Future<List<RegionOption>> getProvinces() => _fetchList('$_base/provinces.json');

  Future<List<RegionOption>> getRegencies(String provinceId) =>
      _fetchList('$_base/regencies/$provinceId.json');

  Future<List<RegionOption>> getDistricts(String regencyId) =>
      _fetchList('$_base/districts/$regencyId.json');

  Future<List<RegionOption>> _fetchList(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) return [];
    final List data = jsonDecode(res.body);
    return data
        .map((e) => RegionOption(id: e['id'].toString(), name: e['name'].toString()))
        .toList();
  }
}