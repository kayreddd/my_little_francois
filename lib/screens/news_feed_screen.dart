import 'package:flutter/material.dart';
import 'dart:io';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../database/database_service.dart';

class NewsFeedScreen extends StatefulWidget {
  final User user;

  const NewsFeedScreen({super.key, required this.user});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    final events = await _databaseService.getAllEvents();
    
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  String _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.newUser:
        return '👤';
      case EventType.newCompetition:
        return '🏆';
      case EventType.newCourse:
        return '📚';
      case EventType.newParty:
        return '🎉';
      default:
        return '📢';
    }
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.newUser:
        return Colors.blue;
      case EventType.newCompetition:
        return Colors.orange;
      case EventType.newCourse:
        return Colors.green;
      case EventType.newParty:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualités'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun événement à afficher',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadEvents,
                        child: const Text('Actualiser'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadEvents,
                  child: ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getEventTypeColor(event.type),
                            child: Text(
                              _getEventTypeIcon(event.type),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          title: Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(event.description),
                              const SizedBox(height: 4),
                              Text(
                                'Le ${event.date.day}/${event.date.month}/${event.date.year} à ${event.date.hour}:${event.date.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: event.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: event.imageUrl!.startsWith('http')
                                      ? Image.network(
                                          event.imageUrl!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(event.imageUrl!),
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: widget.user.isAdmin == true
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Implémenter la création d'événements pour les administrateurs
                _showCreateEventDialog(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Créer un événement'),
          content: const SingleChildScrollView(
            child: Text('Fonctionnalité à venir pour les administrateurs'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
