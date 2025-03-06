import 'package:hive/hive.dart';

part 'horse_model.g.dart';

@HiveType(typeId: 1)
class Horse {
  @HiveField(0)
  final int? id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final int age;
  
  @HiveField(3)
  final String coat; // robe
  
  @HiveField(4)
  final String breed; // race
  
  @HiveField(5)
  final String gender; // sexe
  
  @HiveField(6)
  final String specialty; // spécialité (Dressage, Saut d'obstacle, endurance, Complet)
  
  @HiveField(7)
  final String? photoPath;
  
  @HiveField(8)
  final int? ownerId; // ID du propriétaire (si applicable)

  Horse({
    this.id,
    required this.name,
    required this.age,
    required this.coat,
    required this.breed,
    required this.gender,
    required this.specialty,
    this.photoPath,
    this.ownerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'coat': coat,
      'breed': breed,
      'gender': gender,
      'specialty': specialty,
      'photoPath': photoPath,
      'ownerId': ownerId,
    };
  }

  factory Horse.fromMap(Map<String, dynamic> map) {
    return Horse(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      coat: map['coat'],
      breed: map['breed'],
      gender: map['gender'],
      specialty: map['specialty'],
      photoPath: map['photoPath'],
      ownerId: map['ownerId'],
    );
  }
  
  // Crée une copie de l'objet avec les champs spécifiés mis à jour
  Horse copyWith({
    int? id,
    String? name,
    int? age,
    String? coat,
    String? breed,
    String? gender,
    String? specialty,
    String? photoPath,
    int? ownerId,
  }) {
    return Horse(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      coat: coat ?? this.coat,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      specialty: specialty ?? this.specialty,
      photoPath: photoPath ?? this.photoPath,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
