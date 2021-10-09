import '../Models/ModInfo.dart';
import 'DownloadModLangFile.dart';

class UpdateLang {
  static final String route = "update_lang";

  static Future<void> run() async {
    int _doneCount = 1;

    for (String modID in ModInfos().keys) {
      ModInfo modInfo = ModInfos()[modID]!;
      try {
        _doneCount++;
        print("[ $_doneCount/${ModInfos().keys.length} ] 更新語系檔案中...");
        await DownloadModLangFile.run(modInfo.curseForgeID);
      } catch (e) {
        print("[${modInfo.curseForgeID}] 更新語系檔案時發生未知錯誤\n$e");
      }
    }
  }
}
