import 'package:hive/hive.dart';

part 'competition_model.g.dart';

@HiveType(typeId: 8)
enum CompetitionLevel {
  @HiveField(0)
  amateur,
  @HiveField(1)
  club1,
  @HiveField(2)
  club2,
  @HiveField(3)
  club3,
  @HiveField(4)
  club4
}

@HiveType(typeId: 9)
class CompetitionParticipant extends HiveObject {
  @HiveField(0)
  final int userId;

  @HiveField(1)
  final CompetitionLevel level;

  CompetitionParticipant({
    required this.userId,
    required this.level,
  });

  CompetitionParticipant copyWith({
    int? userId,
    CompetitionLevel? level,
  }) {
    return CompetitionParticipant(
      userId: userId ?? this.userId,
      level: level ?? this.level,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'level': level.toString(),
    };
  }
}

@HiveType(typeId: 10)
class Competition extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? photoUrl;

  @HiveField(5)
  final List<CompetitionParticipant> participants;

  @HiveField(6)
  final int creatorId; // ID de l'utilisateur qui a créé le concours

  Competition({
    this.id,
    required this.name,
    required this.address,
    required this.date,
    this.photoUrl,
    required this.participants,
    required this.creatorId,
  });

  Competition copyWith({
    int? id,
    String? name,
    String? address,
    DateTime? date,
    String? photoUrl,
    List<CompetitionParticipant>? participants,
    int? creatorId,
  }) {
    return Competition(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      date: date ?? this.date,
      photoUrl: photoUrl ?? this.photoUrl,
      participants: participants ?? this.participants,
      creatorId: creatorId ?? this.creatorId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'date': date.toIso8601String(),
      'photoUrl': photoUrl,
      'participants': participants.map((p) => p.toMap()).toList(),
      'creatorId': creatorId,
    };
  }

  // Méthode pour ajouter un participant
  Competition addParticipant(CompetitionParticipant participant) {
    // Vérifier si l'utilisateur est déjà inscrit
    final existingIndex = participants.indexWhere((p) => p.userId == participant.userId);
    
    if (existingIndex != -1) {
      // Mettre à jour le niveau du participant existant
      final updatedParticipants = [...participants];
      updatedParticipants[existingIndex] = participant;
      return copyWith(participants: updatedParticipants);
    } else {
      // Ajouter un nouveau participant
      return copyWith(participants: [...participants, participant]);
    }
  }

  // Méthode pour supprimer un participant
  Competition removeParticipant(int userId) {
    return copyWith(
      participants: participants.where((p) => p.userId != userId).toList(),
    );
  }
}
