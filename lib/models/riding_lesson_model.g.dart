// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riding_lesson_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RidingLessonAdapter extends TypeAdapter<RidingLesson> {
  @override
  final int typeId = 7;

  @override
  RidingLesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RidingLesson(
      id: fields[0] as int?,
      userId: fields[1] as int,
      horseId: fields[2] as int?,
      dateTime: fields[3] as DateTime,
      trainingGround: fields[4] as TrainingGround,
      duration: fields[5] as LessonDuration,
      discipline: fields[6] as Discipline,
      notes: fields[7] as String?,
      approvalStatus: fields[8] as ApprovalStatus,
      rejectionReason: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RidingLesson obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.horseId)
      ..writeByte(3)
      ..write(obj.dateTime)
      ..writeByte(4)
      ..write(obj.trainingGround)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.discipline)
      ..writeByte(7)
      ..write(obj.notes)
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
      other is RidingLessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TrainingGroundAdapter extends TypeAdapter<TrainingGround> {
  @override
  final int typeId = 4;

  @override
  TrainingGround read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TrainingGround.arena;
      case 1:
        return TrainingGround.outdoorArena;
      default:
        return TrainingGround.arena;
    }
  }

  @override
  void write(BinaryWriter writer, TrainingGround obj) {
    switch (obj) {
      case TrainingGround.arena:
        writer.writeByte(0);
        break;
      case TrainingGround.outdoorArena:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingGroundAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonDurationAdapter extends TypeAdapter<LessonDuration> {
  @override
  final int typeId = 5;

  @override
  LessonDuration read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LessonDuration.thirtyMinutes;
      case 1:
        return LessonDuration.oneHour;
      default:
        return LessonDuration.thirtyMinutes;
    }
  }

  @override
  void write(BinaryWriter writer, LessonDuration obj) {
    switch (obj) {
      case LessonDuration.thirtyMinutes:
        writer.writeByte(0);
        break;
      case LessonDuration.oneHour:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonDurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DisciplineAdapter extends TypeAdapter<Discipline> {
  @override
  final int typeId = 6;

  @override
  Discipline read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Discipline.dressage;
      case 1:
        return Discipline.jumpingObstacles;
      case 2:
        return Discipline.endurance;
      default:
        return Discipline.dressage;
    }
  }

  @override
  void write(BinaryWriter writer, Discipline obj) {
    switch (obj) {
      case Discipline.dressage:
        writer.writeByte(0);
        break;
      case Discipline.jumpingObstacles:
        writer.writeByte(1);
        break;
      case Discipline.endurance:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisciplineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ApprovalStatusAdapter extends TypeAdapter<ApprovalStatus> {
  @override
  final int typeId = 14;

  @override
  ApprovalStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ApprovalStatus.pending;
      case 1:
        return ApprovalStatus.approved;
      case 2:
        return ApprovalStatus.rejected;
      default:
        return ApprovalStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, ApprovalStatus obj) {
    switch (obj) {
      case ApprovalStatus.pending:
        writer.writeByte(0);
        break;
      case ApprovalStatus.approved:
        writer.writeByte(1);
        break;
      case ApprovalStatus.rejected:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApprovalStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
