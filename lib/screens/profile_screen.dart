import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../database/database_service.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _ageController;
  late TextEditingController _ffeProfileLinkController;
  late bool _isDelegatedPerson;
  String? _profilePicturePath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneNumberController = TextEditingController(text: widget.user.phoneNumber ?? '');
    _ageController = TextEditingController(text: widget.user.age?.toString() ?? '');
    _ffeProfileLinkController = TextEditingController(text: widget.user.ffeProfileLink ?? '');
    _isDelegatedPerson = widget.user.isDelegatedPerson;
    _profilePicturePath = widget.user.profilePicturePath;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _ageController.dispose();
    _ffeProfileLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profilePicturePath = image.path;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedUser = widget.user.copyWith(
          username: _usernameController.text,
          email: _emailController.text,
          phoneNumber: _phoneNumberController.text.isEmpty ? null : _phoneNumberController.text,
          age: _ageController.text.isEmpty ? null : int.tryParse(_ageController.text),
          ffeProfileLink: _ffeProfileLinkController.text.isEmpty ? null : _ffeProfileLinkController.text,
          isDelegatedPerson: _isDelegatedPerson,
          profilePicturePath: _profilePicturePath,
        );

        final success = await DatabaseService.instance.updateUserProfile(updatedUser);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil mis à jour avec succès')),
          );
          Navigator.pop(context, updatedUser);
        } else if (mounted) {
          setState(() {
            _errorMessage = 'Erreur lors de la mise à jour du profil';
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
        title: const Text('Modifier mon profil'),
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
                  backgroundImage: _profilePicturePath != null
                      ? FileImage(File(_profilePicturePath!))
                      : null,
                  child: _profilePicturePath == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Changer la photo de profil'),
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
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom d\'utilisateur';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
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
                  if (value != null && value.isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null || age <= 0) {
                      return 'Veuillez entrer un âge valide';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ffeProfileLinkController,
                decoration: const InputDecoration(
                  labelText: 'Lien vers profil FFE',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Je suis une personne déléguée (DP)'),
                value: _isDelegatedPerson,
                onChanged: (value) {
                  setState(() {
                    _isDelegatedPerson = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Mettre à jour mon profil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
