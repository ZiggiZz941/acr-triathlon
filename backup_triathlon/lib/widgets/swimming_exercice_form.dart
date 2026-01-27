import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_manager.dart';
import '../constants/triathlon_colors.dart';
import '../constants/triathlon_dimens.dart';
import '../models/triathlon_exercice.dart';
import '../models/sport_type.dart';
import '../widgets/time_input_field.dart';
import '../widgets/swimming_allure_input.dart';

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
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();

  final TextEditingController _reposRepetitionsMinController =
      TextEditingController();
  final TextEditingController _reposRepetitionsSecController =
      TextEditingController();
  final TextEditingController _reposSeriesMinController =
      TextEditingController();
  final TextEditingController _reposSeriesSecController =
      TextEditingController();

  // Contrôleurs pour afficher le temps 400m
  final TextEditingController _temps400mMinController = TextEditingController();
  final TextEditingController _temps400mSecController = TextEditingController();
  final TextEditingController _temps400mCentController =
      TextEditingController();

  // Pour les allures de natation (1-6 comme en course)
  int _selectedAllure = 3; // Allure 3 par défaut (80-85%)

  bool _showResult = false;
  bool _useProfileTime = false;
  String _resultTextTempsLent = '';
  String _resultTextTempsRapide = '';
  String _description = '';

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _scaleAnimation2;

  // Pourcentages correspondant à chaque allure (min et max)
  final Map<int, Map<String, double>> _allurePourcentages = {
    1: {'min': 60.0, 'max': 70.0}, // Allure 1: 60-70%
    2: {'min': 70.0, 'max': 80.0}, // Allure 2: 70-80%
    3: {'min': 80.0, 'max': 85.0}, // Allure 3: 80-85%
    4: {'min': 85.0, 'max': 90.0}, // Allure 4: 85-90%
    5: {'min': 90.0, 'max': 95.0}, // Allure 5: 90-95%
    6: {'min': 100.0, 'max': 100.0}, // Allure 6: 100% (un seul temps)
  };

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

    _scaleAnimation2 = TweenSequence<double>([
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
        : '100';
    _seriesController.text = widget.exercice.nbSeries > 0
        ? widget.exercice.nbSeries.toString()
        : '3';
    _repetitionsController.text = widget.exercice.nbRepetitions > 0
        ? widget.exercice.nbRepetitions.toString()
        : '1';

    // Initialiser les contrôleurs pour le temps
    _initializeTimeControllers();

    // Initialiser le temps 400m par défaut
    _updateTemps400mControllers(360.0); // 6:00.00 par défaut

    // Vérifier si un temps est disponible dans le profil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileTime();
    });
  }

  // Mettre à jour les contrôleurs du temps 400m
  void _updateTemps400mControllers(double seconds400m) {
    int minutes = (seconds400m ~/ 60).toInt();
    int secondes = (seconds400m % 60).toInt();
    int centiemes = ((seconds400m % 1) * 100).toInt();

    _temps400mMinController.text = minutes.toString();
    _temps400mSecController.text = secondes.toString().padLeft(2, '0');
    _temps400mCentController.text = centiemes.toString().padLeft(2, '0');
  }

  // Obtenir la description de l'allure
  String _getAllureDescription(int allureNum) {
    switch (allureNum) {
      case 1:
        return 'Allure 1 (60-70% intensité)';
      case 2:
        return 'Allure 2 (70-80% intensité)';
      case 3:
        return 'Allure 3 (80-85% intensité)';
      case 4:
        return 'Allure 4 (85-90% intensité)';
      case 5:
        return 'Allure 5 (90-95% intensité)';
      case 6:
        return 'Allure 6 (100% intensité)';
      default:
        return 'Allure 3 (80-85% intensité)';
    }
  }

  // Obtenir les pourcentages min et max d'une allure
  Map<String, double> _getAllurePourcentages(int allureNum) {
    return _allurePourcentages[allureNum] ?? {'min': 80.0, 'max': 85.0};
  }

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

  void _checkProfileTime() {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final profileTime = dataManager.getSwimming400mTime();

    if (profileTime != null) {
      setState(() {
        _updateTemps400mControllers(profileTime);
        _useProfileTime = true;
      });
      _updateExercice();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomController.dispose();
    _distanceController.dispose();
    _seriesController.dispose();
    _repetitionsController.dispose();
    _temps400mMinController.dispose();
    _temps400mSecController.dispose();
    _temps400mCentController.dispose();
    _reposRepetitionsMinController.dispose();
    _reposRepetitionsSecController.dispose();
    _reposSeriesMinController.dispose();
    _reposSeriesSecController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final hasProfileTime = dataManager.getSwimming400mTime() != null;
    final bool isAllure6 = _selectedAllure == 6;

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
            // En-tête
            Row(
              children: [
                Text(
                  'Exercice Natation',
                  style: TextStyle(
                    color: TriathlonColors.swimming,
                    fontSize: TriathlonDimens.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onSupprimer,
                  icon: Icon(Icons.close,
                      color: TriathlonColors.swimming, size: 24),
                  iconSize: 20,
                ),
              ],
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Nom
            Text(
              'Nom (optionnel)',
              style: TextStyle(
                color: TriathlonColors.swimming,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _nomController,
              onChanged: (_) => _updateExercice(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Ex: 100m crawl Allure 3',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    TriathlonDimens.borderRadiusMedium,
                  ),
                  borderSide: BorderSide(
                    color: TriathlonColors.swimming,
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

            // Section Allure avec option profil
            if (hasProfileTime)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Utiliser le temps du profil',
                      style: TextStyle(
                        color: TriathlonColors.swimming,
                        fontSize: 16,
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
                            _updateTemps400mControllers(profileTime);
                          }
                        }
                      });
                      _updateExercice();
                    },
                    activeColor: TriathlonColors.swimming,
                  ),
                ],
              ),

            if (hasProfileTime) const SizedBox(height: 5),

            // Temps 400m
            Text(
              'Temps 400m',
              style: TextStyle(
                color: TriathlonColors.swimming,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            SwimmingAllureInput(
              minController: _temps400mMinController,
              secController: _temps400mSecController,
              centController: _temps400mCentController,
              enabled: !_useProfileTime || !hasProfileTime,
              onChanged: (_) => _updateExercice(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                'Temps de référence pour 400m (100% intensité)',
                style: TextStyle(
                  color: TriathlonColors.textSecondary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Sélection d'allure
            Text(
              'Allure',
              style: TextStyle(
                color: TriathlonColors.swimming,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),

            // Grid des allures (2x3)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: List.generate(6, (index) {
                final allureNum = index + 1;
                final isSelected = _selectedAllure == allureNum;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAllure = allureNum;
                    });
                    _updateExercice();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TriathlonColors.swimming
                          : TriathlonColors.swimming.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        TriathlonDimens.borderRadiusMedium,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? TriathlonColors.swimming
                            : TriathlonColors.swimming.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getAllureDescription(allureNum),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : TriathlonColors.swimming,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Distance
            Text(
              'Distance (m)',
              style: TextStyle(
                color: TriathlonColors.swimming,
                fontSize: 16,
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
                  borderRadius: BorderRadius.circular(
                    TriathlonDimens.borderRadiusMedium,
                  ),
                  borderSide: BorderSide(
                    color: TriathlonColors.swimming,
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
                              color: TriathlonColors.swimming,
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
                          color: TriathlonColors.swimming,
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
                              color: TriathlonColors.swimming,
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

            // Utiliser le widget TimeInputField pour repos répétitions
            TimeInputField(
              label: 'Repos répétitions',
              initialSeconds: widget.exercice.reposRepetitionsSec,
              onChanged: (totalSeconds) {
                widget.exercice.reposRepetitionsSec = totalSeconds;
                _updateExercice();
              },
              color: TriathlonColors.swimming,
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Utiliser le widget TimeInputField pour repos séries
            TimeInputField(
              label: 'Repos séries',
              initialSeconds: widget.exercice.reposSeriesSec,
              onChanged: (totalSeconds) {
                widget.exercice.reposSeriesSec = totalSeconds;
                _updateExercice();
              },
              color: TriathlonColors.swimming,
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
                  foregroundColor: TriathlonColors.swimming,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      TriathlonDimens.borderRadiusXLarge,
                    ),
                    side: BorderSide(
                      color: TriathlonColors.swimming,
                      width: 2,
                    ),
                  ),
                ),
                child: const Text(
                  'PRÉVISUALISER',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Zone résultat avec DEUX temps (ou un seul pour allure 6)
            AnimatedOpacity(
              opacity: _showResult ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showResult ? null : 0,
                child: Column(
                  children: [
                    // Premier temps: Temps LENT (pourcentage max)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          TriathlonDimens.paddingMedium,
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: TriathlonColors.swimming,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            TriathlonDimens.borderRadiusMedium,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isAllure6
                                  ? 'Temps pour ${_distanceController.text.isEmpty ? "100" : _distanceController.text}m'
                                  : 'Temps LENT (${_getAllurePourcentages(_selectedAllure)['min']}%)',
                              style: TextStyle(
                                color: TriathlonColors.swimming,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _resultTextTempsLent,
                              style: TextStyle(
                                color: TriathlonColors.swimming,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Deuxième temps: Temps RAPIDE (pourcentage min) - sauf pour allure 6
                    if (!isAllure6)
                      ScaleTransition(
                        scale: _scaleAnimation2,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(
                            TriathlonDimens.paddingMedium,
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: TriathlonColors.swimming.withOpacity(0.7),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(
                              TriathlonDimens.borderRadiusMedium,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Temps RAPIDE (${_getAllurePourcentages(_selectedAllure)['max']}%)',
                                style: TextStyle(
                                  color: TriathlonColors.swimming,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _resultTextTempsRapide,
                                style: TextStyle(
                                  color: TriathlonColors.swimming,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Description
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        TriathlonDimens.paddingMedium,
                      ),
                      decoration: BoxDecoration(
                        color: TriathlonColors.swimming.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusMedium,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getAllureDescription(_selectedAllure),
                            style: TextStyle(
                              color: TriathlonColors.swimming,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _description,
                            style: TextStyle(
                              color: TriathlonColors.textPrimary,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
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
      String distanceStr = _distanceController.text.trim();
      String seriesStr = _seriesController.text.trim();
      String repetitionsStr = _repetitionsController.text.trim();

      // Convertir le temps 400m en secondes
      double temps400m = _convertirTemps400mEnSecondes();

      // Calculer le temps pour 100m à 100% intensité
      double temps100mRef = temps400m / 4.0;

      // Récupérer les valeurs des minutes/secondes pour repos
      int reposRepMin = int.tryParse(_reposRepetitionsMinController.text) ?? 0;
      int reposRepSec = int.tryParse(_reposRepetitionsSecController.text) ?? 0;
      int reposRepTotalSec = (reposRepMin * 60) + reposRepSec;

      int reposSerMin = int.tryParse(_reposSeriesMinController.text) ?? 0;
      int reposSerSec = int.tryParse(_reposSeriesSecController.text) ?? 0;
      int reposSerTotalSec = (reposSerMin * 60) + reposSerSec;

      // Validation
      if (temps400m <= 0 ||
          distanceStr.isEmpty ||
          seriesStr.isEmpty ||
          repetitionsStr.isEmpty) {
        return;
      }

      double distance = double.parse(distanceStr.replaceAll(',', '.'));
      int series = int.parse(seriesStr);
      int repetitions = int.parse(repetitionsStr);

      // Validation des valeurs
      if (distance <= 0 || series <= 0) {
        return;
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

      // Obtenir les pourcentages de l'allure
      Map<String, double> pourcentages =
          _getAllurePourcentages(_selectedAllure);
      double pourcentageMin = pourcentages['min']!;
      double pourcentageMax = pourcentages['max']!;

      // Calculer les temps pour 100m aux deux pourcentages
      double temps100mLent = (temps100mRef * 100.0) / pourcentageMin;
      double temps100mRapide = (temps100mRef * 100.0) / pourcentageMax;

      // Calculer les temps pour la distance spécifiée
      double tempsPourDistanceLent = (temps100mLent * distance) / 100.0;
      double tempsPourDistanceRapide = (temps100mRapide * distance) / 100.0;

      // Créer le nom si vide
      if (nom.isEmpty) {
        nom = '${distance.toInt()}m ${_getAllureDescription(_selectedAllure)}';
      }

      // Mettre à jour l'exercice
      widget.exercice.nom = nom;
      widget.exercice.sportType = SportType.swimming;
      widget.exercice.distance = distance;
      widget.exercice.nbSeries = series;
      widget.exercice.nbRepetitions = repetitions;
      // Stocker le temps moyen pour 100m
      double temps100mMoyen = _selectedAllure == 6
          ? temps100mRapide
          : (temps100mLent + temps100mRapide) / 2.0;
      widget.exercice.valeurReference = temps100mMoyen;
      widget.exercice.reposRepetitionsSec = reposRepTotalSec;
      widget.exercice.reposSeriesSec = reposSerTotalSec;

      // Mettre à jour les temps min et max
      widget.exercice.tempsMin = _selectedAllure == 6
          ? tempsPourDistanceRapide
          : tempsPourDistanceLent;
      widget.exercice.tempsMax = tempsPourDistanceRapide;

      // Formater les résultats
      String tempsLentFormate = _formatTemps(tempsPourDistanceLent);
      String tempsRapideFormate = _formatTemps(tempsPourDistanceRapide);
      String temps400mRefFormate = _formatTemps(temps400m);
      String reposRepFormate =
          TriathlonExercice.formatTempsEnMinutes(reposRepTotalSec);
      String reposSerFormate =
          TriathlonExercice.formatTempsEnMinutes(reposSerTotalSec);

      setState(() {
        _resultTextTempsLent = tempsLentFormate;
        _resultTextTempsRapide = tempsRapideFormate;
        if (_selectedAllure == 6) {
          _description =
              '$series séries de $repetitions × ${distance.toInt()}m\n'
              'Temps 400m de référence: $temps400mRefFormate\n'
              'Repos entre répétitions: $reposRepFormate\n'
              'Repos entre séries: $reposSerFormate\n'
              'Intensité: ${pourcentageMax.toStringAsFixed(0)}%';
        } else {
          _description =
              '$series séries de $repetitions × ${distance.toInt()}m\n'
              'Temps 400m de référence: $temps400mRefFormate\n'
              'Repos entre répétitions: $reposRepFormate\n'
              'Repos entre séries: $reposSerFormate\n'
              'Plage d\'intensité: ${pourcentageMin.toStringAsFixed(0)}-${pourcentageMax.toStringAsFixed(0)}%';
        }
        _showResult = true;
      });

      // Notifier le parent
      widget.onCalculer(widget.exercice);
    } catch (e) {
      // Ignorer les erreurs de parsing pendant la saisie
    }
  }

  // Convertir le temps 400m en secondes
  double _convertirTemps400mEnSecondes() {
    try {
      int minutes = int.tryParse(_temps400mMinController.text) ?? 0;
      int secondes = int.tryParse(_temps400mSecController.text) ?? 0;
      int centiemes = int.tryParse(_temps400mCentController.text) ?? 0;

      // Validation et correction automatique
      if (secondes >= 60) {
        minutes += secondes ~/ 60;
        secondes = secondes % 60;
        _temps400mMinController.text = minutes.toString();
        _temps400mSecController.text = secondes.toString().padLeft(2, '0');
      }

      if (centiemes >= 100) {
        secondes += centiemes ~/ 100;
        centiemes = centiemes % 100;
        if (secondes >= 60) {
          minutes += secondes ~/ 60;
          secondes = secondes % 60;
          _temps400mMinController.text = minutes.toString();
        }
        _temps400mSecController.text = secondes.toString().padLeft(2, '0');
        _temps400mCentController.text = centiemes.toString().padLeft(2, '0');
      }

      return (minutes * 60) + secondes + (centiemes / 100.0);
    } catch (e) {
      return 0;
    }
  }

  // Formater le temps
  String _formatTemps(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    int secondes = (seconds % 60).toInt();
    int centiemes = ((seconds % 1) * 100).toInt();

    if (minutes > 0) {
      return '${minutes}:${secondes.toString().padLeft(2, '0')}.${centiemes.toString().padLeft(2, '0')}';
    } else {
      return '${secondes.toString().padLeft(2, '0')}.${centiemes.toString().padLeft(2, '0')}';
    }
  }
}
