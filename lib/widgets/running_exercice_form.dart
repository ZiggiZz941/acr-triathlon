import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/triathlon_colors.dart';
import '../constants/triathlon_dimens.dart';
import '../constants/triathlon_strings.dart';
import '../models/triathlon_exercice.dart';
import '../services/data_manager.dart';

class RunningExerciceForm extends StatefulWidget {
  final TriathlonExercice exercice;
  final Function(TriathlonExercice) onCalculer;
  final VoidCallback onSupprimer;

  const RunningExerciceForm({
    super.key,
    required this.exercice,
    required this.onCalculer,
    required this.onSupprimer,
  });

  @override
  _RunningExerciceFormState createState() => _RunningExerciceFormState();
}

class _RunningExerciceFormState extends State<RunningExerciceForm>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();
  final TextEditingController _vmaController = TextEditingController();
  final TextEditingController _reposRepetitionsController =
      TextEditingController();
  final TextEditingController _reposSeriesController = TextEditingController();

  int _selectedAllure = 2; // Allure 3 par défaut
  bool _showResult = false;
  bool _useProfileVMA = false; // AJOUT: Pour utiliser la VMA du profil
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

    // Initialiser les contrôleurs avec les valeurs de l'exercice
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
    _reposRepetitionsController.text = widget.exercice.reposRepetitionsFormate;
    _reposSeriesController.text = widget.exercice.reposSeriesFormate;
    _selectedAllure = (widget.exercice.allure ?? 3) - 1;

    // Initialiser la VMA - sera remplie par didChangeDependencies
    if (widget.exercice.valeurReference > 0) {
      _vmaController.text = widget.exercice.valeurReference.toStringAsFixed(1);
    }

    // Si l'exercice a déjà des valeurs, calculer
    if (widget.exercice.distance > 0 && widget.exercice.valeurReference > 0) {
      _updateExercice();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileVMA();
  }

  // AJOUT: Méthode pour charger la VMA du profil
  void _loadProfileVMA() {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final profile = dataManager.getTriathlonProfile();

    if (profile.containsKey('running_vma')) {
      final vma = profile['running_vma'] as double?;
      if (vma != null) {
        // Si le champ VMA est vide ou si on utilise déjà le profil
        if (_vmaController.text.isEmpty || _useProfileVMA) {
          setState(() {
            _vmaController.text = vma.toStringAsFixed(1);
            _useProfileVMA = true;
          });

          // Mettre à jour l'exercice avec la VMA du profil
          if (mounted && _distanceController.text.isNotEmpty) {
            widget.exercice.valeurReference = vma;
            _updateExercice();
          }
        }
      }
    } else {
      // Valeur par défaut si pas de profil
      if (_vmaController.text.isEmpty) {
        setState(() {
          _vmaController.text = '16.0';
          _useProfileVMA = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomController.dispose();
    _distanceController.dispose();
    _seriesController.dispose();
    _repetitionsController.dispose();
    _vmaController.dispose();
    _reposRepetitionsController.dispose();
    _reposSeriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final profile = dataManager.getTriathlonProfile();
    final hasProfileVMA =
        profile.containsKey('running_vma') && profile['running_vma'] != null;

    final sportColor = TriathlonColors.running;

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
                  'Exercice Course',
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
                hintText: 'Ex: 1000m endurance',
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
                hintText: 'Ex: 1000',
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

            // VMA avec switch
            if (hasProfileVMA)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'VMA (km/h)',
                      style: TextStyle(
                        color: sportColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Profil',
                        style: TextStyle(
                          color: sportColor,
                          fontSize: 12,
                        ),
                      ),
                      Switch(
                        value: _useProfileVMA,
                        onChanged: (value) {
                          setState(() {
                            _useProfileVMA = value;
                            if (value) {
                              _loadProfileVMA();
                            } else {
                              // Garder la valeur actuelle
                            }
                          });
                        },
                        activeColor: sportColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              )
            else
              Text(
                'VMA (km/h)',
                style: TextStyle(color: sportColor, fontSize: 16),
              ),

            const SizedBox(height: 5),

            TextField(
              controller: _vmaController,
              enabled: !_useProfileVMA || !hasProfileVMA,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _updateExercice(),
              decoration: InputDecoration(
                filled: true,
                fillColor: _useProfileVMA && hasProfileVMA
                    ? sportColor.withOpacity(0.1)
                    : Colors.white,
                hintText: _useProfileVMA && hasProfileVMA
                    ? 'VMA du profil utilisée'
                    : 'Ex: 16.5',
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
                suffixIcon: hasProfileVMA && !_useProfileVMA
                    ? IconButton(
                        icon: const Icon(Icons.refresh, size: 16),
                        onPressed: () {
                          setState(() {
                            _useProfileVMA = true;
                            _loadProfileVMA();
                          });
                        },
                        tooltip: 'Utiliser la VMA du profil',
                      )
                    : null,
              ),
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Allure
            Text(
              'Allure',
              style: TextStyle(color: sportColor, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: sportColor, width: 2),
                borderRadius: BorderRadius.circular(
                  TriathlonDimens.borderRadiusMedium,
                ),
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedAllure,
                items: TriathlonStrings.alluresSimplifie
                    .asMap()
                    .entries
                    .map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: TriathlonColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAllure = value!;
                  });
                  _updateExercice();
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: TriathlonDimens.paddingMedium,
                    vertical: TriathlonDimens.paddingMedium,
                  ),
                ),
              ),
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

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

                const SizedBox(width: TriathlonDimens.paddingMedium),

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

            // Information si la VMA du profil est utilisée
            if (_useProfileVMA && hasProfileVMA)
              Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sportColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: sportColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Utilisation de la VMA du profil',
                        style: TextStyle(
                          color: TriathlonColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
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
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(TriathlonDimens.paddingMedium),
                    decoration: BoxDecoration(
                      border: Border.all(color: sportColor, width: 2),
                      borderRadius: BorderRadius.circular(
                        TriathlonDimens.borderRadiusMedium,
                      ),
                    ),
                    child: Text(
                      _resultText,
                      style: TextStyle(
                        color: sportColor,
                        fontSize: 15,
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
      if (nom.isEmpty) {
        nom = 'Exercice ${_selectedAllure + 1}';
      }

      double distance = double.parse(
        _distanceController.text.replaceAll(',', '.'),
      );
      int series = int.parse(_seriesController.text);
      int repetitions = int.parse(_repetitionsController.text);
      double vma = double.parse(_vmaController.text.replaceAll(',', '.'));
      int reposRepSec = TriathlonExercice.parseTempsEnSecondes(
        _reposRepetitionsController.text,
      );
      int reposSerSec = TriathlonExercice.parseTempsEnSecondes(
        _reposSeriesController.text,
      );

      // Validations
      if (distance <= 0 || series <= 0 || vma <= 0) {
        return;
      }

      if (repetitions <= 0) repetitions = 1;
      if (reposRepSec < 0) reposRepSec = 0;
      if (reposSerSec < 0) reposSerSec = 0;

      // Si une seule série, ignorer le repos entre séries
      if (series == 1) {
        reposSerSec = 0;
      }

      int allure = _selectedAllure + 1;

      // Mettre à jour l'exercice
      widget.exercice.nom = nom;
      widget.exercice.distance = distance;
      widget.exercice.nbSeries = series;
      widget.exercice.nbRepetitions = repetitions;
      widget.exercice.valeurReference = vma;
      widget.exercice.allure = allure;
      widget.exercice.reposRepetitionsSec = reposRepSec;
      widget.exercice.reposSeriesSec = reposSerSec;

      // Recalculer les temps
      widget.exercice.calculerTemps();

      // Mettre à jour le texte de résultat
      setState(() {
        _resultText = widget.exercice.getDescriptionDetaillee();
        _showResult = true;
      });

      // Notifier le parent
      widget.onCalculer(widget.exercice);
    } catch (e) {
      // Ignorer les erreurs de parsing pendant la saisie
    }
  }
}
