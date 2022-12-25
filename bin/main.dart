import 'dart:io';

import 'package:args/args.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';

import 'Actions/DownloadModLangFile.dart';
import 'Actions/DownloadModPack.dart';
import 'Actions/JsonToLang.dart';
import 'Actions/Spider.dart';
import 'Actions/UpdateLang.dart';
import 'function/RPMTWData.dart';
import 'models/mod_infos.dart';

late String gameVersion;
final modInfos = ModInfos();

void main(List<String> arguments) async {
  print('Hello RPMTW World!');
  await modInfos.init();
  ArgParser parser = ArgParser();

  /// 執行腳本所使用的遊戲版本
  parser.addOption('gameVersion', callback: (value) {
    gameVersion = value!;
  }, allowed: RPMTWData.gameVersions, mandatory: true);

  parser.addMultiOption(
    'action',
    callback: (action) async {
      String actionName = action[0];
      String? actionArgs = action.length > 1 ? action[1] : null;
      if (actionName == DownloadModLangFile.route) {
        if (int.tryParse(actionArgs!) == null) {
          print('Invalid CurseForge Mod ID');
          return;
        }

        await DownloadModLangFile.run(int.parse(actionArgs))
            .then((value) => exit(0));
      } else if (actionName == Spider.route) {
        if (int.tryParse(actionArgs!) == null) {
          print('Invalid Mod Conut');
          return;
        }

        await Spider.run(int.parse(actionArgs)).then((value) => exit(0));
      } else if (actionName == JsonToLang.route) {
        await JsonToLang.run().then((value) => exit(0));
      } else if (actionName == DownloadModPack.route) {
        if (int.tryParse(actionArgs!) == null) {
          print('Invalid CurseForge ModPack ID');
          return;
        }

        await DownloadModPack.run(int.parse(actionArgs))
            .then((value) => exit(0));
      } else if (actionName == UpdateLang.route) {
        await UpdateLang.run().then((value) => exit(0));
      }
    },
  );

  RPMTWApiClient.init();
  parser.parse(arguments);
}
