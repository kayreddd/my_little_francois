import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/horse_model.dart';
import '../models/event_model.dart';
import '../models/riding_lesson_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Box<User>? _usersBox;
  static Box<Horse>? _horsesBox;
  static Box<Event>? _eventsBox;
  static Box<RidingLesson>? _ridingLessonsBox;
  static const String _usersBoxName = 'users';
  static const String _horsesBoxName = 'horses';
  static const String _eventsBoxName = 'events';
  static const String _ridingLessonsBoxName = 'riding_lessons';

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
}

// Initialize Hive for the application
Future<void> initializeDatabaseFactory() async {
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
  
  // Ensure the boxes are ready and persistent
  final usersBox = await Hive.openBox<User>('users');
  final horsesBox = await Hive.openBox<Horse>('horses');
  final eventsBox = await Hive.openBox<Event>('events');
  final ridingLessonsBox = await Hive.openBox<RidingLesson>('riding_lessons');
  
  // Afficher des informations de débogage
  print('Nombre d\'utilisateurs dans la base de données: ${usersBox.length}');
  print('Nombre de chevaux dans la base de données: ${horsesBox.length}');
  print('Nombre d\'événements dans la base de données: ${eventsBox.length}');
}

void main() {
  initializeDatabaseFactory();
  // ... rest of your main function ...
}
