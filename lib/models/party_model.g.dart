// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PartyAdapter extends TypeAdapter<Party> {
  @override
  final int typeId = 11;

  @override
  Party read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Party(
      id: fields[0] as int?,
      title: fields[1] as String,
      description: fields[2] as String,
      date: fields[3] as DateTime,
      imageUrl: fields[4] as String?,
      creatorId: fields[5] as int,
      participants: (fields[6] as List?)?.cast<PartyParticipant>(),
      type: fields[7] as PartyType,
      approvalStatus: fields[8] as ApprovalStatus,
      rejectionReason: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Party obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.creatorId)
      ..writeByte(6)
      ..write(obj.participants)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.approvalStatus)
      ..writeByte(9)
      ..write(obj.rejectionReason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PartyParticipantAdapter extends TypeAdapter<PartyParticipant> {
  @override
  final int typeId = 12;

  @override
  PartyParticipant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PartyParticipant(
      userId: fields[0] as int,
      username: fields[1] as String,
      contribution: fields[2] as String?,
      joinedAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PartyParticipant obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.contribution)
      ..writeByte(3)
      ..write(obj.joinedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartyParticipantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PartyTypeAdapter extends TypeAdapter<PartyType> {
  @override
  final int typeId = 13;

  @override
  PartyType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PartyType.aperitif;
      case 1:
        return PartyType.dinner;
      case 2:
        return PartyType.other;
      default:
        return PartyType.aperitif;
    }
  }

  @override
  void write(BinaryWriter writer, PartyType obj) {
    switch (obj) {
      case PartyType.aperitif:
        writer.writeByte(0);
        break;
      case PartyType.dinner:
        writer.writeByte(1);
        break;
      case PartyType.other:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartyTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
