import 'package:flutter/material.dart';
import '../../constants/triathlon_colors.dart';
import '../../models/triathlon_exercice.dart';
import '../../models/triathlon_seance.dart';
import '../../models/sport_type.dart';
import '../../services/swimming_service.dart';

import '../../widgets/swimming_exercice_form.dart';

class SwimmingCreationIntensiteScreen extends StatefulWidget {
  const SwimmingCreationIntensiteScreen({super.key});

  @override
  _SwimmingCreationIntensiteScreenState createState() =>
      _SwimmingCreationIntensiteScreenState();
}

class _SwimmingCreationIntensiteScreenState
    extends State<SwimmingCreationIntensiteScreen> {
  final TextEditingController _nomSeanceController = TextEditingController();
  final List<TriathlonExercice> _listeExercices = [];
  int _exerciceCounter = 0;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final SwimmingService _swimmingService = SwimmingService();

  @override
  void initState() {
    super.initState();
    _ajouterExercice(); // Ajouter un exercice par défaut
  }

  @override
  void dispose() {
    _nomSeanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TriathlonColors.background,
      appBar: AppBar(
        title: const Text('Création Séance Natation'),
        backgroundColor: TriathlonColors.swimming,
      ),
      body: Column(
        children: [
          // Section nom de séance
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nom de la séance',
                      style: TextStyle(
                        color: TriathlonColors.swimming,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nomSeanceController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Entraînement crawl intensité',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Liste des exercices
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Titre et compteur
                  Row(
                    children: [
                      Text(
                        'Exercices de natation',
                        style: TextStyle(
                          color: TriathlonColors.swimming,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_listeExercices.length} exercice(s)',
                        style: TextStyle(
                          color: TriathlonColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Liste
                  Expanded(
                    child: AnimatedList(
                      key: _listKey,
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
                  ),
                ],
              ),
            ),
          ),

          // Boutons d'action
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                // Bouton Ajouter
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _ajouterExercice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TriathlonColors.swimming,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Ajouter un exercice',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Bouton Sauvegarder
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sauvegarderSeance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          TriathlonColors.swimming.withOpacity(0.9),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Sauvegarder',
                      style: TextStyle(color: Colors.white),
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

  void _ajouterExercice() {
    TriathlonExercice nouvelExercice = TriathlonExercice(
      id: _exerciceCounter++,
      nom: '',
      sportType: SportType.swimming,
      distance: 100, // 100m par défaut
      nbSeries: 3,
      nbRepetitions: 1,
      valeurReference: 90, // temps 400m par défaut (1:30 pour 100m)
      intensite: 80, // 80% par défaut
      reposRepetitionsSec: 30,
      reposSeriesSec: 120,
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
    if (_listeExercices.isEmpty) {
      _showError('Ajoutez au moins un exercice');
      return;
    }

    String nomSeance = _nomSeanceController.text.trim();
    if (nomSeance.isEmpty) {
      nomSeance =
          'Séance natation ${DateTime.now().day}/${DateTime.now().month}';
    }

    TriathlonSeance seance = TriathlonSeance(
      id: DateTime.now().millisecondsSinceEpoch,
      nom: nomSeance,
      sportType: SportType.swimming,
    );

    for (TriathlonExercice exercice in _listeExercices) {
      if (exercice.distance <= 0 || exercice.valeurReference <= 0) {
        _showError('Veuillez compléter tous les exercices');
        return;
      }
      seance.ajouterExercice(exercice);
    }

    bool saved = await _swimmingService.saveSeance(seance);

    if (saved) {
      _showSuccess('Séance sauvegardée !');
      Navigator.pop(context);
    } else {
      _showError('Erreur lors de la sauvegarde');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
