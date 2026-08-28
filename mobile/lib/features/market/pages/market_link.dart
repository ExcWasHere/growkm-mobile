import 'package:url_launcher/url_launcher.dart';

Future<bool> openExternalLink(String? url) async {
  if (url == null || url.trim().isEmpty) return false;
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}