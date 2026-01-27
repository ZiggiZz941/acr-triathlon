// lib/screens/creation_seance_intensite_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/triathlon_colors.dart';
import '../../../constants/triathlon_dimens.dart';
import '../../../models/sport_type.dart';
import '../../../models/triathlon_exercice.dart';
import '../../../models/triathlon_seance.dart';
import '../../../services/data_manager.dart';
import '../../../screens/seance/triathlon_visualisation_seance_screen.dart';

class CreationSeanceIntensiteScreen extends StatefulWidget {
  final SportType sportType;
  final bool isSwimming;

  const CreationSeanceIntensiteScreen({
    super.key,
    required this.sportType,
    this.isSwimming = false,
  });

  @override
  _CreationSeanceIntensiteScreenState createState() =>
      _CreationSeanceIntensiteScreenState();
}

class _CreationSeanceIntensiteScreenState
    extends State<CreationSeanceIntensiteScreen> {
  final TextEditingController _nomSeanceController = TextEditingController();
  final TextEditingController _tempsController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _intensiteController = TextEditingController();
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();
  final TextEditingController _reposRepetitionsController =
      TextEditingController();
  final TextEditingController _reposSeriesController = TextEditingController();

  double _tempsCalcule = 0;
  bool _showResult = false;
  late DataManager _dataManager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataManager = Provider.of<DataManager>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();

    // Valeurs par défaut selon le sport
    if (widget.isSwimming) {
      _seriesController.text = '4';
      _repetitionsController.text = '4';
      _reposRepetitionsController.text = '0:30';
      _reposSeriesController.text = '1:30';
      _intensiteController.text = '85.0';
      _distanceController.text = '100';
    } else {
      _seriesController.text = '3';
      _repetitionsController.text = '1';
      _reposRepetitionsController.text = '0:45';
      _reposSeriesController.text = '2:00';
      _intensiteController.text = '80.0';
      _distanceController.text = '400';
    }
  }

  @override
  void dispose() {
    _nomSeanceController.dispose();
    _tempsController.dispose();
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
    final sportColor = widget.sportType.color;
    final bool isSwimming = widget.isSwimming;

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
                  isSwimming
                      ? 'Création natation par intensité'
                      : 'Création course par intensité',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version simplifiée',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
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
                      padding:
                          const EdgeInsets.all(TriathlonDimens.paddingLarge),
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
                              hintText: isSwimming
                                  ? 'Ex: Séance crawl intensité'
                                  : 'Ex: Séance VMA intensité',
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
                  ),

                  const SizedBox(height: 20),

                  // Carte formulaire
                  Card(
                    elevation: TriathlonDimens.elevationMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        TriathlonDimens.borderRadiusLarge,
                      ),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(TriathlonDimens.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DONNÉES DE BASE',
                            style: TextStyle(
                              color: sportColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Temps
                          Text(
                            isSwimming
                                ? 'Temps pour 100m'
                                : 'Temps de référence',
                            style: TextStyle(
                              color: sportColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _tempsController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: isSwimming
                                  ? 'Ex: 1:30.50'
                                  : 'Ex: 12.50 ou 1:12.50',
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
                                        color: sportColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    TextField(
                                      controller: _distanceController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText:
                                            isSwimming ? 'Ex: 100' : 'Ex: 400',
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
                                          vertical:
                                              TriathlonDimens.paddingMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Intensité
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Intensité (%)',
                                      style: TextStyle(
                                        color: sportColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    TextField(
                                      controller: _intensiteController,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
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
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal:
                                              TriathlonDimens.paddingMedium,
                                          vertical:
                                              TriathlonDimens.paddingMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Text(
                            'STRUCTURE DE LA SÉANCE',
                            style: TextStyle(
                              color: sportColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

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
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText:
                                            'Ex: ${isSwimming ? '4' : '3'}',
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
                                          vertical:
                                              TriathlonDimens.paddingMedium,
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
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText:
                                            'Ex: ${isSwimming ? '4' : '1'}',
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
                                          vertical:
                                              TriathlonDimens.paddingMedium,
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
                                        color: sportColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    TextField(
                                      controller: _reposRepetitionsController,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText:
                                            'Ex: ${isSwimming ? '0:30' : '0:45'}',
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
                                          vertical:
                                              TriathlonDimens.paddingMedium,
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
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText:
                                            'Ex: ${isSwimming ? '1:30' : '2:00'}',
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
                                          vertical:
                                              TriathlonDimens.paddingMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // Bouton Calculer
                          SizedBox(
                            width: double.infinity,
                            height: TriathlonDimens.buttonHeight,
                            child: ElevatedButton(
                              onPressed: _calculerEtAfficher,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sportColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    TriathlonDimens.borderRadiusXLarge,
                                  ),
                                ),
                                elevation: 8,
                              ),
                              child: const Text(
                                'CALCULER LA SÉANCE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section résultats
                  if (_showResult) ...[
                    Text(
                      'RÉSULTATS',
                      style: TextStyle(
                        color: sportColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Carte résultat
                    Card(
                      elevation: TriathlonDimens.elevationMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusLarge,
                        ),
                      ),
                      color: sportColor,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(TriathlonDimens.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Résumé de la séance',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getResultText(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Détail série par série
                    Card(
                      elevation: TriathlonDimens.elevationMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusLarge,
                        ),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(TriathlonDimens.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Détail série par série',
                              style: TextStyle(
                                color: sportColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getDetailText(),
                              style: TextStyle(
                                color: TriathlonColors.textPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  // Bouton Sauvegarder
                  SizedBox(
                    width: double.infinity,
                    height: TriathlonDimens.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _showResult ? _sauvegarderSeance : null,
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
                        'SAUVEGARDER CETTE SÉANCE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _calculerEtAfficher() {
    String tempsStr = _tempsController.text.trim();
    String distanceStr = _distanceController.text.trim();
    String intensiteStr = _intensiteController.text.trim();
    String seriesStr = _seriesController.text.trim();
    String repetitionsStr = _repetitionsController.text.trim();

    // Validation
    if (tempsStr.isEmpty ||
        distanceStr.isEmpty ||
        intensiteStr.isEmpty ||
        seriesStr.isEmpty ||
        repetitionsStr.isEmpty) {
      _showError('Veuillez remplir tous les champs obligatoires');
      return;
    }

    double? distance = _parseDouble(distanceStr);
    double? intensite = _parseDouble(intensiteStr);
    int? series = int.tryParse(seriesStr);
    int? repetitions = int.tryParse(repetitionsStr);

    if (distance == null ||
        intensite == null ||
        series == null ||
        repetitions == null) {
      _showError('Valeurs numériques invalides');
      return;
    }

    if (intensite <= 0 || intensite > 100) {
      _showError('L\'intensité doit être entre 1 et 100%');
      return;
    }

    // Convertir le temps
    double tempsSecondes = _convertirTempsEnSecondes(tempsStr);
    if (tempsSecondes < 0) {
      _showError('Format de temps invalide');
      return;
    }

    // Calcul du temps à l'intensité
    _tempsCalcule = (tempsSecondes * 100.0) / intensite;

    setState(() {
      _showResult = true;
    });
  }

  String _getResultText() {
    double distance = _parseDouble(_distanceController.text) ?? 0;
    int series = int.tryParse(_seriesController.text) ?? 0;
    int repetitions = int.tryParse(_repetitionsController.text) ?? 0;
    String reposRepFormate = _reposRepetitionsController.text;
    String reposSerFormate = _reposSeriesController.text;
    String tempsFormate = _formatTempsAvecCentiemes(_tempsCalcule);

    return '$series séries de $repetitions x ${distance.toInt()}m à $tempsFormate\n'
        'Repos entre répétitions: $reposRepFormate\n'
        'Repos entre séries: $reposSerFormate';
  }

  String _getDetailText() {
    double distance = _parseDouble(_distanceController.text) ?? 0;
    int series = int.tryParse(_seriesController.text) ?? 0;
    int repetitions = int.tryParse(_repetitionsController.text) ?? 0;
    String reposRepFormate = _reposRepetitionsController.text;
    String reposSerFormate = _reposSeriesController.text;
    String tempsFormate = _formatTempsAvecCentiemes(_tempsCalcule);

    StringBuffer detail = StringBuffer();
    double tempsTotalSerie = (_tempsCalcule * repetitions) +
        (TriathlonExercice.parseTempsEnSecondes(reposRepFormate) *
            (repetitions - 1));

    for (int s = 1; s <= series; s++) {
      detail.write('Série $s:\n');

      for (int r = 1; r <= repetitions; r++) {
        detail.write(
          '  Répétition $r: ${distance.toInt()}m en $tempsFormate\n',
        );

        if (r < repetitions) {
          detail.write('  Repos: $reposRepFormate\n');
        }
      }

      if (s < series) {
        detail.write('Repos entre séries: $reposSerFormate\n\n');
      }
    }

    // Temps total estimé
    double tempsTotal = (tempsTotalSerie * series) +
        (TriathlonExercice.parseTempsEnSecondes(reposSerFormate) *
            (series - 1));
    detail.write(
      '\nTemps total estimé: ${_formatTempsAvecCentiemes(tempsTotal)}',
    );

    return detail.toString();
  }

  Future<void> _sauvegarderSeance() async {
    if (_tempsCalcule == 0) {
      _showError('Calculez d\'abord la séance');
      return;
    }

    // Récupérer toutes les valeurs
    double? distance = _parseDouble(_distanceController.text);
    int? series = int.tryParse(_seriesController.text);
    int? repetitions = int.tryParse(_repetitionsController.text);
    String intensiteStr = _intensiteController.text;
    String reposRepStr = _reposRepetitionsController.text;
    String reposSerStr = _reposSeriesController.text;

    if (distance == null || series == null || repetitions == null) {
      _showError('Valeurs invalides');
      return;
    }

    int reposRepSec = TriathlonExercice.parseTempsEnSecondes(reposRepStr);
    int reposSerSec = TriathlonExercice.parseTempsEnSecondes(reposSerStr);

    if (series == 1) {
      reposSerSec = 0;
    }

    // Créer un nom pour la séance
    String nomSeance = _nomSeanceController.text.trim();
    if (nomSeance.isEmpty) {
      nomSeance =
          '${widget.sportType.displayName} ${intensiteStr}% - ${series}x${repetitions}x${distance.toInt()}m';
    }

    // Calculer la valeur de référence
    double valeurReference;
    if (widget.isSwimming) {
      // Pour natation: temps pour 100m
      valeurReference = _tempsCalcule;
    } else {
      // Pour course: VMA
      valeurReference = _calculerVmaPourTemps(distance, _tempsCalcule);
    }

    TriathlonExercice exercice = TriathlonExercice(
      id: DateTime.now().millisecondsSinceEpoch,
      nom: 'Exercice intensité ${intensiteStr}%',
      sportType: widget.sportType,
      distance: distance,
      nbSeries: series,
      nbRepetitions: repetitions,
      valeurReference: valeurReference,
      intensite: double.parse(intensiteStr).round(),
      reposRepetitionsSec: reposRepSec,
      reposSeriesSec: reposSerSec,
    );

    // Créer la séance
    TriathlonSeance seance = TriathlonSeance(
      id: DateTime.now().millisecondsSinceEpoch,
      nom: nomSeance,
      sportType: widget.sportType,
    );
    seance.exercices.add(exercice);

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

    // Sauvegarder
    bool saved = await _dataManager.saveSeance(seance);

    if (saved && mounted) {
      _showSuccess('Séance sauvegardée !');

      // Naviguer vers la visualisation
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

  double _calculerVmaPourTemps(double distance, double tempsSecondes) {
    if (tempsSecondes <= 0) return 18.0;
    double vitesseMs = distance / tempsSecondes;
    return vitesseMs * 3.6;
  }

  double _convertirTempsEnSecondes(String tempsStr) {
    try {
      if (tempsStr.contains(":")) {
        List<String> parties = tempsStr.split(":");
        if (parties.length == 2) {
          double minutes = _parseDouble(parties[0]) ?? 0;
          double secondes = _parseDouble(parties[1]) ?? 0;
          if (minutes < 0 || secondes < 0 || secondes >= 60) {
            return -1;
          }
          return (minutes * 60) + secondes;
        }
      }
      double secondes = _parseDouble(tempsStr) ?? 0;
      if (secondes < 0) {
        return -1;
      }
      return secondes;
    } catch (e) {
      return -1;
    }
  }

  String _formatTempsAvecCentiemes(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    double secondesDecimal = seconds % 60;

    if (secondesDecimal >= 60) {
      minutes += (secondesDecimal ~/ 60).toInt();
      secondesDecimal = secondesDecimal % 60;
    }

    if (minutes > 0) {
      return '${minutes}:${secondesDecimal.toStringAsFixed(2).padLeft(5, '0')}';
    } else {
      return '${secondesDecimal.toStringAsFixed(2)} sec';
    }
  }

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) return null;
    try {
      value = value.replaceAll(',', '.');
      return double.parse(value);
    } catch (e) {
      return null;
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }
}
