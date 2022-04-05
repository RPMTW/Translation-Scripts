import 'package:args/command_runner.dart';

class CurseForgeCommand extends Command {
  @override
  String get name => "curseforge";

  @override
  String get description => "Downloads a curseforge project source files.";

  CurseForgeCommand() {
    argParser.addOption('type',
        help: 'Type of the curseforge project to download',
        abbr: 't',
        mandatory: true,
        allowed: CurseForgeProjectType.values.map((e) => e.name));
  }

  @override
  void run() {
    CurseForgeProjectType type =
        CurseForgeProjectType.values.byName(argResults?['type']);

    print(type);
  }
}

enum CurseForgeProjectType {
  mod,
  modpack,
}
