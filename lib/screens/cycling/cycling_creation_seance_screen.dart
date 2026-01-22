import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triathlon_app/constants/triathlon_colors.dart';
import 'package:triathlon_app/constants/triathlon_dimens.dart';
import 'package:triathlon_app/models/sport_type.dart';
import 'package:triathlon_app/models/triathlon_exercice.dart';
import 'package:triathlon_app/models/triathlon_seance.dart';
import 'package:triathlon_app/services/data_manager.dart';
import 'package:triathlon_app/widgets/cycling_exercice_form.dart';
import 'package:triathlon_app/screens/seance/triathlon_visualisation_seance_screen.dart';

class CyclingCreationSeanceScreen extends StatefulWidget {
  const CyclingCreationSeanceScreen({super.key});

  @override
  _CyclingCreationSeanceScreenState createState() =>
      _CyclingCreationSeanceScreenState();
}

class _CyclingCreationSeanceScreenState
    extends State<CyclingCreationSeanceScreen> {
  final TextEditingController _nomSeanceController = TextEditingController();
  final List<TriathlonExercice> _listeExercices = [];
  int _exerciceCounter = 0;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void dispose() {
    _nomSeanceController.dispose();
    super.dispose();
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
                  'Création de séance - Cyclisme',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: TriathlonDimens.fontSizeXXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Concevez votre programme d\'entraînement',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: TriathlonDimens.fontSizeMedium,
                  ),
                ),
              ],
            ),
          ),

          // Contenu
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(TriathlonDimens.paddingMedium),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Carte nom de séance
                          Card(
                            elevation: TriathlonDimens.elevationLarge,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                TriathlonDimens.borderRadiusLarge,
                              ),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                TriathlonDimens.paddingLarge,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nom de la séance',
                                    style: TextStyle(
                                      color: TriathlonColors.cycling,
                                      fontSize: TriathlonDimens.fontSizeXLarge,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: TriathlonDimens.paddingMedium),
                                  TextField(
                                    controller: _nomSeanceController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Ex: Séance intervalles FTP',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          TriathlonDimens.borderRadiusMedium,
                                        ),
                                        borderSide: BorderSide(
                                          color: TriathlonColors.cycling,
                                          width: TriathlonDimens.borderWidth,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.title,
                                        color: TriathlonColors.cycling,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: TriathlonDimens.paddingLarge),

                          // Titre exercices - CORRECTION ICI
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TriathlonDimens.paddingSmall,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Exercices de cyclisme',
                                        style: TextStyle(
                                          color: TriathlonColors.cycling,
                                          fontSize:
                                              TriathlonDimens.fontSizeXXLarge,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Texte "x exercice(s)" sous le titre
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              TriathlonDimens.paddingSmall,
                                          vertical:
                                              TriathlonDimens.paddingSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          color: TriathlonColors.cycling
                                              .withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            TriathlonDimens.borderRadiusMedium,
                                          ),
                                        ),
                                        child: Text(
                                          '${_listeExercices.length} exercice${_listeExercices.length > 1 ? 's' : ''}',
                                          style: TextStyle(
                                            color: TriathlonColors.cycling,
                                            fontWeight: FontWeight.w600,
                                            fontSize:
                                                TriathlonDimens.fontSizeSmall,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: TriathlonDimens.paddingMedium),

                          // Liste des exercices
                          AnimatedList(
                            key: _listKey,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            initialItemCount: _listeExercices.length,
                            itemBuilder: (context, index, animation) {
                              return SizeTransition(
                                sizeFactor: animation,
                                child: CyclingExerciceForm(
                                  key: ValueKey(_listeExercices[index].id),
                                  exercice: _listeExercices[index],
                                  onCalculer: (exercice) {
                                    setState(() {
                                      _updateExerciceInList(exercice);
                                    });
                                  },
                                  onSupprimer: () {
                                    _supprimerExercice(index);
                                  },
                                ),
                              );
                            },
                          ),

                          // Bouton Ajouter (version mobile pour ajouter plus facilement)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: TriathlonDimens.paddingLarge,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: TriathlonDimens.buttonHeight,
                              child: ElevatedButton.icon(
                                onPressed: _ajouterExercice,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: TriathlonColors.cycling,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      TriathlonDimens.borderRadiusXLarge,
                                    ),
                                  ),
                                  elevation: TriathlonDimens.elevationMedium,
                                ),
                                icon: const Icon(Icons.add, size: 24),
                                label: const Text(
                                  'AJOUTER UN EXERCICE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bouton Sauvegarder fixe
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
                  child: SizedBox(
                    width: double.infinity,
                    height: TriathlonDimens.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _sauvegarderSeance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TriathlonColors.cycling,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TriathlonDimens.borderRadiusXLarge,
                          ),
                        ),
                        elevation: TriathlonDimens.elevationXLarge,
                      ),
                      child: const Text(
                        'SAUVEGARDER LA SÉANCE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.bottom + 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _ajouterExercice() {
    try {
      TriathlonExercice nouvelExercice = TriathlonExercice(
        id: _exerciceCounter++,
        nom: 'Exercice FTP',
        sportType: SportType.cycling,
        distance: 5000.0, // 5km en mètres
        nbSeries: 3,
        nbRepetitions: 1,
        valeurReference: 250.0, // FTP en watts
        intensite: 80, // 80% FTP
        reposRepetitionsSec: 60,
        reposSeriesSec: 180,
        tempsMin: 0,
        tempsMax: 0,
      );

      // Calculer le temps initial
      nouvelExercice.calculerTemps();

      setState(() {
        _listeExercices.add(nouvelExercice);
      });

      // Animer l'insertion
      if (_listKey.currentState != null) {
        _listKey.currentState!.insertItem(_listeExercices.length - 1);
      }
    } catch (e) {
      print("Erreur lors de l'ajout d'exercice: $e");
      _showError('Erreur lors de la création de l\'exercice: ${e.toString()}');
    }
  }

  void _supprimerExercice(int index) {
    if (index >= 0 && index < _listeExercices.length) {
      TriathlonExercice exerciceASupprimer = _listeExercices[index];

      if (_listKey.currentState != null) {
        _listKey.currentState!.removeItem(
          index,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: CyclingExerciceForm(
              exercice: exerciceASupprimer,
              onCalculer: (_) {},
              onSupprimer: () {},
            ),
          ),
        );
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _listeExercices.removeAt(index);
        });
      });
    }
  }

  void _updateExerciceInList(TriathlonExercice exercice) {
    int index = _listeExercices.indexWhere((e) => e.id == exercice.id);
    if (index != -1) {
      setState(() {
        _listeExercices[index] = exercice;
      });
    }
  }

  Future<void> _sauvegarderSeance() async {
    try {
      // Valider
      if (_listeExercices.isEmpty) {
        _showError('Ajoutez au moins un exercice');
        return;
      }

      // Récupérer le nom de la séance
      String nomSeance = _nomSeanceController.text.trim();
      if (nomSeance.isEmpty) {
        final now = DateTime.now();
        nomSeance = 'Séance cyclisme ${now.day}/${now.month}';
      }

      // Créer la séance
      TriathlonSeance seance = TriathlonSeance(
        id: DateTime.now().millisecondsSinceEpoch,
        nom: nomSeance,
        sportType: SportType.cycling,
      );

      for (TriathlonExercice exercice in _listeExercices) {
        // Valider chaque exercice
        if (exercice.distance <= 0 ||
            exercice.nbSeries <= 0 ||
            exercice.valeurReference <= 0) {
          _showError('Veuillez compléter tous les exercices');
          return;
        }

        // Calculer les temps si pas déjà fait
        if (exercice.tempsMin <= 0) {
          exercice.calculerTemps();
        }

        seance.exercices.add(exercice);
      }

      // Sauvegarder
      DataManager dataManager =
          Provider.of<DataManager>(context, listen: false);

      // Vérifier la limite
      int count = await dataManager.getSeancesCountBySport(SportType.cycling);
      bool limitReached = count >= 25;

      if (limitReached && mounted) {
        bool continuer = await _showLimitWarning();
        if (!continuer) return;
      }

      bool saved = await dataManager.saveSeance(seance);

      if (saved && mounted) {
        // Animation de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Séance sauvegardée !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Naviguer vers la visualisation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TriathlonVisualisationSeanceScreen(
              seance: seance,
            ),
          ),
        );
      } else if (mounted) {
        _showError('Erreur lors de la sauvegarde');
      }
    } catch (e) {
      print("Erreur lors de la sauvegarde: $e");
      _showError('Erreur: ${e.toString()}');
    }
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

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
