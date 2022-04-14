// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ModMetadataAdapter extends TypeAdapter<ModMetadata> {
  @override
  final int typeId = 4;

  @override
  ModMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ModMetadata(
      id: fields[0] as String,
      name: fields[1] as String,
      version: fields[2] as String,
      type: fields[3] as ModMetadataType,
      source: fields[4] as ProjectSource,
    );
  }

  @override
  void write(BinaryWriter writer, ModMetadata obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.version)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.source);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
