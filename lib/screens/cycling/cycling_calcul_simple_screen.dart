import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/triathlon_colors.dart';
import '../../constants/triathlon_dimens.dart';
import '../../services/data_manager.dart';

class CyclingCalculSimpleScreen extends StatefulWidget {
  const CyclingCalculSimpleScreen({super.key});

  @override
  _CyclingCalculSimpleScreenState createState() =>
      _CyclingCalculSimpleScreenState();
}

class _CyclingCalculSimpleScreenState extends State<CyclingCalculSimpleScreen> {
  final TextEditingController _powerController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _gradientController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  String _resultAverageSpeed = '--- km/h';
  String _resultWattsPerKg = '--- w/kg';
  String _resultMinTime = '---';
  String _resultMaxTime = '---';

  bool _showResult = false;
  bool _useProfileWeight = false;
  bool _useProfileFTP = false; // NOUVEAU: Pour utiliser FTP du profil

  // Variable pour la zone sélectionnée
  String _selectedZone = 'Zone 4'; // Zone par défaut

  // Définition des zones d'entraînement basées sur FTP
  final Map<String, Map<String, dynamic>> _trainingZones = {
    'Zone 1': {
      'name': 'Récupération active',
      'min': 0.55,
      'max': 0.75,
      'description': '55-75% FTP - Échauffement, récupération',
      'color': Colors.green,
    },
    'Zone 2': {
      'name': 'Endurance',
      'min': 0.75,
      'max': 0.85,
      'description': '75-85% FTP - Base aérobie, sortie longue',
      'color': Colors.lightGreen,
    },
    'Zone 3': {
      'name': 'Tempo',
      'min': 0.85,
      'max': 0.95,
      'description': '85-95% FTP - Endurance force, rythme soutenu',
      'color': Colors.blue,
    },
    'Zone 4': {
      'name': 'Seuil lactique',
      'min': 0.95,
      'max': 1.05,
      'description': '95-105% FTP - Seuil anaérobie, FTP',
      'color': Colors.orange,
    },
    'Zone 5': {
      'name': 'VO2 Max',
      'min': 1.05,
      'max': 1.20,
      'description': '105-120% FTP - Intervalles 3-8 min',
      'color': Colors.red,
    },
    'Zone 6': {
      'name': 'Anaérobie',
      'min': 1.20,
      'max': 1.50,
      'description': '120-150% FTP - Intervalles 30sec-3min',
      'color': Colors.purple,
    },
  };

  @override
  void initState() {
    super.initState();
    // Initialiser avec des valeurs par défaut
    _gradientController.text = '0.0';
    _distanceController.text = '40.0';
    // Ne pas initialiser le poids et FTP ici, attendre didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileData();
  }

  void _loadProfileData() {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final profile = dataManager.getTriathlonProfile();

    // Charger le poids du profil
    if (profile.containsKey('poids')) {
      final poids = profile['poids'] as double? ?? 70.0;
      setState(() {
        _weightController.text = poids.toStringAsFixed(1);
        _useProfileWeight = true;
      });
      print('Poids chargé depuis profil: ${poids}kg');
    } else {
      setState(() {
        _weightController.text = '70.0';
        _useProfileWeight = false;
      });
      print('Poids par défaut utilisé: 70.0kg');
    }

    // Charger la FTP du profil
    if (profile.containsKey('cycling_ftp')) {
      final ftp = profile['cycling_ftp'] as double?;
      if (ftp != null) {
        setState(() {
          _powerController.text = ftp.toStringAsFixed(0);
          _useProfileFTP = true;
        });
        print('FTP chargée depuis profil: ${ftp} watts');
      }
    } else {
      setState(() {
        _powerController.text = '200'; // Valeur par défaut
        _useProfileFTP = false;
      });
      print('FTP par défaut utilisé: 200 watts');
    }
  }

  @override
  void dispose() {
    _powerController.dispose();
    _weightController.dispose();
    _gradientController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final profile = dataManager.getTriathlonProfile();
    final hasProfileWeight =
        profile.containsKey('poids') && profile['poids'] != null;
    final hasProfileFTP =
        profile.containsKey('cycling_ftp') && profile['cycling_ftp'] != null;

    return Scaffold(
      backgroundColor: TriathlonColors.background,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: TriathlonDimens.paddingLarge,
              right: TriathlonDimens.paddingLarge,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: TriathlonColors.cyclingGradient,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(TriathlonDimens.borderRadiusXLarge),
                bottomRight:
                    Radius.circular(TriathlonDimens.borderRadiusXLarge),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: TriathlonDimens.elevationLarge,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Icon(
                    Icons.speed,
                    size: TriathlonDimens.iconSizeXXLarge,
                    color: Colors.white,
                  ),
                  const SizedBox(height: TriathlonDimens.paddingMedium),
                  Text(
                    'Calcul Puissance → Vitesse & Allure',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: TriathlonDimens.fontSizeXXLarge,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TriathlonDimens.paddingSmall),
                  Text(
                    'Calculez les temps min et max pour chaque zone',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: TriathlonDimens.fontSizeLarge,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Formulaire
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
              child: Column(
                children: [
                  Card(
                    elevation: TriathlonDimens.elevationLarge,
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
                          // Puissance demandée (FTP de référence) avec switch
                          if (hasProfileFTP)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'FTP de référence (watts)',
                                    style: TextStyle(
                                      color: TriathlonColors.cycling,
                                      fontSize: TriathlonDimens.fontSizeXLarge,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Profil',
                                      style: TextStyle(
                                        color: TriathlonColors.cycling,
                                        fontSize: TriathlonDimens.fontSizeSmall,
                                      ),
                                    ),
                                    Switch(
                                      value: _useProfileFTP,
                                      onChanged: (value) {
                                        setState(() {
                                          _useProfileFTP = value;
                                          if (value) {
                                            _loadProfileData();
                                          } else {
                                            _powerController.text = '200';
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
                              'FTP de référence (watts)',
                              style: TextStyle(
                                color: TriathlonColors.cycling,
                                fontSize: TriathlonDimens.fontSizeXLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          const SizedBox(height: TriathlonDimens.paddingSmall),
                          TextField(
                            controller: _powerController,
                            enabled: !_useProfileFTP || !hasProfileFTP,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _useProfileFTP && hasProfileFTP
                                  ? TriathlonColors.cycling.withOpacity(0.1)
                                  : TriathlonColors.background,
                              hintText: _useProfileFTP && hasProfileFTP
                                  ? 'FTP du profil utilisée'
                                  : 'Ex: 200 (watts FTP)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  TriathlonDimens.borderRadiusMedium,
                                ),
                                borderSide: BorderSide(
                                  color: TriathlonColors.cycling,
                                  width: TriathlonDimens.borderWidth,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.power,
                                color: TriathlonColors.cycling,
                              ),
                              suffixIcon: hasProfileFTP && !_useProfileFTP
                                  ? IconButton(
                                      icon: const Icon(Icons.refresh),
                                      onPressed: () {
                                        setState(() {
                                          _useProfileFTP = true;
                                          _loadProfileData();
                                        });
                                      },
                                      tooltip: 'Utiliser la FTP du profil',
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: TriathlonDimens.paddingMedium,
                                vertical: TriathlonDimens.paddingMedium,
                              ),
                            ),
                          ),

                          const SizedBox(height: TriathlonDimens.paddingLarge),

                          // Poids avec switch
                          if (hasProfileWeight)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Poids du cycliste (kg)',
                                    style: TextStyle(
                                      color: TriathlonColors.cycling,
                                      fontSize: TriathlonDimens.fontSizeXLarge,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Profil',
                                      style: TextStyle(
                                        color: TriathlonColors.cycling,
                                        fontSize: TriathlonDimens.fontSizeSmall,
                                      ),
                                    ),
                                    Switch(
                                      value: _useProfileWeight,
                                      onChanged: (value) {
                                        setState(() {
                                          _useProfileWeight = value;
                                          if (value) {
                                            _loadProfileData();
                                          } else {
                                            _weightController.text = '70.0';
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
                                fontSize: TriathlonDimens.fontSizeXLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          const SizedBox(height: TriathlonDimens.paddingSmall),

                          TextField(
                            controller: _weightController,
                            enabled: !_useProfileWeight || !hasProfileWeight,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _useProfileWeight && hasProfileWeight
                                  ? TriathlonColors.cycling.withOpacity(0.1)
                                  : TriathlonColors.background,
                              hintText: _useProfileWeight && hasProfileWeight
                                  ? 'Poids du profil utilisé'
                                  : 'Ex: 70.0 (kg)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  TriathlonDimens.borderRadiusMedium,
                                ),
                                borderSide: BorderSide(
                                  color: TriathlonColors.cycling,
                                  width: TriathlonDimens.borderWidth,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.monitor_weight,
                                color: TriathlonColors.cycling,
                              ),
                              suffixIcon: hasProfileWeight && !_useProfileWeight
                                  ? IconButton(
                                      icon: const Icon(Icons.refresh),
                                      onPressed: () {
                                        setState(() {
                                          _useProfileWeight = true;
                                          _loadProfileData();
                                        });
                                      },
                                      tooltip: 'Utiliser le poids du profil',
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: TriathlonDimens.paddingMedium,
                                vertical: TriathlonDimens.paddingMedium,
                              ),
                            ),
                          ),

                          const SizedBox(height: TriathlonDimens.paddingLarge),

                          // Pente
                          Text(
                            'Pente (%)',
                            style: TextStyle(
                              color: TriathlonColors.cycling,
                              fontSize: TriathlonDimens.fontSizeXLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: TriathlonDimens.paddingSmall),
                          TextField(
                            controller: _gradientController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: TriathlonColors.background,
                              hintText: 'Ex: 5.0 (montée) ou -3.0 (descente)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  TriathlonDimens.borderRadiusMedium,
                                ),
                                borderSide: BorderSide(
                                  color: TriathlonColors.cycling,
                                  width: TriathlonDimens.borderWidth,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.trending_up,
                                color: TriathlonColors.cycling,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: TriathlonDimens.paddingMedium,
                                vertical: TriathlonDimens.paddingMedium,
                              ),
                            ),
                          ),

                          const SizedBox(height: TriathlonDimens.paddingLarge),

                          // Distance
                          Text(
                            'Distance (km)',
                            style: TextStyle(
                              color: TriathlonColors.cycling,
                              fontSize: TriathlonDimens.fontSizeXLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: TriathlonDimens.paddingSmall),
                          TextField(
                            controller: _distanceController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: TriathlonColors.background,
                              hintText: 'Ex: 40.0 (km)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  TriathlonDimens.borderRadiusMedium,
                                ),
                                borderSide: BorderSide(
                                  color: TriathlonColors.cycling,
                                  width: TriathlonDimens.borderWidth,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.linear_scale,
                                color: TriathlonColors.cycling,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: TriathlonDimens.paddingMedium,
                                vertical: TriathlonDimens.paddingMedium,
                              ),
                            ),
                          ),

                          const SizedBox(height: TriathlonDimens.paddingLarge),

                          // Spinner Zone
                          Text(
                            'Zone d\'intensité',
                            style: TextStyle(
                              color: TriathlonColors.cycling,
                              fontSize: TriathlonDimens.fontSizeXLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: TriathlonDimens.paddingSmall),

                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: TriathlonColors.cycling,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedZone,
                              isExpanded: true,
                              underline: Container(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedZone = newValue;
                                    if (_showResult) {
                                      _calculer();
                                    }
                                  });
                                }
                              },
                              items: _trainingZones.keys
                                  .map<DropdownMenuItem<String>>((String zone) {
                                final zoneData = _trainingZones[zone]!;
                                return DropdownMenuItem<String>(
                                  value: zone,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: zoneData['color'] as Color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                zone,
                                                style: TextStyle(
                                                  color: TriathlonColors
                                                      .textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                zoneData['description']
                                                    as String,
                                                style: TextStyle(
                                                  color: TriathlonColors
                                                      .textSecondary,
                                                  fontSize: 10,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // Info zone sélectionnée
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (_trainingZones[_selectedZone]!['color']
                                        as Color)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      (_trainingZones[_selectedZone]!['color']
                                              as Color)
                                          .withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color:
                                        (_trainingZones[_selectedZone]!['color']
                                            as Color),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _trainingZones[_selectedZone]!['name']
                                              as String,
                                          style: TextStyle(
                                            color: TriathlonColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${(_trainingZones[_selectedZone]!['min'] * 100).toStringAsFixed(0)}% - ${(_trainingZones[_selectedZone]!['max'] * 100).toStringAsFixed(0)}% FTP',
                                          style: TextStyle(
                                            color:
                                                TriathlonColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Information si les données du profil sont utilisées
                          if ((_useProfileFTP && hasProfileFTP) ||
                              (_useProfileWeight && hasProfileWeight))
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: TriathlonColors.cycling.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: TriathlonColors.cycling,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _useProfileFTP &&
                                              hasProfileFTP &&
                                              _useProfileWeight &&
                                              hasProfileWeight
                                          ? 'Utilisation des données du profil (FTP et poids)'
                                          : _useProfileFTP && hasProfileFTP
                                              ? 'Utilisation de la FTP du profil'
                                              : 'Utilisation du poids du profil',
                                      style: TextStyle(
                                        color: TriathlonColors.textPrimary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(
                              height: TriathlonDimens.paddingXXLarge),

                          // Bouton Calculer
                          SizedBox(
                            width: double.infinity,
                            height: TriathlonDimens.buttonHeightLarge,
                            child: ElevatedButton(
                              onPressed: _calculer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TriathlonColors.cycling,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    TriathlonDimens.borderRadiusXLarge,
                                  ),
                                ),
                                elevation: TriathlonDimens.elevationLarge,
                              ),
                              child: const Text(
                                'CALCULER',
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

                  const SizedBox(height: TriathlonDimens.paddingLarge),

                  // Résultat
                  AnimatedOpacity(
                    opacity: _showResult ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _showResult ? null : 0,
                      child: Card(
                        elevation: TriathlonDimens.elevationLarge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TriathlonDimens.borderRadiusLarge,
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(
                              TriathlonDimens.paddingLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RÉSULTATS POUR ${_selectedZone.toUpperCase()}',
                                style: TextStyle(
                                  color: TriathlonColors.cycling,
                                  fontSize: TriathlonDimens.fontSizeXXLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                  height: TriathlonDimens.paddingMedium),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(
                                    TriathlonDimens.paddingLarge),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        (_trainingZones[_selectedZone]!['color']
                                            as Color),
                                    width: TriathlonDimens.borderWidth,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    TriathlonDimens.borderRadiusMedium,
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      (_trainingZones[_selectedZone]!['color']
                                              as Color)
                                          .withOpacity(0.1),
                                      (_trainingZones[_selectedZone]!['color']
                                              as Color)
                                          .withOpacity(0.05),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Info zone sélectionnée
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: (_trainingZones[_selectedZone]![
                                                'color'] as Color)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: (_trainingZones[
                                                  _selectedZone]!['color']
                                              as Color),
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: (_trainingZones[
                                                      _selectedZone]!['color']
                                                  as Color),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _trainingZones[
                                                          _selectedZone]![
                                                      'name'] as String,
                                                  style: TextStyle(
                                                    color: TriathlonColors
                                                        .textPrimary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: TriathlonDimens
                                                        .fontSizeMedium,
                                                  ),
                                                ),
                                                Text(
                                                  '${(_trainingZones[_selectedZone]!['min'] * 100).toStringAsFixed(0)}% - ${(_trainingZones[_selectedZone]!['max'] * 100).toStringAsFixed(0)}% FTP',
                                                  style: TextStyle(
                                                    color: TriathlonColors
                                                        .textSecondary,
                                                    fontSize: TriathlonDimens
                                                        .fontSizeSmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Vitesse moyenne au milieu de la zone
                                    _buildResultRow(
                                      'Vitesse moyenne',
                                      _resultAverageSpeed,
                                      isMain: true,
                                    ),

                                    const SizedBox(
                                        height: TriathlonDimens.paddingMedium),

                                    // Watts/kg au milieu de la zone
                                    _buildResultRow(
                                      'Puissance spécifique',
                                      _resultWattsPerKg,
                                    ),

                                    const SizedBox(
                                        height: TriathlonDimens.paddingMedium),

                                    // Temps pour distance selon la zone
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Temps pour ${_distanceController.text} km',
                                          style: TextStyle(
                                            color:
                                                TriathlonColors.textSecondary,
                                            fontSize:
                                                TriathlonDimens.fontSizeMedium,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Min (${(_trainingZones[_selectedZone]!['min'] * 100).toStringAsFixed(0)}% FTP)',
                                                    style: TextStyle(
                                                      color: TriathlonColors
                                                          .textSecondary,
                                                      fontSize: TriathlonDimens
                                                          .fontSizeSmall,
                                                    ),
                                                  ),
                                                  Text(
                                                    _resultMinTime,
                                                    style: TextStyle(
                                                      color: TriathlonColors
                                                          .cycling,
                                                      fontSize: TriathlonDimens
                                                          .fontSizeLarge,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Max (${(_trainingZones[_selectedZone]!['max'] * 100).toStringAsFixed(0)}% FTP)',
                                                    style: TextStyle(
                                                      color: TriathlonColors
                                                          .textSecondary,
                                                      fontSize: TriathlonDimens
                                                          .fontSizeSmall,
                                                    ),
                                                  ),
                                                  Text(
                                                    _resultMaxTime,
                                                    style: TextStyle(
                                                      color: TriathlonColors
                                                          .cycling,
                                                      fontSize: TriathlonDimens
                                                          .fontSizeLarge,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: TriathlonDimens.paddingLarge),

                  // Informations
                  Card(
                    elevation: TriathlonDimens.elevationMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        TriathlonDimens.borderRadiusLarge,
                      ),
                    ),
                    color: TriathlonColors.background,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(TriathlonDimens.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: TriathlonColors.cycling,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'À PROPOS DU CALCUL',
                                style: TextStyle(
                                  color: TriathlonColors.cycling,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pour chaque zone, le calcul donne deux temps :\n'
                            '• Temps MIN : à l\'intensité minimale de la zone\n'
                            '• Temps MAX : à l\'intensité maximale de la zone\n'
                            'Ex: Zone 1 donne les temps à 55% FTP (min) et 75% FTP (max)',
                            style: TextStyle(
                              color: TriathlonColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: TriathlonDimens.paddingXXLarge),

                  // Bouton Retour
                  SizedBox(
                    width: double.infinity,
                    height: TriathlonDimens.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: TriathlonColors.cycling,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TriathlonDimens.borderRadiusXLarge,
                          ),
                          side: BorderSide(
                            color: TriathlonColors.cycling,
                            width: TriathlonDimens.borderWidth,
                          ),
                        ),
                        elevation: TriathlonDimens.elevationSmall,
                      ),
                      child: const Text(
                        'RETOUR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).viewPadding.bottom + 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isMain = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: TriathlonColors.textSecondary,
            fontSize: isMain
                ? TriathlonDimens.fontSizeMedium
                : TriathlonDimens.fontSizeSmall,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: TriathlonColors.cycling,
            fontSize: isMain
                ? TriathlonDimens.fontSizeXXLarge
                : TriathlonDimens.fontSizeLarge,
            fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _calculer() {
    // Validation
    if (_powerController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _gradientController.text.isEmpty ||
        _distanceController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    try {
      double ftp = double.parse(_powerController.text.replaceAll(',', '.'));
      double weight = double.parse(_weightController.text.replaceAll(',', '.'));
      double gradient =
          double.parse(_gradientController.text.replaceAll(',', '.'));
      double distance =
          double.parse(_distanceController.text.replaceAll(',', '.'));

      // Validation des valeurs
      if (ftp <= 0 || ftp > 1000) {
        _showError('FTP invalide (1-1000 watts)');
        return;
      }

      if (weight <= 0 || weight > 200) {
        _showError('Poids invalide (10-200 kg)');
        return;
      }

      if (gradient < -30 || gradient > 30) {
        _showError('Pente invalide (-30% à +30%)');
        return;
      }

      if (distance <= 0 || distance > 500) {
        _showError('Distance invalide (0.1-500 km)');
        return;
      }

      // Calculer le dénivelé (distance en m * pente %)
      double elevation = distance * 1000 * (gradient / 100);

      // Récupérer les valeurs min et max de la zone sélectionnée
      final zone = _trainingZones[_selectedZone]!;
      double minIntensity = zone['min'] as double;
      double maxIntensity = zone['max'] as double;
      double middleIntensity = (minIntensity + maxIntensity) / 2;

      // Calculer les puissances pour chaque intensité
      double minPower = ftp * minIntensity;
      double maxPower = ftp * maxIntensity;
      double middlePower = ftp * middleIntensity;

      // Utiliser la classe CyclingCalculator
      // 1. Calculer les watts/kg au milieu de la zone
      double wattsPerKg = CyclingCalculator.calculateWattsPerKg(
        power: middlePower,
        weight: weight,
      );

      // 2. Calculer la vitesse moyenne au milieu de la zone
      double averageSpeed = CyclingCalculator.calculateAverageSpeed(
        power: middlePower,
        weight: weight,
        elevation: elevation,
      );

      // 3. Calculer les temps min et max pour la zone
      double minTimeSeconds = CyclingCalculator.calculateTimeForDistance(
        power: minPower,
        distance: distance,
        weight: weight,
        elevation: elevation,
      );

      double maxTimeSeconds = CyclingCalculator.calculateTimeForDistance(
        power: maxPower,
        distance: distance,
        weight: weight,
        elevation: elevation,
      );

      // 4. Formater les résultats
      String formattedWattsPerKg = '${wattsPerKg.toStringAsFixed(1)} w/kg';
      String formattedSpeed = '${averageSpeed.toStringAsFixed(1)} km/h';
      String formattedMinTime =
          CyclingCalculator.formatCyclingTime(minTimeSeconds);
      String formattedMaxTime =
          CyclingCalculator.formatCyclingTime(maxTimeSeconds);

      setState(() {
        _resultWattsPerKg = formattedWattsPerKg;
        _resultAverageSpeed = formattedSpeed;
        _resultMinTime = formattedMinTime;
        _resultMaxTime = formattedMaxTime;
        _showResult = true;
      });
    } catch (e) {
      _showError('Erreur de calcul: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Classe CyclingCalculator (identique à celle que vous avez fournie)
class CyclingCalculator {
  // Calculer la puissance pour une intensité donnée
  static double calculatePowerFromFTP({
    required double ftp, // FTP en watts
    required double intensity, // Intensité en pourcentage (70 = 70% FTP)
  }) {
    return ftp * (intensity / 100.0);
  }

  // Calculer le temps pour une distance avec une puissance donnée
  static double calculateTimeForDistance({
    required double power, // Puissance en watts
    required double distance, // Distance en km
    required double weight, // Poids du cycliste en kg (optionnel)
    required double elevation, // Dénivelé en mètres (optionnel)
  }) {
    // Formule simplifiée basée sur la puissance
    // Vitesse approximative (km/h) = (Puissance * 0.1) + 20
    // C'est une approximation - dans la réalité c'est plus complexe

    double speedKmh = (power * 0.1) + 20;

    // Ajuster pour le dénivelé
    if (elevation > 0) {
      double elevationFactor = elevation / 1000; // pour 1000m de dénivelé
      speedKmh *= (1 - (elevationFactor * 0.1));
    }

    // Limiter la vitesse
    speedKmh = speedKmh.clamp(10, 50);

    // Calcul du temps
    double timeHours = distance / speedKmh;
    return timeHours * 3600; // Convertir en secondes
  }

  // Calculer la vitesse moyenne
  static double calculateAverageSpeed({
    required double power,
    required double weight,
    double elevation = 0,
  }) {
    double baseSpeed = (power * 0.1) + 20;

    if (elevation > 0) {
      double elevationFactor = elevation / 1000;
      baseSpeed *= (1 - (elevationFactor * 0.1));
    }

    return baseSpeed.clamp(10, 50);
  }

  // Calculer la puissance nécessaire pour une vitesse donnée
  static double calculatePowerForSpeed({
    required double targetSpeed, // Vitesse cible en km/h
    required double weight,
    double elevation = 0,
  }) {
    // Formule inverse
    double adjustedSpeed = targetSpeed;

    if (elevation > 0) {
      double elevationFactor = elevation / 1000;
      adjustedSpeed /= (1 - (elevationFactor * 0.1));
    }

    double power = (adjustedSpeed - 20) / 0.1;
    return power.clamp(50, 500); // Limites réalistes
  }

  // Convertir des watts en watts/kg
  static double calculateWattsPerKg({
    required double power,
    required double weight,
  }) {
    if (weight <= 0) return 0;
    return power / weight;
  }

  // Formater le temps cyclisme
  static String formatCyclingTime(double seconds) {
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

  // Calculer les zones d'entraînement basées sur FTP
  static Map<String, Map<String, dynamic>> getTrainingZones(double ftp) {
    return {
      'Zone 1': {
        'name': 'Récupération active',
        'min': ftp * 0.55,
        'max': ftp * 0.75,
        'description': 'Pour la récupération',
      },
      'Zone 2': {
        'name': 'Endurance',
        'min': ftp * 0.75,
        'max': ftp * 0.85,
        'description': 'Base aérobie',
      },
      'Zone 3': {
        'name': 'Tempo',
        'min': ftp * 0.85,
        'max': ftp * 0.95,
        'description': 'Seuil aérobie',
      },
      'Zone 4': {
        'name': 'Seuil lactique',
        'min': ftp * 0.95,
        'max': ftp * 1.05,
        'description': 'Seuil anaérobie',
      },
      'Zone 5': {
        'name': 'VO2 Max',
        'min': ftp * 1.05,
        'max': ftp * 1.20,
        'description': 'Puissance aérobie',
      },
      'Zone 6': {
        'name': 'Anaérobie',
        'min': ftp * 1.20,
        'max': ftp * 1.50,
        'description': 'Capacité anaérobie',
      },
    };
  }
}
