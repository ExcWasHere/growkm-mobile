import 'package:shared_preferences/shared_preferences.dart';

class ProductTourService {
  ProductTourService._();
  static final instance = ProductTourService._();

  Future<bool> hasSeenTour(String tourKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tour_seen_$tourKey') ?? false;
  }

  Future<void> markTourSeen(String tourKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tour_seen_$tourKey', true);
  }
}