import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';
import 'package:rpmtranslator_script/src/commands/curseforge_command.dart';
import 'package:rpmtranslator_script/src/commands/upgrade_command.dart';
import 'package:rpmtranslator_script/src/data/rpmtw_data.dart';
import 'package:rpmtw_dart_common_library/rpmtw_dart_common_library.dart';
import 'package:rpmtranslator_script/src/handler/database_handler.dart';

void main(List<String> arguments) async {
  await DatabaseHandler.init();

  try {
    CommandRunner runner =
        CommandRunner('rpmtranslator_script', 'RPMTranslator server script');
    runner.addCommand(CurseForgeCommand());
    runner.addCommand(UpgradeCommand());

    runner.argParser.addFlag('development',
        help:
            'Runs the script in development mode. (will use the local RPMTW API server)',
        defaultsTo: false,
        callback: (value) {});
    runner.argParser.addOption('gameVersion',
        defaultsTo: RPMTWData.gameVersions.last,
        abbr: 'v',
        help: 'The game version to use.',
        allowed: RPMTWData.gameVersions);
    runner.argParser.addOption('rpmtwToken',
        help: 'The token to use for the RPMTW API. This is a required option.',
        mandatory: true);

    if (arguments.contains('help') ||
        arguments.contains('--help') ||
        arguments.contains('-h') ||
        arguments.isEmpty) {
      runner.printUsage();
      exit(0);
    }

    ArgResults results = runner.parse(arguments);
    RPMTWApiClient.init(
        development: results['development']!, token: results['rpmtwToken']!);

    await runner.run(arguments);
  } on UsageException catch (e, stackTrace) {
    RPMTWLogger.error(e.message, stackTrace: stackTrace);
    exit(64);
  } catch (e, stackTrace) {
    RPMTWLogger.error('Unknown exception: $e', stackTrace: stackTrace);
    exit(1);
  }
  exit(0);
}
