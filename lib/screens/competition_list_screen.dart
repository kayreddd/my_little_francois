import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/competition_model.dart';
import '../database/database_service.dart';
import 'competition_detail_screen.dart';

class CompetitionListScreen extends StatefulWidget {
  final User user;

  const CompetitionListScreen({super.key, required this.user});

  @override
  State<CompetitionListScreen> createState() => _CompetitionListScreenState();
}

class _CompetitionListScreenState extends State<CompetitionListScreen> with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService.instance;
  bool _isLoading = true;
  List<Competition> _upcomingCompetitions = [];
  List<Competition> _myCompetitions = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCompetitions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCompetitions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger les concours à venir
      final upcomingCompetitions = await _databaseService.getUpcomingCompetitions();
      
      // Charger les concours auxquels l'utilisateur participe
      final myCompetitions = await _databaseService.getCompetitionsByParticipant(widget.user.id!);
      
      setState(() {
        _upcomingCompetitions = upcomingCompetitions;
        _myCompetitions = myCompetitions;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des concours: $e');
      setState(() {
        _isLoading = false;
      });
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

  Widget _buildCompetitionCard(Competition competition) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final participantsCount = competition.participants.length;
    final isCreator = competition.creatorId == widget.user.id;
    final isParticipant = competition.participants.any((p) => p.userId == widget.user.id);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompetitionDetailScreen(
                user: widget.user,
                competitionId: competition.id!,
              ),
            ),
          ).then((_) => _loadCompetitions());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du concours (si disponible)
            if (competition.photoUrl != null)
              Image.network(
                competition.photoUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50),
                  );
                },
              )
            else
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.event, size: 50),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          competition.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCreator)
                        const Chip(
                          label: Text('Créateur'),
                          backgroundColor: Colors.blue,
                          labelStyle: TextStyle(color: Colors.white),
                        )
                      else if (isParticipant)
                        const Chip(
                          label: Text('Participant'),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          competition.address,
                          style: TextStyle(color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(competition.date),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$participantsCount participant${participantsCount > 1 ? 's' : ''}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  
                  // Afficher le niveau de l'utilisateur s'il participe
                  if (isParticipant) ...[
                    const SizedBox(height: 8),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.grade, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          'Votre niveau: ${_getCompetitionLevelLabel(competition.participants.firstWhere((p) => p.userId == widget.user.id).level)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Concours'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Mes concours'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Onglet des concours à venir
                _upcomingCompetitions.isEmpty
                    ? const Center(
                        child: Text('Aucun concours à venir'),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCompetitions,
                        child: ListView.builder(
                          itemCount: _upcomingCompetitions.length,
                          itemBuilder: (context, index) {
                            return _buildCompetitionCard(_upcomingCompetitions[index]);
                          },
                        ),
                      ),
                
                // Onglet de mes concours
                _myCompetitions.isEmpty
                    ? const Center(
                        child: Text('Vous ne participez à aucun concours'),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCompetitions,
                        child: ListView.builder(
                          itemCount: _myCompetitions.length,
                          itemBuilder: (context, index) {
                            return _buildCompetitionCard(_myCompetitions[index]);
                          },
                        ),
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompetitionDetailScreen(
                user: widget.user,
                isCreating: true,
              ),
            ),
          ).then((_) => _loadCompetitions());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
