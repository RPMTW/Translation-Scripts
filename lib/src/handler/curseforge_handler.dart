import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';
import 'package:rpmtw_dart_common_library/rpmtw_dart_common_library.dart';
import 'package:rpmtranslator_script/src/extension/archive_file_extension.dart';
import 'package:rpmtranslator_script/src/handler/database_handler.dart';
import 'package:rpmtranslator_script/src/model/mod_metadata.dart';
import 'package:rpmtranslator_script/src/model/mod_metadata_type.dart';
import 'package:rpmtranslator_script/src/model/project_source.dart';
import 'package:rpmtranslator_script/src/model/project_source_type.dart';
import 'package:rpmtranslator_script/src/util/path_util.dart';

class CurseForgeHandler {
  static Future<void> downloadMod(int id, String version) async {
    RPMTWApiClient client = RPMTWApiClient.instance;
    RPMTWLogger.info('[$id | 1/6 ] Fetching mod from curseforge');
    CurseForgeMod mod = await client.curseforgeResource.getMod(id);
    String commandPrefix = '${mod.name} (${mod.id})';
    CurseForgeModLatestFilesIndex filesIndex;
    try {
      filesIndex =
          mod.latestFilesIndexes.firstWhere((m) => m.gameVersion == version);
    } catch (e) {
      RPMTWLogger.error('No mod files index found for $version in ${mod.name}');
      return;
    }
    RPMTWLogger.info('[$commandPrefix | 2/6 ] Fetched mod files index');

    CurseForgeModFile file =
        await client.curseforgeResource.getModFile(id, filesIndex.fileId);

    String downloadUrl = file.downloadUrl;
    File modFile = PathUtil.getTempFile("${mod.slug}_${file.id}");

    RPMTWLogger.info('[$commandPrefix | 3/6 ] Downloading mod file');
    await Dio().download(downloadUrl, modFile.absolute.path);

    Archive archive = ZipDecoder().decodeBytes(await modFile.readAsBytes());
    ProjectSource source =
        ProjectSource(type: ProjectSourceType.curseforge, identifier: id);
    ModMetadata? metadata;
    try {
      metadata = _getModMetadata(archive, source);
    } catch (e) {
      RPMTWLogger.error('[$commandPrefix | 4/6 ] Failed to parse mod file');
      return;
    }

    if (metadata == null) {
      RPMTWLogger.warning(
          '[$commandPrefix | 4/6 ] No metadata found in mod file');
      return;
    }

    RPMTWLogger.info('[$commandPrefix | 4/6 ] Parsed mod file');
    await DatabaseHandler.addModMetadata(metadata);

    RPMTWLogger.info('[$commandPrefix | 5/6 ] Handling source files');
    Set<String> namespaces = _getModNamespaces(archive);

    for (String namespace in namespaces) {
      if (namespace.isEmpty || namespace == 'minecraft') {
        continue;
      }

      ListModelResponse<ModSourceInfo> response = await client.translateResource
          .listModSourceInfo(namespace: namespace);

      ModSourceInfo info;
      if (response.data.isNotEmpty) {
        info = response.data.first;
      } else {
        info = await client.translateResource
            .addModSourceInfo(namespace: namespace);
      }

      ArchiveFile? _gsonFile =
          archive.findFile("assets/$namespace/lang/en_us.json");
      ArchiveFile? _langFile =
          archive.findFile("assets/$namespace/lang/en_us.lang");
      ArchiveFile? _langUppercaseFile =
          archive.findFile("assets/$namespace/lang/en_US.lang");

      if (_gsonFile != null) {
        await _addSourceFile(info, _gsonFile, SourceFileType.gsonLang, version);
      } else if (_langFile != null) {
        await _addSourceFile(
            info, _langFile, SourceFileType.minecraftLang, version);
      } else if (_langUppercaseFile != null) {
        await _addSourceFile(
            info, _langUppercaseFile, SourceFileType.minecraftLang, version);
      }
    }

    RPMTWLogger.info('[$commandPrefix | 6/6 ] Finished');
  }

  static ModMetadata? _getModMetadata(Archive archive, ProjectSource source) {
    for (final ArchiveFile f in archive.files) {
      if (f.name == ModMetadataType.legacyForge.fileName) {
        return ModMetadata.fromLegacyForge(f.readAsString(), source);
      } else if (f.name == ModMetadataType.forge.fileName) {
        return ModMetadata.fromForge(f.readAsString(), source);
      } else if (f.name == ModMetadataType.fabric.fileName) {
        return ModMetadata.fromFabric(f.readAsString(), source);
      }
    }

    return null;
  }

  static Set<String> _getModNamespaces(Archive archive) {
    Set<String> result = {};
    for (final ArchiveFile f in archive.files) {
      String filePath = f.name;
      bool prefixMatch =
          filePath.startsWith('assets') || filePath.startsWith('data');
      bool needToAdd =
          filePath.contains('lang') || filePath.contains('patchouli_books');

      /// assets/[modID]/...
      if (prefixMatch && needToAdd) {
        String id = split(filePath)[1];
        result.add(id);
      }
    }
    return result;
  }

  static Future<void> _addSourceFile(ModSourceInfo info, ArchiveFile file,
      SourceFileType type, String version) async {
    RPMTWApiClient client = RPMTWApiClient.instance;
    Storage storage = await client.storageResource
        .createStorageByBytes(Uint8List.fromList(file.content as List<int>));

    List<String> gameVersions = [version];

    client.translateResource.addSourceFile(
        modSourceInfo: info,
        storage: storage,
        path: file.name,
        type: type,
        gameVersions: gameVersions);
  }
}
