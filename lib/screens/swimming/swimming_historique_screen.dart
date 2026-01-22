import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triathlon_app/screens/seance/triathlon_visualisation_seance_screen.dart';
import '../../constants/triathlon_colors.dart';
import '../../constants/triathlon_dimens.dart';
import '../../models/sport_type.dart';
import '../../models/triathlon_seance.dart';
import '../../services/data_manager.dart';
import '../../widgets/seance_item_widget.dart'; // CHANGER LE NOM
import 'swimming_creation_seance_screen.dart';

class SwimmingHistoriqueScreen extends StatefulWidget {
  const SwimmingHistoriqueScreen({super.key});

  @override
  _SwimmingHistoriqueScreenState createState() =>
      _SwimmingHistoriqueScreenState();
}

class _SwimmingHistoriqueScreenState extends State<SwimmingHistoriqueScreen> {
  List<TriathlonSeance> _seances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerSeances();
  }

  Future<void> _chargerSeances() async {
    DataManager dataManager = Provider.of<DataManager>(context, listen: false);
    List<TriathlonSeance> allSeances = await dataManager.loadAllSeances();
    List<TriathlonSeance> swimmingSeances = allSeances
        .where((seance) => seance.sportType == SportType.swimming)
        .toList();

    setState(() {
      _seances = swimmingSeances;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TriathlonColors.background,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: TriathlonDimens.paddingLarge,
              right: TriathlonDimens.paddingLarge,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: TriathlonColors.swimmingGradient,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(TriathlonDimens.borderRadiusXLarge),
                bottomRight:
                    Radius.circular(TriathlonDimens.borderRadiusXLarge),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: TriathlonDimens.elevationLarge,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Icon(
                    Icons.pool,
                    size: TriathlonDimens.iconSizeXXLarge,
                    color: Colors.white,
                  ),
                  const SizedBox(height: TriathlonDimens.paddingMedium),
                  Text(
                    'Historique - Natation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: TriathlonDimens.fontSizeXXLarge,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TriathlonDimens.paddingXSmall),
                  Text(
                    'Mes séances sauvegardées',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: TriathlonDimens.fontSizeMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Contenu
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: TriathlonColors.swimming,
                    ),
                  )
                : _seances.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pool,
                              size: TriathlonDimens.iconSizeXXLarge,
                              color: TriathlonColors.textSecondary,
                            ),
                            const SizedBox(
                                height: TriathlonDimens.paddingLarge),
                            Text(
                              'Aucune séance sauvegardée',
                              style: TextStyle(
                                color: TriathlonColors.textPrimary,
                                fontSize: TriathlonDimens.fontSizeXLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                                height: TriathlonDimens.paddingMedium),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TriathlonDimens.paddingXXLarge,
                              ),
                              child: Text(
                                'Créez votre première séance pour commencer votre entraînement',
                                style: TextStyle(
                                  color: TriathlonColors.textSecondary,
                                  fontSize: TriathlonDimens.fontSizeMedium,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _chargerSeances,
                        color: TriathlonColors.swimming,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(
                              TriathlonDimens.paddingLarge),
                          itemCount: _seances.length,
                          itemBuilder: (context, index) {
                            return SeanceItemWidget(
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
                  blurRadius: TriathlonDimens.elevationMedium,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                // Bouton Nouvelle Séance
                SizedBox(
                  width: double.infinity,
                  height: TriathlonDimens.buttonHeightLarge,
                  child: ElevatedButton(
                    onPressed: () async {
                      DataManager dataManager =
                          Provider.of<DataManager>(context, listen: false);
                      bool limitReached = await dataManager.isLimitReached(
                        SportType.swimming,
                      );

                      if (limitReached && mounted) {
                        bool continuer = await _showLimitWarning();
                        if (continuer) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SwimmingCreationSeanceScreen(),
                            ),
                          );
                        }
                      } else if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SwimmingCreationSeanceScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TriathlonColors.swimming,
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
                      foregroundColor: TriathlonColors.swimming,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusXLarge,
                        ),
                        side: BorderSide(
                          color: TriathlonColors.swimming,
                          width: TriathlonDimens.borderWidth,
                        ),
                      ),
                      elevation: TriathlonDimens.elevationSmall,
                    ),
                    child: const Text(
                      'RETOUR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
              'Vous avez déjà 25 séances sauvegardées en natation.\n\n'
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
      bool deleted = await dataManager.deleteSeanceById(seance.id);

      if (deleted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Séance supprimée'),
            backgroundColor: TriathlonColors.swimming,
            duration: const Duration(seconds: 2),
          ),
        );
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
