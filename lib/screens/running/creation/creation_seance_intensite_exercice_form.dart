// lib/screens/creation_seance_intensite_exercice_form.dart
import 'package:flutter/material.dart';
import '../../../constants/triathlon_colors.dart';
import '../../../constants/triathlon_dimens.dart';
import '../../../models/triathlon_exercice.dart';
import '../../../models/sport_type.dart';

class IntensiteExerciceForm extends StatefulWidget {
  final TriathlonExercice exercice;
  final SportType sportType;
  final Function(TriathlonExercice) onCalculer;
  final VoidCallback onSupprimer;

  const IntensiteExerciceForm({
    super.key,
    required this.exercice,
    required this.sportType,
    required this.onCalculer,
    required this.onSupprimer,
  });

  @override
  _IntensiteExerciceFormState createState() => _IntensiteExerciceFormState();
}

class _IntensiteExerciceFormState extends State<IntensiteExerciceForm>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _tempsReferenceController =
      TextEditingController();
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();
  final TextEditingController _intensiteController = TextEditingController();
  final TextEditingController _reposRepetitionsController =
      TextEditingController();
  final TextEditingController _reposSeriesController = TextEditingController();

  bool _showResult = false;
  String _resultText = '--:--.--';
  String _resultDescription = '';

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 1.2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.bounceOut,
      ),
    );

    // Initialiser les contrôleurs
    _nomController.text = widget.exercice.nom;
    _distanceController.text = widget.exercice.distance > 0
        ? widget.exercice.distance.toInt().toString()
        : '';
    _seriesController.text = widget.exercice.nbSeries > 0
        ? widget.exercice.nbSeries.toString()
        : '1';
    _repetitionsController.text = widget.exercice.nbRepetitions > 0
        ? widget.exercice.nbRepetitions.toString()
        : '1';
    _intensiteController.text = widget.exercice.valeurReference > 0
        ? widget.exercice.valeurReference.toStringAsFixed(1)
        : '100.0';

    // Initialiser le temps de référence
    if (widget.exercice.tempsReference > 0) {
      _tempsReferenceController.text =
          _formatTempsSecondes(widget.exercice.tempsReference);
    } else {
      // Valeur par défaut selon le sport
      switch (widget.sportType) {
        case SportType.swimming:
          _tempsReferenceController.text = '1:30.00'; // 1:30 pour 100m
          break;
        case SportType.cycling:
          _tempsReferenceController.text = '0:20.00'; // 20s pour 100m
          break;
        case SportType.running:
          _tempsReferenceController.text = '0:45.00'; // 45s pour 100m
          break;
      }
    }

    _reposRepetitionsController.text = widget.exercice.reposRepetitionsFormate;
    _reposSeriesController.text = widget.exercice.reposSeriesFormate;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomController.dispose();
    _distanceController.dispose();
    _tempsReferenceController.dispose();
    _seriesController.dispose();
    _repetitionsController.dispose();
    _intensiteController.dispose();
    _reposRepetitionsController.dispose();
    _reposSeriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sportColor = widget.sportType.color;

    return Card(
      elevation: TriathlonDimens.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TriathlonDimens.borderRadiusLarge),
      ),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: TriathlonDimens.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec bouton supprimer
            Row(
              children: [
                Text(
                  'Exercice ${widget.sportType.displayName}',
                  style: TextStyle(
                    color: sportColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onSupprimer,
                  icon: Icon(Icons.close, color: sportColor),
                  iconSize: 24,
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Nom de l'exercice
            Text(
              'Nom (optionnel)',
              style: TextStyle(color: sportColor, fontSize: 16),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _nomController,
              onChanged: (_) => _updateExercice(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Ex: Séance vitesse',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    TriathlonDimens.borderRadiusMedium,
                  ),
                  borderSide: BorderSide(
                    color: sportColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: TriathlonDimens.paddingMedium,
                  vertical: TriathlonDimens.paddingMedium,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Distance
            Text(
              'Distance (m)',
              style: TextStyle(color: sportColor, fontSize: 16),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateExercice(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Ex: 100',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    TriathlonDimens.borderRadiusMedium,
                  ),
                  borderSide: BorderSide(
                    color: sportColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: TriathlonDimens.paddingMedium,
                  vertical: TriathlonDimens.paddingMedium,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Temps de référence
            Text(
              'Temps de référence',
              style: TextStyle(color: sportColor, fontSize: 16),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _tempsReferenceController,
              onChanged: (_) => _updateExercice(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Ex: 12.50 ou 1:12.50',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    TriathlonDimens.borderRadiusMedium,
                  ),
                  borderSide: BorderSide(
                    color: sportColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: TriathlonDimens.paddingMedium,
                  vertical: TriathlonDimens.paddingMedium,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Deux colonnes Séries/Répétitions
            Row(
              children: [
                // Séries
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Séries',
                        style: TextStyle(
                          color: sportColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _seriesController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _updateExercice(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Ex: 3',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              TriathlonDimens.borderRadiusMedium,
                            ),
                            borderSide: BorderSide(
                              color: sportColor,
                              width: 2,
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

                const SizedBox(width: 8),

                // Répétitions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Répétitions',
                        style: TextStyle(
                          color: sportColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _repetitionsController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _updateExercice(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Ex: 4',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              TriathlonDimens.borderRadiusMedium,
                            ),
                            borderSide: BorderSide(
                              color: sportColor,
                              width: 2,
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
              ],
            ),

            const SizedBox(height: 15),

            // Intensité
            Text(
              'Intensité (%)',
              style: TextStyle(color: sportColor, fontSize: 16),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _intensiteController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _updateExercice(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Ex: 80.0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    TriathlonDimens.borderRadiusMedium,
                  ),
                  borderSide: BorderSide(
                    color: sportColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: TriathlonDimens.paddingMedium,
                  vertical: TriathlonDimens.paddingMedium,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Deux colonnes Repos
            Row(
              children: [
                // Repos répétitions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repos répétitions',
                        style: TextStyle(
                          color: sportColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _reposRepetitionsController,
                        onChanged: (_) => _updateExercice(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Ex: 0:45',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              TriathlonDimens.borderRadiusMedium,
                            ),
                            borderSide: BorderSide(
                              color: sportColor,
                              width: 2,
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

                const SizedBox(width: 8),

                // Repos séries
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repos séries',
                        style: TextStyle(
                          color: sportColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _reposSeriesController,
                        onChanged: (_) => _updateExercice(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Ex: 2:00',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              TriathlonDimens.borderRadiusMedium,
                            ),
                            borderSide: BorderSide(
                              color: sportColor,
                              width: 2,
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
              ],
            ),

            const SizedBox(height: 20),

            // Bouton Prévisualiser
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _updateExercice();
                  _animationController.reset();
                  _animationController.forward();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: sportColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      TriathlonDimens.borderRadiusXLarge,
                    ),
                    side: BorderSide(color: sportColor, width: 2),
                  ),
                ),
                child: const Text(
                  'PRÉVISUALISER',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Zone résultat
            AnimatedOpacity(
              opacity: _showResult ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showResult ? null : 0,
                child: Column(
                  children: [
                    // Temps calculé
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: sportColor, width: 2),
                          borderRadius: BorderRadius.circular(
                            TriathlonDimens.borderRadiusMedium,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Temps à ${_intensiteController.text}%',
                              style: TextStyle(
                                color: sportColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _resultText,
                              style: TextStyle(
                                color: sportColor,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Description
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: sportColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusMedium,
                        ),
                      ),
                      child: Text(
                        _resultDescription,
                        style: TextStyle(
                          color: TriathlonColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateExercice() {
    try {
      // Parser les valeurs
      String nom = _nomController.text.trim();
      if (nom.isEmpty) {
        nom = 'Exercice ${widget.sportType.displayName}';
      }

      double distance = double.parse(
        _distanceController.text.replaceAll(',', '.'),
      );
      int series = int.parse(_seriesController.text);
      int repetitions = int.parse(_repetitionsController.text);
      double intensite =
          double.parse(_intensiteController.text.replaceAll(',', '.'));

      // Convertir le temps de référence
      double tempsReference =
          _convertirTempsEnSecondes(_tempsReferenceController.text);

      int reposRepSec = TriathlonExercice.parseTempsEnSecondes(
        _reposRepetitionsController.text,
      );
      int reposSerSec = TriathlonExercice.parseTempsEnSecondes(
        _reposSeriesController.text,
      );

      // Validations
      if (distance <= 0 ||
          series <= 0 ||
          intensite <= 0 ||
          intensite > 100 ||
          tempsReference <= 0) {
        return;
      }

      if (repetitions <= 0) repetitions = 1;
      if (reposRepSec < 0) reposRepSec = 0;
      if (reposSerSec < 0) reposSerSec = 0;

      // Si une seule série, ignorer le repos entre séries
      if (series == 1) {
        reposSerSec = 0;
      }

      // Mettre à jour l'exercice
      widget.exercice.nom = nom;
      widget.exercice.distance = distance;
      widget.exercice.nbSeries = series;
      widget.exercice.nbRepetitions = repetitions;
      widget.exercice.valeurReference = intensite;
      widget.exercice.tempsReference = tempsReference;
      widget.exercice.reposRepetitionsSec = reposRepSec;
      widget.exercice.reposSeriesSec = reposSerSec;

      // Calculer le temps à l'intensité donnée
      // Formule: Temps calculé = (Temps référence * 100) / Intensité
      double tempsCalcule = (tempsReference * 100.0) / intensite;

      // Mettre à jour les temps min et max de l'exercice
      widget.exercice.tempsMin = tempsCalcule;
      widget.exercice.tempsMax = tempsCalcule;

      // Mettre à jour le texte de résultat
      setState(() {
        _resultText = _formatResultAvecCentiemes(tempsCalcule);
        _resultDescription =
            _getResultDescription(tempsCalcule, series, repetitions);
        _showResult = true;
      });

      // Notifier le parent
      widget.onCalculer(widget.exercice);
    } catch (e) {
      // Ignorer les erreurs de parsing pendant la saisie
    }
  }

  double _convertirTempsEnSecondes(String tempsStr) {
    try {
      if (tempsStr.trim().isEmpty) return 0;

      // Si le temps contient ':' (format mm:ss.xx)
      if (tempsStr.contains(":")) {
        List<String> parties = tempsStr.split(":");
        if (parties.length == 2) {
          double minutes = double.parse(parties[0].replaceAll(',', '.'));
          double secondes = double.parse(parties[1].replaceAll(',', '.'));
          if (minutes < 0 || secondes < 0 || secondes >= 60) {
            return 0;
          }
          return (minutes * 60) + secondes;
        }
      }
      // Sinon, c'est en secondes (format ss.xx)
      double secondes = double.parse(tempsStr.replaceAll(',', '.'));
      if (secondes < 0) {
        return 0;
      }
      return secondes;
    } catch (e) {
      return 0;
    }
  }

  String _formatTempsSecondes(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    double secondesDecimal = seconds % 60;

    if (minutes > 0) {
      return '${minutes}:${secondesDecimal.toStringAsFixed(2).padLeft(5, '0')}';
    } else {
      return secondesDecimal.toStringAsFixed(2);
    }
  }

  String _formatResultAvecCentiemes(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    double secondesDecimal = seconds % 60;

    // Correction: gérer le cas où secondesDecimal >= 60
    if (secondesDecimal >= 60) {
      minutes += (secondesDecimal ~/ 60).toInt();
      secondesDecimal = secondesDecimal % 60;
    }

    // Formater avec 2 décimales
    if (minutes > 0) {
      return '${minutes}:${secondesDecimal.toStringAsFixed(2).padLeft(5, '0')}';
    } else {
      return '${secondesDecimal.toStringAsFixed(2)}';
    }
  }

  String _getResultDescription(
      double tempsCalcule, int series, int repetitions) {
    double distance =
        double.parse(_distanceController.text.replaceAll(',', '.'));
    double intensite =
        double.parse(_intensiteController.text.replaceAll(',', '.'));

    String distanceFormatted;
    if (distance >= 1000) {
      distanceFormatted = '${(distance / 1000).toStringAsFixed(1)} km';
    } else {
      distanceFormatted = '${distance.toInt()} m';
    }

    return '${series} série(s) de ${repetitions} × ${distanceFormatted} à ${intensite.toStringAsFixed(1)}%';
  }
}
