import 'package:args/command_runner.dart';
import 'package:rpmtw_dart_common_library/rpmtw_dart_common_library.dart';
import 'package:rpmtranslator_script/src/handler/curseforge_handler.dart';

class CurseForgeCommand extends Command {
  @override
  String get name => 'curseforge';

  @override
  String get description => 'Downloads a curseforge project source files.';

  CurseForgeCommand() {
    argParser.addOption('type',
        help: 'Type of the curseforge project to download',
        abbr: 't',
        mandatory: true,
        allowed: CurseForgeProjectType.values.map((e) => e.name));
    argParser.addOption(
      'id',
      help: 'ID of the curseforge project to download',
      abbr: 'i',
      mandatory: true,
    );
  }

  @override
  void run() async {
    CurseForgeProjectType type =
        CurseForgeProjectType.values.byName(argResults?['type']);

    int? id = int.tryParse(argResults?['id']);
    if (id == null) {
      RPMTWLogger.error('Invalid id: ${argResults?['id']}');
      return;
    }
    String version = globalResults?['gameVersion'];

    if (type == CurseForgeProjectType.mod) {
      await CurseForgeHandler.downloadMod(id, version);
    }
  }
}

enum CurseForgeProjectType {
  mod,
  modpack,
}
