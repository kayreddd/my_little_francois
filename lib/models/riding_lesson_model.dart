import 'package:hive/hive.dart';

part 'riding_lesson_model.g.dart';

@HiveType(typeId: 4)
enum TrainingGround {
  @HiveField(0)
  arena, // Manège
  @HiveField(1)
  outdoorArena // Carrière
}

@HiveType(typeId: 5)
enum LessonDuration {
  @HiveField(0)
  thirtyMinutes,
  @HiveField(1)
  oneHour
}

@HiveType(typeId: 6)
enum Discipline {
  @HiveField(0)
  dressage,
  @HiveField(1)
  jumpingObstacles,
  @HiveField(2)
  endurance
}

@HiveType(typeId: 14)
enum ApprovalStatus {
  @HiveField(0)
  pending, // En attente d'approbation
  @HiveField(1)
  approved, // Approuvé
  @HiveField(2)
  rejected // Refusé
}

@HiveType(typeId: 7)
class RidingLesson extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final int userId; // ID de l'utilisateur qui a programmé le cours

  @HiveField(2)
  final int? horseId; // ID du cheval utilisé pour le cours (optionnel)

  @HiveField(3)
  final DateTime dateTime; // Date et heure du cours

  @HiveField(4)
  final TrainingGround trainingGround; // Terrain d'entraînement (Manège ou Carrière)

  @HiveField(5)
  final LessonDuration duration; // Durée du cours (30 minutes ou 1 heure)

  @HiveField(6)
  final Discipline discipline; // Discipline (Dressage, Saut d'obstacle, Endurance)

  @HiveField(7)
  final String? notes; // Notes supplémentaires (optionnel)

  @HiveField(8)
  final ApprovalStatus approvalStatus; // Statut d'approbation

  @HiveField(9)
  final String? rejectionReason; // Raison du refus (si applicable)

  RidingLesson({
    this.id,
    required this.userId,
    this.horseId,
    required this.dateTime,
    required this.trainingGround,
    required this.duration,
    required this.discipline,
    this.notes,
    this.approvalStatus = ApprovalStatus.pending,
    this.rejectionReason,
  });

  RidingLesson copyWith({
    int? id,
    int? userId,
    int? horseId,
    DateTime? dateTime,
    TrainingGround? trainingGround,
    LessonDuration? duration,
    Discipline? discipline,
    String? notes,
    ApprovalStatus? approvalStatus,
    String? rejectionReason,
  }) {
    return RidingLesson(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      horseId: horseId ?? this.horseId,
      dateTime: dateTime ?? this.dateTime,
      trainingGround: trainingGround ?? this.trainingGround,
      duration: duration ?? this.duration,
      discipline: discipline ?? this.discipline,
      notes: notes ?? this.notes,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'horseId': horseId,
      'dateTime': dateTime.toIso8601String(),
      'trainingGround': trainingGround.toString(),
      'duration': duration.toString(),
      'discipline': discipline.toString(),
      'notes': notes,
      'approvalStatus': approvalStatus.toString(),
      'rejectionReason': rejectionReason,
    };
  }

  @override
  String toString() {
    return 'RidingLesson(id: $id, userId: $userId, horseId: $horseId, dateTime: $dateTime, trainingGround: $trainingGround, duration: $duration, discipline: $discipline, notes: $notes, approvalStatus: $approvalStatus, rejectionReason: $rejectionReason)';
  }
}
