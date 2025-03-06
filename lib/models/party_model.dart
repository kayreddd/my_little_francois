import 'package:hive/hive.dart';
import 'riding_lesson_model.dart';

part 'party_model.g.dart';

@HiveType(typeId: 11)
class Party extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String? imageUrl;

  @HiveField(5)
  int creatorId;

  @HiveField(6)
  List<PartyParticipant> participants;

  @HiveField(7)
  PartyType type;

  @HiveField(8)
  ApprovalStatus approvalStatus;

  @HiveField(9)
  String? rejectionReason;

  Party({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
    required this.creatorId,
    List<PartyParticipant>? participants,
    required this.type,
    this.approvalStatus = ApprovalStatus.pending,
    this.rejectionReason,
  }) : participants = participants ?? [];

  // Ajouter un participant
  void addParticipant(PartyParticipant participant) {
    if (!participants.any((p) => p.userId == participant.userId)) {
      participants.add(participant);
    }
  }

  // Supprimer un participant
  void removeParticipant(int userId) {
    participants.removeWhere((p) => p.userId == userId);
  }

  // Vérifier si un utilisateur participe déjà
  bool isParticipating(int userId) {
    return participants.any((p) => p.userId == userId);
  }
}

@HiveType(typeId: 12)
class PartyParticipant extends HiveObject {
  @HiveField(0)
  int userId;

  @HiveField(1)
  String username;

  @HiveField(2)
  String? contribution;

  @HiveField(3)
  DateTime joinedAt;

  PartyParticipant({
    required this.userId,
    required this.username,
    this.contribution,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();
}

@HiveType(typeId: 13)
enum PartyType {
  @HiveField(0)
  aperitif,

  @HiveField(1)
  dinner,

  @HiveField(2)
  other
}

// Réutilisation de l'énumération ApprovalStatus définie dans riding_lesson_model.dart
