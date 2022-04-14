import 'package:hive/hive.dart';
import 'package:json5/json5.dart';
import 'package:rpmtranslator_script/src/model/mod_metadata_type.dart';
import 'package:rpmtranslator_script/src/model/project_source.dart';
import 'package:toml/toml.dart';
part 'mod_metadata.g.dart';

@HiveType(typeId: 4)
class ModMetadata extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String version;
  @HiveField(3)
  final ModMetadataType type;
  @HiveField(4)
  final ProjectSource source;
  ModMetadata({
    required this.id,
    required this.name,
    required this.version,
    required this.type,
    required this.source,
  });

  ModMetadata copyWith({
    String? id,
    String? name,
    String? version,
    ModMetadataType? type,
    ProjectSource? source,
  }) {
    return ModMetadata(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      type: type ?? this.type,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'type': type.name,
      'source': source.toMap(),
    };
  }

  factory ModMetadata.fromMap(Map<String, dynamic> map) {
    return ModMetadata(
      id: map['id'],
      name: map['name'],
      version: map['version'],
      type: ModMetadataType.values.byName(map['type']),
      source: ProjectSource.fromMap(map['source']),
    );
  }

  @override
  String toString() {
    return 'ModMetadata(id: $id, name: $name, version: $version, type: $type, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ModMetadata &&
        other.id == id &&
        other.name == name &&
        other.version == version &&
        other.type == type &&
        other.source == source;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        version.hashCode ^
        type.hashCode ^
        source.hashCode;
  }

  factory ModMetadata.fromLegacyForge(String str, ProjectSource source) {
    dynamic json = JSON5.parse(str);
    Map meta;
    try {
      meta = json[0];
    } catch (e) {
      meta = json["modList"][0];
    }

    return ModMetadata(
        id: meta['modid'],
        name: meta['name'],
        version: meta['version'],
        type: ModMetadataType.legacyForge,
        source: source);
  }

  factory ModMetadata.fromForge(String str, ProjectSource source) {
    Map meta = TomlDocument.parse(str).toMap()['mods'][0];

    return ModMetadata(
        id: meta['modId'],
        name: meta['displayName'],
        version: meta['version'],
        type: ModMetadataType.forge,
        source: source);
  }

  factory ModMetadata.fromFabric(String str, ProjectSource source) {
    Map meta = JSON5.parse(str);

    return ModMetadata(
        id: meta['id'],
        name: meta['name'],
        version: meta['version'],
        type: ModMetadataType.fabric,
        source: source);
  }
}
