import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

void downloadCallBack(String id, int status, int progress) async {
      
  debugPrint('Download status for task ID $id: $status with progress $progress%');

  // ignore: unrelated_type_equality_checks
  if (status == 3) {
    debugPrint('[!] Download complete!');
    scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text("Download telah selesai, silahkan buka file untuk melihat."),
        backgroundColor: Colors.green,
      ),
    );
  // ignore: unrelated_type_equality_checks
  } else if (status == 4) {
    debugPrint('[!] Download canceled!');
    scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text("Download gagal, silahkan coba lagi."),
        backgroundColor: Colors.red,
      ),
    );
  }
}

startUp() async {

  await initializeDateFormatting('id', null);
  Intl.defaultLocale = 'id_ID';
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await Hive.openBox("storage");
  await getBaseDeviceInfo();

  await FlutterDownloader.initialize(debug: true);
  await FlutterDownloader.registerCallback(downloadCallBack);

}