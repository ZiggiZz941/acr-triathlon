import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/triathlon_colors.dart';
import '../../models/swimming_calculator.dart';
import '../../services/data_manager.dart'; // AJOUT: Importer DataManager

class SwimmingCalculSimpleScreen extends StatefulWidget {
  const SwimmingCalculSimpleScreen({super.key});

  @override
  _SwimmingCalculSimpleScreenState createState() =>
      _SwimmingCalculSimpleScreenState();
}

class _SwimmingCalculSimpleScreenState extends State<SwimmingCalculSimpleScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _temps400mController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _allureController = TextEditingController();

  String _resultText = '--:--.--';
  bool _showResult = false;
  bool _useProfileTime = false; // AJOUT: Pour utiliser le temps du profil

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
    _allureController.text = '1';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileData(); // AJOUT: Charger les données du profil
  }

  // AJOUT: Méthode pour charger les données du profil
  void _loadProfileData() {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final profile = dataManager.getTriathlonProfile();

    // Charger le temps 400m du profil
    if (profile.containsKey('swimming_400m_time')) {
      final temps400m = profile['swimming_400m_time'] as double?;
      if (temps400m != null) {
        final tempsFormate = _formatSwimmingTime(temps400m);
        setState(() {
          _temps400mController.text = tempsFormate;
          _useProfileTime = true;
        });
        print('Temps 400m chargé depuis profil: ${temps400m}s ($tempsFormate)');
      }
    } else {
      setState(() {
        _temps400mController.text = '6:30.50'; // Valeur par défaut
        _useProfileTime = false;
      });
      print('Temps 400m par défaut utilisé: 6:30.50');
    }
  }

  // AJOUT: Méthode pour formater le temps
  String _formatSwimmingTime(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    double remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toStringAsFixed(2).padLeft(5, '0')}';
    } else {
      return remainingSeconds.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _temps400mController.dispose();
    _distanceController.dispose();
    _allureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final profile = dataManager.getTriathlonProfile();
    final hasProfileTime = profile.containsKey('swimming_400m_time') &&
        profile['swimming_400m_time'] != null;

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
                colors: TriathlonColors.swimmingGradient,
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
                  'Calcul Natation Simple',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Temps pour une distance donnée',
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
                          // Temps au 400m avec switch
                          if (hasProfileTime)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Temps au 400m',
                                    style: TextStyle(
                                      color: TriathlonColors.swimming,
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
                                        color: TriathlonColors.swimming,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Switch(
                                      value: _useProfileTime,
                                      onChanged: (value) {
                                        setState(() {
                                          _useProfileTime = value;
                                          if (value) {
                                            _loadProfileData();
                                          } else {
                                            _temps400mController.text =
                                                '6:30.50';
                                          }
                                        });
                                      },
                                      activeColor: TriathlonColors.swimming,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          else
                            Text(
                              'Temps au 400m',
                              style: TextStyle(
                                color: TriathlonColors.swimming,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          const SizedBox(height: 8),
                          TextField(
                            controller: _temps400mController,
                            enabled: !_useProfileTime || !hasProfileTime,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _useProfileTime && hasProfileTime
                                  ? TriathlonColors.swimming.withOpacity(0.1)
                                  : Colors.white,
                              hintText: _useProfileTime && hasProfileTime
                                  ? 'Temps du profil utilisé'
                                  : 'Ex: 6:30.50 (mm:ss.xx)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: TriathlonColors.swimming,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.timer,
                                color: TriathlonColors.swimming,
                              ),
                              suffixIcon: hasProfileTime && !_useProfileTime
                                  ? IconButton(
                                      icon: const Icon(Icons.refresh),
                                      onPressed: () {
                                        setState(() {
                                          _useProfileTime = true;
                                          _loadProfileData();
                                        });
                                      },
                                      tooltip: 'Utiliser le temps du profil',
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Distance
                          Text(
                            'Distance (mètres)',
                            style: TextStyle(
                              color: TriathlonColors.swimming,
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
                              hintText: 'Ex: 200, 400, 800...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: TriathlonColors.swimming,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.linear_scale,
                                color: TriathlonColors.swimming,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Allure
                          Text(
                            'Allure (1-6)',
                            style: TextStyle(
                              color: TriathlonColors.swimming,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: TriathlonColors.swimming,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _allureController.text,
                              items: [
                                DropdownMenuItem(
                                  value: '1',
                                  child: Row(
                                    children: [
                                      Icon(Icons.speed,
                                          size: 20, color: Colors.green),
                                      const SizedBox(width: 10),
                                      const Text('Allure 1 (60-70%)'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '2',
                                  child: Row(
                                    children: [
                                      Icon(Icons.speed,
                                          size: 20, color: Colors.lightGreen),
                                      const SizedBox(width: 10),
                                      const Text('Allure 2 (70-80%)'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '3',
                                  child: Row(
                                    children: [
                                      Icon(Icons.speed,
                                          size: 20, color: Colors.orange),
                                      const SizedBox(width: 10),
                                      const Text('Allure 3 (80-85%)'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '4',
                                  child: Row(
                                    children: [
                                      Icon(Icons.speed,
                                          size: 20, color: Colors.deepOrange),
                                      const SizedBox(width: 10),
                                      const Text('Allure 4 (85-90%)'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '5',
                                  child: Row(
                                    children: [
                                      Icon(Icons.speed,
                                          size: 20, color: Colors.red),
                                      const SizedBox(width: 10),
                                      const Text('Allure 5 (90-95%)'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: '6',
                                  child: Row(
                                    children: [
                                      Icon(Icons.speed,
                                          size: 20, color: Colors.deepPurple),
                                      const SizedBox(width: 10),
                                      const Text('Allure Max (100%)'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _allureController.text = value!;
                                });
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Description allure
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: TriathlonColors.swimming.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _getAllureDescription(
                                  int.parse(_allureController.text)),
                              style: TextStyle(
                                color: TriathlonColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          // Information si les données du profil sont utilisées
                          if (_useProfileTime && hasProfileTime)
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    TriathlonColors.swimming.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: TriathlonColors.swimming,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Utilisation du temps 400m du profil',
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
                                backgroundColor: TriathlonColors.swimming,
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

                  // Résultat
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
                                  'RÉSULTAT',
                                  style: TextStyle(
                                    color: TriathlonColors.swimming,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: TriathlonColors.swimming,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          TriathlonColors.swimming
                                              .withOpacity(0.1),
                                          TriathlonColors.swimming
                                              .withOpacity(0.05),
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          _resultText,
                                          style: TextStyle(
                                            color: TriathlonColors.swimming,
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          _getResultDescription(),
                                          style: TextStyle(
                                            color:
                                                TriathlonColors.textSecondary,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
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
                        'RETOUR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).viewPadding.bottom +
                        10, // ← IMPORTANT
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAllureDescription(int allure) {
    switch (allure) {
      case 1:
        return 'Allure 1 (60-70%): Récupération active, natation facile';
      case 2:
        return 'Allure 2 (70-80%): Endurance, conversation possible';
      case 3:
        return 'Allure 3 (80-85%): Seuil aérobie, effort modéré';
      case 4:
        return 'Allure 4 (85-90%): Seuil anaérobie, effort soutenu';
      case 5:
        return 'Allure 5 (90-95%): VO2 Max, effort intense';
      case 6:
        return 'Allure Max (100%): Sprint, effort maximal';
      default:
        return 'Allure non définie';
    }
  }

  String _getResultDescription() {
    int allure = int.parse(_allureController.text);
    if (allure == 6) {
      return 'Temps cible à allure maximale';
    } else {
      return 'Fourchette de temps recommandée';
    }
  }

  void _calculer() {
    // Validation
    if (_temps400mController.text.isEmpty || _distanceController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    try {
      // Parser les valeurs
      double? temps400m = SwimmingCalculator.parseSwimmingTime(
        _temps400mController.text,
      );

      double distance = double.parse(
        _distanceController.text.replaceAll(',', '.'),
      );
      int allure = int.parse(_allureController.text);

      // Validation des valeurs
      if (temps400m <= 0) {
        _showError('Temps au 400m invalide');
        return;
      }

      if (distance <= 0) {
        _showError('Distance invalide');
        return;
      }

      if (allure < 1 || allure > 6) {
        _showError('Allure invalide (1-6)');
        return;
      }

      // Calculer les pourcentages selon l'allure
      double pourcentageMin, pourcentageMax;
      switch (allure) {
        case 1:
          pourcentageMin = 60;
          pourcentageMax = 70;
          break;
        case 2:
          pourcentageMin = 70;
          pourcentageMax = 80;
          break;
        case 3:
          pourcentageMin = 80;
          pourcentageMax = 85;
          break;
        case 4:
          pourcentageMin = 85;
          pourcentageMax = 90;
          break;
        case 5:
          pourcentageMin = 90;
          pourcentageMax = 95;
          break;
        case 6:
          pourcentageMin = 100;
          pourcentageMax = 100;
          break;
        default:
          pourcentageMin = 80;
          pourcentageMax = 85;
      }

      // CORRECTION DU CALCUL : formule correcte
      // Temps pour 100m à 100% = temps_400m / 4
      double timeFor100mAt100Percent = temps400m / 4;

      // Temps pour la distance à 100% = temps_100m * (distance / 100)
      double timeAt100Percent = timeFor100mAt100Percent * (distance / 100);

      // Pour allure 6 (100%), un seul temps
      if (allure == 6) {
        String resultText =
            SwimmingCalculator.formatSwimmingTime(timeAt100Percent);

        setState(() {
          _resultText = resultText;
          _showResult = true;
        });
      } else {
        // CORRECTION : À une intensité plus faible, le temps est PLUS LONG
        // intensité = 80% => temps = temps_100% / 0.80
        double tempsMin = timeAt100Percent / (pourcentageMax / 100);
        double tempsMax = timeAt100Percent / (pourcentageMin / 100);

        String tempsMinStr = SwimmingCalculator.formatSwimmingTime(tempsMin);
        String tempsMaxStr = SwimmingCalculator.formatSwimmingTime(tempsMax);
        String resultText = '$tempsMinStr - $tempsMaxStr';

        setState(() {
          _resultText = resultText;
          _showResult = true;
        });
      }

      // Lancer l'animation
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      _showError('Erreur de calcul: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
