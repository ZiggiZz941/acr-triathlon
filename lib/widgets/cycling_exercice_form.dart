import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_manager.dart';
import '../constants/triathlon_colors.dart';
import '../constants/triathlon_dimens.dart';
import '../models/triathlon_exercice.dart';
import '../widgets/time_input_field.dart';

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
  final TextEditingController _ftpController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();

  bool _showResult = false;
  bool _useProfileFTP = false;
  String _resultText = '';
  double? _poidsUtilisateur; // NOUVEAU: Poids de l'utilisateur

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int _reposRepetitionsSec = 0;
  int _reposSeriesSec = 0;

  // Sélection de la zone
  String? _selectedZone;

  // Définition des zones
  final List<Map<String, dynamic>> _zones = [
    {
      'id': 'zone1',
      'name': 'Zone 1',
      'desc': 'Récupération active',
      'range': '<55-75% FTP'
    },
    {
      'id': 'zone2',
      'name': 'Zone 2',
      'desc': 'Endurance',
      'range': '75-85% FTP'
    },
    {'id': 'zone3', 'name': 'Zone 3', 'desc': 'Tempo', 'range': '85-95% FTP'},
    {
      'id': 'zone4',
      'name': 'Zone 4',
      'desc': 'Seuil lactique',
      'range': '95-105% FTP'
    },
    {
      'id': 'zone5',
      'name': 'Zone 5',
      'desc': 'VO2 Max',
      'range': '105-120% FTP'
    },
    {
      'id': 'zone6',
      'name': 'Zone 6',
      'desc': 'Anaérobie',
      'range': '>120% FTP'
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
        : '5000';
    _seriesController.text = widget.exercice.nbSeries > 0
        ? widget.exercice.nbSeries.toString()
        : '3';
    _repetitionsController.text = widget.exercice.nbRepetitions > 0
        ? widget.exercice.nbRepetitions.toString()
        : '1';

    // Initialiser les temps
    _reposRepetitionsSec = widget.exercice.reposRepetitionsSec;
    _reposSeriesSec = widget.exercice.reposSeriesSec;

    // Initialiser FTP
    if (widget.exercice.valeurReference > 0) {
      _ftpController.text = widget.exercice.valeurReference.toStringAsFixed(1);
    } else {
      _ftpController.text = '250.0';
    }

    // Initialiser la zone
    if (widget.exercice.intensite != null) {
      _selectedZone = _getZoneFromIntensity(widget.exercice.intensite!);
    } else {
      _selectedZone = 'zone3'; // Zone par défaut (Tempo)
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileData();
  }

  void _loadProfileData() {
    final dataManager = Provider.of<DataManager>(context, listen: false);

    // Charger le FTP
    final ftp = dataManager.getCyclingFTP();
    if (ftp != null) {
      if (_ftpController.text.isEmpty || _useProfileFTP) {
        setState(() {
          _ftpController.text = ftp.toStringAsFixed(1);
          _useProfileFTP = true;
        });
      }
    }

    // Charger le poids
    final poids = dataManager.getPoids();
    setState(() {
      _poidsUtilisateur = poids;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomController.dispose();
    _ftpController.dispose();
    _distanceController.dispose();
    _seriesController.dispose();
    _repetitionsController.dispose();
    super.dispose();
  }

  // Méthode pour obtenir la zone à partir de l'intensité
  String _getZoneFromIntensity(int intensite) {
    if (intensite < 75) return 'zone1';
    if (intensite < 85) return 'zone2';
    if (intensite < 95) return 'zone3';
    if (intensite < 105) return 'zone4';
    if (intensite < 120) return 'zone5';
    return 'zone6';
  }

  // Méthode pour obtenir les pourcentages min/max d'une zone
  (int min, int max) _getIntensityRangeForZone(String zone) {
    switch (zone) {
      case 'zone1':
        return (55, 75);
      case 'zone2':
        return (75, 85);
      case 'zone3':
        return (85, 95);
      case 'zone4':
        return (95, 105);
      case 'zone5':
        return (105, 120);
      case 'zone6':
        return (120, 130); // >120%, on met une limite max arbitraire
      default:
        return (85, 95); // Zone 3 par défaut
    }
  }

  // NOUVEAU: Fonction pour calculer le w/kg
  String? _calculerWkg(double ftp) {
    if (_poidsUtilisateur != null && _poidsUtilisateur! > 0) {
      double wkg = ftp / _poidsUtilisateur!;
      return wkg.toStringAsFixed(1);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);

    // REMPLACER: Vérifier directement les valeurs
    final hasProfileFTP = dataManager.getCyclingFTP() != null;
    final hasProfilePoids =
        dataManager.getPoids() != 70.0; // 70.0 est la valeur par défau

    final sportColor = TriathlonColors.cycling;

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
                Expanded(
                  child: Text(
                    'Exercice Cyclisme',
                    style: TextStyle(
                      color: sportColor,
                      fontSize: TriathlonDimens.fontSizeXLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onSupprimer,
                  icon: Icon(Icons.close, color: sportColor, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
            SizedBox(
              height: 50,
              child: TextField(
                controller: _nomController,
                onChanged: (_) => _updateExercice(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Ex: Intervalles FTP',
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
                    vertical: 12,
                  ),
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
            SizedBox(
              height: 50,
              child: TextField(
                controller: _distanceController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateExercice(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Ex: 5000',
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
                    vertical: 12,
                  ),
                ),
              ),
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
                      SizedBox(
                        height: 50,
                        child: TextField(
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
                              vertical: 12,
                            ),
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
                      SizedBox(
                        height: 50,
                        child: TextField(
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
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // FTP avec switch
            if (hasProfileFTP)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'FTP (watts)',
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
                        value: _useProfileFTP,
                        onChanged: (value) {
                          setState(() {
                            _useProfileFTP = value;
                            if (value) {
                              _loadProfileData(); // MODIFIÉ: Charger toutes les données
                            }
                          });
                          _updateExercice();
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
                'FTP (watts)',
                style: TextStyle(color: sportColor, fontSize: 16),
              ),

            const SizedBox(height: 5),

            SizedBox(
              height: 50,
              child: TextField(
                controller: _ftpController,
                enabled: !_useProfileFTP || !hasProfileFTP,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _updateExercice(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _useProfileFTP && hasProfileFTP
                      ? sportColor.withOpacity(0.1)
                      : Colors.white,
                  hintText: _useProfileFTP && hasProfileFTP
                      ? 'FTP du profil utilisé'
                      : 'Ex: 250.0',
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
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Sélection de la zone
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zone d\'intensité',
                  style: TextStyle(color: sportColor, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: sportColor, width: 2),
                    borderRadius: BorderRadius.circular(
                      TriathlonDimens.borderRadiusMedium,
                    ),
                    color: Colors.white,
                  ),
                  child: DropdownButton<String>(
                    value: _selectedZone,
                    isExpanded: true,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(
                      TriathlonDimens.borderRadiusMedium,
                    ),
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      color: sportColor,
                      fontSize: 16,
                    ),
                    items: _zones.map((zone) {
                      return DropdownMenuItem<String>(
                        value: zone['id'],
                        child: Text(
                          '${zone['name']} - ${zone['desc']}',
                          style: TextStyle(
                            color: sportColor,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedZone = value;
                      });
                      _updateExercice();
                    },
                  ),
                ),
                // Affichage de la plage en dessous
                if (_selectedZone != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _zones
                          .firstWhere((z) => z['id'] == _selectedZone)['range'],
                      style: TextStyle(
                        color: sportColor.withOpacity(0.7),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Utiliser le widget TimeInputField pour repos répétitions
            TimeInputField(
              label: 'Repos répétitions',
              initialSeconds: _reposRepetitionsSec,
              onChanged: (totalSeconds) {
                setState(() {
                  _reposRepetitionsSec = totalSeconds;
                });
                _updateExercice();
              },
              color: sportColor,
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Utiliser le widget TimeInputField pour repos séries
            TimeInputField(
              label: 'Repos séries',
              initialSeconds: _reposSeriesSec,
              onChanged: (totalSeconds) {
                setState(() {
                  _reposSeriesSec = totalSeconds;
                });
                _updateExercice();
              },
              color: sportColor,
            ),

            // Information si le FTP du profil est utilisé
            if (_useProfileFTP && hasProfileFTP)
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Utilisation du FTP du profil',
                            style: TextStyle(
                              color: TriathlonColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // NOUVEAU: Afficher le w/kg si le poids est disponible
                          if (_poidsUtilisateur != null &&
                              _poidsUtilisateur! > 0)
                            FutureBuilder<double>(
                              future: Future.value(double.tryParse(
                                      _ftpController.text
                                          .replaceAll(',', '.')) ??
                                  0),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data! > 0) {
                                  final ftp = snapshot.data!;
                                  final wkg = _calculerWkg(ftp);
                                  if (wkg != null) {
                                    return Text(
                                      'Poids profil: ${_poidsUtilisateur!.toStringAsFixed(1)} kg • w/kg: $wkg',
                                      style: TextStyle(
                                        color: TriathlonColors.textPrimary,
                                        fontSize: 11,
                                      ),
                                    );
                                  }
                                }
                                return const SizedBox();
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // NOUVEAU: Information si le poids n'est pas disponible
            if (_useProfileFTP && hasProfileFTP && !hasProfilePoids)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Poids non disponible dans le profil. Le calcul w/kg ne sera pas effectué.',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 11,
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
                constraints: BoxConstraints(
                  minHeight: _showResult ? 0 : 0,
                  maxHeight: _showResult ? double.infinity : 0,
                ),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                      TriathlonDimens.paddingMedium,
                    ),
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
      double distance = double.parse(
        _distanceController.text.replaceAll(',', '.'),
      );
      int series = int.parse(_seriesController.text);
      int repetitions = int.parse(_repetitionsController.text);
      double ftp = double.parse(_ftpController.text.replaceAll(',', '.'));

      // Validations
      if (distance <= 0 || series <= 0 || ftp <= 0) {
        return;
      }

      if (repetitions <= 0) repetitions = 1;
      if (_reposRepetitionsSec < 0) _reposRepetitionsSec = 0;
      if (_reposSeriesSec < 0) _reposSeriesSec = 0;

      // Si une seule série, ignorer le repos entre séries
      if (series == 1) {
        _reposSeriesSec = 0;
      }

      // Créer le nom si vide
      if (nom.isEmpty) {
        final zoneInfo = _zones.firstWhere((z) => z['id'] == _selectedZone);
        nom = '${distance.toInt()}m en ${zoneInfo['name']}';
      }

      // Obtenir la plage d'intensité pour la zone sélectionnée
      final (intensiteMin, intensiteMax) =
          _getIntensityRangeForZone(_selectedZone!);

      // Mettre à jour l'exercice avec la plage d'intensité
      widget.exercice.nom = nom;
      widget.exercice.distance = distance;
      widget.exercice.nbSeries = series;
      widget.exercice.nbRepetitions = repetitions;
      widget.exercice.valeurReference = ftp;
      widget.exercice.intensiteMin = intensiteMin;
      widget.exercice.intensite = intensiteMax;
      widget.exercice.reposRepetitionsSec = _reposRepetitionsSec;
      widget.exercice.reposSeriesSec = _reposSeriesSec;

      // NOUVEAU: Sauvegarder le poids utilisé dans l'exercice
      if (_poidsUtilisateur != null) {
        widget.exercice.poids = _poidsUtilisateur;
      }

      // Recalculer les temps
      widget.exercice.calculerTemps();

      // Formater le résultat
      final zoneInfo = _zones.firstWhere((z) => z['id'] == _selectedZone);
      String tempsMinFormate =
          widget.exercice.formatTemps(widget.exercice.tempsMin);
      String tempsMaxFormate =
          widget.exercice.formatTemps(widget.exercice.tempsMax);
      String reposRepFormate =
          TriathlonExercice.formatTempsEnMinutes(_reposRepetitionsSec);
      String reposSerFormate =
          TriathlonExercice.formatTempsEnMinutes(_reposSeriesSec);

      // NOUVEAU: Ajouter le calcul w/kg au résultat
      String resultatBase = '${zoneInfo['name']} - ${zoneInfo['desc']}\n'
          'Intensité: ${zoneInfo['range']}\n'
          '$series séries de $repetitions x ${distance.toInt()}m\n'
          'Temps: $tempsMinFormate à $tempsMaxFormate\n'
          'Repos entre répétitions: $reposRepFormate\n'
          'Repos entre séries: $reposSerFormate';

      // Ajouter le calcul w/kg si disponible
      String? wkg = _calculerWkg(ftp);
      String infoWkg = '';
      if (wkg != null && _poidsUtilisateur != null) {
        // Calculer aussi les valeurs de puissance pour les zones min et max
        double puissanceMin = ftp * (intensiteMin / 100);
        double puissanceMax = ftp * (intensiteMax / 100);
        String wkgMin = (puissanceMin / _poidsUtilisateur!).toStringAsFixed(1);
        String wkgMax = (puissanceMax / _poidsUtilisateur!).toStringAsFixed(1);

        infoWkg = '\n\nCalculs w/kg:\n'
            'FTP: ${ftp.toStringAsFixed(1)}w • Poids: ${_poidsUtilisateur!.toStringAsFixed(1)}kg\n'
            'FTP: $wkg w/kg\n'
            'Puissance zone: ${puissanceMin.toStringAsFixed(0)}-${puissanceMax.toStringAsFixed(0)}w\n'
            'w/kg zone: $wkgMin-$wkgMax w/kg';
      }

      setState(() {
        _resultText = resultatBase + infoWkg;
        _showResult = true;
      });

      // Notifier le parent
      widget.onCalculer(widget.exercice);
    } catch (e) {
      // Ignorer les erreurs de parsing pendant la saisie
      print('Erreur dans _updateExercice: $e');
    }
  }
}
