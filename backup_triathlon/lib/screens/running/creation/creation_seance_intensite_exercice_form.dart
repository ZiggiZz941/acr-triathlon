// lib/screens/running/creation/creation_seance_intensite_exercice_form.dart
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

  // NOUVEAUX: Contrôleurs pour le temps de référence
  final TextEditingController _tempsRefMinutesController =
      TextEditingController();
  final TextEditingController _tempsRefSecondesController =
      TextEditingController();
  final TextEditingController _tempsRefCentiemesController =
      TextEditingController();

  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();
  final TextEditingController _intensiteController = TextEditingController();

  // Contrôleurs pour les repos
  final TextEditingController _reposRepetitionsMinController =
      TextEditingController();
  final TextEditingController _reposRepetitionsSecController =
      TextEditingController();
  final TextEditingController _reposSeriesMinController =
      TextEditingController();
  final TextEditingController _reposSeriesSecController =
      TextEditingController();

  bool _showResult = false;
  String _resultText = '--:--.--';
  String _resultDescription = '';

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Focus nodes pour la navigation entre champs
  final FocusNode _tempsRefMinutesFocus = FocusNode();
  final FocusNode _tempsRefSecondesFocus = FocusNode();
  final FocusNode _tempsRefCentiemesFocus = FocusNode();

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
        : widget.sportType.defaultDistance.toString();
    _seriesController.text = widget.exercice.nbSeries > 0
        ? widget.exercice.nbSeries.toString()
        : '1';
    _repetitionsController.text = widget.exercice.nbRepetitions > 0
        ? widget.exercice.nbRepetitions.toString()
        : '1';
    _intensiteController.text = widget.exercice.valeurReference > 0
        ? widget.exercice.valeurReference.toStringAsFixed(1)
        : '100.0';

    // Initialiser les contrôleurs de repos
    _initializeTimeControllers();

    // NOUVEAU: Initialiser le temps de référence séparé en minutes, secondes, centièmes
    _initializeTempsReference();

    // Si des valeurs sont déjà présentes, calculer
    if (widget.exercice.distance > 0 && widget.exercice.tempsReference > 0) {
      _updateExercice();
    }
  }

  // NOUVEAU: Initialiser le temps de référence séparé
  void _initializeTempsReference() {
    double tempsRef = widget.exercice.tempsReference;

    if (tempsRef <= 0) {
      // Valeur par défaut selon le sport
      switch (widget.sportType) {
        case SportType.swimming:
          tempsRef = 90.0; // 1:30.00 pour 100m
          break;
        case SportType.cycling:
          tempsRef = 20.0; // 0:20.00 pour 100m
          break;
        case SportType.running:
          tempsRef = 45.0; // 0:45.00 pour 100m
          break;
      }
    }

    // Convertir en minutes, secondes, centièmes
    int minutes = (tempsRef ~/ 60).toInt();
    int secondes = (tempsRef % 60).toInt();
    int centiemes = ((tempsRef % 1) * 100).toInt();

    _tempsRefMinutesController.text = minutes.toString();
    _tempsRefSecondesController.text = secondes.toString().padLeft(2, '0');
    _tempsRefCentiemesController.text = centiemes.toString().padLeft(2, '0');
  }

  // Initialiser les contrôleurs de repos
  void _initializeTimeControllers() {
    // Pour repos répétitions
    int reposRepSec = widget.exercice.reposRepetitionsSec;
    int reposRepMin = reposRepSec ~/ 60;
    int reposRepSecRest = reposRepSec % 60;

    _reposRepetitionsMinController.text = reposRepMin.toString();
    _reposRepetitionsSecController.text =
        reposRepSecRest.toString().padLeft(2, '0');

    // Pour repos séries
    int reposSerSec = widget.exercice.reposSeriesSec;
    int reposSerMin = reposSerSec ~/ 60;
    int reposSerSecRest = reposSerSec % 60;

    _reposSeriesMinController.text = reposSerMin.toString();
    _reposSeriesSecController.text = reposSerSecRest.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomController.dispose();
    _distanceController.dispose();

    // NOUVEAU: Dispose des nouveaux contrôleurs
    _tempsRefMinutesController.dispose();
    _tempsRefSecondesController.dispose();
    _tempsRefCentiemesController.dispose();

    _seriesController.dispose();
    _repetitionsController.dispose();
    _intensiteController.dispose();
    _reposRepetitionsMinController.dispose();
    _reposRepetitionsSecController.dispose();
    _reposSeriesMinController.dispose();
    _reposSeriesSecController.dispose();

    // Dispose des focus nodes
    _tempsRefMinutesFocus.dispose();
    _tempsRefSecondesFocus.dispose();
    _tempsRefCentiemesFocus.dispose();

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
                    fontSize: TriathlonDimens.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onSupprimer,
                  icon: Icon(Icons.close, color: sportColor, size: 24),
                  iconSize: 24,
                ),
              ],
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

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

            const SizedBox(height: TriathlonDimens.paddingMedium),

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

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // NOUVEAU: Temps de référence séparé en Minutes/Secondes/Centièmes
            Text(
              'Temps de référence',
              style: TextStyle(color: sportColor, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                // Minutes
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minutes',
                        style: TextStyle(
                          color: TriathlonColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      TextField(
                        controller: _tempsRefMinutesController,
                        focusNode: _tempsRefMinutesFocus,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.length == 2) {
                            FocusScope.of(context)
                                .requestFocus(_tempsRefSecondesFocus);
                          }
                          _updateExercice();
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '0',
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
                const SizedBox(width: TriathlonDimens.paddingSmall),
                Text(
                  ':',
                  style: TextStyle(
                    color: sportColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: TriathlonDimens.paddingSmall),

                // Secondes
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secondes',
                        style: TextStyle(
                          color: TriathlonColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      TextField(
                        controller: _tempsRefSecondesController,
                        focusNode: _tempsRefSecondesFocus,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.length == 2) {
                            FocusScope.of(context)
                                .requestFocus(_tempsRefCentiemesFocus);
                          }
                          _updateExercice();
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '00',
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
                const SizedBox(width: TriathlonDimens.paddingSmall),
                Text(
                  '.',
                  style: TextStyle(
                    color: sportColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: TriathlonDimens.paddingSmall),

                // Centièmes
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Centièmes',
                        style: TextStyle(
                          color: TriathlonColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      TextField(
                        controller: _tempsRefCentiemesController,
                        focusNode: _tempsRefCentiemesFocus,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _updateExercice(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '00',
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

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Séries et Répétitions
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

                const SizedBox(width: TriathlonDimens.paddingMedium),

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

            const SizedBox(height: TriathlonDimens.paddingMedium),

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

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Repos répétitions (Minutes/Secondes)
            Text(
              'Repos répétitions',
              style: TextStyle(
                color: sportColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minutes',
                        style: TextStyle(
                          color: TriathlonColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      TextField(
                        controller: _reposRepetitionsMinController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _updateExercice(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Min',
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
                const SizedBox(width: TriathlonDimens.paddingSmall),
                Text(
                  ':',
                  style: TextStyle(
                    color: sportColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: TriathlonDimens.paddingSmall),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secondes',
                        style: TextStyle(
                          color: TriathlonColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      TextField(
                        controller: _reposRepetitionsSecController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _updateExercice(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Sec',
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

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Repos séries (Minutes/Secondes)
            Text(
              'Repos séries',
              style: TextStyle(
                color: sportColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minutes',
                        style: TextStyle(
                          color: TriathlonColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      TextField(
                        controller: _reposSeriesMinController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _updateExercice(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Min',
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
                const SizedBox(width: TriathlonDimens.paddingSmall),
                Text(
                  ':',
                  style: TextStyle(
                    color: sportColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: TriathlonDimens.paddingSmall),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secondes',
                        style: TextStyle(
                          color: TriathlonColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      TextField(
                        controller: _reposSeriesSecController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _updateExercice(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Sec',
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

            const SizedBox(height: TriathlonDimens.paddingLarge),

            // Bouton Prévisualiser
            SizedBox(
              width: double.infinity,
              height: TriathlonDimens.buttonHeight,
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

            const SizedBox(height: TriathlonDimens.paddingMedium),

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
                        padding: const EdgeInsets.all(
                          TriathlonDimens.paddingLarge,
                        ),
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
                      padding: const EdgeInsets.all(
                        TriathlonDimens.paddingMedium,
                      ),
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
      double distance = double.parse(
        _distanceController.text.replaceAll(',', '.'),
      );
      int series = int.parse(_seriesController.text);
      int repetitions = int.parse(_repetitionsController.text);
      double intensite =
          double.parse(_intensiteController.text.replaceAll(',', '.'));

      // NOUVEAU: Convertir le temps de référence depuis les champs séparés
      double tempsReference = _convertirTempsReferenceEnSecondes();

      // Parser les minutes et secondes pour repos répétitions
      int reposRepMin = int.tryParse(_reposRepetitionsMinController.text) ?? 0;
      int reposRepSec = int.tryParse(_reposRepetitionsSecController.text) ?? 0;
      int reposRepTotalSec = (reposRepMin * 60) + reposRepSec;

      // Parser les minutes et secondes pour repos séries
      int reposSerMin = int.tryParse(_reposSeriesMinController.text) ?? 0;
      int reposSerSec = int.tryParse(_reposSeriesSecController.text) ?? 0;
      int reposSerTotalSec = (reposSerMin * 60) + reposSerSec;

      // Validations
      if (distance <= 0 ||
          series <= 0 ||
          intensite <= 0 ||
          intensite > 100 ||
          tempsReference <= 0) {
        return;
      }

      // Validation des secondes et centièmes
      int secondes = int.tryParse(_tempsRefSecondesController.text) ?? 0;
      int centiemes = int.tryParse(_tempsRefCentiemesController.text) ?? 0;

      if (secondes >= 60) {
        // Corriger automatiquement si secondes >= 60
        int minutesAjoutees = secondes ~/ 60;
        secondes = secondes % 60;
        int minutesActuelles =
            int.tryParse(_tempsRefMinutesController.text) ?? 0;
        _tempsRefMinutesController.text =
            (minutesActuelles + minutesAjoutees).toString();
        _tempsRefSecondesController.text = secondes.toString().padLeft(2, '0');
      }

      if (centiemes >= 100) {
        // Corriger automatiquement si centièmes >= 100
        int secondesAjoutees = centiemes ~/ 100;
        centiemes = centiemes % 100;
        secondes += secondesAjoutees;
        _tempsRefSecondesController.text = secondes.toString().padLeft(2, '0');
        _tempsRefCentiemesController.text =
            centiemes.toString().padLeft(2, '0');
      }

      if (repetitions <= 0) repetitions = 1;
      if (reposRepTotalSec < 0) reposRepTotalSec = 0;
      if (reposSerTotalSec < 0) reposSerTotalSec = 0;

      // Si une seule série, ignorer le repos entre séries
      if (series == 1) {
        reposSerTotalSec = 0;
        _reposSeriesMinController.text = '0';
        _reposSeriesSecController.text = '00';
      }

      // Mettre à jour l'exercice
      widget.exercice.nom = nom;
      widget.exercice.distance = distance;
      widget.exercice.nbSeries = series;
      widget.exercice.nbRepetitions = repetitions;
      widget.exercice.valeurReference = intensite;
      widget.exercice.tempsReference = tempsReference;
      widget.exercice.reposRepetitionsSec = reposRepTotalSec;
      widget.exercice.reposSeriesSec = reposSerTotalSec;

      // Calculer le temps à l'intensité donnée
      double tempsCalcule = (tempsReference * 100.0) / intensite;

      // Mettre à jour les temps min et max de l'exercice
      widget.exercice.tempsMin = tempsCalcule;
      widget.exercice.tempsMax = tempsCalcule;

      // Formater les temps de repos
      String reposRepFormate =
          TriathlonExercice.formatTempsEnMinutes(reposRepTotalSec);
      String reposSerFormate =
          TriathlonExercice.formatTempsEnMinutes(reposSerTotalSec);

      // Mettre à jour le texte de résultat
      setState(() {
        _resultText = _formatResultAvecCentiemes(tempsCalcule);
        _resultDescription =
            '$series séries de $repetitions × ${distance.toInt()}m à ${intensite.toStringAsFixed(1)}%\n'
            'Repos entre répétitions: $reposRepFormate\n'
            'Repos entre séries: $reposSerFormate';
        _showResult = true;
      });

      // Notifier le parent
      widget.onCalculer(widget.exercice);
    } catch (e) {
      // Ignorer les erreurs de parsing pendant la saisie
    }
  }

  // NOUVEAU: Fonction pour convertir le temps de référence en secondes
  double _convertirTempsReferenceEnSecondes() {
    try {
      int minutes = int.tryParse(_tempsRefMinutesController.text) ?? 0;
      int secondes = int.tryParse(_tempsRefSecondesController.text) ?? 0;
      int centiemes = int.tryParse(_tempsRefCentiemesController.text) ?? 0;

      // Validation
      if (secondes >= 60) {
        minutes += secondes ~/ 60;
        secondes = secondes % 60;
      }

      if (centiemes >= 100) {
        secondes += centiemes ~/ 100;
        centiemes = centiemes % 100;
      }

      // Convertir en secondes avec décimales
      double totalSecondes = (minutes * 60) + secondes + (centiemes / 100.0);

      if (totalSecondes < 0) {
        return 0;
      }

      return totalSecondes;
    } catch (e) {
      return 0;
    }
  }

  String _formatResultAvecCentiemes(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    double secondesDecimal = seconds % 60;

    if (secondesDecimal >= 60) {
      minutes += (secondesDecimal ~/ 60).toInt();
      secondesDecimal = secondesDecimal % 60;
    }

    int secondesInt = secondesDecimal.toInt();
    int centiemes = ((secondesDecimal - secondesInt) * 100).toInt();

    if (minutes > 0) {
      return '${minutes}:${secondesInt.toString().padLeft(2, '0')}.${centiemes.toString().padLeft(2, '0')}';
    } else {
      return '${secondesInt.toString().padLeft(2, '0')}.${centiemes.toString().padLeft(2, '0')}';
    }
  }
}
