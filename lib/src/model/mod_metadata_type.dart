import 'package:hive/hive.dart';
part 'mod_metadata_type.g.dart';

@HiveType(typeId: 1)
enum ModMetadataType {
  /// The metadata used by forge versions 1.7 -> 1.12.2.
  @HiveField(0)
  legacyForge,

  /// The metadata used by forge versions 1.13 or higher.
  @HiveField(1)
  forge,

  /// The metadata used by fabric mod loader.
  @HiveField(2)
  fabric
}

extension ModMetadataExtension on ModMetadataType {
  String get fileName {
    switch (this) {
      case ModMetadataType.legacyForge:
        return "mcmod.info";
      case ModMetadataType.forge:
        return "META-INF/mods.toml";
      case ModMetadataType.fabric:
        return "fabric.mod.json";
    }
  }
}
