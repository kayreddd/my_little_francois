import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/horse_model.dart';
import '../models/riding_lesson_model.dart';
import '../database/database_service.dart';

class RidingLessonScreen extends StatefulWidget {
  final User user;

  const RidingLessonScreen({super.key, required this.user});

  @override
  State<RidingLessonScreen> createState() => _RidingLessonScreenState();
}

class _RidingLessonScreenState extends State<RidingLessonScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final _formKey = GlobalKey<FormState>();
  
  // Valeurs par défaut
  TrainingGround _selectedTrainingGround = TrainingGround.arena;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  LessonDuration _selectedDuration = LessonDuration.oneHour;
  Discipline _selectedDiscipline = Discipline.dressage;
  
  // Pour la sélection du cheval
  List<Horse> _userHorses = [];
  Horse? _selectedHorse;
  
  final _notesController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoadingHorses = true;

  @override
  void initState() {
    super.initState();
    _loadUserHorses();
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserHorses() async {
    setState(() {
      _isLoadingHorses = true;
    });
    
    try {
      // Charger les chevaux de l'utilisateur
      final horses = await _databaseService.getHorsesByOwner(widget.user.id!);
      
      setState(() {
        _userHorses = horses;
        _isLoadingHorses = false;
        
        // Sélectionner le premier cheval par défaut si disponible
        if (_userHorses.isNotEmpty) {
          _selectedHorse = _userHorses.first;
        }
      });
    } catch (e) {
      print('Erreur lors du chargement des chevaux: $e');
      setState(() {
        _isLoadingHorses = false;
      });
    }
  }
  
  String _getTrainingGroundLabel(TrainingGround ground) {
    switch (ground) {
      case TrainingGround.arena:
        return 'Manège';
      case TrainingGround.outdoorArena:
        return 'Carrière';
      default:
        return 'Inconnu';
    }
  }
  
  String _getDurationLabel(LessonDuration duration) {
    switch (duration) {
      case LessonDuration.thirtyMinutes:
        return '30 minutes';
      case LessonDuration.oneHour:
        return '1 heure';
      default:
        return 'Inconnu';
    }
  }
  
  String _getDisciplineLabel(Discipline discipline) {
    switch (discipline) {
      case Discipline.dressage:
        return 'Dressage';
      case Discipline.jumpingObstacles:
        return 'Saut d\'obstacle';
      case Discipline.endurance:
        return 'Endurance';
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
  
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  Future<void> _saveRidingLesson() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Combiner la date et l'heure
        final dateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
        
        // Créer le cours
        final lesson = RidingLesson(
          userId: widget.user.id!,
          horseId: _selectedHorse?.id,
          dateTime: dateTime,
          trainingGround: _selectedTrainingGround,
          duration: _selectedDuration,
          discipline: _selectedDiscipline,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
        
        // Enregistrer le cours dans la base de données
        final createdLesson = await _databaseService.createRidingLesson(lesson);
        
        setState(() {
          _isLoading = false;
        });
        
        if (createdLesson != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cours programmé avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Retourner à l'écran précédent
            Navigator.of(context).pop();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur lors de la programmation du cours'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('Erreur lors de la programmation du cours: $e');
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la programmation du cours'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programmer un cours'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Programmez votre cours d\'équitation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Sélection du terrain d'entraînement
                    const Text(
                      'Terrain d\'entraînement',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<TrainingGround>(
                      segments: [
                        ButtonSegment<TrainingGround>(
                          value: TrainingGround.arena,
                          label: Text(_getTrainingGroundLabel(TrainingGround.arena)),
                          icon: const Icon(Icons.home),
                        ),
                        ButtonSegment<TrainingGround>(
                          value: TrainingGround.outdoorArena,
                          label: Text(_getTrainingGroundLabel(TrainingGround.outdoorArena)),
                          icon: const Icon(Icons.landscape),
                        ),
                      ],
                      selected: {_selectedTrainingGround},
                      onSelectionChanged: (Set<TrainingGround> newSelection) {
                        setState(() {
                          _selectedTrainingGround = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Sélection de la date et de l'heure
                    const Text(
                      'Date et heure',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time),
                            label: Text('${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
                            onPressed: () => _selectTime(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Sélection de la durée
                    const Text(
                      'Durée',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<LessonDuration>(
                      segments: [
                        ButtonSegment<LessonDuration>(
                          value: LessonDuration.thirtyMinutes,
                          label: Text(_getDurationLabel(LessonDuration.thirtyMinutes)),
                          icon: const Icon(Icons.timer),
                        ),
                        ButtonSegment<LessonDuration>(
                          value: LessonDuration.oneHour,
                          label: Text(_getDurationLabel(LessonDuration.oneHour)),
                          icon: const Icon(Icons.hourglass_bottom),
                        ),
                      ],
                      selected: {_selectedDuration},
                      onSelectionChanged: (Set<LessonDuration> newSelection) {
                        setState(() {
                          _selectedDuration = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Sélection de la discipline
                    const Text(
                      'Discipline',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Discipline>(
                      value: _selectedDiscipline,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      items: Discipline.values.map((discipline) {
                        return DropdownMenuItem<Discipline>(
                          value: discipline,
                          child: Text(_getDisciplineLabel(discipline)),
                        );
                      }).toList(),
                      onChanged: (Discipline? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedDiscipline = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Sélection du cheval (si l'utilisateur en possède)
                    if (_isLoadingHorses)
                      const Center(child: CircularProgressIndicator())
                    else if (_userHorses.isNotEmpty) ...[
                      const Text(
                        'Cheval',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Horse>(
                        value: _selectedHorse,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        items: _userHorses.map((horse) {
                          return DropdownMenuItem<Horse>(
                            value: horse,
                            child: Text(horse.name),
                          );
                        }).toList(),
                        onChanged: (Horse? newValue) {
                          setState(() {
                            _selectedHorse = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Notes
                    const Text(
                      'Notes (optionnel)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Ajoutez des notes supplémentaires...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    
                    // Bouton de validation
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveRidingLesson,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Programmer le cours',
                          style: TextStyle(fontSize: 16),
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
