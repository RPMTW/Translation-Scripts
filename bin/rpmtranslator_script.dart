import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';
import 'package:rpmtw_translation_scripts/src/commands/curseforge_command.dart';
import 'package:rpmtw_translation_scripts/src/commands/upgrade_command.dart';
import 'package:rpmtw_translation_scripts/src/data/rpmtw_data.dart';

late String gameVersion;

void main(List<String> arguments) async {
  print('Hello RPMTW World!');
  RPMTWApiClient.init();
  RPMTWApiClient client = RPMTWApiClient.instance;

  try {
    CommandRunner runner = CommandRunner(
        'rpmtranslator_script', 'RPMTranslator server script');
    runner.addCommand(CurseForgeCommand());
    runner.addCommand(UpgradeCommand());

    runner.argParser.addOption('gameVersion',
        defaultsTo: RPMTWData.gameVersions.last,
        help: "The game version to use.", callback: (value) {
      gameVersion = value!;
    }, allowed: RPMTWData.gameVersions);

    await runner.run(arguments);
  } on UsageException catch (e) {
    print('[Error] ${e.toString()}');
    exit(64);
  } catch (e) {
    print('Unknown exception: $e');
    exit(1);
  }
  print("Bye!");
  exit(0);
}
