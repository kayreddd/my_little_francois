import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:html' as html;
import 'screens/login_screen.dart';
import 'database/database_service.dart';
import 'models/user_model.dart';
import 'models/horse_model.dart';
import 'models/event_model.dart';
import 'models/riding_lesson_model.dart';
import 'models/competition_model.dart';
import 'models/party_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Hive avec un chemin de stockage spécifique pour garantir la persistance
  await Hive.initFlutter();
  
  // Configuration spécifique pour le web pour assurer la persistance
  if (html.window.navigator.userAgent.contains('Chrome')) {
    html.window.localStorage['hive_initialized'] = 'true';
    print('Configuration de persistance pour Chrome activée');
  }
  
  // Enregistrer les adaptateurs et ouvrir les boîtes
  await initializeDatabaseFactory();
  
  // Afficher des informations de débogage pour vérifier l'initialisation
  final usersBox = await Hive.openBox<User>('users', 
    crashRecovery: true,
    compactionStrategy: (entries, deletedEntries) {
      return deletedEntries > 50 || deletedEntries > 0.3 * entries;
    },
  );
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
  
  print('Application démarrée avec:');
  print('- ${usersBox.length} utilisateurs');
  print('- ${horsesBox.length} chevaux');
  print('- ${eventsBox.length} événements');
  print('- ${ridingLessonsBox.length} cours d\'équitation');
  print('- ${competitionsBox.length} concours');
  print('- ${partiesBox.length} soirées');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Little François',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
