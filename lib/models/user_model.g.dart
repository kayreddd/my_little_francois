// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as int?,
      username: fields[1] as String,
      password: fields[2] as String,
      email: fields[3] as String,
      profilePicturePath: fields[4] as String?,
      phoneNumber: fields[5] as String?,
      age: fields[6] as int?,
      ffeProfileLink: fields[7] as String?,
      isDelegatedPerson: fields[8] as bool,
      ownedHorseIds: (fields[9] as List?)?.cast<int>(),
      associatedHorseIds: (fields[10] as List?)?.cast<int>(),
      isAdmin: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.profilePicturePath)
      ..writeByte(5)
      ..write(obj.phoneNumber)
      ..writeByte(6)
      ..write(obj.age)
      ..writeByte(7)
      ..write(obj.ffeProfileLink)
      ..writeByte(8)
      ..write(obj.isDelegatedPerson)
      ..writeByte(9)
      ..write(obj.ownedHorseIds)
      ..writeByte(10)
      ..write(obj.associatedHorseIds)
      ..writeByte(11)
      ..write(obj.isAdmin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
