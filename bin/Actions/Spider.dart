import 'package:rpmtw_api_client/rpmtw_api_client.dart';

import '../main.dart';
import 'DownloadModLangFile.dart';

class Spider {
  static final String route = "spider";

  static Future<void> run(int modConut) async {
    final RPMTWApiClient client = RPMTWApiClient.instance;
    final int _index = (modConut / 50).ceil();

    for (int i = 0; i < _index; i++) {
      try {
        List<CurseForgeMod> mods = await client.curseforgeResource.searchMods(
            game: CurseForgeGames.minecraft,
            gameVersion: gameVersion,
            index: i * 50,
            sortField: CurseForgeSortField.popularity,
            pageSize: _index == (i + 1) ? modConut % 50 : 50);

        for (CurseForgeMod mod in mods) {
          await DownloadModLangFile.run(mod.id);
        }
      } catch (e) {
        print("抓取模組時發生未知錯誤\n$e");
      }
    }
  }
}
