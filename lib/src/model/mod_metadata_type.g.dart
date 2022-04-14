// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_metadata_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ModMetadataTypeAdapter extends TypeAdapter<ModMetadataType> {
  @override
  final int typeId = 1;

  @override
  ModMetadataType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ModMetadataType.legacyForge;
      case 1:
        return ModMetadataType.forge;
      case 2:
        return ModMetadataType.fabric;
      default:
        return ModMetadataType.legacyForge;
    }
  }

  @override
  void write(BinaryWriter writer, ModMetadataType obj) {
    switch (obj) {
      case ModMetadataType.legacyForge:
        writer.writeByte(0);
        break;
      case ModMetadataType.forge:
        writer.writeByte(1);
        break;
      case ModMetadataType.fabric:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModMetadataTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
