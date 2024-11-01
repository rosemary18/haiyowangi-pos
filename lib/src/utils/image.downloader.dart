import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> downloadImage(String url, String filename) async {

  final downloadsDirectory = await getApplicationDocumentsDirectory();

  final taskId = await FlutterDownloader.enqueue(
    url: url,
    savedDir: downloadsDirectory.path,
    fileName: filename,
    showNotification: false,
    openFileFromNotification: false,
    saveInPublicStorage: false
  );

  return taskId;
}