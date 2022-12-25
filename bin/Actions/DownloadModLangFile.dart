import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';

import '../mod/mod_info.dart';
import '../mod/ModMetadata.dart';
import '../function/LangUttily.dart';
import '../function/extension.dart';
import '../main.dart';

enum ModMetadataTypes {
  /// Forge 1.7 -> 1.12.2 所使用的模組資訊檔案
  forge112,

  /// Forge 1.13 -> 1.17.1 所使用的模組資訊檔案
  forge113,

  /// Fabric 所使用的模組資訊檔案
  fabric
}

extension ModMetadataExtension on ModMetadataTypes {
  String get fileName {
    switch (this) {
      case ModMetadataTypes.forge112:
        return "mcmod.info";
      case ModMetadataTypes.forge113:
        return "META-INF/mods.toml";
      case ModMetadataTypes.fabric:
        return "fabric.mod.json";
    }
  }
}

class DownloadModLangFile {
  static final String route = "download_mod";

  static Future<void> run(int curseForgeID, {int? fileID}) async {
    print("[ $curseForgeID | 1/3 ] 解析模組資訊中...");
    final RPMTWApiClient client = RPMTWApiClient.instance;
    final CurseForgeMod mod =
        await client.curseforgeResource.getMod(curseForgeID);

    int? modFileId;
    try {
      modFileId = fileID ??
          mod.latestFilesIndexes
              .where((e) => e.gameVersion.contains(gameVersion))
              .first
              .fileId;
    } catch (e) {
      modFileId = null;
    }

    if (modFileId == null) {
      print("[$curseForgeID | error ] 在 CurseForge 找不到符合此版本的語系檔案");
      return;
    }

    CurseForgeModFile file =
        await client.curseforgeResource.getModFile(curseForgeID, modFileId);
    Archive? archive = await file.downloadToArchive();

    if (archive != null) {
      /// 處理模組資訊檔案
      try {
        ModMetadata? data = _getModMetadata(archive);
        if (data != null) {
          await modInfos.setItem(
              data.modID, ModInfo(curseForgeID, DateTime.now(), data.modID));
          print("[ $curseForgeID | 2/4 ] 解析模組資訊檔案成功");
        } else {
          print("[ $curseForgeID | wrong ] 找不到模組資訊檔案");
        }
      } catch (e) {
        print("[ $curseForgeID | error ] 解析模組資訊檔案時發生未知錯誤\n$e");
      }

      /// 處理模組語系檔案與手冊
      try {
        List<String> modIDList = _getHasLangMod(archive);
        for (String modID in modIDList) {
          if (modID == "minecraft") continue;

          Future<void> _runLangWrite(ArchiveFile file) async {
            await LangUttily.write(
                modID,
                Utf8Decoder(allowMalformed: true)
                    .convert(file.content as List<int>));
          }

          ArchiveFile? newEnglishLangFile =
              archive.findFile("assets/$modID/lang/en_us.json");
          ArchiveFile? englishLangFile1 =
              archive.findFile("assets/$modID/lang/en_us.lang");
          ArchiveFile? englishLangFile2 =
              archive.findFile("assets/$modID/lang/en_US.lang");

          if (newEnglishLangFile != null) {
            await _runLangWrite(newEnglishLangFile);
          } else if (englishLangFile1 != null) {
            await _runLangWrite(englishLangFile1);
          } else if (englishLangFile2 != null) {
            await _runLangWrite(englishLangFile2);
          }

          await LangUttily.writePatchouliBooks(archive, modID).then((value) {
            if (value) {
              print("[ $curseForgeID | other ] 處理 [$modID] 的 Patchouli 手冊完成");
            }
          });

          print("[ $curseForgeID | 3/3 ] 處理 [$modID] 的語系檔案完成");
        }
      } catch (e, stack) {
        print("[ $curseForgeID | error ] 解析模組語系時發生未知錯誤\n$e\n$stack");
      }
    } else {
      print("[ $curseForgeID | error ] 解壓縮模組檔案時發生未知錯誤");
    }
  }

  static ModMetadata? _getModMetadata(Archive archive) {
    for (final ArchiveFile f in archive.files) {
      if (f.name == ModMetadataTypes.forge112.fileName) {
        return ModMetadata.fromForge112(f.content as List<int>);
      } else if (f.name == ModMetadataTypes.forge113.fileName) {
        return ModMetadata.fromForge113(f.content as List<int>);
      } else if (f.name == ModMetadataTypes.fabric.fileName) {
        return ModMetadata.fromFabric(f.content as List<int>);
      }
    }
    return null;
  }

  static List<String> _getHasLangMod(Archive archive) {
    List<String> result = [];
    for (final ArchiveFile f in archive.files) {
      String fileName = f.name;
      if (fileName.startsWith('assets') && fileName.contains('lang')) {
        /// assets/[modID]/lang/...
        String modID = fileName.split('/')[1];
        if (result.any((e) => e == modID)) continue;
        result.add(modID);
      }
    }
    return result;
  }
}
