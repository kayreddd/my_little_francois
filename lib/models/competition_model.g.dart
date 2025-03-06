// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competition_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompetitionParticipantAdapter
    extends TypeAdapter<CompetitionParticipant> {
  @override
  final int typeId = 9;

  @override
  CompetitionParticipant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompetitionParticipant(
      userId: fields[0] as int,
      level: fields[1] as CompetitionLevel,
    );
  }

  @override
  void write(BinaryWriter writer, CompetitionParticipant obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.level);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompetitionParticipantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompetitionAdapter extends TypeAdapter<Competition> {
  @override
  final int typeId = 10;

  @override
  Competition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Competition(
      id: fields[0] as int?,
      name: fields[1] as String,
      address: fields[2] as String,
      date: fields[3] as DateTime,
      photoUrl: fields[4] as String?,
      participants: (fields[5] as List).cast<CompetitionParticipant>(),
      creatorId: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Competition obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.photoUrl)
      ..writeByte(5)
      ..write(obj.participants)
      ..writeByte(6)
      ..write(obj.creatorId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompetitionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompetitionLevelAdapter extends TypeAdapter<CompetitionLevel> {
  @override
  final int typeId = 8;

  @override
  CompetitionLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CompetitionLevel.amateur;
      case 1:
        return CompetitionLevel.club1;
      case 2:
        return CompetitionLevel.club2;
      case 3:
        return CompetitionLevel.club3;
      case 4:
        return CompetitionLevel.club4;
      default:
        return CompetitionLevel.amateur;
    }
  }

  @override
  void write(BinaryWriter writer, CompetitionLevel obj) {
    switch (obj) {
      case CompetitionLevel.amateur:
        writer.writeByte(0);
        break;
      case CompetitionLevel.club1:
        writer.writeByte(1);
        break;
      case CompetitionLevel.club2:
        writer.writeByte(2);
        break;
      case CompetitionLevel.club3:
        writer.writeByte(3);
        break;
      case CompetitionLevel.club4:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompetitionLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
