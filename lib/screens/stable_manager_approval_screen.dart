import 'package:flutter/material.dart';
import '../models/riding_lesson_model.dart';
import '../models/party_model.dart';
import '../models/user_model.dart';
import '../database/database_service.dart';
import '../utils/date_formatter.dart';
import '../models/horse_model.dart'; // Importation du modèle Horse

class StableManagerApprovalScreen extends StatefulWidget {
  final User currentUser;

  const StableManagerApprovalScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  _StableManagerApprovalScreenState createState() => _StableManagerApprovalScreenState();
}

class _StableManagerApprovalScreenState extends State<StableManagerApprovalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService.instance;
  List<RidingLesson> _pendingLessons = [];
  List<Party> _pendingParties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPendingItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pendingLessons = await _databaseService.getPendingRidingLessons();
      final pendingParties = await _databaseService.getPendingParties();

      setState(() {
        _pendingLessons = pendingLessons;
        _pendingParties = pendingParties;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des éléments en attente: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveLesson(RidingLesson lesson) async {
    try {
      final success = await _databaseService.approveRidingLesson(lesson.id!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cours approuvé avec succès')),
        );
        _loadPendingItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'approbation du cours')),
        );
      }
    } catch (e) {
      print('Erreur lors de l\'approbation du cours: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur est survenue')),
      );
    }
  }

  Future<void> _rejectLesson(RidingLesson lesson) async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motif du refus'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Veuillez indiquer le motif du refus',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final success = await _databaseService.rejectRidingLesson(lesson.id!, result);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cours refusé avec succès')),
          );
          _loadPendingItems();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors du refus du cours')),
          );
        }
      } catch (e) {
        print('Erreur lors du refus du cours: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Une erreur est survenue')),
        );
      }
    }
  }

  Future<void> _approveParty(Party party) async {
    try {
      final success = await _databaseService.approveParty(party.id!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Soirée approuvée avec succès')),
        );
        _loadPendingItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'approbation de la soirée')),
        );
      }
    } catch (e) {
      print('Erreur lors de l\'approbation de la soirée: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur est survenue')),
      );
    }
  }

  Future<void> _rejectParty(Party party) async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motif du refus'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Veuillez indiquer le motif du refus',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final success = await _databaseService.rejectParty(party.id!, result);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Soirée refusée avec succès')),
          );
          _loadPendingItems();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors du refus de la soirée')),
          );
        }
      } catch (e) {
        print('Erreur lors du refus de la soirée: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Une erreur est survenue')),
        );
      }
    }
  }

  Widget _buildLessonCard(RidingLesson lesson) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<User?>(
              future: _databaseService.getUserById(lesson.userId),
              builder: (context, snapshot) {
                final username = snapshot.data?.username ?? 'Utilisateur inconnu';
                return Text(
                  'Demandé par: $username',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 8),
            Text('Date: ${DateFormatter.formatDateTime(lesson.dateTime)}'),
            Text('Durée: ${lesson.duration == LessonDuration.thirtyMinutes ? '30 minutes' : '1 heure'}'),
            Text('Terrain: ${lesson.trainingGround == TrainingGround.arena ? 'Manège' : 'Carrière'}'),
            Text('Discipline: ${_getDisciplineName(lesson.discipline)}'),
            if (lesson.horseId != null)
              FutureBuilder<Horse?>(
                future: _databaseService.getHorseById(lesson.horseId!),
                builder: (context, snapshot) {
                  final horseName = snapshot.data?.name ?? 'Cheval inconnu';
                  return Text('Cheval: $horseName');
                },
              ),
            if (lesson.notes != null && lesson.notes!.isNotEmpty)
              Text('Notes: ${lesson.notes}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _rejectLesson(lesson),
                  child: const Text('Refuser', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _approveLesson(lesson),
                  child: const Text('Approuver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartyCard(Party party) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              party.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<User?>(
              future: _databaseService.getUserById(party.creatorId),
              builder: (context, snapshot) {
                final username = snapshot.data?.username ?? 'Utilisateur inconnu';
                return Text('Organisé par: $username');
              },
            ),
            const SizedBox(height: 8),
            Text('Date: ${DateFormatter.formatDateTime(party.date)}'),
            Text('Type: ${_getPartyTypeName(party.type)}'),
            const SizedBox(height: 8),
            Text('Description: ${party.description}'),
            const SizedBox(height: 8),
            Text('Participants: ${party.participants.length}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _rejectParty(party),
                  child: const Text('Refuser', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _approveParty(party),
                  child: const Text('Approuver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDisciplineName(Discipline discipline) {
    switch (discipline) {
      case Discipline.dressage:
        return 'Dressage';
      case Discipline.jumpingObstacles:
        return 'Saut d\'obstacles';
      case Discipline.endurance:
        return 'Endurance';
      default:
        return 'Inconnu';
    }
  }

  String _getPartyTypeName(PartyType type) {
    switch (type) {
      case PartyType.aperitif:
        return 'Apéritif';
      case PartyType.dinner:
        return 'Repas';
      case PartyType.other:
        return 'Autre';
      default:
        return 'Inconnu';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.currentUser.isStableManager) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Accès refusé'),
        ),
        body: const Center(
          child: Text('Vous n\'avez pas les droits d\'accès à cette page.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation des demandes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cours d\'équitation'),
            Tab(text: 'Soirées'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Onglet des cours d'équitation
                _pendingLessons.isEmpty
                    ? const Center(child: Text('Aucun cours en attente d\'approbation'))
                    : ListView.builder(
                        itemCount: _pendingLessons.length,
                        itemBuilder: (context, index) => _buildLessonCard(_pendingLessons[index]),
                      ),
                
                // Onglet des soirées
                _pendingParties.isEmpty
                    ? const Center(child: Text('Aucune soirée en attente d\'approbation'))
                    : ListView.builder(
                        itemCount: _pendingParties.length,
                        itemBuilder: (context, index) => _buildPartyCard(_pendingParties[index]),
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadPendingItems,
        child: const Icon(Icons.refresh),
        tooltip: 'Actualiser',
      ),
    );
  }
}
