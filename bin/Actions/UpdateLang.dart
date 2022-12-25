import '../main.dart';
import '../mod/mod_info.dart';
import 'DownloadModLangFile.dart';

class UpdateLang {
  static final String route = "update_lang";

  static Future<void> run() async {
    int _doneCount = 1;

    final allModInfos = await modInfos.getAll();

    for (String modID in allModInfos.keys) {
      ModInfo modInfo = ModInfo.fromMap(allModInfos[modID]!);
      try {
        _doneCount++;
        if (modInfo.needUpdate) {
          print("[ $_doneCount/${allModInfos.keys.length} ] 更新語系檔案中...");
          await DownloadModLangFile.run(modInfo.curseForgeID);
        }
      } catch (e) {
        print("[${modInfo.curseForgeID}] 更新語系檔案時發生未知錯誤\n$e");
      }
    }
  }
}
