import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/triathlon_colors.dart';
import '../../models/cycling_calculator.dart';
import '../../services/data_manager.dart';

class CyclingCalculIntensiteScreen extends StatefulWidget {
  const CyclingCalculIntensiteScreen({super.key});

  @override
  _CyclingCalculIntensiteScreenState createState() =>
      _CyclingCalculIntensiteScreenState();
}

class _CyclingCalculIntensiteScreenState
    extends State<CyclingCalculIntensiteScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _ftpController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _intensiteController = TextEditingController();
  final TextEditingController _poidsController = TextEditingController();
  final TextEditingController _deniveleController = TextEditingController();

  String _resultPower = '--';
  String _resultSpeed = '--';
  String _resultTime = '--:--';
  bool _showResult = false;
  bool _useProfileFTP = false; // NOUVEAU: Pour utiliser FTP du profil
  bool _useProfileWeight = false; // NOUVEAU: Pour utiliser poids du profil

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

    // Valeurs par défaut
    _intensiteController.text = '80.0';
    _deniveleController.text = '0';
    // Ne pas initialiser FTP et poids ici, attendre didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileData();
  }

  void _loadProfileData() {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final profile = dataManager.getTriathlonProfile();

    // Charger la FTP du profil
    if (profile.containsKey('cycling_ftp')) {
      final ftp = profile['cycling_ftp'] as double?;
      if (ftp != null) {
        setState(() {
          _ftpController.text = ftp.toStringAsFixed(0);
          _useProfileFTP = true;
        });
        print('FTP chargée depuis profil: ${ftp} watts');
      }
    } else {
      setState(() {
        _ftpController.text = '250'; // Valeur par défaut
        _useProfileFTP = false;
      });
      print('FTP par défaut utilisé: 250 watts');
    }

    // Charger le poids du profil
    if (profile.containsKey('poids')) {
      final poids = profile['poids'] as double? ?? 70.0;
      setState(() {
        _poidsController.text = poids.toStringAsFixed(1);
        _useProfileWeight = true;
      });
      print('Poids chargé depuis profil: ${poids}kg');
    } else {
      setState(() {
        _poidsController.text = '70.0';
        _useProfileWeight = false;
      });
      print('Poids par défaut utilisé: 70.0kg');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ftpController.dispose();
    _distanceController.dispose();
    _intensiteController.dispose();
    _poidsController.dispose();
    _deniveleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final profile = dataManager.getTriathlonProfile();
    final hasProfileFTP =
        profile.containsKey('cycling_ftp') && profile['cycling_ftp'] != null;
    final hasProfileWeight =
        profile.containsKey('poids') && profile['poids'] != null;

    return Scaffold(
      backgroundColor: TriathlonColors.background,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 30,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: TriathlonColors.cyclingGradient,
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
                  'Calcul Cyclisme par Intensité FTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Basé sur votre Functional Threshold Power',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Formulaire
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FTP avec switch
                          if (hasProfileFTP)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'FTP (watts)',
                                    style: TextStyle(
                                      color: TriathlonColors.cycling,
                                      fontSize: 18,
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
                                        fontSize: 14,
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
                                            _ftpController.text = '250';
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
                              'FTP (watts)',
                              style: TextStyle(
                                color: TriathlonColors.cycling,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          const SizedBox(height: 8),
                          TextField(
                            controller: _ftpController,
                            enabled: !_useProfileFTP || !hasProfileFTP,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _useProfileFTP && hasProfileFTP
                                  ? TriathlonColors.cycling.withOpacity(0.1)
                                  : Colors.white,
                              hintText: _useProfileFTP && hasProfileFTP
                                  ? 'FTP du profil utilisée'
                                  : 'Ex: 250',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: TriathlonColors.cycling,
                                  width: 2,
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
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Distance
                          Text(
                            'Distance (km)',
                            style: TextStyle(
                              color: TriathlonColors.cycling,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _distanceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Ex: 20, 40, 100...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: TriathlonColors.cycling,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.linear_scale,
                                color: TriathlonColors.cycling,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Deux colonnes Intensité/Poids
                          Row(
                            children: [
                              // Intensité
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Intensité (%)',
                                      style: TextStyle(
                                        color: TriathlonColors.cycling,
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: TriathlonColors.cycling,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Poids avec switch
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (hasProfileWeight)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Poids (kg)',
                                              style: TextStyle(
                                                color: TriathlonColors.cycling,
                                                fontSize: 16,
                                              ),
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
                                                  _poidsController.text =
                                                      '70.0';
                                                }
                                              });
                                            },
                                            activeColor:
                                                TriathlonColors.cycling,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                        ],
                                      )
                                    else
                                      Text(
                                        'Poids (kg)',
                                        style: TextStyle(
                                          color: TriathlonColors.cycling,
                                          fontSize: 16,
                                        ),
                                      ),
                                    const SizedBox(height: 5),
                                    TextField(
                                      controller: _poidsController,
                                      enabled: !_useProfileWeight ||
                                          !hasProfileWeight,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: _useProfileWeight &&
                                                hasProfileWeight
                                            ? TriathlonColors.cycling
                                                .withOpacity(0.1)
                                            : Colors.white,
                                        hintText: _useProfileWeight &&
                                                hasProfileWeight
                                            ? 'Poids du profil utilisé'
                                            : 'Ex: 70.0',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: TriathlonColors.cycling,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        suffixIcon: hasProfileWeight &&
                                                !_useProfileWeight
                                            ? IconButton(
                                                icon: const Icon(Icons.refresh,
                                                    size: 16),
                                                onPressed: () {
                                                  setState(() {
                                                    _useProfileWeight = true;
                                                    _loadProfileData();
                                                  });
                                                },
                                                tooltip:
                                                    'Utiliser le poids du profil',
                                              )
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Dénivelé
                          Text(
                            'Dénivelé positif (mètres)',
                            style: TextStyle(
                              color: TriathlonColors.cycling,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _deniveleController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Ex: 500 (facultatif)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: TriathlonColors.cycling,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.terrain,
                                color: TriathlonColors.cycling,
                              ),
                            ),
                          ),

                          // Information si les données du profil sont utilisées
                          if ((_useProfileFTP && hasProfileFTP) ||
                              (_useProfileWeight && hasProfileWeight))
                            Container(
                              margin: const EdgeInsets.only(top: 20),
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

                          const SizedBox(height: 30),

                          // Bouton Calculer
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _calculer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TriathlonColors.cycling,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                              ),
                              child: const Text(
                                'CALCULER',
                                style: TextStyle(
                                  fontSize: 18,
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

                  // Résultats
                  AnimatedOpacity(
                    opacity: _showResult ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _showResult ? null : 0,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RÉSULTATS',
                                  style: TextStyle(
                                    color: TriathlonColors.cycling,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Puissance
                                _buildResultCard(
                                  title: 'Puissance cible',
                                  value: _resultPower,
                                  unit: 'watts',
                                  icon: Icons.power,
                                ),

                                const SizedBox(height: 10),

                                // Vitesse
                                _buildResultCard(
                                  title: 'Vitesse moyenne',
                                  value: _resultSpeed,
                                  unit: 'km/h',
                                  icon: Icons.speed,
                                ),

                                const SizedBox(height: 10),

                                // Temps
                                _buildResultCard(
                                  title: 'Temps estimé',
                                  value: _resultTime,
                                  unit: '',
                                  icon: Icons.timer,
                                ),

                                const SizedBox(height: 15),

                                // Note
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: TriathlonColors.cycling
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Ces calculs sont des estimations basées sur des formules simplifiées.',
                                    style: TextStyle(
                                      color: TriathlonColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Bouton Retour
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
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

  Widget _buildResultCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: TriathlonColors.cycling.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TriathlonColors.cycling.withOpacity(0.1),
            TriathlonColors.cycling.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: TriathlonColors.cycling,
            size: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: TriathlonColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: TriathlonColors.cycling,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      unit,
                      style: TextStyle(
                        color: TriathlonColors.cycling,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _calculer() {
    // Validation
    if (_ftpController.text.isEmpty ||
        _distanceController.text.isEmpty ||
        _intensiteController.text.isEmpty ||
        _poidsController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs obligatoires');
      return;
    }

    try {
      // Parser les valeurs
      double ftp = double.parse(_ftpController.text.replaceAll(',', '.'));
      double distance =
          double.parse(_distanceController.text.replaceAll(',', '.'));
      double intensity =
          double.parse(_intensiteController.text.replaceAll(',', '.'));
      double poids = double.parse(_poidsController.text.replaceAll(',', '.'));
      double denivele = _deniveleController.text.isNotEmpty
          ? double.parse(_deniveleController.text.replaceAll(',', '.'))
          : 0;

      // Validation des valeurs
      if (ftp <= 0 || ftp > 1000) {
        _showError('FTP invalide (50-1000 watts)');
        return;
      }

      if (distance <= 0) {
        _showError('Distance invalide');
        return;
      }

      if (intensity <= 0 || intensity > 200) {
        _showError('L\'intensité doit être entre 1 et 200%');
        return;
      }

      if (poids <= 0 || poids > 200) {
        _showError('Poids invalide (10-200 kg)');
        return;
      }

      // Calculs
      double puissanceCible = CyclingCalculator.calculatePowerFromFTP(
        ftp: ftp,
        intensity: intensity,
      );

      double tempsSecondes = CyclingCalculator.calculateTimeForDistance(
        power: puissanceCible,
        distance: distance,
        weight: poids,
        elevation: denivele,
      );

      double vitesse = CyclingCalculator.calculateAverageSpeed(
        power: puissanceCible,
        weight: poids,
        elevation: denivele,
      );

      // Formater les résultats
      String puissanceFormatee = puissanceCible.toStringAsFixed(0);
      String vitesseFormatee = vitesse.toStringAsFixed(1);
      String tempsFormate = CyclingCalculator.formatCyclingTime(tempsSecondes);

      // Mettre à jour l'interface
      setState(() {
        _resultPower = puissanceFormatee;
        _resultSpeed = vitesseFormatee;
        _resultTime = tempsFormate;
        _showResult = true;
      });

      // Lancer l'animation
      _animationController.reset();
      _animationController.forward();
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
