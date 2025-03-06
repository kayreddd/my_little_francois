import 'package:hive/hive.dart';
import 'riding_lesson_model.dart';

part 'party_model.g.dart';

@HiveType(typeId: 11)
class Party extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String title; // Titre de la soirée

  @HiveField(2)
  String description; // Description de la soirée

  @HiveField(3)
  DateTime date; // Date et heure de la soirée

  @HiveField(4)
  String? imageUrl; // URL de l'image (optionnel)

  @HiveField(5)
  int creatorId; // ID de l'utilisateur qui a créé la soirée

  @HiveField(6)
  List<PartyParticipant> participants; // Liste des participants

  @HiveField(7)
  PartyType type; // Type de soirée

  @HiveField(8)
  ApprovalStatus approvalStatus; // Statut d'approbation

  @HiveField(9)
  String? rejectionReason; // Raison du refus (si applicable)

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
  int userId; // ID de l'utilisateur participant

  @HiveField(1)
  String username; // Nom d'utilisateur du participant

  @HiveField(2)
  String? contribution; // Ce que le participant apporte à la soirée (optionnel)

  @HiveField(3)
  DateTime joinedAt; // Date à laquelle l'utilisateur a rejoint la soirée

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
  aperitif, // Apéritif

  @HiveField(1)
  dinner, // Dîner

  @HiveField(2)
  other // Autre type de soirée
}
