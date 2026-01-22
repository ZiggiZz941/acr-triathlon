import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/triathlon_colors.dart';
import '../../constants/triathlon_dimens.dart';
import '../../models/sport_type.dart';
import '../../models/triathlon_seance.dart';
import '../../services/data_manager.dart';
import '../../widgets/triathlon_seance_item.dart';
import '../seance/triathlon_visualisation_seance_screen.dart';
import 'cycling_creation_seance_screen.dart';

class CyclingHistoriqueScreen extends StatefulWidget {
  const CyclingHistoriqueScreen({super.key});

  @override
  _CyclingHistoriqueScreenState createState() =>
      _CyclingHistoriqueScreenState();
}

class _CyclingHistoriqueScreenState extends State<CyclingHistoriqueScreen> {
  List<TriathlonSeance> _seances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerSeances();
  }

  Future<void> _chargerSeances() async {
    DataManager dataManager = Provider.of<DataManager>(context, listen: false);
    List<TriathlonSeance> loadedSeances =
        dataManager.getSeancesBySport(SportType.cycling);

    setState(() {
      _seances = loadedSeances;
      _isLoading = false;
    });
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
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: TriathlonDimens.paddingLarge,
              right: TriathlonDimens.paddingLarge,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: TriathlonColors.cyclingGradient,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(TriathlonDimens.borderRadiusXLarge),
                bottomRight:
                    Radius.circular(TriathlonDimens.borderRadiusXLarge),
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
                  'Historique - Cyclisme',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: TriathlonDimens.fontSizeXXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Mes séances sauvegardées',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: TriathlonDimens.fontSizeLarge,
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
                      color: TriathlonColors.cycling,
                    ),
                  )
                : _seances.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_bike,
                              size: TriathlonDimens.iconSizeXXLarge,
                              color: TriathlonColors.textSecondary,
                            ),
                            const SizedBox(
                                height: TriathlonDimens.paddingLarge),
                            Text(
                              'Aucune séance sauvegardée',
                              style: TextStyle(
                                color: TriathlonColors.textSecondary,
                                fontSize: TriathlonDimens.fontSizeXLarge,
                              ),
                            ),
                            const SizedBox(
                                height: TriathlonDimens.paddingMedium),
                            Text(
                              'Commencez par créer une séance',
                              style: TextStyle(
                                color: TriathlonColors.textSecondary,
                                fontSize: TriathlonDimens.fontSizeMedium,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _chargerSeances,
                        color: TriathlonColors.cycling,
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
            padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
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
                // Bouton Nouvelle Séance
                SizedBox(
                  width: double.infinity,
                  height: TriathlonDimens.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () async {
                      DataManager dataManager =
                          Provider.of<DataManager>(context, listen: false);
                      bool limitReached =
                          await dataManager.isLimitReached(SportType.cycling);

                      if (limitReached && mounted) {
                        bool continuer = await _showLimitWarning();
                        if (continuer) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CyclingCreationSeanceScreen(),
                            ),
                          );
                        }
                      } else if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CyclingCreationSeanceScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TriathlonColors.cycling,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusXLarge,
                        ),
                      ),
                      elevation: TriathlonDimens.elevationLarge,
                    ),
                    child: const Text(
                      'Créer une nouvelle séance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: TriathlonDimens.paddingMedium),

                // Bouton Retour
                SizedBox(
                  width: double.infinity,
                  height: TriathlonDimens.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: TriathlonColors.cycling,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusXLarge,
                        ),
                        side: BorderSide(
                          color: TriathlonColors.cycling,
                          width: TriathlonDimens.borderWidth,
                        ),
                      ),
                    ),
                    child: const Text(
                      'RETOUR',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.bottom +
                      10, // ← IMPORTANT
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showLimitWarning() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Limite atteinte'),
            content: const Text(
              'Vous avez déjà 25 séances sauvegardées en cyclisme.\n\n'
              'La création d\'une nouvelle séance supprimera automatiquement la plus ancienne.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continuer'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
            ],
          ),
        ) ??
        false;
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
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      DataManager dataManager =
          Provider.of<DataManager>(context, listen: false);
      // CORRECTION ICI : Utilisez deleteSeanceById au lieu de deleteSeance
      bool deleted = await dataManager.deleteSeanceById(seance.id);

      if (deleted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Séance supprimée'),
            backgroundColor: Colors.green,
          ),
        );

        // Recharger la liste
        await _chargerSeances();
      } else if (mounted) {
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
