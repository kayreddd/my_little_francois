import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'database/database_service.dart';
import 'models/user_model.dart';
import 'models/horse_model.dart';
import 'models/event_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Hive avec un chemin de stockage spécifique pour garantir la persistance
  await Hive.initFlutter();
  
  // Enregistrer les adaptateurs et ouvrir les boîtes
  await initializeDatabaseFactory();
  
  // Afficher des informations de débogage pour vérifier l'initialisation
  final usersBox = await Hive.openBox<User>('users');
  final horsesBox = await Hive.openBox<Horse>('horses');
  final eventsBox = await Hive.openBox<Event>('events');
  print('Application démarrée avec ${usersBox.length} utilisateurs, ${horsesBox.length} chevaux et ${eventsBox.length} événements dans la base de données');
  
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
