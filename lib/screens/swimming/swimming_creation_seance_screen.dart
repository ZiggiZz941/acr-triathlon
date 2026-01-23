import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/triathlon_colors.dart';
import '../../constants/triathlon_dimens.dart';
import '../../constants/triathlon_strings.dart';
import '../../models/sport_type.dart';
import '../../models/triathlon_exercice.dart';
import '../../models/triathlon_seance.dart';
import '../../services/data_manager.dart';
import '../../widgets/swimming_exercice_form.dart';
import '../seance/triathlon_visualisation_seance_screen.dart';

class SwimmingCreationSeanceScreen extends StatefulWidget {
  const SwimmingCreationSeanceScreen({super.key});

  @override
  _SwimmingCreationSeanceScreenState createState() =>
      _SwimmingCreationSeanceScreenState();
}

class _SwimmingCreationSeanceScreenState
    extends State<SwimmingCreationSeanceScreen> {
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
                    'Création de séance - Natation',
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
                    'Concevez votre programme d\'entraînement',
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
                                      color: TriathlonColors.swimming,
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
                                      fillColor: TriathlonColors.background,
                                      hintText: 'Ex: Séance endurance crawl',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          TriathlonDimens.borderRadiusMedium,
                                        ),
                                        borderSide: BorderSide(
                                          color: TriathlonColors.swimming,
                                          width: TriathlonDimens.borderWidth,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.title,
                                        color: TriathlonColors.swimming,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal:
                                            TriathlonDimens.paddingMedium,
                                        vertical: TriathlonDimens.paddingMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: TriathlonDimens.paddingLarge),

                          // Titre exercices
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TriathlonDimens.paddingSmall,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Exercices de natation',
                                        style: TextStyle(
                                          color: TriathlonColors.swimming,
                                          fontSize:
                                              TriathlonDimens.fontSizeXXLarge,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            TriathlonDimens.paddingMedium,
                                        vertical: TriathlonDimens.paddingSmall,
                                      ),
                                      decoration: BoxDecoration(
                                        color: TriathlonColors.swimming
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          TriathlonDimens.borderRadiusLarge,
                                        ),
                                        border: Border.all(
                                          color: TriathlonColors.swimming
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      child: Text(
                                        _listeExercices.length == 1
                                            ? '1 exercice'
                                            : '${_listeExercices.length} exercices',
                                        style: TextStyle(
                                          color: TriathlonColors.swimming,
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              TriathlonDimens.fontSizeMedium,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                child: SwimmingExerciceForm(
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

                          // Bouton Ajouter
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: TriathlonDimens.paddingLarge,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: TriathlonDimens.buttonHeightLarge,
                              child: ElevatedButton.icon(
                                onPressed: _ajouterExercice,
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
                                icon: const Icon(Icons.add,
                                    size: TriathlonDimens.iconSizeLarge),
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

                          const SizedBox(
                              height: TriathlonDimens.paddingXXLarge),
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
                        blurRadius: TriathlonDimens.elevationMedium,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: TriathlonDimens.buttonHeightLarge,
                    child: ElevatedButton(
                      onPressed: _sauvegarderSeance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TriathlonColors.swimming,
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
    TriathlonExercice nouvelExercice = TriathlonExercice(
      id: _exerciceCounter++,
      nom: '',
      sportType: SportType.swimming,
      distance: 100,
      nbSeries: 3,
      nbRepetitions: 1,
      valeurReference:
          90.0, // 1:30.00 pour 100m par défaut (soit 6:00.00 pour 400m)
      intensite: 100, // Toujours 100% quand on spécifie l'allure
      reposRepetitionsSec: 30,
      reposSeriesSec: 120,
    );

    setState(() {
      _listeExercices.add(nouvelExercice);
    });

    // Animer l'insertion
    _listKey.currentState?.insertItem(_listeExercices.length - 1);
  }

  void _supprimerExercice(int index) {
    if (index >= 0 && index < _listeExercices.length) {
      TriathlonExercice exerciceASupprimer = _listeExercices[index];

      _listKey.currentState?.removeItem(
        index,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: SwimmingExerciceForm(
            exercice: exerciceASupprimer,
            onCalculer: (_) {},
            onSupprimer: () {},
          ),
        ),
      );

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
    // Valider
    if (_listeExercices.isEmpty) {
      _showError('Ajoutez au moins un exercice');
      return;
    }

    // Récupérer le nom de la séance
    String nomSeance = _nomSeanceController.text.trim();
    if (nomSeance.isEmpty) {
      final now = DateTime.now();
      nomSeance = 'Séance natation ${now.day}/${now.month}';
    }

    // Créer la séance
    TriathlonSeance seance = TriathlonSeance(
      nom: nomSeance,
      sportType: SportType.swimming,
    );

    for (TriathlonExercice exercice in _listeExercices) {
      // Valider chaque exercice
      if (exercice.distance <= 0 ||
          exercice.nbSeries <= 0 ||
          exercice.valeurReference <= 0) {
        _showError('Veuillez compléter tous les exercices');
        return;
      }
      seance.ajouterExercice(exercice);
    }

    // Sauvegarder
    DataManager dataManager = Provider.of<DataManager>(context, listen: false);

    // Vérifier la limite
    bool limitReached = await dataManager.isLimitReached(SportType.swimming);

    if (limitReached) {
      bool continuer = await _showLimitWarning();
      if (!continuer) return;
    }

    bool saved = await dataManager.saveSeance(seance);

    if (saved) {
      // Animation de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(TriathlonStrings.saveSuccess),
            backgroundColor: TriathlonColors.swimming,
            duration: const Duration(seconds: 2),
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
      }
    } else {
      _showError(TriathlonStrings.saveError);
    }
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
