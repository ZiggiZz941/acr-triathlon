import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_manager.dart';
import '../constants/triathlon_colors.dart';
import '../models/triathlon_exercice.dart';
import '../models/sport_type.dart';
import '../models/swimming_calculator.dart';

class SwimmingExerciceForm extends StatefulWidget {
  final TriathlonExercice exercice;
  final Function(TriathlonExercice) onCalculer;
  final VoidCallback onSupprimer;

  const SwimmingExerciceForm({
    super.key,
    required this.exercice,
    required this.onCalculer,
    required this.onSupprimer,
  });

  @override
  _SwimmingExerciceFormState createState() => _SwimmingExerciceFormState();
}

class _SwimmingExerciceFormState extends State<SwimmingExerciceForm>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _temps400mController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _intensiteController = TextEditingController();
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();
  final TextEditingController _reposRepetitionsController =
      TextEditingController();
  final TextEditingController _reposSeriesController = TextEditingController();

  bool _showResult = false;
  bool _useProfileTime = false;
  String _resultText = '';

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Initialiser les contrôleurs
    _nomController.text = widget.exercice.nom;
    _distanceController.text = widget.exercice.distance > 0
        ? widget.exercice.distance.toInt().toString()
        : '100';
    _seriesController.text = widget.exercice.nbSeries > 0
        ? widget.exercice.nbSeries.toString()
        : '3';
    _repetitionsController.text = widget.exercice.nbRepetitions > 0
        ? widget.exercice.nbRepetitions.toString()
        : '1';
    _reposRepetitionsController.text = widget.exercice.reposRepetitionsFormate;
    _reposSeriesController.text = widget.exercice.reposSeriesFormate;
    _intensiteController.text = '80.0';

    // Déterminer si on utilise le temps du profil
    final hasProfileTime = widget.exercice.valeurReference > 0;

    if (hasProfileTime) {
      // Convertir le temps de référence (pour 100m) en temps 400m
      double temps400m = widget.exercice.valeurReference * 4;
      _temps400mController.text =
          SwimmingCalculator.formatSwimmingTime(temps400m);
      _useProfileTime = true;
    } else {
      // Temps 400m par défaut (6:30 = 390 secondes)
      _temps400mController.text = '6:30.00';
      _useProfileTime = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Vérifier si un temps est disponible dans le profil
    _checkProfileTime();
  }

  void _checkProfileTime() {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final profileTime = dataManager.getSwimming400mTime();

    if (profileTime != null && _temps400mController.text.isEmpty) {
      setState(() {
        _temps400mController.text =
            SwimmingCalculator.formatSwimmingTime(profileTime);
        _useProfileTime = true;
      });
      _updateExercice();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomController.dispose();
    _temps400mController.dispose();
    _distanceController.dispose();
    _intensiteController.dispose();
    _seriesController.dispose();
    _repetitionsController.dispose();
    _reposRepetitionsController.dispose();
    _reposSeriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final hasProfileTime = dataManager.getSwimming400mTime() != null;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Text(
                  'Exercice Natation',
                  style: TextStyle(
                    color: TriathlonColors.swimming,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onSupprimer,
                  icon: const Icon(Icons.close, color: Colors.red),
                  iconSize: 20,
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Nom
            Text(
              'Nom (optionnel)',
              style: TextStyle(
                color: TriathlonColors.swimming,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _nomController,
              onChanged: (_) => _updateExercice(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Ex: 100m crawl à 80%',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: TriathlonColors.swimming,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Section Temps 400m avec option profil
            if (hasProfileTime)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Utiliser le temps du profil',
                      style: TextStyle(
                        color: TriathlonColors.swimming,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Switch(
                    value: _useProfileTime,
                    onChanged: (value) {
                      setState(() {
                        _useProfileTime = value;
                        if (value) {
                          final profileTime = dataManager.getSwimming400mTime();
                          if (profileTime != null) {
                            _temps400mController.text =
                                SwimmingCalculator.formatSwimmingTime(
                                    profileTime);
                          }
                        }
                      });
                      _updateExercice();
                    },
                    activeColor: TriathlonColors.swimming,
                  ),
                ],
              ),

            const SizedBox(height: 5),

            // Temps 400m et Distance
            Row(
              children: [
                // Temps 400m
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temps 400m',
                        style: TextStyle(
                          color: TriathlonColors.swimming,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _temps400mController,
                        enabled: !_useProfileTime || !hasProfileTime,
                        onChanged: (_) => _updateExercice(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _useProfileTime && hasProfileTime
                              ? TriathlonColors.swimming.withOpacity(0.1)
                              : Colors.white,
                          hintText: _useProfileTime && hasProfileTime
                              ? 'Temps du profil utilisé'
                              : 'mm:ss.xx',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: TriathlonColors.swimming,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Distance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distance (m)',
                        style: TextStyle(
                          color: TriathlonColors.swimming,
                          fontSize: 14,
                        ),
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
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: TriathlonColors.swimming,
                              width: 2,
                            ),
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
              style: TextStyle(
                color: TriathlonColors.swimming,
                fontSize: 14,
              ),
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
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: TriathlonColors.swimming,
                    width: 2,
                  ),
                ),
              ),
            ),

            // ... (le reste du formulaire reste inchangé)

            const SizedBox(height: 15),

            // Structure (Séries/Répétitions)
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
                          color: TriathlonColors.swimming,
                          fontSize: 14,
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
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: TriathlonColors.swimming,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Répétitions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Répétitions',
                        style: TextStyle(
                          color: TriathlonColors.swimming,
                          fontSize: 14,
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
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: TriathlonColors.swimming,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Repos
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
                          color: TriathlonColors.swimming,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _reposRepetitionsController,
                        onChanged: (_) => _updateExercice(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Ex: 0:30',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: TriathlonColors.swimming,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Repos séries
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repos séries',
                        style: TextStyle(
                          color: TriathlonColors.swimming,
                          fontSize: 14,
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
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: TriathlonColors.swimming,
                              width: 2,
                            ),
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
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  _updateExercice();
                  _animationController.reset();
                  _animationController.forward();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: TriathlonColors.swimming,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                      color: TriathlonColors.swimming,
                      width: 2,
                    ),
                  ),
                ),
                child: const Text(
                  'PRÉVISUALISER',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: TriathlonColors.swimming,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _resultText,
                      style: TextStyle(
                        color: TriathlonColors.swimming,
                        fontSize: 14,
                      ),
                    ),
                  ),
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
      String temps400mStr = _temps400mController.text.trim();
      String distanceStr = _distanceController.text.trim();
      String intensiteStr = _intensiteController.text.trim();
      String seriesStr = _seriesController.text.trim();
      String repetitionsStr = _repetitionsController.text.trim();
      String reposRepStr = _reposRepetitionsController.text.trim();
      String reposSerStr = _reposSeriesController.text.trim();

      // Validation
      if (temps400mStr.isEmpty ||
          distanceStr.isEmpty ||
          intensiteStr.isEmpty ||
          seriesStr.isEmpty ||
          repetitionsStr.isEmpty) {
        return;
      }

      // Convertir le temps 400m
      double temps400m = SwimmingCalculator.parseSwimmingTime(temps400mStr);
      double distance = double.parse(distanceStr.replaceAll(',', '.'));
      double intensite = double.parse(intensiteStr.replaceAll(',', '.'));
      int series = int.parse(seriesStr);
      int repetitions = int.parse(repetitionsStr);
      int reposRepSec = TriathlonExercice.parseTempsEnSecondes(reposRepStr);
      int reposSerSec = TriathlonExercice.parseTempsEnSecondes(reposSerStr);

      // Validation des valeurs
      if (temps400m <= 0 ||
          distance <= 0 ||
          intensite <= 0 ||
          intensite > 100) {
        return;
      }

      if (repetitions <= 0) repetitions = 1;
      if (reposRepSec < 0) reposRepSec = 0;
      if (reposSerSec < 0) reposSerSec = 0;

      // Si une seule série, ignorer le repos entre séries
      if (series == 1) {
        reposSerSec = 0;
      }

      // Calculer le temps pour 100m
      double tempsPour100m = temps400m / 4.0;
      double valeurReference = tempsPour100m; // temps pour 100m

      // Créer le nom si vide
      if (nom.isEmpty) {
        nom = '${distance.toInt()}m à ${intensite.toInt()}%';
      }

      // Mettre à jour l'exercice
      widget.exercice.nom = nom;
      widget.exercice.sportType = SportType.swimming;
      widget.exercice.distance = distance;
      widget.exercice.nbSeries = series;
      widget.exercice.nbRepetitions = repetitions;
      widget.exercice.valeurReference = valeurReference;
      widget.exercice.intensite = intensite.round();
      widget.exercice.reposRepetitionsSec = reposRepSec;
      widget.exercice.reposSeriesSec = reposSerSec;

      // Recalculer les temps
      widget.exercice.calculerTemps();

      // Formater le résultat
      String tempsFormate =
          widget.exercice.formatTemps(widget.exercice.tempsMin);
      String reposRepFormate =
          TriathlonExercice.formatTempsEnMinutes(reposRepSec);
      String reposSerFormate =
          TriathlonExercice.formatTempsEnMinutes(reposSerSec);

      setState(() {
        _resultText =
            '$series séries de $repetitions x ${distance.toInt()}m à $tempsFormate\n'
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
}
