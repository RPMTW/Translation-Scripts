// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_source_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectSourceTypeAdapter extends TypeAdapter<ProjectSourceType> {
  @override
  final int typeId = 3;

  @override
  ProjectSourceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProjectSourceType.curseforge;
      case 1:
        return ProjectSourceType.modrinth;
      case 2:
        return ProjectSourceType.github;
      default:
        return ProjectSourceType.curseforge;
    }
  }

  @override
  void write(BinaryWriter writer, ProjectSourceType obj) {
    switch (obj) {
      case ProjectSourceType.curseforge:
        writer.writeByte(0);
        break;
      case ProjectSourceType.modrinth:
        writer.writeByte(1);
        break;
      case ProjectSourceType.github:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectSourceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
