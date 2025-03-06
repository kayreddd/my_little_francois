import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/horse_model.dart';
import '../models/event_model.dart';
import '../models/riding_lesson_model.dart';
import '../models/competition_model.dart';
import '../models/party_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Box<User>? _usersBox;
  static Box<Horse>? _horsesBox;
  static Box<Event>? _eventsBox;
  static Box<RidingLesson>? _ridingLessonsBox;
  static Box<Competition>? _competitionsBox;
  static Box<Party>? _partiesBox;
  static const String _usersBoxName = 'users';
  static const String _horsesBoxName = 'horses';
  static const String _eventsBoxName = 'events';
  static const String _ridingLessonsBoxName = 'riding_lessons';
  static const String _competitionsBoxName = 'competitions';
  static const String _partiesBoxName = 'parties';

  DatabaseService._init();

  Future<Box<User>> get usersBox async {
    if (_usersBox != null && _usersBox!.isOpen) return _usersBox!;
    _usersBox = await Hive.openBox<User>(_usersBoxName);
    return _usersBox!;
  }
  
  Future<Box<Horse>> get horsesBox async {
    if (_horsesBox != null && _horsesBox!.isOpen) return _horsesBox!;
    _horsesBox = await Hive.openBox<Horse>(_horsesBoxName);
    return _horsesBox!;
  }
  
  Future<Box<Event>> get eventsBox async {
    if (_eventsBox != null && _eventsBox!.isOpen) return _eventsBox!;
    _eventsBox = await Hive.openBox<Event>(_eventsBoxName);
    return _eventsBox!;
  }
  
  Future<Box<RidingLesson>> get ridingLessonsBox async {
    if (_ridingLessonsBox != null && _ridingLessonsBox!.isOpen) return _ridingLessonsBox!;
    _ridingLessonsBox = await Hive.openBox<RidingLesson>(_ridingLessonsBoxName);
    return _ridingLessonsBox!;
  }
  
  Future<Box<Competition>> get competitionsBox async {
    if (_competitionsBox != null && _competitionsBox!.isOpen) return _competitionsBox!;
    _competitionsBox = await Hive.openBox<Competition>(_competitionsBoxName);
    return _competitionsBox!;
  }
  
  Future<Box<Party>> get partiesBox async {
    if (_partiesBox != null && _partiesBox!.isOpen) return _partiesBox!;
    _partiesBox = await Hive.openBox<Party>(_partiesBoxName);
    return _partiesBox!;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<User?> createUser(User user) async {
    final box = await usersBox;
    final hashedPassword = _hashPassword(user.password);

    // Check if username or email already exists
    final existingUserByUsername = box.values.any((u) => u.username == user.username);
    final existingUserByEmail = box.values.any((u) => u.email == user.email);

    if (existingUserByUsername || existingUserByEmail) {
      return null; // Username or email already exists
    }

    try {
      final id = box.values.isEmpty ? 1 : box.values.last.id! + 1;
      
      final newUser = User(
        id: id,
        username: user.username,
        password: hashedPassword,
        email: user.email,
        profilePicturePath: user.profilePicturePath,
      );

      // Ajouter l'utilisateur à la boîte et s'assurer que les données sont persistées
      final index = await box.add(newUser);
      await box.flush(); // Force l'écriture des données sur le disque
      
      // Créer un événement pour le nouvel utilisateur
      await createEvent(
        Event(
          title: 'Nouveau cavalier',
          description: '${user.username} a rejoint My Little François !',
          date: DateTime.now(),
          type: EventType.newUser,
          relatedUserId: id,
          imageUrl: user.profilePicturePath,
        )
      );
      
      return newUser;
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur: $e');
      return null;
    }
  }

  Future<User?> getUser(String username, String password) async {
    final box = await usersBox;
    final hashedPassword = _hashPassword(password);

    try {
      final user = box.values.firstWhere(
        (user) => user.username == username && user.password == hashedPassword,
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final box = await usersBox;

    try {
      final user = box.values.firstWhere(
        (user) => user.email == email,
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePassword(String email, String newPassword) async {
    final box = await usersBox;
    final hashedPassword = _hashPassword(newPassword);

    try {
      final userIndex = box.values.toList().indexWhere((user) => user.email == email);
      
      if (userIndex != -1) {
        final user = box.getAt(userIndex);
        if (user != null) {
          final updatedUser = user.copyWith(password: hashedPassword);
          await box.putAt(userIndex, updatedUser);
          await box.flush(); // Force l'écriture des données sur le disque
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erreur lors de la mise à jour du mot de passe: $e');
      return false;
    }
  }
  
  // Méthodes pour mettre à jour le profil utilisateur
  Future<bool> updateUserProfile(User updatedUser) async {
    final box = await usersBox;
    
    try {
      final userIndex = box.values.toList().indexWhere((user) => user.id == updatedUser.id);
      
      if (userIndex != -1) {
        final user = box.getAt(userIndex);
        if (user != null) {
          // Conserver le mot de passe existant
          final updatedUserWithPassword = updatedUser.copyWith(password: user.password);
          await box.putAt(userIndex, updatedUserWithPassword);
          await box.flush(); // Force l'écriture des données sur le disque
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erreur lors de la mise à jour du profil utilisateur: $e');
      return false;
    }
  }
  
  // Méthodes pour gérer les chevaux
  Future<Horse?> createHorse(Horse horse) async {
    final box = await horsesBox;
    
    try {
      final id = box.values.isEmpty ? 1 : box.values.last.id! + 1;
      
      final newHorse = horse.copyWith(id: id);
      await box.add(newHorse);
      await box.flush(); // Force l'écriture des données sur le disque
      return newHorse;
    } catch (e) {
      print('Erreur lors de la création du cheval: $e');
      return null;
    }
  }
  
  Future<Horse?> getHorse(int id) async {
    final box = await horsesBox;
    
    try {
      final horse = box.values.firstWhere((horse) => horse.id == id);
      return horse;
    } catch (e) {
      return null;
    }
  }
  
  Future<List<Horse>> getAllHorses() async {
    final box = await horsesBox;
    return box.values.toList();
  }
  
  Future<Horse?> getHorseById(int horseId) async {
    final box = await horsesBox;
    try {
      return box.values.firstWhere((horse) => horse.id == horseId);
    } catch (e) {
      print('Erreur lors de la récupération du cheval avec l\'ID $horseId: $e');
      return null;
    }
  }
  
  Future<List<Horse>> getHorsesByOwner(int ownerId) async {
    final box = await horsesBox;
    return box.values.where((horse) => horse.ownerId == ownerId).toList();
  }
  
  Future<bool> updateHorse(Horse updatedHorse) async {
    final box = await horsesBox;
    
    try {
      final horseIndex = box.values.toList().indexWhere((horse) => horse.id == updatedHorse.id);
      
      if (horseIndex != -1) {
        await box.putAt(horseIndex, updatedHorse);
        await box.flush(); // Force l'écriture des données sur le disque
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la mise à jour du cheval: $e');
      return false;
    }
  }
  
  Future<bool> deleteHorse(int id) async {
    final box = await horsesBox;
    
    try {
      final horseIndex = box.values.toList().indexWhere((horse) => horse.id == id);
      
      if (horseIndex != -1) {
        await box.deleteAt(horseIndex);
        await box.flush(); // Force l'écriture des données sur le disque
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la suppression du cheval: $e');
      return false;
    }
  }
  
  // Méthodes pour associer des chevaux à un utilisateur
  Future<bool> associateHorseWithUser(int horseId, int userId, {bool isOwner = false}) async {
    final userBox = await usersBox;
    final horseBox = await horsesBox;
    
    try {
      final userIndex = userBox.values.toList().indexWhere((user) => user.id == userId);
      final horseIndex = horseBox.values.toList().indexWhere((horse) => horse.id == horseId);
      
      if (userIndex != -1 && horseIndex != -1) {
        final user = userBox.getAt(userIndex);
        final horse = horseBox.getAt(horseIndex);
        
        if (user != null && horse != null) {
          User updatedUser;
          Horse updatedHorse;
          
          if (isOwner) {
            // Ajouter le cheval à la liste des chevaux possédés par l'utilisateur
            final ownedHorseIds = user.ownedHorseIds?.toList() ?? [];
            if (!ownedHorseIds.contains(horseId)) {
              ownedHorseIds.add(horseId);
            }
            updatedUser = user.copyWith(ownedHorseIds: ownedHorseIds);
            
            // Mettre à jour le propriétaire du cheval
            updatedHorse = horse.copyWith(ownerId: userId);
          } else {
            // Ajouter le cheval à la liste des chevaux associés à l'utilisateur (pour les DP)
            final associatedHorseIds = user.associatedHorseIds?.toList() ?? [];
            if (!associatedHorseIds.contains(horseId)) {
              associatedHorseIds.add(horseId);
            }
            updatedUser = user.copyWith(associatedHorseIds: associatedHorseIds);
            updatedHorse = horse; // Pas de changement pour le cheval
          }
          
          await userBox.putAt(userIndex, updatedUser);
          await horseBox.putAt(horseIndex, updatedHorse);
          
          // Force l'écriture des données sur le disque
          await userBox.flush();
          await horseBox.flush();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> disassociateHorseFromUser(int horseId, int userId, {bool isOwner = false}) async {
    final userBox = await usersBox;
    final horseBox = await horsesBox;
    
    try {
      final userIndex = userBox.values.toList().indexWhere((user) => user.id == userId);
      final horseIndex = horseBox.values.toList().indexWhere((horse) => horse.id == horseId);
      
      if (userIndex != -1 && horseIndex != -1) {
        final user = userBox.getAt(userIndex);
        final horse = horseBox.getAt(horseIndex);
        
        if (user != null && horse != null) {
          User updatedUser;
          Horse? updatedHorse;
          
          if (isOwner) {
            // Retirer le cheval de la liste des chevaux possédés par l'utilisateur
            final ownedHorseIds = user.ownedHorseIds?.toList() ?? [];
            ownedHorseIds.remove(horseId);
            updatedUser = user.copyWith(ownedHorseIds: ownedHorseIds);
            
            // Mettre à jour le propriétaire du cheval (null)
            updatedHorse = horse.copyWith(ownerId: null);
          } else {
            // Retirer le cheval de la liste des chevaux associés à l'utilisateur (pour les DP)
            final associatedHorseIds = user.associatedHorseIds?.toList() ?? [];
            associatedHorseIds.remove(horseId);
            updatedUser = user.copyWith(associatedHorseIds: associatedHorseIds);
            updatedHorse = null; // Pas de changement pour le cheval
          }
          
          await userBox.putAt(userIndex, updatedUser);
          if (updatedHorse != null) {
            await horseBox.putAt(horseIndex, updatedHorse);
          }
          
          // Force l'écriture des données sur le disque
          await userBox.flush();
          await horseBox.flush();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Méthodes pour gérer les événements
  Future<Event?> createEvent(Event event) async {
    final box = await eventsBox;
    
    try {
      final id = box.values.isEmpty ? 1 : box.values.last.id! + 1;
      
      final newEvent = event.copyWith(id: id);
      await box.add(newEvent);
      await box.flush(); // Force l'écriture des données sur le disque
      return newEvent;
    } catch (e) {
      print('Erreur lors de la création de l\'\u00e9vénement: $e');
      return null;
    }
  }
  
  Future<List<Event>> getAllEvents() async {
    final box = await eventsBox;
    // Trier les événements par date, du plus récent au plus ancien
    final events = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return events;
  }
  
  Future<Event?> getEvent(int id) async {
    final box = await eventsBox;
    
    try {
      final event = box.values.firstWhere((event) => event.id == id);
      return event;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> deleteEvent(int id) async {
    final box = await eventsBox;
    
    try {
      final eventIndex = box.values.toList().indexWhere((event) => event.id == id);
      
      if (eventIndex != -1) {
        await box.deleteAt(eventIndex);
        await box.flush(); // Force l'écriture des données sur le disque
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la suppression de l\'\u00e9vénement: $e');
      return false;
    }
  }
  
  // Méthodes pour créer différents types d'événements
  Future<Event?> createCompetitionEvent(String title, String description, DateTime date, {String? imageUrl}) async {
    return createEvent(
      Event(
        title: title,
        description: description,
        date: date,
        type: EventType.newCompetition,
        imageUrl: imageUrl,
      )
    );
  }
  
  Future<Event?> createCourseEvent(String title, String description, DateTime date, {String? imageUrl}) async {
    return createEvent(
      Event(
        title: title,
        description: description,
        date: date,
        type: EventType.newCourse,
        imageUrl: imageUrl,
      )
    );
  }
  
  Future<Event?> createPartyEvent(String title, String description, DateTime date, {String? imageUrl}) async {
    return createEvent(
      Event(
        title: title,
        description: description,
        date: date,
        type: EventType.newParty,
        imageUrl: imageUrl,
      )
    );
  }
  
  // Méthodes pour gérer les cours d'équitation
  Future<RidingLesson?> createRidingLesson(RidingLesson lesson) async {
    final box = await ridingLessonsBox;
    
    try {
      final id = box.values.isEmpty ? 1 : box.values.last.id! + 1;
      
      final newLesson = lesson.copyWith(id: id);
      await box.add(newLesson);
      await box.flush(); // Force l'écriture des données sur le disque
      
      // Créer un événement pour le nouveau cours
      String disciplineText = '';
      switch (lesson.discipline) {
        case Discipline.dressage:
          disciplineText = 'Dressage';
          break;
        case Discipline.jumpingObstacles:
          disciplineText = 'Saut d\'obstacle';
          break;
        case Discipline.endurance:
          disciplineText = 'Endurance';
          break;
      }
      
      String durationText = lesson.duration == LessonDuration.thirtyMinutes ? '30 minutes' : '1 heure';
      String locationText = lesson.trainingGround == TrainingGround.arena ? 'Manège' : 'Carrière';
      
      await createEvent(
        Event(
          title: 'Nouveau cours d\'équitation',
          description: 'Cours de $disciplineText programmé le ${lesson.dateTime.day}/${lesson.dateTime.month} à ${lesson.dateTime.hour}:${lesson.dateTime.minute.toString().padLeft(2, '0')} ($durationText, $locationText)',
          date: DateTime.now(),
          type: EventType.newCourse,
          relatedUserId: lesson.userId,
        )
      );
      
      return newLesson;
    } catch (e) {
      print('Erreur lors de la création du cours d\'\u00e9quitation: $e');
      return null;
    }
  }
  
  Future<List<RidingLesson>> getAllRidingLessons() async {
    final box = await ridingLessonsBox;
    // Trier les cours par date, du plus récent au plus ancien
    final lessons = box.values.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return lessons;
  }
  
  Future<List<RidingLesson>> getRidingLessonsByUser(int userId) async {
    final box = await ridingLessonsBox;
    // Filtrer les cours par utilisateur et trier par date
    final lessons = box.values.where((lesson) => lesson.userId == userId).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return lessons;
  }
  
  Future<RidingLesson?> getRidingLesson(int id) async {
    final box = await ridingLessonsBox;
    
    try {
      final lesson = box.values.firstWhere((lesson) => lesson.id == id);
      return lesson;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> deleteRidingLesson(int id) async {
    final box = await ridingLessonsBox;
    
    try {
      final lessonIndex = box.values.toList().indexWhere((lesson) => lesson.id == id);
      
      if (lessonIndex != -1) {
        await box.deleteAt(lessonIndex);
        await box.flush(); // Force l'écriture des données sur le disque
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la suppression du cours d\'\u00e9quitation: $e');
      return false;
    }
  }
  
  // Méthodes pour approuver/refuser les cours d'équitation
  Future<bool> approveRidingLesson(int lessonId) async {
    final box = await ridingLessonsBox;
    try {
      final lesson = box.values.firstWhere((lesson) => lesson.id == lessonId);
      final updatedLesson = lesson.copyWith(approvalStatus: ApprovalStatus.approved);
      await box.put(lesson.key, updatedLesson);
      await box.flush();
      
      // Créer un événement pour l'approbation du cours
      await createEvent(
        Event(
          title: 'Cours approuvé',
          description: 'Un cours d\'équitation a été approuvé par le gérant',
          date: DateTime.now(),
          type: EventType.newCourse,
          relatedUserId: updatedLesson.userId,
        )
      );
      
      return true;
    } catch (e) {
      print('Erreur lors de l\'approbation du cours: $e');
      return false;
    }
  }
  
  Future<bool> rejectRidingLesson(int lessonId, String reason) async {
    final box = await ridingLessonsBox;
    try {
      final lesson = box.values.firstWhere((lesson) => lesson.id == lessonId);
      final updatedLesson = lesson.copyWith(
        approvalStatus: ApprovalStatus.rejected,
        rejectionReason: reason,
      );
      await box.put(lesson.key, updatedLesson);
      await box.flush();
      
      // Créer un événement pour le refus du cours
      await createEvent(
        Event(
          title: 'Cours refusé',
          description: 'Un cours d\'équitation a été refusé par le gérant',
          date: DateTime.now(),
          type: EventType.newCourse,
          relatedUserId: updatedLesson.userId,
        )
      );
      
      return true;
    } catch (e) {
      print('Erreur lors du refus du cours: $e');
      return false;
    }
  }
  
  // Méthodes pour gérer les concours
  Future<Competition?> createCompetition(Competition competition) async {
    final box = await competitionsBox;
    
    try {
      final id = box.values.isEmpty ? 1 : box.values.last.id! + 1;
      
      final newCompetition = competition.copyWith(id: id);
      await box.add(newCompetition);
      await box.flush(); // Force l'écriture des données sur le disque
      
      // Créer un événement pour le nouveau concours
      await createEvent(
        Event(
          title: 'Nouveau concours: ${competition.name}',
          description: 'Un nouveau concours a été programmé le ${competition.date.day}/${competition.date.month}/${competition.date.year} à ${competition.address}',
          date: DateTime.now(),
          type: EventType.newCompetition,
          relatedUserId: competition.creatorId,
          imageUrl: competition.photoUrl,
        )
      );
      
      return newCompetition;
    } catch (e) {
      print('Erreur lors de la création du concours: $e');
      return null;
    }
  }
  
  Future<List<Competition>> getAllCompetitions() async {
    final box = await competitionsBox;
    // Trier les concours par date, du plus récent au plus ancien
    final competitions = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return competitions;
  }
  
  Future<List<Competition>> getUpcomingCompetitions() async {
    final box = await competitionsBox;
    final now = DateTime.now();
    // Filtrer les concours à venir et les trier par date
    final competitions = box.values.where((comp) => comp.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return competitions;
  }
  
  Future<Competition?> getCompetition(int id) async {
    final box = await competitionsBox;
    
    try {
      final competition = box.values.firstWhere((comp) => comp.id == id);
      return competition;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> updateCompetition(Competition updatedCompetition) async {
    final box = await competitionsBox;
    
    try {
      final competitionIndex = box.values.toList().indexWhere((comp) => comp.id == updatedCompetition.id);
      
      if (competitionIndex != -1) {
        await box.putAt(competitionIndex, updatedCompetition);
        await box.flush(); // Force l'écriture des données sur le disque
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la mise à jour du concours: $e');
      return false;
    }
  }
  
  Future<bool> deleteCompetition(int id) async {
    final box = await competitionsBox;
    
    try {
      final competitionIndex = box.values.toList().indexWhere((comp) => comp.id == id);
      
      if (competitionIndex != -1) {
        await box.deleteAt(competitionIndex);
        await box.flush(); // Force l'écriture des données sur le disque
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la suppression du concours: $e');
      return false;
    }
  }
  
  // Méthodes pour gérer les participants aux concours
  Future<bool> addParticipantToCompetition(int competitionId, CompetitionParticipant participant) async {
    final box = await competitionsBox;
    
    try {
      final competitionIndex = box.values.toList().indexWhere((comp) => comp.id == competitionId);
      
      if (competitionIndex != -1) {
        final competition = box.getAt(competitionIndex);
        if (competition != null) {
          final updatedCompetition = competition.addParticipant(participant);
          await box.putAt(competitionIndex, updatedCompetition);
          await box.flush(); // Force l'écriture des données sur le disque
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erreur lors de l\'ajout du participant au concours: $e');
      return false;
    }
  }
  
  Future<bool> removeParticipantFromCompetition(int competitionId, int userId) async {
    final box = await competitionsBox;
    
    try {
      final competitionIndex = box.values.toList().indexWhere((comp) => comp.id == competitionId);
      
      if (competitionIndex != -1) {
        final competition = box.getAt(competitionIndex);
        if (competition != null) {
          final updatedCompetition = competition.removeParticipant(userId);
          await box.putAt(competitionIndex, updatedCompetition);
          await box.flush(); // Force l'écriture des données sur le disque
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erreur lors de la suppression du participant du concours: $e');
      return false;
    }
  }
  
  Future<List<Competition>> getCompetitionsByParticipant(int userId) async {
    final box = await competitionsBox;
    
    // Filtrer les concours auxquels l'utilisateur participe
    final competitions = box.values.where((comp) => 
      comp.participants.any((p) => p.userId == userId)
    ).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return competitions;
  }
  
  // Méthode pour récupérer tous les utilisateurs
  Future<List<User>> getAllUsers() async {
    final box = await usersBox;
    return box.values.toList();
  }
  
  Future<User?> getUserById(int userId) async {
    final box = await usersBox;
    try {
      return box.values.firstWhere((user) => user.id == userId);
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur avec l\'ID $userId: $e');
      return null;
    }
  }
  
  // Méthodes pour les soirées à thème
  Future<Party?> createParty(Party party) async {
    final box = await partiesBox;
    
    try {
      final id = box.values.isEmpty ? 1 : box.values.last.id! + 1;
      
      final newParty = Party(
        id: id,
        title: party.title,
        description: party.description,
        date: party.date,
        imageUrl: party.imageUrl,
        creatorId: party.creatorId,
        participants: party.participants,
        type: party.type,
      );
      
      // Ajouter la soirée à la boîte et s'assurer que les données sont persistées
      final index = await box.add(newParty);
      await box.flush();
      
      // Créer un événement pour la nouvelle soirée
      await createEvent(
        Event(
          title: 'Nouvelle soirée',
          description: '${party.title} a été créée !',
          date: DateTime.now(),
          type: EventType.newParty,
          relatedUserId: party.creatorId,
          imageUrl: party.imageUrl,
        )
      );
      
      return newParty;
    } catch (e) {
      print('Erreur lors de la création de la soirée: $e');
      return null;
    }
  }
  
  Future<List<Party>> getAllParties() async {
    final box = await partiesBox;
    return box.values.toList();
  }
  
  Future<List<Party>> getUpcomingParties() async {
    final box = await partiesBox;
    final now = DateTime.now();
    return box.values.where((party) => party.date.isAfter(now)).toList();
  }
  
  Future<Party?> getParty(int id) async {
    final box = await partiesBox;
    return box.values.firstWhere((party) => party.id == id);
  }
  
  Future<bool> updateParty(Party updatedParty) async {
    final box = await partiesBox;
    try {
      final existingParty = box.values.firstWhere((party) => party.id == updatedParty.id);
      final index = existingParty.key;
      await box.put(index, updatedParty);
      await box.flush();
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de la soirée: $e');
      return false;
    }
  }
  
  Future<bool> deleteParty(int id) async {
    final box = await partiesBox;
    try {
      final existingParty = box.values.firstWhere((party) => party.id == id);
      await existingParty.delete();
      await box.flush();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de la soirée: $e');
      return false;
    }
  }
  
  Future<bool> addParticipantToParty(int partyId, PartyParticipant participant) async {
    final box = await partiesBox;
    try {
      final party = box.values.firstWhere((party) => party.id == partyId);
      party.addParticipant(participant);
      await box.put(party.key, party);
      await box.flush();
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout du participant à la soirée: $e');
      return false;
    }
  }
  
  Future<bool> removeParticipantFromParty(int partyId, int userId) async {
    final box = await partiesBox;
    try {
      final party = box.values.firstWhere((party) => party.id == partyId);
      party.removeParticipant(userId);
      await box.put(party.key, party);
      await box.flush();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du participant de la soirée: $e');
      return false;
    }
  }
  
  Future<bool> updateParticipantContribution(int partyId, int userId, String contribution) async {
    final box = await partiesBox;
    try {
      final party = box.values.firstWhere((party) => party.id == partyId);
      final participantIndex = party.participants.indexWhere((p) => p.userId == userId);
      
      if (participantIndex != -1) {
        party.participants[participantIndex].contribution = contribution;
        await box.put(party.key, party);
        await box.flush();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la mise à jour de la contribution du participant: $e');
      return false;
    }
  }
  
  Future<List<Party>> getPartiesByParticipant(int userId) async {
    final box = await partiesBox;
    return box.values.where((party) => party.participants.any((p) => p.userId == userId)).toList();
  }
  
  // Méthodes pour approuver/refuser les soirées
  Future<bool> approveParty(int partyId) async {
    final box = await partiesBox;
    try {
      final party = box.values.firstWhere((party) => party.id == partyId);
      party.approvalStatus = ApprovalStatus.approved;
      await box.put(party.key, party);
      await box.flush();
      
      // Créer un événement pour l'approbation de la soirée
      await createEvent(
        Event(
          title: 'Soirée approuvée',
          description: 'La soirée "${party.title}" a été approuvée par le gérant',
          date: DateTime.now(),
          type: EventType.newParty,
          relatedUserId: party.creatorId,
        )
      );
      
      return true;
    } catch (e) {
      print('Erreur lors de l\'approbation de la soirée: $e');
      return false;
    }
  }
  
  Future<bool> rejectParty(int partyId, String reason) async {
    final box = await partiesBox;
    try {
      final party = box.values.firstWhere((party) => party.id == partyId);
      party.approvalStatus = ApprovalStatus.rejected;
      party.rejectionReason = reason;
      await box.put(party.key, party);
      await box.flush();
      
      // Créer un événement pour le refus de la soirée
      await createEvent(
        Event(
          title: 'Soirée refusée',
          description: 'La soirée "${party.title}" a été refusée par le gérant',
          date: DateTime.now(),
          type: EventType.newParty,
          relatedUserId: party.creatorId,
        )
      );
      
      return true;
    } catch (e) {
      print('Erreur lors du refus de la soirée: $e');
      return false;
    }
  }
  
  // Méthodes pour récupérer les cours et soirées en attente d'approbation
  Future<List<RidingLesson>> getPendingRidingLessons() async {
    final box = await ridingLessonsBox;
    return box.values.where((lesson) => lesson.approvalStatus == ApprovalStatus.pending).toList();
  }
  
  Future<List<Party>> getPendingParties() async {
    final box = await partiesBox;
    return box.values.where((party) => party.approvalStatus == ApprovalStatus.pending).toList();
  }
}

// Initialize Hive for the application
Future<void> initializeDatabaseFactory() async {
  try {
    // Register the User adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    
    // Register the Horse adapter
    if (!Hive.isAdapterRegistered(1)) {
      // Création de l'adaptateur pour Horse
      // L'adaptateur HorseAdapter est défini dans le fichier horse_model.dart
      // et généré dans horse_model.g.dart
      final adapter = HorseAdapter();
      Hive.registerAdapter(adapter);
    }
    
    // Register the Event adapter and EventType enum
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(EventAdapter());
      Hive.registerAdapter(EventTypeAdapter());
    }
    
    // Register the RidingLesson adapters
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TrainingGroundAdapter());
    }
    
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(LessonDurationAdapter());
    }
    
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(DisciplineAdapter());
    }
    
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(RidingLessonAdapter());
    }
    
    // Register the Competition adapters
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(CompetitionLevelAdapter());
    }
    
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(CompetitionParticipantAdapter());
    }
    
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(CompetitionAdapter());
    }
    
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(PartyAdapter());
    }
    
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(PartyParticipantAdapter());
    }
    
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(PartyTypeAdapter());
    }
    
    // Register the ApprovalStatus enum
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(ApprovalStatusAdapter());
    }
    
    // Options de configuration pour améliorer la persistance définies directement lors de l'ouverture des boîtes
    
    // Ensure the boxes are ready and persistent
    final usersBox = await Hive.openBox<User>('users', crashRecovery: true);
    final horsesBox = await Hive.openBox<Horse>('horses', crashRecovery: true);
    final eventsBox = await Hive.openBox<Event>('events', crashRecovery: true);
    final ridingLessonsBox = await Hive.openBox<RidingLesson>('riding_lessons', crashRecovery: true);
    final competitionsBox = await Hive.openBox<Competition>('competitions', crashRecovery: true);
    final partiesBox = await Hive.openBox<Party>('parties', crashRecovery: true);
    
    // Forcer la synchronisation des données
    await usersBox.flush();
    await horsesBox.flush();
    await eventsBox.flush();
    await ridingLessonsBox.flush();
    await competitionsBox.flush();
    await partiesBox.flush();
    
    // Vérifier si les boîtes sont vides et ajouter un utilisateur de test si nécessaire
    if (usersBox.isEmpty) {
      print('Aucun utilisateur trouvé, création d\'un utilisateur de test...');
      
      // Créer un utilisateur de test pour s'assurer que la persistance fonctionne
      // Hasher le mot de passe manuellement (même algorithme que dans DatabaseService._hashPassword)
      final bytes = utf8.encode('test');
      final hash = sha256.convert(bytes);
      final hashedPassword = hash.toString();
      
      final testUser = User(
        id: 1,
        username: 'test',
        password: hashedPassword,
        email: 'test@example.com',
        isStableManager: true, // Donner le rôle de gérant des écuries à l'utilisateur de test
      );
      
      await usersBox.add(testUser);
      await usersBox.flush();
      
      print('Utilisateur de test créé avec succès!');
    }
    
    // Afficher des informations de débogage
    print('Nombre d\'utilisateurs dans la base de données: ${usersBox.length}');
    print('Nombre de chevaux dans la base de données: ${horsesBox.length}');
    print('Nombre d\'événements dans la base de données: ${eventsBox.length}');
    print('Nombre de cours d\'équitation dans la base de données: ${ridingLessonsBox.length}');
    print('Nombre de concours dans la base de données: ${competitionsBox.length}');
    print('Nombre de soirées dans la base de données: ${partiesBox.length}');
  } catch (e) {
    print('Erreur lors de l\'initialisation de la base de données: $e');
    // Tenter de récupérer en cas d'erreur
    await Hive.deleteFromDisk();
    print('Base de données réinitialisée suite à une erreur. Veuillez redémarrer l\'application.');
  }
}

void main() {
  initializeDatabaseFactory();
  // ... rest of your main function ...
}
