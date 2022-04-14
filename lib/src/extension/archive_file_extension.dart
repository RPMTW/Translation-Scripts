import 'dart:convert';

import 'package:archive/archive.dart';

extension ArchiveFileExtension on ArchiveFile {
  String readAsString() {
    Utf8Decoder decoder = Utf8Decoder(allowMalformed: true);
    return decoder.convert(content as List<int>);
  }
}
