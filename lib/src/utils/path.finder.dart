import 'dart:io';

String getImagePath(Directory? dir, String imageName) {

  String p = "";

  if (dir != null) {
    List<FileSystemEntity> files = dir.listSync();
    for (FileSystemEntity file in files) {
      if (file.path.contains(imageName)) {
        p = file.path;
        break;
      }
    }
  }

  return p;
}