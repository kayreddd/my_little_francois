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
    
    // Forcer le stockage persistant pour le web (demande explicite au navigateur)
    try {
      await html.window.navigator.storage?.persist();
      print('Stockage persistant demandé explicitement au navigateur');
    } catch (e) {
      print('Erreur lors de la demande de stockage persistant: $e');
    }
  }
  
  // Enregistrer les adaptateurs et ouvrir les boîtes
  await initializeDatabaseFactory();
  
  // Nous n'ouvrons plus les boîtes ici car elles sont déjà ouvertes dans initializeDatabaseFactory()
  // Cela évite les problèmes de double ouverture et de synchronisation
  
  // Afficher des informations de débogage pour vérifier l'initialisation
  final usersBox = Hive.box<User>('users');
  final horsesBox = Hive.box<Horse>('horses');
  final eventsBox = Hive.box<Event>('events');
  final ridingLessonsBox = Hive.box<RidingLesson>('riding_lessons');
  final competitionsBox = Hive.box<Competition>('competitions');
  final partiesBox = Hive.box<Party>('parties');
  
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
      title: 'Horses Time',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
    );
  }
}
