// lib/screens/historique/historique_triathlon_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triathlon_app/screens/resultat/saisie_resultat_screen.dart';
import 'package:triathlon_app/screens/resultat/visualisation_resultat_screen.dart';
import '../../models/sport_type.dart';
import '../../models/triathlon_seance.dart';
import '../../services/data_manager.dart';
import '../../constants/triathlon_colors.dart';
import '../../constants/triathlon_dimens.dart';
import '../seance/triathlon_visualisation_seance_screen.dart';

class HistoriqueTriathlonScreen extends StatefulWidget {
  const HistoriqueTriathlonScreen({super.key});

  @override
  _HistoriqueTriathlonScreenState createState() =>
      _HistoriqueTriathlonScreenState();
}

class _HistoriqueTriathlonScreenState extends State<HistoriqueTriathlonScreen> {
  List<TriathlonSeance> _seances = [];
  bool _isLoading = true;
  SportType? _selectedSport;

  @override
  void initState() {
    super.initState();
    _chargerSeances();
  }

  Future<void> _chargerSeances() async {
    try {
      final dataManager = Provider.of<DataManager>(context, listen: false);
      // Au lieu de : final dataManager = DataManager.data_manager;

      List<TriathlonSeance> allSeances = await dataManager.loadAllSeances();

      // Trier par date de création (la plus récente en premier)
      allSeances.sort((a, b) => b.id.compareTo(a.id));

      if (mounted) {
        setState(() {
          _seances = allSeances;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur chargement séances: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<TriathlonSeance> _getFilteredSeances() {
    if (_selectedSport == null) {
      return _seances;
    }
    return _seances
        .where((seance) => seance.sportType == _selectedSport)
        .toList();
  }

  Widget _buildSportFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Tous
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: const Text('Tous'),
              selected: _selectedSport == null,
              onSelected: (selected) {
                setState(() {
                  _selectedSport = null;
                });
              },
              selectedColor: TriathlonColors.running.withOpacity(0.3),
              checkmarkColor: TriathlonColors.running,
            ),
          ),

          // Filtres par sport
          ...SportType.values.map((sport) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(sport.displayName),
                selected: _selectedSport == sport,
                onSelected: (selected) {
                  setState(() {
                    _selectedSport = sport;
                  });
                },
                selectedColor: sport.color.withOpacity(0.3),
                checkmarkColor: sport.color,
                avatar: Icon(
                  _getSportIcon(sport),
                  size: 16,
                  color: sport.color,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredSeances = _getFilteredSeances();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Séances'),
        backgroundColor: TriathlonColors.running,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerSeances,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtres
                Padding(
                  padding: const EdgeInsets.all(TriathlonDimens.paddingMedium),
                  child: _buildSportFilterChips(),
                ),

                // Compteur
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TriathlonDimens.paddingMedium,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${filteredSeances.length} séance${filteredSeances.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: TriathlonColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedSport != null)
                        Icon(
                          _getSportIcon(_selectedSport!),
                          color: _selectedSport!.color,
                          size: 20,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Liste
                Expanded(
                  child: filteredSeances.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 80,
                                color: TriathlonColors.textSecondary,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _selectedSport == null
                                    ? 'Aucune séance sauvegardée'
                                    : 'Aucune séance en ${_selectedSport!.displayName}',
                                style: TextStyle(
                                  color: TriathlonColors.textSecondary,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Créer une séance'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _chargerSeances,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(
                                TriathlonDimens.paddingMedium),
                            itemCount: filteredSeances.length,
                            itemBuilder: (context, index) {
                              final seance = filteredSeances[index];
                              return _buildSeanceCard(seance);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSeanceCard(TriathlonSeance seance) {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final resultats = dataManager.getResultatsForSeance(seance.id);
    final aDesResultats = resultats.isNotEmpty;
    final totalCases = seance.exercices.fold(
        0, (sum, exercice) => sum + exercice.nbSeries * exercice.nbRepetitions);
    final casesRemplis = resultats.length;

    return Card(
      margin: const EdgeInsets.only(bottom: TriathlonDimens.paddingMedium),
      elevation: 4,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: seance.sportType.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  _getSportIcon(seance.sportType),
                  color: seance.sportType.color,
                ),
              ),
              if (aDesResultats)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$casesRemplis',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        title: Text(
          seance.nom,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              seance.sportType.displayName,
              style: TextStyle(
                color: seance.sportType.color,
                fontSize: 12,
              ),
            ),
            Text(
              '${seance.exercices.length} exercice${seance.exercices.length > 1 ? 's' : ''} • $totalCases répétitions',
              style: TextStyle(
                color: TriathlonColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              'Créée le: ${_formatDate(seance.dateCreation)}',
              style: TextStyle(
                color: TriathlonColors.textSecondary,
                fontSize: 10,
              ),
            ),
            if (aDesResultats)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$casesRemplis/$totalCases complétés',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton pour voir/modifier les résultats
            IconButton(
              icon: Icon(
                aDesResultats ? Icons.edit : Icons.add_chart,
                color: aDesResultats ? Colors.orange : seance.sportType.color,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SaisieResultatScreen(seance: seance),
                  ),
                );
              },
            ),
            // Bouton pour voir la visualisation des résultats
            if (aDesResultats)
              IconButton(
                icon: const Icon(Icons.bar_chart, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VisualisationResultatScreen(seance: seance),
                    ),
                  );
                },
              ),
            // Bouton suppression
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade300),
              onPressed: () => _showDeleteDialog(seance),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TriathlonVisualisationSeanceScreen(seance: seance),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteDialog(TriathlonSeance seance) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la séance'),
        content: Text(
          'Voulez-vous vraiment supprimer "${seance.nom}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final dataManager = Provider.of<DataManager>(context, listen: false);
      bool deleted = await dataManager.deleteSeanceById(seance.id);

      if (deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Séance supprimée'),
            backgroundColor: Colors.green,
          ),
        );
        await _chargerSeances();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getSportIcon(SportType sportType) {
    switch (sportType) {
      case SportType.swimming:
        return Icons.pool;
      case SportType.cycling:
        return Icons.directions_bike;
      case SportType.running:
        return Icons.directions_run;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
