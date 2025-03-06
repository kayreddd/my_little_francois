import 'package:flutter/material.dart';
import '../models/party_model.dart';
import '../models/user_model.dart';
import '../database/database_service.dart';

class PartyDetailScreen extends StatefulWidget {
  final User currentUser;
  final int? partyId;

  const PartyDetailScreen({
    Key? key,
    required this.currentUser,
    this.partyId,
  }) : super(key: key);

  @override
  _PartyDetailScreenState createState() => _PartyDetailScreenState();
}

class _PartyDetailScreenState extends State<PartyDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService.instance;
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  PartyType _selectedType = PartyType.aperitif;
  String _imageUrl = '';
  
  List<User> _allUsers = [];
  List<PartyParticipant> _participants = [];
  
  bool _isLoading = true;
  bool _isEditing = false;
  Party? _existingParty;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger tous les utilisateurs
      _allUsers = await _databaseService.getAllUsers();
      
      // Si nous sommes en mode édition, charger les détails de la soirée existante
      if (widget.partyId != null) {
        _isEditing = true;
        _existingParty = await _databaseService.getParty(widget.partyId!);
        
        if (_existingParty != null) {
          _titleController.text = _existingParty!.title;
          _descriptionController.text = _existingParty!.description;
          _selectedDate = _existingParty!.date;
          _selectedTime = TimeOfDay(hour: _existingParty!.date.hour, minute: _existingParty!.date.minute);
          _selectedType = _existingParty!.type;
          _imageUrl = _existingParty!.imageUrl ?? '';
          _participants = List.from(_existingParty!.participants);
        }
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du chargement des données')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveParty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final party = Party(
        id: _isEditing ? _existingParty!.id : null,
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        imageUrl: _imageUrl.isEmpty ? null : _imageUrl,
        creatorId: widget.currentUser.id!,
        participants: _participants,
        type: _selectedType,
      );

      bool success;
      if (_isEditing) {
        success = await _databaseService.updateParty(party);
      } else {
        // Ajouter automatiquement le créateur comme participant
        if (!party.isParticipating(widget.currentUser.id!)) {
          party.addParticipant(
            PartyParticipant(
              userId: widget.currentUser.id!,
              username: widget.currentUser.username,
            ),
          );
        }
        
        final createdParty = await _databaseService.createParty(party);
        success = createdParty != null;
      }

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'enregistrement de la soirée')),
        );
      }
    } catch (e) {
      print('Erreur lors de l\'enregistrement de la soirée: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'enregistrement de la soirée')),
      );
    }
  }

  Future<void> _deleteParty() async {
    if (!_isEditing || _existingParty == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la soirée'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette soirée ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _databaseService.deleteParty(_existingParty!.id!);
      
      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression de la soirée')),
        );
      }
    } catch (e) {
      print('Erreur lors de la suppression de la soirée: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression de la soirée')),
      );
    }
  }

  void _toggleParticipation(User user) {
    setState(() {
      if (_participants.any((p) => p.userId == user.id)) {
        _participants.removeWhere((p) => p.userId == user.id);
      } else {
        _participants.add(
          PartyParticipant(
            userId: user.id!,
            username: user.username,
          ),
        );
      }
    });
  }

  Future<void> _updateContribution(PartyParticipant participant) async {
    final contributionController = TextEditingController(text: participant.contribution);
    
    final contribution = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Que comptez-vous apporter ?'),
        content: TextField(
          controller: contributionController,
          decoration: const InputDecoration(
            labelText: 'Votre contribution',
            hintText: 'Ex: Bouteille de vin, dessert, etc.',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, contributionController.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (contribution != null) {
      setState(() {
        final index = _participants.indexWhere((p) => p.userId == participant.userId);
        if (index != -1) {
          _participants[index].contribution = contribution;
        }
      });
      
      if (_isEditing && _existingParty != null) {
        await _databaseService.updateParticipantContribution(
          _existingParty!.id!,
          participant.userId,
          contribution,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la soirée' : 'Nouvelle soirée'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteParty,
              tooltip: 'Supprimer la soirée',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informations sur la soirée',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Titre de la soirée',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un titre';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer une description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectDate(context),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Date',
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectTime(context),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Heure',
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<PartyType>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Type de soirée',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: PartyType.aperitif,
                                  child: Text('Apéritif'),
                                ),
                                DropdownMenuItem(
                                  value: PartyType.dinner,
                                  child: Text('Repas'),
                                ),
                                DropdownMenuItem(
                                  value: PartyType.other,
                                  child: Text('Autre'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedType = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _imageUrl,
                              decoration: const InputDecoration(
                                labelText: 'URL de l\'image (optionnel)',
                                border: OutlineInputBorder(),
                                hintText: 'https://example.com/image.jpg',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _imageUrl = value;
                                });
                              },
                            ),
                            if (_imageUrl.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _imageUrl,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Text('Image non valide'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Participants',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_participants.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Aucun participant pour le moment',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _participants.length,
                                itemBuilder: (context, index) {
                                  final participant = _participants[index];
                                  return ListTile(
                                    title: Text(participant.username),
                                    subtitle: participant.contribution != null && participant.contribution!.isNotEmpty
                                        ? Text('Apporte: ${participant.contribution}')
                                        : const Text('Aucune contribution spécifiée'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (participant.userId == widget.currentUser.id)
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _updateContribution(participant),
                                            tooltip: 'Modifier votre contribution',
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline),
                                          onPressed: () {
                                            setState(() {
                                              _participants.removeAt(index);
                                            });
                                          },
                                          tooltip: 'Retirer le participant',
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 16),
                            ExpansionTile(
                              title: const Text('Ajouter des participants'),
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _allUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = _allUsers[index];
                                    final isParticipating = _participants.any((p) => p.userId == user.id);
                                    
                                    return CheckboxListTile(
                                      title: Text(user.username),
                                      subtitle: Text(user.email),
                                      value: isParticipating,
                                      onChanged: (value) => _toggleParticipation(user),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveParty,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'Mettre à jour la soirée' : 'Créer la soirée',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
