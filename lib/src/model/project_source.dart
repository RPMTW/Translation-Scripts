import 'package:hive/hive.dart';
import 'package:rpmtranslator_script/src/model/project_source_type.dart';
part 'project_source.g.dart';

@HiveType(typeId: 2)
class ProjectSource {
  /// unique identifier of source.
  ///
  /// If the source is [ProjectSourceType.curseforge], this is the id of project. (int)
  /// If the source is [ProjectSourceType.modrinth], this is the id of project. (string)
  /// If the source is [ProjectSourceType.github], this is the repository name. (string)
  @HiveField(0)
  final dynamic identifier;

  @HiveField(1)
  final ProjectSourceType type;
  const ProjectSource({
    required this.identifier,
    required this.type,
  });

  ProjectSource copyWith({
    String? identifier,
    ProjectSourceType? type,
  }) {
    return ProjectSource(
      identifier: identifier ?? this.identifier,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier,
      'type': type.name,
    };
  }

  factory ProjectSource.fromMap(Map<String, dynamic> map) {
    return ProjectSource(
      identifier: map['identifier'],
      type: ProjectSourceType.values.byName(map['type']),
    );
  }

  @override
  String toString() => 'ProjectSource(identifier: $identifier, type: $type)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProjectSource &&
        other.identifier == identifier &&
        other.type == type;
  }

  @override
  int get hashCode => identifier.hashCode ^ type.hashCode;
}
