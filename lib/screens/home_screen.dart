import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../database/database_service.dart';
import 'profile_screen.dart';
import 'horse_management_screen.dart';
import 'news_feed_screen.dart';
import 'riding_lesson_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User _currentUser;
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Event> _recentEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadRecentEvents();
  }
  
  Future<void> _loadRecentEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final events = await _databaseService.getAllEvents();
      setState(() {
        // Prendre les 3 événements les plus récents
        _recentEvents = events.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des événements: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Little François'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              final updatedUser = await Navigator.push<User>(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: _currentUser),
                ),
              );
              
              if (updatedUser != null) {
                setState(() {
                  _currentUser = updatedUser;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pop(); // Retour à l'écran de connexion
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section profil utilisateur
              Center(
                child: Column(
                  children: [
                    if (_currentUser.profilePicturePath != null)
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _currentUser.profilePicturePath!.startsWith('http')
                          ? NetworkImage(_currentUser.profilePicturePath!) as ImageProvider
                          : FileImage(File(_currentUser.profilePicturePath!)),
                      )
                    else
                      const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 50),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'Bienvenue, ${_currentUser.username} !',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Section des actions rapides
              Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                alignment: WrapAlignment.center,
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.pets,
                    label: 'Mes chevaux',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HorseManagementScreen(user: _currentUser),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.newspaper,
                    label: 'Actualités',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsFeedScreen(user: _currentUser),
                        ),
                      ).then((_) => _loadRecentEvents());
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.school,
                    label: 'Cours',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RidingLessonScreen(user: _currentUser),
                        ),
                      ).then((_) => _loadRecentEvents());
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Section des actualités récentes
              const Text(
                'Dernières actualités',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recentEvents.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Aucune actualité à afficher'),
                      ),
                    )
                  : Column(
                      children: _recentEvents.map((event) => _buildEventCard(event)).toList(),
                    ),
              
              if (_recentEvents.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Voir toutes les actualités'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsFeedScreen(user: _currentUser),
                          ),
                        ).then((_) => _loadRecentEvents());
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
  
  Widget _buildEventCard(Event event) {
    String eventIcon;
    Color eventColor;
    
    switch (event.type) {
      case EventType.newUser:
        eventIcon = '👤';
        eventColor = Colors.blue;
        break;
      case EventType.newCompetition:
        eventIcon = '🏆';
        eventColor = Colors.orange;
        break;
      case EventType.newCourse:
        eventIcon = '📚';
        eventColor = Colors.green;
        break;
      case EventType.newRidingLesson:
        eventIcon = '🐎';
        eventColor = Colors.brown;
        break;
      case EventType.newParty:
        eventIcon = '🎉';
        eventColor = Colors.purple;
        break;
      default:
        eventIcon = '📢';
        eventColor = Colors.grey;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: eventColor.withOpacity(0.2),
          child: Text(eventIcon, style: TextStyle(fontSize: 20)),
        ),
        title: Text(event.title),
        subtitle: Text(
          '${event.description}\n${event.date.day}/${event.date.month}/${event.date.year}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsFeedScreen(user: _currentUser),
            ),
          ).then((_) => _loadRecentEvents());
        },
      ),
    );
  }
}
