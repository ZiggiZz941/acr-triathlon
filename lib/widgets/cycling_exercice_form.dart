import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/triathlon_colors.dart';
import '../models/triathlon_exercice.dart';
import '../models/sport_type.dart';
import '../services/data_manager.dart';

class CyclingExerciceForm extends StatefulWidget {
  final TriathlonExercice exercice;
  final Function(TriathlonExercice) onCalculer;
  final VoidCallback onSupprimer;

  const CyclingExerciceForm({
    super.key,
    required this.exercice,
    required this.onCalculer,
    required this.onSupprimer,
  });

  @override
  _CyclingExerciceFormState createState() => _CyclingExerciceFormState();
}

class _CyclingExerciceFormState extends State<CyclingExerciceForm>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _intensiteController = TextEditingController();
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();
  final TextEditingController _reposRepetitionsController =
      TextEditingController();
  final TextEditingController _reposSeriesController = TextEditingController();
  final TextEditingController _puissanceController = TextEditingController();
  final TextEditingController _poidsController =
      TextEditingController(); // Nouveau

  bool _showResult = false;
  bool _useProfileFTP = false;
  bool _useProfileWeight = false; // Maintenant utilisé
  bool _showWeightField = false; // Nouveau: contrôler l'affichage du poids
  String _selectedZone = 'Zone 4';
  String _resultText = '';

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Zones d'entraînement
  final List<Map<String, dynamic>> _zones = [
    {
      'id': 'Zone 1',
      'name': 'Récupération active',
      'min': 0.55,
      'max': 0.75,
      'description': '55-75% FTP',
      'color': Colors.green,
    },
    {
      'id': 'Zone 2',
      'name': 'Endurance',
      'min': 0.75,
      'max': 0.85,
      'description': '75-85% FTP',
      'color': Colors.lightGreen,
    },
    {
      'id': 'Zone 3',
      'name': 'Tempo',
      'min': 0.85,
      'max': 0.95,
      'description': '85-95% FTP',
      'color': Colors.blue,
    },
    {
      'id': 'Zone 4',
      'name': 'Seuil lactique',
      'min': 0.95,
      'max': 1.05,
      'description': '95-105% FTP',
      'color': Colors.orange,
    },
    {
      'id': 'Zone 5',
      'name': 'VO2 Max',
      'min': 1.05,
      'max': 1.20,
      'description': '105-120% FTP',
      'color': Colors.red,
    },
    {
      'id': 'Zone 6',
      'name': 'Anaérobie',
      'min': 1.20,
      'max': 1.50,
      'description': '120-150% FTP',
      'color': Colors.purple,
    },
  ];

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
        : '1000';
    _seriesController.text = widget.exercice.nbSeries > 0
        ? widget.exercice.nbSeries.toString()
        : '3';
    _repetitionsController.text = widget.exercice.nbRepetitions > 0
        ? widget.exercice.nbRepetitions.toString()
        : '1';
    _reposRepetitionsController.text = widget.exercice.reposRepetitionsFormate;
    _reposSeriesController.text = widget.exercice.reposSeriesFormate;
    _intensiteController.text = '80.0';

    // Initialiser la puissance
    if (widget.exercice.valeurReference > 0) {
      _puissanceController.text =
          widget.exercice.valeurReference.toStringAsFixed(0);
    } else {
      _puissanceController.text = '250';
    }

    // Poids par défaut
    _poidsController.text = '70.0';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkProfileData();
  }

  void _checkProfileData() {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final profile = dataManager.getTriathlonProfile();

    // Vérifier si FTP disponible
    if (profile['cycling_ftp'] != null) {
      setState(() {
        _useProfileFTP = true;
      });
      _calculatePowerFromFTP();
    }

    // Vérifier si poids disponible et l'utiliser
    if (profile['poids'] != null) {
      final poids = profile['poids'] as double;
      setState(() {
        _useProfileWeight = true;
        _poidsController.text = poids.toStringAsFixed(1);
      });
    }
  }

  void _calculatePowerFromFTP() {
    if (!_useProfileFTP) return;

    final dataManager = Provider.of<DataManager>(context, listen: false);
    final profile = dataManager.getTriathlonProfile();
    final ftp = profile['cycling_ftp'] as double?;

    if (ftp != null) {
      // Trouver l'intensité de la zone sélectionnée
      final zone = _zones.firstWhere((z) => z['id'] == _selectedZone);
      double min = zone['min'] as double;
      double max = zone['max'] as double;
      double zoneIntensity = (min + max) / 2.0;

      double power = ftp * zoneIntensity;
      setState(() {
        _puissanceController.text = power.toStringAsFixed(0);
      });

      // Mettre à jour l'intensité dans le contrôleur
      _intensiteController.text = (zoneIntensity * 100).toStringAsFixed(1);

      _updateExercice();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomController.dispose();
    _distanceController.dispose();
    _intensiteController.dispose();
    _seriesController.dispose();
    _repetitionsController.dispose();
    _reposRepetitionsController.dispose();
    _reposSeriesController.dispose();
    _puissanceController.dispose();
    _poidsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final profile = dataManager.getTriathlonProfile();
    final hasProfileFTP = profile['cycling_ftp'] != null;
    final hasProfileWeight = profile['poids'] != null;

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
                  'Exercice Cyclisme',
                  style: TextStyle(
                    color: TriathlonColors.cycling,
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
                color: TriathlonColors.cycling,
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
                hintText: 'Ex: 5km à 80% FTP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: TriathlonColors.cycling,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Mode FTP/Manuel
            if (hasProfileFTP)
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Utiliser FTP du profil',
                        style: TextStyle(
                          color: TriathlonColors.cycling,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _useProfileFTP,
                        onChanged: (value) {
                          setState(() {
                            _useProfileFTP = value;
                            if (value) {
                              _calculatePowerFromFTP();
                            }
                          });
                        },
                        activeColor: TriathlonColors.cycling,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),

            // Sélection de zone (seulement en mode FTP)
            if (_useProfileFTP && hasProfileFTP)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zone d\'entraînement',
                    style: TextStyle(
                      color: TriathlonColors.cycling,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Grille de zones
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: _zones.length,
                    itemBuilder: (context, index) {
                      final zone = _zones[index];
                      bool isSelected = _selectedZone == zone['id'];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedZone = zone['id'] as String;
                            _calculatePowerFromFTP();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (zone['color'] as Color).withOpacity(0.2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? zone['color'] as Color
                                  : Colors.grey.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                zone['id'] as String,
                                style: TextStyle(
                                  color: isSelected
                                      ? zone['color'] as Color
                                      : TriathlonColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${((zone['min'] as double) * 100).toStringAsFixed(0)}-'
                                '${((zone['max'] as double) * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: TriathlonColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),

            // Puissance
            Text(
              'Puissance (watts)',
              style: TextStyle(
                color: TriathlonColors.cycling,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _puissanceController,
              enabled: !_useProfileFTP || !hasProfileFTP,
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateExercice(),
              decoration: InputDecoration(
                filled: true,
                fillColor: _useProfileFTP && hasProfileFTP
                    ? TriathlonColors.cycling.withOpacity(0.1)
                    : Colors.white,
                hintText: _useProfileFTP && hasProfileFTP
                    ? 'Calculée automatiquement'
                    : 'Ex: 200 (watts)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: TriathlonColors.cycling,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Toggle pour afficher le poids
            Row(
              children: [
                Text(
                  'Inclure le poids pour calcul W/kg',
                  style: TextStyle(
                    color: TriathlonColors.cycling,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _showWeightField,
                  onChanged: (value) {
                    setState(() {
                      _showWeightField = value;
                    });
                  },
                  activeColor: TriathlonColors.cycling,
                ),
              ],
            ),

            // Champ poids (conditionnel)
            if (_showWeightField)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  if (hasProfileWeight)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Poids du cycliste (kg)',
                            style: TextStyle(
                              color: TriathlonColors.cycling,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Profil',
                              style: TextStyle(
                                color: TriathlonColors.cycling,
                                fontSize: 12,
                              ),
                            ),
                            Switch(
                              value: _useProfileWeight,
                              onChanged: (value) {
                                setState(() {
                                  _useProfileWeight = value;
                                  if (value) {
                                    final profile = Provider.of<DataManager>(
                                            context,
                                            listen: false)
                                        .getTriathlonProfile();
                                    if (profile['poids'] != null) {
                                      _poidsController.text =
                                          (profile['poids'] as double)
                                              .toStringAsFixed(1);
                                    }
                                  }
                                });
                              },
                              activeColor: TriathlonColors.cycling,
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Text(
                      'Poids du cycliste (kg)',
                      style: TextStyle(
                        color: TriathlonColors.cycling,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _poidsController,
                    enabled: !_useProfileWeight || !hasProfileWeight,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _updateExercice(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _useProfileWeight && hasProfileWeight
                          ? TriathlonColors.cycling.withOpacity(0.1)
                          : Colors.white,
                      hintText: _useProfileWeight && hasProfileWeight
                          ? 'Poids du profil utilisé'
                          : 'Ex: 70.0 (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: TriathlonColors.cycling,
                          width: 2,
                        ),
                      ),
                      suffixIcon: hasProfileWeight && !_useProfileWeight
                          ? IconButton(
                              icon: const Icon(Icons.refresh, size: 16),
                              onPressed: () {
                                setState(() {
                                  _useProfileWeight = true;
                                  final profile = Provider.of<DataManager>(
                                          context,
                                          listen: false)
                                      .getTriathlonProfile();
                                  if (profile['poids'] != null) {
                                    _poidsController.text =
                                        (profile['poids'] as double)
                                            .toStringAsFixed(1);
                                  }
                                });
                              },
                              tooltip: 'Utiliser le poids du profil',
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),

            const SizedBox(height: 15),

            // Distance et Intensité
            Row(
              children: [
                // Distance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distance (m)',
                        style: TextStyle(
                          color: TriathlonColors.cycling,
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
                          hintText: 'Ex: 1000',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: TriathlonColors.cycling,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Intensité
              ],
            ),

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
                          color: TriathlonColors.cycling,
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
                              color: TriathlonColors.cycling,
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
                          color: TriathlonColors.cycling,
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
                              color: TriathlonColors.cycling,
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
                          color: TriathlonColors.cycling,
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
                              color: TriathlonColors.cycling,
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
                          color: TriathlonColors.cycling,
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
                              color: TriathlonColors.cycling,
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
                  foregroundColor: TriathlonColors.cycling,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                      color: TriathlonColors.cycling,
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
                        color: TriathlonColors.cycling,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _resultText,
                      style: TextStyle(
                        color: TriathlonColors.cycling,
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
      String distanceStr = _distanceController.text.trim();
      String intensiteStr = _intensiteController.text.trim();
      String seriesStr = _seriesController.text.trim();
      String repetitionsStr = _repetitionsController.text.trim();
      String reposRepStr = _reposRepetitionsController.text.trim();
      String reposSerStr = _reposSeriesController.text.trim();
      String puissanceStr = _puissanceController.text.trim();
      String poidsStr = _poidsController.text.trim();

      // Validation
      if (distanceStr.isEmpty ||
          intensiteStr.isEmpty ||
          seriesStr.isEmpty ||
          repetitionsStr.isEmpty ||
          puissanceStr.isEmpty) {
        return;
      }

      // Convertir les valeurs
      double distance = double.parse(distanceStr.replaceAll(',', '.'));
      double intensite = double.parse(intensiteStr.replaceAll(',', '.'));
      int series = int.parse(seriesStr);
      int repetitions = int.parse(repetitionsStr);
      int reposRepSec = TriathlonExercice.parseTempsEnSecondes(reposRepStr);
      int reposSerSec = TriathlonExercice.parseTempsEnSecondes(reposSerStr);
      double puissance = double.parse(puissanceStr.replaceAll(',', '.'));
      double poids = _showWeightField && poidsStr.isNotEmpty
          ? double.parse(poidsStr.replaceAll(',', '.'))
          : 0.0;

      // Validation des valeurs
      if (distance <= 0 ||
          intensite <= 0 ||
          intensite > 100 ||
          puissance <= 0 ||
          (_showWeightField && poids <= 0)) {
        return;
      }

      if (repetitions <= 0) repetitions = 1;
      if (reposRepSec < 0) reposRepSec = 0;
      if (reposSerSec < 0) reposSerSec = 0;

      // Si une seule série, ignorer le repos entre séries
      if (series == 1) {
        reposSerSec = 0;
      }

      // Créer le nom si vide
      if (nom.isEmpty) {
        nom = '${distance.toInt()}m à ${puissance.toInt()}W';
      }

      // Mettre à jour l'exercice
      widget.exercice.nom = nom;
      widget.exercice.sportType = SportType.cycling;
      widget.exercice.distance = distance;
      widget.exercice.nbSeries = series;
      widget.exercice.nbRepetitions = repetitions;
      widget.exercice.valeurReference = puissance;
      widget.exercice.intensite = intensite.round();
      widget.exercice.reposRepetitionsSec = reposRepSec;
      widget.exercice.reposSeriesSec = reposSerSec;

      // Calculer les temps estimés (amélioré avec poids si disponible)
      double vitesseKmh = _estimateSpeedFromPower(puissance, poids);
      double tempsSeconds = (distance / 1000) / (vitesseKmh / 3600);

      widget.exercice.tempsMin = tempsSeconds;
      widget.exercice.tempsMax = tempsSeconds;

      // Formater le résultat
      String tempsFormate = _formatCyclingTime(tempsSeconds);
      String reposRepFormate =
          TriathlonExercice.formatTempsEnMinutes(reposRepSec);
      String reposSerFormate =
          TriathlonExercice.formatTempsEnMinutes(reposSerSec);

      String zoneInfo = '';
      if (_useProfileFTP) {
        final zone = _zones.firstWhere((z) => z['id'] == _selectedZone);
        zoneInfo = ' (${zone['name']})';
      }

      // Calculer W/kg si poids disponible
      String wkgInfo = '';
      if (_showWeightField && poids > 0) {
        double wattsPerKg = puissance / poids;
        wkgInfo =
            '\nPuissance spécifique: ${wattsPerKg.toStringAsFixed(1)} W/kg';
      }

      setState(() {
        _resultText =
            '$series séries de $repetitions x ${distance.toInt()}m à $tempsFormate\n'
            'Puissance: ${puissance.toInt()}W$zoneInfo'
            '$wkgInfo\n'
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

  double _estimateSpeedFromPower(double power, double weight) {
    // Estimation améliorée de la vitesse basée sur la puissance et le poids
    if (weight > 0) {
      // Prendre en compte le rapport puissance/poids (W/kg)
      double wattsPerKg = power / weight;

      if (wattsPerKg < 1.5) return 20.0; // ~20 km/h
      if (wattsPerKg < 2.0) return 25.0; // ~25 km/h
      if (wattsPerKg < 2.5) return 28.0; // ~28 km/h
      if (wattsPerKg < 3.0) return 32.0; // ~32 km/h
      if (wattsPerKg < 3.5) return 36.0; // ~36 km/h
      if (wattsPerKg < 4.0) return 40.0; // ~40 km/h
      return 45.0; // ~45 km/h pour plus de 4 W/kg
    } else {
      // Fallback sans poids
      if (power < 150) return 20.0;
      if (power < 200) return 25.0;
      if (power < 250) return 28.0;
      if (power < 300) return 32.0;
      if (power < 350) return 36.0;
      return 40.0;
    }
  }

  String _formatCyclingTime(double seconds) {
    int hours = (seconds ~/ 3600).toInt();
    int minutes = ((seconds % 3600) ~/ 60).toInt();
    int secs = (seconds % 60).toInt();

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
    } else if (minutes > 0) {
      return '${minutes}min ${secs.toString().padLeft(2, '0')}s';
    } else {
      return '${secs}s';
    }
  }
}
