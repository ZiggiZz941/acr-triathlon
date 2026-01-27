import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/triathlon_colors.dart';
import '../../../constants/triathlon_dimens.dart';
import '../../../constants/triathlon_strings.dart';
import '../../../models/sport_type.dart';
import '../../../models/triathlon_exercice.dart';
import '../../../models/triathlon_seance.dart';
import '../../../services/data_manager.dart';
import '../../../widgets/running_exercice_form.dart';
import '../../seance/triathlon_visualisation_seance_screen.dart';

class CreationSeanceScreen extends StatefulWidget {
  const CreationSeanceScreen({super.key});

  @override
  _CreationSeanceScreenState createState() => _CreationSeanceScreenState();
}

class _CreationSeanceScreenState extends State<CreationSeanceScreen> {
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
      body: Container(
        color: const Color.fromARGB(255, 245, 245, 245),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                  left: TriathlonDimens.paddingLarge,
                  right: TriathlonDimens.paddingLarge,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: TriathlonColors.runningGradient,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft:
                        Radius.circular(TriathlonDimens.borderRadiusXLarge),
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
                      'Création de séance',
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

              // Contenu avec SingleChildScrollView
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewPadding.bottom + 100,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(TriathlonDimens.paddingMedium),
                    child: Column(
                      children: [
                        // Carte nom de séance
                        Card(
                          elevation: TriathlonDimens.elevationXLarge,
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
                                    color: TriathlonColors.running,
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
                                    hintText:
                                        'Ex: Séance endurance fondamentale',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        TriathlonDimens.borderRadiusMedium,
                                      ),
                                      borderSide: BorderSide(
                                        color: TriathlonColors.running,
                                        width: TriathlonDimens.borderWidth,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: TriathlonDimens.paddingMedium,
                                      vertical: TriathlonDimens.paddingMedium,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Exercices',
                                      style: TextStyle(
                                        color: TriathlonColors.running,
                                        fontSize:
                                            TriathlonDimens.fontSizeXXLarge,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: TriathlonDimens.paddingMedium,
                                      vertical: TriathlonDimens.paddingSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TriathlonColors.running
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(
                                        TriathlonDimens.borderRadiusLarge,
                                      ),
                                    ),
                                    child: Text(
                                      _listeExercices.length == 1
                                          ? '1 exercice'
                                          : '${_listeExercices.length} exercices',
                                      style: TextStyle(
                                        color: TriathlonColors.running,
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
                              child: RunningExerciceForm(
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
                            vertical: TriathlonDimens.paddingMedium,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: TriathlonDimens.buttonHeight,
                            child: ElevatedButton.icon(
                              onPressed: _ajouterExercice,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TriathlonColors.running,
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

                        // Espace pour les boutons en bas
                        SizedBox(
                          height: TriathlonDimens.buttonHeight * 2 + 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bouton Sauvegarder fixe en bas
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
                child: SizedBox(
                  width: double.infinity,
                  height: TriathlonDimens.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _sauvegarderSeance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TriathlonColors.running,
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
            ],
          ),
        ),
      ),
    );
  }

  void _ajouterExercice() {
    TriathlonExercice nouvelExercice = TriathlonExercice(
      id: _exerciceCounter++,
      nom: '',
      sportType: SportType.running,
      distance: 0,
      nbSeries: 1,
      nbRepetitions: 1,
      valeurReference: 0,
      allure: 3, // Allure 3 par défaut
      reposRepetitionsSec: 45,
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
          child: RunningExerciceForm(
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
      nomSeance = 'Séance du ${now.day}/${now.month}';
    }

    // Créer la séance avec un ID unique
    TriathlonSeance seance = TriathlonSeance(
      id: DateTime.now().millisecondsSinceEpoch,
      nom: nomSeance,
      sportType: SportType.running,
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
    bool limitReached = await dataManager.isLimitReached(SportType.running);

    if (limitReached) {
      bool continuer = await _showLimitWarning();
      if (!continuer) return;
    }

    bool saved = await dataManager.saveSeance(seance);

    if (saved) {
      // Animation de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Séance sauvegardée !'),
            backgroundColor: Colors.green,
          ),
        );

        // Naviguer vers la visualisation
        Navigator.pushReplacement(
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
              'Vous avez déjà 25 séances sauvegardées en course à pied.\n\n'
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
