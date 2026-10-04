import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'nexora_update_installer.dart';

class NexoraUpdateInfo {
  final String version;
  final String downloadUrl;
  final String notes;
  const NexoraUpdateInfo({required this.version, required this.downloadUrl, required this.notes});
}

class NexoraUpdateService {
  static const _latestReleaseUrl = 'https://api.github.com/repos/sepeleeee35-arch/Nexora/releases/latest';

  static Future<NexoraUpdateInfo?> checkForUpdate() async {
    if (kIsWeb) return null;
    try {
      final info = await PackageInfo.fromPlatform();
      final response = await http.get(Uri.parse(_latestReleaseUrl), headers: const {'Accept': 'application/vnd.github+json'}).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final latest = (data['tag_name'] as String? ?? '').replaceFirst(RegExp(r'^v'), '');
      if (latest.isEmpty || !_isNewer(latest, info.version)) return null;
      final assets = (data['assets'] as List<dynamic>? ?? const []);
      final apk = assets.cast<Map<String, dynamic>>().firstWhere(
        (a) => (a['name'] as String? ?? '').toLowerCase().endsWith('.apk'),
        orElse: () => <String, dynamic>{},
      );
      final url = apk['browser_download_url'] as String? ?? '';
      if (url.isEmpty) return null;
      return NexoraUpdateInfo(version: latest, downloadUrl: url, notes: (data['body'] as String? ?? '').trim());
    } catch (_) {
      return null;
    }
  }

  static bool _isNewer(String latest, String current) {
    List<int> parse(String value) => value.split('+').first.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final a = parse(latest), b = parse(current);
    for (var i = 0; i < 3; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av != bv) return av > bv;
    }
    return false;
  }

  static Future<void> downloadAndInstall(NexoraUpdateInfo update) async {
    await NexoraUpdateInstaller.downloadAndInstall(update.downloadUrl);
  }
}
