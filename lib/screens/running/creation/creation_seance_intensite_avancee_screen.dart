// lib/screens/creation_seance_intensite_avancee_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triathlon_app/screens/running/creation/creation_seance_intensite_exercice_form.dart';
import '../../../constants/triathlon_colors.dart';
import '../../../constants/triathlon_dimens.dart';
import '../../../models/sport_type.dart';
import '../../../models/triathlon_exercice.dart';
import '../../../models/triathlon_seance.dart';
import '../../../services/data_manager.dart';
import '../../../screens/seance/triathlon_visualisation_seance_screen.dart';

class CreationSeanceIntensiteAvanceeScreen extends StatefulWidget {
  final SportType sportType;

  const CreationSeanceIntensiteAvanceeScreen({
    super.key,
    required this.sportType,
  });

  @override
  _CreationSeanceIntensiteAvanceeScreenState createState() =>
      _CreationSeanceIntensiteAvanceeScreenState();
}

class _CreationSeanceIntensiteAvanceeScreenState
    extends State<CreationSeanceIntensiteAvanceeScreen> {
  final TextEditingController _nomSeanceController = TextEditingController();
  final List<TriathlonExercice> _listeExercices = [];
  int _exerciceCounter = 0;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late DataManager _dataManager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataManager = Provider.of<DataManager>(context, listen: false);
  }

  @override
  void dispose() {
    _nomSeanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sportColor = widget.sportType.color;

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
                colors: [sportColor.withOpacity(0.9), sportColor],
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
                  widget.sportType.creationTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version intensité - Multiple exercices',
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
                            elevation: TriathlonDimens.elevationMedium,
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
                                      color: sportColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _nomSeanceController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: widget.sportType.hintText,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          TriathlonDimens.borderRadiusMedium,
                                        ),
                                        borderSide: BorderSide(
                                          color: sportColor,
                                          width: 2,
                                        ),
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

                          const SizedBox(height: 20),

                          // Titre exercices
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TriathlonDimens.paddingSmall,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Exercices',
                                  style: TextStyle(
                                    color: sportColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${_listeExercices.length} exercice(s)',
                                  style: TextStyle(
                                    color: TriathlonColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Liste des exercices
                          AnimatedList(
                            key: _listKey,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            initialItemCount: _listeExercices.length,
                            itemBuilder: (context, index, animation) {
                              return SizeTransition(
                                sizeFactor: animation,
                                child: _buildExerciceForm(
                                    _listeExercices[index], index),
                              );
                            },
                          ),

                          // Bouton Ajouter
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
                                  backgroundColor: sportColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      TriathlonDimens.borderRadiusXLarge,
                                    ),
                                  ),
                                  elevation: 6,
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
                        backgroundColor: sportColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TriathlonDimens.borderRadiusXLarge,
                          ),
                        ),
                        elevation: 12,
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

  Widget _buildExerciceForm(TriathlonExercice exercice, int index) {
    return IntensiteExerciceForm(
      key: ValueKey(exercice.id),
      exercice: exercice,
      sportType: widget.sportType,
      onCalculer: (updatedExercice) {
        _updateExerciceInList(updatedExercice);
      },
      onSupprimer: () {
        _supprimerExercice(index);
      },
    );
  }

  void _ajouterExercice() {
    TriathlonExercice nouvelExercice = TriathlonExercice(
      id: _exerciceCounter++,
      nom: '',
      sportType: widget.sportType,
      distance: widget.sportType.defaultDistance,
      nbSeries: 1,
      nbRepetitions: 1,
      valeurReference: 100.0, // Intensité de 100% par défaut
      reposRepetitionsSec: widget.sportType.defaultReposRep,
      reposSeriesSec: widget.sportType.defaultReposSer,
      tempsMin: 0,
      tempsMax: 0,
      tempsReference: 0, // Temps de référence
    );

    setState(() {
      _listeExercices.add(nouvelExercice);
    });

    _listKey.currentState?.insertItem(_listeExercices.length - 1);
  }

  void _supprimerExercice(int index) {
    if (index >= 0 && index < _listeExercices.length) {
      TriathlonExercice exerciceASupprimer = _listeExercices[index];

      _listKey.currentState?.removeItem(
        index,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: _buildExerciceForm(exerciceASupprimer, index),
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
    if (_listeExercices.isEmpty) {
      _showError('Ajoutez au moins un exercice');
      return;
    }

    String nomSeance = _nomSeanceController.text.trim();
    if (nomSeance.isEmpty) {
      final now = DateTime.now();
      nomSeance = '${widget.sportType.displayName} ${now.day}/${now.month}';
    }

    TriathlonSeance seance = TriathlonSeance(
      id: DateTime.now().millisecondsSinceEpoch,
      nom: nomSeance,
      sportType: widget.sportType,
    );

    for (TriathlonExercice exercice in _listeExercices) {
      if (exercice.distance <= 0 ||
          exercice.nbSeries <= 0 ||
          exercice.tempsReference <= 0) {
        _showError('Veuillez compléter tous les exercices');
        return;
      }
      seance.exercices.add(exercice);
    }

    // Vérifier la limite
    bool limitReached = await _dataManager.isLimitReached(widget.sportType);

    if (limitReached) {
      bool continuer = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Limite atteinte'),
              content: Text(
                'Vous avez déjà 25 séances sauvegardées en ${widget.sportType.displayName}.\n\n'
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

      if (!continuer) return;
    }

    bool saved = await _dataManager.saveSeance(seance);

    if (saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Séance sauvegardée !'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TriathlonVisualisationSeanceScreen(seance: seance),
        ),
      );
    } else if (mounted) {
      _showError('Erreur lors de la sauvegarde');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
