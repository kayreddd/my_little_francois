import 'package:flutter/material.dart';
import '../models/party_model.dart';
import '../models/user_model.dart';
import '../database/database_service.dart';
import 'party_detail_screen.dart';

class PartyListScreen extends StatefulWidget {
  final User currentUser;

  const PartyListScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  _PartyListScreenState createState() => _PartyListScreenState();
}

class _PartyListScreenState extends State<PartyListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Party> _upcomingParties = [];
  List<Party> _myParties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadParties();
  }

  Future<void> _loadParties() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final upcomingParties = await _databaseService.getUpcomingParties();
      final myParties = await _databaseService.getPartiesByParticipant(widget.currentUser.id!);

      setState(() {
        _upcomingParties = upcomingParties;
        _myParties = myParties;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des soirées: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soirées à thème'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Soirées à venir'),
            Tab(text: 'Mes soirées'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPartyList(_upcomingParties),
                _buildPartyList(_myParties),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PartyDetailScreen(
                currentUser: widget.currentUser,
              ),
            ),
          );

          if (result == true) {
            _loadParties();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Proposer une soirée',
      ),
    );
  }

  Widget _buildPartyList(List<Party> parties) {
    if (parties.isEmpty) {
      return const Center(
        child: Text(
          'Aucune soirée pour le moment',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadParties,
      child: ListView.builder(
        itemCount: parties.length,
        itemBuilder: (context, index) {
          final party = parties[index];
          return _buildPartyCard(party);
        },
      ),
    );
  }

  Widget _buildPartyCard(Party party) {
    final isParticipating = party.isParticipating(widget.currentUser.id!);
    final formattedDate = '${party.date.day}/${party.date.month}/${party.date.year} à ${party.date.hour}h${party.date.minute.toString().padLeft(2, '0')}';
    final partyTypeText = party.type == PartyType.aperitif ? 'Apéritif' : party.type == PartyType.dinner ? 'Repas' : 'Autre';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PartyDetailScreen(
                currentUser: widget.currentUser,
                partyId: party.id,
              ),
            ),
          );

          if (result == true) {
            _loadParties();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: party.imageUrl != null && party.imageUrl!.isNotEmpty
                  ? Image.network(
                      party.imageUrl!,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 50),
                        );
                      },
                    )
                  : Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: Icon(
                        party.type == PartyType.aperitif
                            ? Icons.local_bar
                            : party.type == PartyType.dinner
                                ? Icons.restaurant
                                : Icons.celebration,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          party.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          partyTypeText,
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    party.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${party.participants.length} participant(s)',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isParticipating
                          ? Chip(
                              backgroundColor: Colors.green[100],
                              label: Text(
                                'Vous participez',
                                style: TextStyle(color: Colors.green[800]),
                              ),
                              avatar: Icon(Icons.check_circle, color: Colors.green[800], size: 18),
                            )
                          : OutlinedButton.icon(
                              onPressed: () async {
                                await _databaseService.addParticipantToParty(
                                  party.id!,
                                  PartyParticipant(
                                    userId: widget.currentUser.id!,
                                    username: widget.currentUser.username,
                                  ),
                                );
                                _loadParties();
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Participer'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
