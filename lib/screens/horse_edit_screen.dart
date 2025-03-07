import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/horse_model.dart';
import '../database/database_service.dart';

class HorseEditScreen extends StatefulWidget {
  final Horse? horse;
  final int userId;
  final bool isOwner;

  const HorseEditScreen({
    super.key,
    this.horse,
    required this.userId,
    required this.isOwner,
  });

  @override
  State<HorseEditScreen> createState() => _HorseEditScreenState();
}

class _HorseEditScreenState extends State<HorseEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _coatController;
  late TextEditingController _breedController;
  late String _gender;
  late String _specialty;
  String? _photoPath;
  String? _errorMessage;

  final List<String> _genders = ['Mâle', 'Femelle', 'Hongre'];
  final List<String> _specialties = [
    'Dressage',
    'Saut d\'obstacle',
    'Endurance',
    'Complet',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.horse?.name ?? '');
    _ageController = TextEditingController(text: widget.horse?.age.toString() ?? '');
    _coatController = TextEditingController(text: widget.horse?.coat ?? '');
    _breedController = TextEditingController(text: widget.horse?.breed ?? '');
    _gender = widget.horse?.gender ?? _genders[0];
    _specialty = widget.horse?.specialty ?? _specialties[0];
    _photoPath = widget.horse?.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _coatController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  Future<void> _saveHorse() async {
    if (_formKey.currentState!.validate()) {
      try {
        final horse = Horse(
          id: widget.horse?.id,
          name: _nameController.text,
          age: int.parse(_ageController.text),
          coat: _coatController.text,
          breed: _breedController.text,
          gender: _gender,
          specialty: _specialty,
          photoPath: _photoPath,
          ownerId: widget.isOwner ? widget.userId : widget.horse?.ownerId,
        );

        bool success = false;
        Horse? resultHorse;
        
        if (widget.horse == null) {
          // Création d'un nouveau cheval
          final newHorse = await DatabaseService.instance.createHorse(horse);
          success = newHorse != null;
          resultHorse = newHorse;
          
          if (success && widget.isOwner && newHorse != null) {
            // Associer le cheval à l'utilisateur en tant que propriétaire
            await DatabaseService.instance.associateHorseWithUser(
              newHorse.id!,
              widget.userId,
              isOwner: true,
            );
          }
        } else {
          // Mise à jour d'un cheval existant
          success = await DatabaseService.instance.updateHorse(horse);
          if (success) {
            // Récupérer le cheval mis à jour depuis la base de données
            resultHorse = await DatabaseService.instance.getHorse(horse.id!);
          }
        }

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.horse == null
                  ? 'Cheval créé avec succès'
                  : 'Cheval mis à jour avec succès'),
            ),
          );
          // Retourner le cheval complet avec l'ID généré par la base de données
          Navigator.pop(context, resultHorse);
        } else if (mounted) {
          setState(() {
            _errorMessage = 'Erreur lors de l\'enregistrement du cheval';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Erreur: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.horse == null ? 'Ajouter un cheval' : 'Modifier le cheval'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _photoPath != null
                      ? FileImage(File(_photoPath!))
                      : null,
                  child: _photoPath == null
                      ? const Icon(Icons.pets, size: 50)
                      : null,
                ),
              ),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Choisir une photo'),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du cheval',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Âge',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'âge';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Veuillez entrer un âge valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _coatController,
                decoration: const InputDecoration(
                  labelText: 'Robe',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la robe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Race',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la race';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'Sexe',
                  border: OutlineInputBorder(),
                ),
                items: _genders.map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _gender = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner le sexe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _specialty,
                decoration: const InputDecoration(
                  labelText: 'Spécialité',
                  border: OutlineInputBorder(),
                ),
                items: _specialties.map((specialty) {
                  return DropdownMenuItem<String>(
                    value: specialty,
                    child: Text(specialty),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _specialty = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner la spécialité';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveHorse,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(widget.horse == null ? 'Ajouter' : 'Mettre à jour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
