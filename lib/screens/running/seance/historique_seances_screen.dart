// lib/screens/historique/historique_seances_screen.dart
import 'package:flutter/material.dart';
import '../../../constants/triathlon_colors.dart';
import '../../../constants/triathlon_dimens.dart';
import '../../../models/triathlon_seance.dart';
import '../../../services/data_manager.dart';
import '../../../widgets/triathlon_seance_item.dart';
import 'package:triathlon_app/screens/seance/triathlon_visualisation_seance_screen.dart';
import 'package:triathlon_app/screens/main_triathlon_menu_screen.dart';

class HistoriqueSeancesScreen extends StatefulWidget {
  const HistoriqueSeancesScreen({super.key});

  @override
  _HistoriqueSeancesScreenState createState() =>
      _HistoriqueSeancesScreenState();
}

class _HistoriqueSeancesScreenState extends State<HistoriqueSeancesScreen> {
  List<TriathlonSeance> _seances = [];
  bool _isLoading = true;
  late DataManager _dataManager;

  @override
  void initState() {
    super.initState();
    _dataManager = DataManager();
    _chargerSeances();
  }

  Future<void> _chargerSeances() async {
    try {
      List<TriathlonSeance> loadedSeances = await _dataManager.loadAllSeances();

      // Trier par date de création (ID décroissant)
      loadedSeances.sort((a, b) => b.id.compareTo(a.id));

      if (mounted) {
        setState(() {
          _seances = loadedSeances;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur chargement: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: TriathlonDimens.paddingLarge,
              right: TriathlonDimens.paddingLarge,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  TriathlonColors.running.withOpacity(0.9),
                  TriathlonColors.running
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Historique des Séances',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toutes vos séances triathlon',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Contenu
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: TriathlonColors.running,
                    ),
                  )
                : _seances.isEmpty
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
                              'Aucune séance sauvegardée',
                              style: TextStyle(
                                color: TriathlonColors.textSecondary,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Créez votre première séance !',
                              style: TextStyle(
                                color: TriathlonColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _chargerSeances,
                        color: TriathlonColors.running,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(
                              TriathlonDimens.paddingLarge),
                          itemCount: _seances.length,
                          itemBuilder: (context, index) {
                            return TriathlonSeanceItem(
                              seance: _seances[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TriathlonVisualisationSeanceScreen(
                                      seance: _seances[index],
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () {
                                _showDeleteDialog(_seances[index]);
                              },
                            );
                          },
                        ),
                      ),
          ),

          // Boutons fixes en bas
          Container(
            padding: EdgeInsets.only(
              left: TriathlonDimens.paddingLarge,
              right: TriathlonDimens.paddingLarge,
              top: TriathlonDimens.paddingMedium,
              bottom: MediaQuery.of(context).viewPadding.bottom +
                  TriathlonDimens.paddingMedium,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Bouton Retour
                SizedBox(
                  width: double.infinity,
                  height: TriathlonDimens.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainTriathlonMenuScreen(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TriathlonColors.running,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusXLarge,
                        ),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'RETOUR AU MENU',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(TriathlonSeance seance) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la séance'),
        content: Text(
          'Voulez-vous vraiment supprimer la séance "${seance.nom}" ?',
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
      bool deleted = await _dataManager.deleteSeanceById(seance.id);

      if (deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Séance supprimée'),
            backgroundColor: Colors.green,
          ),
        );

        // Recharger la liste
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
}
