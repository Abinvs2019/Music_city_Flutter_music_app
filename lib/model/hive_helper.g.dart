// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_helper.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongPlayListAdapter extends TypeAdapter<SongPlayList> {
  @override
  final int typeId = 1;

  @override
  SongPlayList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongPlayList()
      ..songInfo = fields[0] as String
      ..songId = fields[1] as int;
  }

  @override
  void write(BinaryWriter writer, SongPlayList obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.songInfo)
      ..writeByte(1)
      ..write(obj.songId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongPlayListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
