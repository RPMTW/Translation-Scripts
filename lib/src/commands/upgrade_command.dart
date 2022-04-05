import 'package:args/command_runner.dart';

class UpgradeCommand extends Command {
  @override
  String get name => "upgrade";

  @override
  String get description => "Upgrades all source files.";

  UpgradeCommand();

  @override
  void run() {
    print(argResults?.arguments);
  }
}
