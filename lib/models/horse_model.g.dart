// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horse_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HorseAdapter extends TypeAdapter<Horse> {
  @override
  final int typeId = 1;

  @override
  Horse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Horse(
      id: fields[0] as int?,
      name: fields[1] as String,
      age: fields[2] as int,
      coat: fields[3] as String,
      breed: fields[4] as String,
      gender: fields[5] as String,
      specialty: fields[6] as String,
      photoPath: fields[7] as String?,
      ownerId: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Horse obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.coat)
      ..writeByte(4)
      ..write(obj.breed)
      ..writeByte(5)
      ..write(obj.gender)
      ..writeByte(6)
      ..write(obj.specialty)
      ..writeByte(7)
      ..write(obj.photoPath)
      ..writeByte(8)
      ..write(obj.ownerId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HorseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
