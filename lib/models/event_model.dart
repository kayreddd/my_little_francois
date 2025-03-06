import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 3)
enum EventType {
  @HiveField(0)
  newUser,
  @HiveField(1)
  newCompetition,
  @HiveField(2)
  newCourse,
  @HiveField(3)
  newParty,
  @HiveField(4)
  newRidingLesson
}

@HiveType(typeId: 2)
class Event extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final EventType type;

  @HiveField(5)
  final int? relatedUserId;

  @HiveField(6)
  final String? imageUrl;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.relatedUserId,
    this.imageUrl,
  });

  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    EventType? type,
    int? relatedUserId,
    String? imageUrl,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      relatedUserId: relatedUserId ?? this.relatedUserId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.toString(),
      'relatedUserId': relatedUserId,
      'imageUrl': imageUrl,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      type: EventType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => EventType.newUser,
      ),
      relatedUserId: map['relatedUserId'],
      imageUrl: map['imageUrl'],
    );
  }
}
