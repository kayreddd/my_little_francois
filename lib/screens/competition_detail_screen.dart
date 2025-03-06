import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/competition_model.dart';
import '../database/database_service.dart';

class CompetitionDetailScreen extends StatefulWidget {
  final User user;
  final int? competitionId;
  final bool isCreating;

  const CompetitionDetailScreen({
    super.key,
    required this.user,
    this.competitionId,
    this.isCreating = false,
  }) : assert(isCreating || competitionId != null);

  @override
  State<CompetitionDetailScreen> createState() => _CompetitionDetailScreenState();
}

class _CompetitionDetailScreenState extends State<CompetitionDetailScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  Competition? _competition;
  List<User> _allUsers = [];
  
  // Contrôleurs pour les champs de formulaire
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String? _photoUrl;
  
  // Pour la participation de l'utilisateur actuel
  bool _isParticipating = false;
  CompetitionLevel _selectedLevel = CompetitionLevel.club2;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Charger tous les utilisateurs
      final users = await _databaseService.getAllUsers();
      
      if (widget.isCreating) {
        // Initialiser un nouveau concours vide
        setState(() {
          _allUsers = users;
          _isLoading = false;
        });
      } else {
        // Charger le concours existant
        final competition = await _databaseService.getCompetition(widget.competitionId!);
        
        if (competition != null) {
          // Initialiser les contrôleurs avec les données du concours
          _nameController.text = competition.name;
          _addressController.text = competition.address;
          _selectedDate = competition.date;
          _photoUrl = competition.photoUrl;
          
          // Vérifier si l'utilisateur actuel participe déjà
          final participantIndex = competition.participants.indexWhere((p) => p.userId == widget.user.id!);
          if (participantIndex != -1) {
            _isParticipating = true;
            _selectedLevel = competition.participants[participantIndex].level;
          }
          
          setState(() {
            _competition = competition;
            _allUsers = users;
            _isLoading = false;
          });
        } else {
          // Concours non trouvé
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Concours non trouvé'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du chargement des données'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  String _getCompetitionLevelLabel(CompetitionLevel level) {
    switch (level) {
      case CompetitionLevel.amateur:
        return 'Amateur';
      case CompetitionLevel.club1:
        return 'Club 1';
      case CompetitionLevel.club2:
        return 'Club 2';
      case CompetitionLevel.club3:
        return 'Club 3';
      case CompetitionLevel.club4:
        return 'Club 4';
      default:
        return 'Inconnu';
    }
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
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _saveCompetition() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        if (widget.isCreating) {
          // Créer un nouveau concours
          final newCompetition = Competition(
            name: _nameController.text,
            address: _addressController.text,
            date: _selectedDate,
            photoUrl: _photoUrl,
            participants: _isParticipating 
              ? [CompetitionParticipant(userId: widget.user.id!, level: _selectedLevel)]
              : [],
            creatorId: widget.user.id!,
          );
          
          final createdCompetition = await _databaseService.createCompetition(newCompetition);
          
          setState(() {
            _isSaving = false;
          });
          
          if (createdCompetition != null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Concours créé avec succès !'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erreur lors de la création du concours'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          // Mettre à jour un concours existant
          if (_competition != null) {
            final updatedCompetition = _competition!.copyWith(
              name: _nameController.text,
              address: _addressController.text,
              date: _selectedDate,
              photoUrl: _photoUrl,
            );
            
            final success = await _databaseService.updateCompetition(updatedCompetition);
            
            // Gérer la participation de l'utilisateur actuel
            if (success) {
              if (_isParticipating) {
                await _databaseService.addParticipantToCompetition(
                  updatedCompetition.id!,
                  CompetitionParticipant(
                    userId: widget.user.id!,
                    level: _selectedLevel,
                  ),
                );
              } else {
                // Si l'utilisateur était participant mais ne l'est plus
                final wasParticipant = _competition!.participants.any((p) => p.userId == widget.user.id!);
                if (wasParticipant) {
                  await _databaseService.removeParticipantFromCompetition(
                    updatedCompetition.id!,
                    widget.user.id!,
                  );
                }
              }
            }
            
            setState(() {
              _isSaving = false;
            });
            
            if (success) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Concours mis à jour avec succès !'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de la mise à jour du concours'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        }
      } catch (e) {
        print('Erreur lors de l\'enregistrement du concours: $e');
        setState(() {
          _isSaving = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'enregistrement du concours'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  Future<void> _deleteCompetition() async {
    if (_competition == null) return;
    
    // Demander confirmation avant de supprimer
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le concours'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce concours ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final success = await _databaseService.deleteCompetition(_competition!.id!);
        
        setState(() {
          _isLoading = false;
        });
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Concours supprimé avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur lors de la suppression du concours'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('Erreur lors de la suppression du concours: $e');
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la suppression du concours'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  Widget _buildParticipantsList() {
    if (_competition == null || _competition!.participants.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Aucun participant pour le moment'),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _competition!.participants.length,
      itemBuilder: (context, index) {
        final participant = _competition!.participants[index];
        final user = _allUsers.firstWhere(
          (u) => u.id == participant.userId,
          orElse: () => User(
            username: 'Utilisateur inconnu',
            password: '',
            email: '',
          ),
        );
        
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profilePicturePath != null
              ? user.profilePicturePath!.startsWith('http')
                ? NetworkImage(user.profilePicturePath!) as ImageProvider
                : FileImage(File(user.profilePicturePath!))
              : null,
            child: user.profilePicturePath == null
              ? const Icon(Icons.person)
              : null,
          ),
          title: Text(user.username),
          subtitle: Text('Niveau: ${_getCompetitionLevelLabel(participant.level)}'),
          trailing: participant.userId == widget.user.id!
            ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Permettre à l'utilisateur de modifier son niveau
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Modifier votre niveau'),
                      content: DropdownButtonFormField<CompetitionLevel>(
                        value: participant.level,
                        items: CompetitionLevel.values.map((level) {
                          return DropdownMenuItem<CompetitionLevel>(
                            value: level,
                            child: Text(_getCompetitionLevelLabel(level)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedLevel = newValue;
                            });
                          }
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            
                            setState(() {
                              _isLoading = true;
                            });
                            
                            try {
                              final success = await _databaseService.addParticipantToCompetition(
                                _competition!.id!,
                                CompetitionParticipant(
                                  userId: widget.user.id!,
                                  level: _selectedLevel,
                                ),
                              );
                              
                              if (success) {
                                // Recharger les données
                                await _loadData();
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Erreur lors de la mise à jour du niveau'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              print('Erreur lors de la mise à jour du niveau: $e');
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          child: const Text('Enregistrer'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCreator = _competition != null && _competition!.creatorId == widget.user.id!;
    final canEdit = widget.isCreating || isCreator;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCreating ? 'Nouveau concours' : 'Détails du concours'),
        actions: [
          if (!widget.isCreating && isCreator)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCompetition,
            ),
        ],
      ),
      body: _isLoading || _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du concours
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du concours',
                        border: OutlineInputBorder(),
                      ),
                      enabled: canEdit,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom pour le concours';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Adresse du concours
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        border: OutlineInputBorder(),
                      ),
                      enabled: canEdit,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une adresse pour le concours';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Date du concours
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                            onPressed: canEdit ? () => _selectDate(context) : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // URL de la photo (optionnel)
                    TextFormField(
                      initialValue: _photoUrl,
                      decoration: const InputDecoration(
                        labelText: 'URL de la photo (optionnel)',
                        border: OutlineInputBorder(),
                        hintText: 'https://example.com/image.jpg',
                      ),
                      enabled: canEdit,
                      onChanged: (value) {
                        setState(() {
                          _photoUrl = value.isNotEmpty ? value : null;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Section pour participer au concours
                    if (!widget.isCreating) ...[
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      Text(
                        'Participation',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      
                      SwitchListTile(
                        title: const Text('Je participe à ce concours'),
                        value: _isParticipating,
                        onChanged: (value) {
                          setState(() {
                            _isParticipating = value;
                          });
                        },
                      ),
                      
                      if (_isParticipating) ...[
                        const SizedBox(height: 8),
                        const Text('Niveau de participation:'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<CompetitionLevel>(
                          value: _selectedLevel,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          items: CompetitionLevel.values.map((level) {
                            return DropdownMenuItem<CompetitionLevel>(
                              value: level,
                              child: Text(_getCompetitionLevelLabel(level)),
                            );
                          }).toList(),
                          onChanged: (CompetitionLevel? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedLevel = newValue;
                              });
                            }
                          },
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Liste des participants
                      Text(
                        'Participants',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      
                      _buildParticipantsList(),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Bouton de validation
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canEdit ? _saveCompetition : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.isCreating ? 'Créer le concours' : 'Enregistrer les modifications',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
