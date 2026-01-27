import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_manager.dart';
import '../constants/triathlon_colors.dart';
import '../constants/triathlon_dimens.dart';
import '../models/triathlon_exercice.dart';
import '../widgets/time_input_field.dart';
import '../utils/cycling_zones.dart';

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
  double? _poidsUtilisateur;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int _reposRepetitionsSec = 0;
  int _reposSeriesSec = 0;
  String? _selectedZone;

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

    // Initialisation
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

    _reposRepetitionsSec = widget.exercice.reposRepetitionsSec;
    _reposSeriesSec = widget.exercice.reposSeriesSec;

    if (widget.exercice.valeurReference > 0) {
      _ftpController.text = widget.exercice.valeurReference.toStringAsFixed(1);
    } else {
      _ftpController.text = '250.0';
    }

    if (widget.exercice.intensite != null) {
      _selectedZone = _getZoneFromIntensity(widget.exercice.intensite!);
    } else {
      _selectedZone = 'zone3';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileData();
  }

  void _loadProfileData() {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final profile = dataManager.getTriathlonProfile();

    if (profile.containsKey('cycling_ftp')) {
      final ftp = profile['cycling_ftp'] as double?;
      if (ftp != null) {
        if (_ftpController.text.isEmpty || _useProfileFTP) {
          setState(() {
            _ftpController.text = ftp.toStringAsFixed(1);
            _useProfileFTP = true;
          });
        }
      }
    }

    if (profile.containsKey('poids')) {
      final poids = profile['poids'] as double?;
      if (poids != null) {
        setState(() {
          _poidsUtilisateur = poids;
        });
      }
    }
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

  String _getZoneFromIntensity(int intensite) {
    if (intensite < 75) return 'zone1';
    if (intensite < 85) return 'zone2';
    if (intensite < 95) return 'zone3';
    if (intensite < 105) return 'zone4';
    if (intensite < 120) return 'zone5';
    return 'zone6';
  }

  List<int> _getIntensityRangeForZone(String zone) {
    return CyclingZones.getIntensityRangeForZone(zone);
  }

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
    final profile = dataManager.getTriathlonProfile();
    final hasProfileFTP =
        profile.containsKey('cycling_ftp') && profile['cycling_ftp'] != null;
    final hasProfilePoids =
        profile.containsKey('poids') && profile['poids'] != null;

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

            // Nom
            Text('Nom (optionnel)',
                style: TextStyle(color: sportColor, fontSize: 16)),
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
                        TriathlonDimens.borderRadiusMedium),
                    borderSide: BorderSide(color: sportColor, width: 2),
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
            Text('Distance (m)',
                style: TextStyle(color: sportColor, fontSize: 16)),
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
                        TriathlonDimens.borderRadiusMedium),
                    borderSide: BorderSide(color: sportColor, width: 2),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Séries',
                          style: TextStyle(color: sportColor, fontSize: 16)),
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
                                  TriathlonDimens.borderRadiusMedium),
                              borderSide:
                                  BorderSide(color: sportColor, width: 2),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Répétitions',
                          style: TextStyle(color: sportColor, fontSize: 16)),
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
                                  TriathlonDimens.borderRadiusMedium),
                              borderSide:
                                  BorderSide(color: sportColor, width: 2),
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

            // FTP
            if (hasProfileFTP)
              Row(
                children: [
                  Expanded(
                      child: Text('FTP (watts)',
                          style: TextStyle(color: sportColor, fontSize: 16))),
                  Row(
                    children: [
                      Text('Profil',
                          style: TextStyle(color: sportColor, fontSize: 12)),
                      Switch(
                        value: _useProfileFTP,
                        onChanged: (value) {
                          setState(() => _useProfileFTP = value);
                          if (value) _loadProfileData();
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
              Text('FTP (watts)',
                  style: TextStyle(color: sportColor, fontSize: 16)),

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
                        TriathlonDimens.borderRadiusMedium),
                    borderSide: BorderSide(color: sportColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: TriathlonDimens.paddingMedium,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Zone d'intensité
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Zone d\'intensité',
                    style: TextStyle(color: sportColor, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: sportColor, width: 2),
                    borderRadius: BorderRadius.circular(
                        TriathlonDimens.borderRadiusMedium),
                    color: Colors.white,
                  ),
                  child: DropdownButton<String>(
                    value: _selectedZone,
                    isExpanded: true,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(
                        TriathlonDimens.borderRadiusMedium),
                    dropdownColor: Colors.white,
                    style: TextStyle(color: sportColor, fontSize: 16),
                    items: CyclingZones.zones.map((zone) {
                      return DropdownMenuItem<String>(
                        value: zone['id'],
                        child: Text(
                          '${zone['name']} - ${zone['description']}',
                          style: TextStyle(color: sportColor, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedZone = value);
                      _updateExercice();
                    },
                  ),
                ),
                if (_selectedZone != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      CyclingZones.getZoneById(_selectedZone!)?['range'] ?? '',
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

            // Repos répétitions
            TimeInputField(
              label: 'Repos répétitions',
              initialSeconds: _reposRepetitionsSec,
              onChanged: (totalSeconds) {
                setState(() => _reposRepetitionsSec = totalSeconds);
                _updateExercice();
              },
              color: sportColor,
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Repos séries
            TimeInputField(
              label: 'Repos séries',
              initialSeconds: _reposSeriesSec,
              onChanged: (totalSeconds) {
                setState(() => _reposSeriesSec = totalSeconds);
                _updateExercice();
              },
              color: sportColor,
            ),

            // Info FTP profil
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
                    Icon(Icons.check_circle, color: sportColor, size: 18),
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
                          if (_poidsUtilisateur != null &&
                              _poidsUtilisateur! > 0)
                            FutureBuilder<double>(
                              future: Future.value(double.tryParse(
                                      _ftpController.text
                                          .replaceAll(',', '.')) ??
                                  0),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data! > 0) {
                                  final wkg = _calculerWkg(snapshot.data!);
                                  if (wkg != null) {
                                    return Text(
                                      'Poids profil: ${_poidsUtilisateur!.toStringAsFixed(1)} kg • w/kg: $wkg',
                                      style: TextStyle(
                                          color: TriathlonColors.textPrimary,
                                          fontSize: 11),
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

            // Avertissement poids manquant
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
                    Icon(Icons.warning, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Poids non disponible dans le profil. Le calcul w/kg ne sera pas effectué.',
                        style:
                            TextStyle(color: Colors.orange[800], fontSize: 11),
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
                        TriathlonDimens.borderRadiusXLarge),
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

            // Résultat
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
                    padding:
                        const EdgeInsets.all(TriathlonDimens.paddingMedium),
                    decoration: BoxDecoration(
                      border: Border.all(color: sportColor, width: 2),
                      borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusMedium),
                    ),
                    child: Text(
                      _resultText,
                      style: TextStyle(color: sportColor, fontSize: 14),
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
      String nom = _nomController.text.trim();
      double distance =
          double.parse(_distanceController.text.replaceAll(',', '.'));
      int series = int.parse(_seriesController.text);
      int repetitions = int.parse(_repetitionsController.text);
      double ftp = double.parse(_ftpController.text.replaceAll(',', '.'));

      if (distance <= 0 || series <= 0 || ftp <= 0) return;

      if (repetitions <= 0) repetitions = 1;
      if (_reposRepetitionsSec < 0) _reposRepetitionsSec = 0;
      if (_reposSeriesSec < 0) _reposSeriesSec = 0;
      if (series == 1) _reposSeriesSec = 0;

      if (nom.isEmpty) {
        final zoneInfo = CyclingZones.getZoneById(_selectedZone!);
        nom = '${distance.toInt()}m en ${zoneInfo?['name'] ?? 'Zone 3'}';
      }

      List<int> intensityRange = _getIntensityRangeForZone(_selectedZone!);
      int intensiteMin = intensityRange[0];
      int intensiteMax = intensityRange[1];

      widget.exercice.nom = nom;
      widget.exercice.distance = distance;
      widget.exercice.nbSeries = series;
      widget.exercice.nbRepetitions = repetitions;
      widget.exercice.valeurReference = ftp;
      widget.exercice.intensiteMin = intensiteMin;
      widget.exercice.intensite = intensiteMax;
      widget.exercice.reposRepetitionsSec = _reposRepetitionsSec;
      widget.exercice.reposSeriesSec = _reposSeriesSec;

      if (_poidsUtilisateur != null) {
        widget.exercice.poids = _poidsUtilisateur;
      }

      widget.exercice.calculerTemps();

      final zoneInfo = CyclingZones.getZoneById(_selectedZone!);
      String tempsMinFormate =
          widget.exercice.formatTemps(widget.exercice.tempsMin);
      String tempsMaxFormate =
          widget.exercice.formatTemps(widget.exercice.tempsMax);
      String reposRepFormate =
          TriathlonExercice.formatTempsEnMinutes(_reposRepetitionsSec);
      String reposSerFormate =
          TriathlonExercice.formatTempsEnMinutes(_reposSeriesSec);

      String resultatBase =
          '${zoneInfo?['name'] ?? 'Zone 3'} - ${zoneInfo?['description'] ?? ''}\n'
          'Intensité: ${zoneInfo?['range'] ?? ''}\n'
          '$series séries de $repetitions x ${distance.toInt()}m\n'
          'Temps: $tempsMinFormate à $tempsMaxFormate\n'
          'Repos entre répétitions: $reposRepFormate\n'
          'Repos entre séries: $reposSerFormate';

      String? wkg = _calculerWkg(ftp);
      String infoWkg = '';
      if (wkg != null && _poidsUtilisateur != null) {
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

      widget.onCalculer(widget.exercice);
    } catch (e) {
      print('Erreur dans _updateExercice: $e');
    }
  }
}
