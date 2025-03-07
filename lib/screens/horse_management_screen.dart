import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/horse_model.dart';
import '../database/database_service.dart';
import 'horse_edit_screen.dart';

class HorseManagementScreen extends StatefulWidget {
  final User user;

  const HorseManagementScreen({super.key, required this.user});

  @override
  State<HorseManagementScreen> createState() => _HorseManagementScreenState();
}

class _HorseManagementScreenState extends State<HorseManagementScreen> {
  List<Horse> _ownedHorses = [];
  List<Horse> _associatedHorses = [];
  List<Horse> _allHorses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHorses();
  }

  Future<void> _loadHorses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Recharger l'utilisateur actuel pour obtenir les listes de chevaux à jour
      final updatedUser = await DatabaseService.instance.getUserById(widget.user.id!);
      if (updatedUser != null) {
        // Mettre à jour la référence à l'utilisateur dans le widget parent
        // Cela n'est pas possible directement, mais nous pouvons utiliser les données mises à jour
        
        // Charger tous les chevaux
        _allHorses = await DatabaseService.instance.getAllHorses();

        // Filtrer les chevaux possédés par l'utilisateur avec les données mises à jour
        if (updatedUser.ownedHorseIds != null && updatedUser.ownedHorseIds!.isNotEmpty) {
          _ownedHorses = _allHorses
              .where((horse) => updatedUser.ownedHorseIds!.contains(horse.id))
              .toList();
        } else {
          _ownedHorses = [];
        }

        // Filtrer les chevaux associés à l'utilisateur (pour les DP) avec les données mises à jour
        if (updatedUser.associatedHorseIds != null && updatedUser.associatedHorseIds!.isNotEmpty) {
          _associatedHorses = _allHorses
              .where((horse) => updatedUser.associatedHorseIds!.contains(horse.id))
              .toList();
        } else {
          _associatedHorses = [];
        }
        
        // Afficher des informations de débogage
        print('Utilisateur rechargé: ${updatedUser.username}');
        print('Chevaux possédés: ${updatedUser.ownedHorseIds}');
        print('Chevaux associés: ${updatedUser.associatedHorseIds}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des chevaux: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addHorse() async {
    final result = await Navigator.push<Horse>(
      context,
      MaterialPageRoute(
        builder: (context) => HorseEditScreen(
          userId: widget.user.id!,
          isOwner: true,
        ),
      ),
    );

    if (result != null) {
      // Mettre à jour la liste des chevaux immédiatement
      setState(() {
        // Ajouter le nouveau cheval à la liste des chevaux possédés
        _ownedHorses.add(result);
        // Ajouter également à la liste complète
        _allHorses.add(result);
      });
      
      // Afficher un message de confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cheval ajouté avec succès')),
        );
      }
      
      // Recharger les données pour s'assurer que tout est à jour
      await _loadHorses();
    }
  }

  Future<void> _editHorse(Horse horse, bool isOwner) async {
    final result = await Navigator.push<Horse>(
      context,
      MaterialPageRoute(
        builder: (context) => HorseEditScreen(
          horse: horse,
          userId: widget.user.id!,
          isOwner: isOwner,
        ),
      ),
    );

    if (result != null) {
      // Mettre à jour la liste des chevaux immédiatement
      setState(() {
        // Mettre à jour le cheval dans la liste des chevaux possédés
        final ownedIndex = _ownedHorses.indexWhere((h) => h.id == result.id);
        if (ownedIndex >= 0) {
          _ownedHorses[ownedIndex] = result;
        }
        
        // Mettre à jour le cheval dans la liste des chevaux associés
        final associatedIndex = _associatedHorses.indexWhere((h) => h.id == result.id);
        if (associatedIndex >= 0) {
          _associatedHorses[associatedIndex] = result;
        }
        
        // Mettre à jour le cheval dans la liste complète
        final allIndex = _allHorses.indexWhere((h) => h.id == result.id);
        if (allIndex >= 0) {
          _allHorses[allIndex] = result;
        }
      });
      
      // Afficher un message de confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cheval modifié avec succès')),
        );
      }
    }
  }

  Future<void> _associateWithHorse() async {
    // Afficher une liste de tous les chevaux pour que l'utilisateur puisse s'associer à un cheval
    if (!widget.user.isDelegatedPerson) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être une personne déléguée (DP) pour vous associer à un cheval')),
      );
      return;
    }

    final availableHorses = _allHorses
        .where((horse) => 
            !_ownedHorses.contains(horse) && 
            !_associatedHorses.contains(horse))
        .toList();

    if (availableHorses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun cheval disponible pour association')),
      );
      return;
    }

    final Horse? selectedHorse = await showDialog<Horse>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir un cheval'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableHorses.length,
              itemBuilder: (context, index) {
                final horse = availableHorses[index];
                return ListTile(
                  leading: horse.photoPath != null
                      ? CircleAvatar(
                          backgroundImage: FileImage(File(horse.photoPath!)),
                        )
                      : const CircleAvatar(child: Icon(Icons.pets)),
                  title: Text(horse.name),
                  subtitle: Text('${horse.breed}, ${horse.age} ans'),
                  onTap: () {
                    Navigator.of(context).pop(horse);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );

    if (selectedHorse != null && mounted) {
      final success = await DatabaseService.instance.associateHorseWithUser(
        selectedHorse.id!,
        widget.user.id!,
        isOwner: false,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Association réussie')),
        );
        _loadHorses();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'association')),
        );
      }
    }
  }

  Future<void> _disassociateHorse(Horse horse, bool isOwner) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(isOwner
              ? 'Êtes-vous sûr de vouloir supprimer ce cheval de votre liste de propriété ?'
              : 'Êtes-vous sûr de vouloir vous désassocier de ce cheval ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      final success = await DatabaseService.instance.disassociateHorseFromUser(
        horse.id!,
        widget.user.id!,
        isOwner: isOwner,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isOwner
                ? 'Cheval supprimé de votre liste de propriété'
                : 'Désassociation réussie'),
          ),
        );
        _loadHorses();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la désassociation')),
        );
      }
    }
  }

  Widget _buildHorseList(List<Horse> horses, String title, bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (horses.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Aucun cheval dans cette catégorie'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: horses.length,
            itemBuilder: (context, index) {
              final horse = horses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: ListTile(
                  leading: horse.photoPath != null
                      ? CircleAvatar(
                          backgroundImage: FileImage(File(horse.photoPath!)),
                        )
                      : const CircleAvatar(child: Icon(Icons.pets)),
                  title: Text(horse.name),
                  subtitle: Text(
                      '${horse.breed}, ${horse.age} ans, ${horse.specialty}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editHorse(horse, isOwner),
                      ),
                      IconButton(
                        icon: const Icon(Icons.link_off),
                        onPressed: () => _disassociateHorse(horse, isOwner),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des chevaux'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHorses,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHorseList(_ownedHorses, 'Mes chevaux (propriétaire)', true),
                    if (widget.user.isDelegatedPerson)
                      _buildHorseList(_associatedHorses, 'Chevaux associés (DP)', false),
                  ],
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'addHorse',
            onPressed: _addHorse,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          if (widget.user.isDelegatedPerson)
            FloatingActionButton(
              heroTag: 'associateHorse',
              onPressed: _associateWithHorse,
              child: const Icon(Icons.link),
            ),
        ],
      ),
    );
  }
}
