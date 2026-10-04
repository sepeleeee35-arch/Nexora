import 'dart:io';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:path_provider/path_provider.dart';

class NexoraUpdateInstaller {
  static Future<void> downloadAndInstall(String url) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) throw Exception('Download APK gagal (${response.statusCode}).');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Nexora-update.apk');
      if (await file.exists()) await file.delete();
      final sink = file.openWrite();
      await response.pipe(sink);
      await sink.flush();
      await sink.close();
      await FlutterAppInstaller().installApk(filePath: file.path);
    } finally {
      client.close(force: true);
    }
  }
}
