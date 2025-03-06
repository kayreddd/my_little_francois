import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final int? id;
  
  @HiveField(1)
  final String username;
  
  @HiveField(2)
  final String password;
  
  @HiveField(3)
  final String email;
  
  @HiveField(4)
  final String? profilePicturePath;
  
  @HiveField(5)
  final String? phoneNumber;
  
  @HiveField(6)
  final int? age;
  
  @HiveField(7)
  final String? ffeProfileLink; // Lien vers le profil FFE
  
  @HiveField(8)
  final bool isDelegatedPerson; // DP = Personne Déléguée
  
  @HiveField(9)
  final List<int>? ownedHorseIds; // IDs des chevaux dont l'utilisateur est propriétaire
  
  @HiveField(10)
  final List<int>? associatedHorseIds; // IDs des chevaux associés à l'utilisateur (pour les DP)
  
  @HiveField(11)
  final bool isAdmin; // Indique si l'utilisateur est un administrateur
  
  @HiveField(12)
  final bool isStableManager; // Indique si l'utilisateur est un gérant des écuries

  User({
    this.id,
    required this.username,
    required this.password,
    required this.email,
    this.profilePicturePath,
    this.phoneNumber,
    this.age,
    this.ffeProfileLink,
    this.isDelegatedPerson = false,
    this.ownedHorseIds,
    this.associatedHorseIds,
    this.isAdmin = false,
    this.isStableManager = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'profilePicturePath': profilePicturePath,
      'phoneNumber': phoneNumber,
      'age': age,
      'ffeProfileLink': ffeProfileLink,
      'isDelegatedPerson': isDelegatedPerson,
      'ownedHorseIds': ownedHorseIds,
      'associatedHorseIds': associatedHorseIds,
      'isAdmin': isAdmin,
      'isStableManager': isStableManager,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      email: map['email'],
      profilePicturePath: map['profilePicturePath'],
      phoneNumber: map['phoneNumber'],
      age: map['age'],
      ffeProfileLink: map['ffeProfileLink'],
      isDelegatedPerson: map['isDelegatedPerson'] ?? false,
      ownedHorseIds: map['ownedHorseIds'] != null ? List<int>.from(map['ownedHorseIds']) : null,
      associatedHorseIds: map['associatedHorseIds'] != null ? List<int>.from(map['associatedHorseIds']) : null,
      isAdmin: map['isAdmin'] ?? false,
      isStableManager: map['isStableManager'] ?? false,
    );
  }
  
  // Crée une copie de l'objet avec les champs spécifiés mis à jour
  User copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    String? profilePicturePath,
    String? phoneNumber,
    int? age,
    String? ffeProfileLink,
    bool? isDelegatedPerson,
    List<int>? ownedHorseIds,
    List<int>? associatedHorseIds,
    bool? isAdmin,
    bool? isStableManager,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      ffeProfileLink: ffeProfileLink ?? this.ffeProfileLink,
      isDelegatedPerson: isDelegatedPerson ?? this.isDelegatedPerson,
      ownedHorseIds: ownedHorseIds ?? this.ownedHorseIds,
      associatedHorseIds: associatedHorseIds ?? this.associatedHorseIds,
      isAdmin: isAdmin ?? this.isAdmin,
      isStableManager: isStableManager ?? this.isStableManager,
    );
  }
}
