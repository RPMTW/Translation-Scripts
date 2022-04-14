import 'dart:io';

import 'package:path/path.dart';

class PathUtil {
  static Directory getRootDir() {
    return Directory.current;
  }

  static Directory getTempDir() {
    return Directory.systemTemp;
  }

  static Directory getDatabaseDir() {
    return Directory(join(getRootDir().path, 'db'));
  }

  static File getTempFile(String name) {
    DateTime now = DateTime.now();
    return File(join(getTempDir().path, 'rpmtw', 'translation_scripts',
        '${now.millisecondsSinceEpoch}_$name'));
  }
}
