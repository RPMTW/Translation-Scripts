import 'package:hive/hive.dart';
import 'package:rpmtranslator_script/src/model/mod_metadata.dart';
import 'package:rpmtranslator_script/src/model/mod_metadata_type.dart';
import 'package:rpmtranslator_script/src/model/project_source.dart';
import 'package:rpmtranslator_script/src/model/project_source_type.dart';
import 'package:rpmtranslator_script/src/util/path_util.dart';

class DatabaseHandler {
  static late final Box _modMetadataBox;

  static Future<void> init() async {
    Hive.init(PathUtil.getDatabaseDir().path);
    Hive.registerAdapter(ModMetadataAdapter());
    Hive.registerAdapter(ProjectSourceAdapter());
    Hive.registerAdapter(ModMetadataTypeAdapter());
    Hive.registerAdapter(ProjectSourceTypeAdapter());

    _modMetadataBox = await Hive.openBox('mod_metadata');
  }

  static Future<void> addModMetadata(ModMetadata modMetadata) async {
    await _modMetadataBox.add(modMetadata);
  }
}
