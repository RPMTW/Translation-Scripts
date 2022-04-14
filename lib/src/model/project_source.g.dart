// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_source.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectSourceAdapter extends TypeAdapter<ProjectSource> {
  @override
  final int typeId = 2;

  @override
  ProjectSource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectSource(
      identifier: fields[0] as dynamic,
      type: fields[1] as ProjectSourceType,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectSource obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.identifier)
      ..writeByte(1)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
