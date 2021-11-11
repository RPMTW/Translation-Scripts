import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart';

import '../Data/MinecraftVanillaLang.dart';
import '../main.dart';
import 'PathUttily.dart';

class LangUttily {
  /// Lang轉換為Json格式，由 https://gist.github.com/ChAoSUnItY/31c147efd2391b653b8cc12da9699b43 修改並移植而成
  /// 特別感謝3X0DUS - ChAoS#6969 編寫此function。
  static Map<String, String> oldLangToMap(String source) {
    Map<String, String> obj = {};

    String? lastKey;

    for (String line in LineSplitter().convert(source)) {
      if (line.startsWith("#") ||
          line.startsWith("//") ||
          line.startsWith("!")) {
        continue;
      }
      if (line.contains("=")) {
        if (line.split("=").length == 2) {
          List<String> kv = line.split("=");
          lastKey = kv[0];

          obj[kv[0]] = kv[1].trimLeft();
        } else {
          if (lastKey == null) continue;
          obj[lastKey] = "${obj[lastKey]}\n$line";
        }
      } else if (!line.contains("=")) {
        if (lastKey == null) continue;
        if (line == "") continue;

        obj[lastKey] = "${obj[lastKey]}\n$line";
      }
    }
    return obj;
  }

  static String oldLangToJson(String source) {
    Map obj = oldLangToMap(source);
    return json.encode(obj);
  }

  static String jsonToOldLang(Map json) {
    List<String> jsonKeys = json.keys.toList().cast<String>();
    String _lang = "";
    for (int i = 0; i < jsonKeys.length; i++) {
      if (jsonKeys[i].startsWith("_comment_")) {
        _lang += "#${json[jsonKeys[i]]}\n";
      } else {
        _lang += "${jsonKeys[i]}=${json[jsonKeys[i]]}\n";
      }
    }
    return _lang;
  }

  static Future<void> write(String modID, String englishLang) async {
    Map<String, String> langMap = {};
    File chineseLang = PathUttily().getChineseLangFile(modID);
    late Map<String, String> englishLangMap;

    /// 由於 1.12 使用舊版語系檔案格式
    if (gameVersion == "1.12") {
      englishLangMap = oldLangToMap(englishLang);
    } else {
      englishLangMap = json.decode(englishLang).cast<String, String>();
    }

    /// 假設先前已經存在語系檔案就新增回去
    if (await chineseLang.exists()) {
      langMap.addAll(json.decode(await chineseLang.readAsString()));
    }

    /// 新增英文語系檔案的內容
    langMap.addAll(englishLangMap);

    /// 防呆處理：假設語系檔案為空
    if (langMap.isEmpty) return;

    /// 防呆處理：修改原版語系檔案
    langMap.removeWhere((key, value) => minecraftVanillaLang.keys.any((e) => e == key));

    PathUttily().getChineseLangFile(modID)
      ..createSync(recursive: true)
      ..writeAsStringSync(JsonEncoder.withIndent('    ').convert(langMap));
  }

  static Future<bool> writePatchouliBooks(Archive archive, String modID) async {
    bool isPatchouliBooks = false;
    bool isI18n = false;
    Map<String, void> bookNames = {};
    List<ArchiveFile> files = [];
    for (ArchiveFile file in archive) {
      String fileName = file.name;

      /// 1.14+ 使用 data 作為儲存 Patchouli 手冊位置 ，1.14 以下版本使用 assets 儲存 Patchouli 手冊位置
      if (fileName.startsWith("data/$modID/patchouli_books") ||
          fileName.startsWith("assets/$modID/patchouli_books")) {
        /// 如果是檔案才處理
        if (file.isFile) {
          isPatchouliBooks = true;
          bookNames.addAll({
            fileName.split("/").sublist(3)[0]: null,
          });
          files.add(file);
        }
      }
    }

    for (String bookName in bookNames.keys) {
      try {
        ArchiveFile bookConfigFile = files.firstWhere((f) {
          List<String> _ = f.name.split("/").sublist(3);

          try {
            return _[1] == "book.json" && _[0] == bookName;
          } catch (e) {
            return false;
          }
        });

        Map bookConfig = json.decode(Utf8Decoder(allowMalformed: true)
            .convert(bookConfigFile.content as List<int>));

        isI18n = bookConfig['i18n'] ?? false;
      } catch (e) {
        if (isPatchouliBooks) {
          print("[ $modID - $bookName | wrong ] 找不到手冊資訊檔案\n$e");
        }
      }

      if (isI18n) {
        print("[ $modID - $bookName | info ] 由於此模組手冊內容被偵測到不需翻譯，因此略過新增");
        Directory _booksDir = Directory(join(
            PathUttily().getPatchouliBooksDirectory(modID).path, bookName));

        if (_booksDir.existsSync()) {
          _booksDir.deleteSync(recursive: true);
        }
      } else {
        for (ArchiveFile file in files) {
          String fileName = file.name;
          Directory patchouliBooksDir =
              PathUttily().getPatchouliBooksDirectory(modID);

          /// assets/[modID]/patchouli_books/[BookName]/[Lang_Code]/......

          List<String> _allPath = [patchouliBooksDir.path];
          List<String> _bookPath =
              split(fileName.split("/").sublist(3).join("/"));

          if (_bookPath[0] != bookName) continue;

          try {
            if (_bookPath[2] == "templates") continue;
          } catch (e) {}

          if (_bookPath[1] == "en_us") {
            /// 將 en_us 換成 zh_tw
            _bookPath[1] = "zh_tw";
          } else {
            continue;
          }

          _allPath.addAll(_bookPath);

          File(joinAll(_allPath))
            ..createSync(recursive: true)
            ..writeAsBytesSync(file.content as List<int>);
        }
      }
    }

    return isPatchouliBooks;
  }
}
