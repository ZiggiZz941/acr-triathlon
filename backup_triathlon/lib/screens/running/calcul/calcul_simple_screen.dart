import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/triathlon_colors.dart';
import '../../../constants/triathlon_dimens.dart';
import '../../../constants/triathlon_strings.dart';
import '../../../services/data_manager.dart'; // AJOUT: Importer DataManager

class CalculSimpleScreen extends StatefulWidget {
  const CalculSimpleScreen({super.key});

  @override
  _CalculSimpleScreenState createState() => _CalculSimpleScreenState();
}

class _CalculSimpleScreenState extends State<CalculSimpleScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _vitesseController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  int _selectedAllure = 3; // Allure 3 par défaut
  String _resultText = '--:--.--';
  bool _showResult = false;
  bool _useProfileVMA = false; // AJOUT: Pour utiliser la VMA du profil

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: TriathlonDimens.animationDurationSlow,
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
        curve: Curves.easeInOut,
      ),
    );
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

    // Charger la VMA du profil
    if (profile.containsKey('running_vma')) {
      final vma = profile['running_vma'] as double?;
      if (vma != null) {
        setState(() {
          _vitesseController.text = vma.toStringAsFixed(1);
          _useProfileVMA = true;
        });
        print('VMA chargée depuis profil: ${vma} km/h');
      }
    } else {
      setState(() {
        _vitesseController.text = '16.0'; // Valeur par défaut
        _useProfileVMA = false;
      });
      print('VMA par défaut utilisée: 16.0 km/h');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _vitesseController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final profile = dataManager.getTriathlonProfile();
    final hasProfileVMA =
        profile.containsKey('running_vma') && profile['running_vma'] != null;

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
              left: TriathlonDimens.paddingLarge,
              right: TriathlonDimens.paddingLarge,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: TriathlonColors.runningGradient,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(TriathlonDimens.borderRadiusXLarge),
                bottomRight:
                    Radius.circular(TriathlonDimens.borderRadiusXLarge),
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
                  'Calcul de temps',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: TriathlonDimens.fontSizeXXXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Calcul basé sur la vitesse et l\'allure',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: TriathlonDimens.fontSizeLarge,
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
                  // Carte formulaire
                  Card(
                    elevation: TriathlonDimens.elevationXLarge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        TriathlonDimens.borderRadiusLarge,
                      ),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(TriathlonDimens.paddingXLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vitesse avec switch
                          if (hasProfileVMA)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Vitesse (km/h)',
                                    style: TextStyle(
                                      color: TriathlonColors.running,
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
                                        color: TriathlonColors.running,
                                        fontSize: TriathlonDimens.fontSizeSmall,
                                      ),
                                    ),
                                    Switch(
                                      value: _useProfileVMA,
                                      onChanged: (value) {
                                        setState(() {
                                          _useProfileVMA = value;
                                          if (value) {
                                            _loadProfileData();
                                          } else {
                                            _vitesseController.text = '16.0';
                                          }
                                        });
                                      },
                                      activeColor: TriathlonColors.running,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          else
                            Text(
                              'Vitesse (km/h)',
                              style: TextStyle(
                                color: TriathlonColors.running,
                                fontSize: TriathlonDimens.fontSizeXLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          const SizedBox(height: TriathlonDimens.paddingSmall),
                          TextField(
                            controller: _vitesseController,
                            enabled: !_useProfileVMA || !hasProfileVMA,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _useProfileVMA && hasProfileVMA
                                  ? TriathlonColors.running.withOpacity(0.1)
                                  : Colors.white,
                              hintText: _useProfileVMA && hasProfileVMA
                                  ? 'VMA du profil utilisée'
                                  : 'Ex: 16.0',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  TriathlonDimens.borderRadiusMedium,
                                ),
                                borderSide: BorderSide(
                                  color: TriathlonColors.running,
                                  width: TriathlonDimens.borderWidth,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: TriathlonDimens.paddingMedium,
                                vertical: TriathlonDimens.paddingMedium,
                              ),
                              suffixIcon: hasProfileVMA && !_useProfileVMA
                                  ? IconButton(
                                      icon: const Icon(Icons.refresh),
                                      onPressed: () {
                                        setState(() {
                                          _useProfileVMA = true;
                                          _loadProfileData();
                                        });
                                      },
                                      tooltip: 'Utiliser la VMA du profil',
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(height: TriathlonDimens.paddingLarge),

                          // Distance
                          Text(
                            'Distance (mètres)',
                            style: TextStyle(
                              color: TriathlonColors.running,
                              fontSize: TriathlonDimens.fontSizeXLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: TriathlonDimens.paddingSmall),
                          TextField(
                            controller: _distanceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Ex: 1000',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  TriathlonDimens.borderRadiusMedium,
                                ),
                                borderSide: BorderSide(
                                  color: TriathlonColors.running,
                                  width: TriathlonDimens.borderWidth,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: TriathlonDimens.paddingMedium,
                                vertical: TriathlonDimens.paddingMedium,
                              ),
                            ),
                          ),

                          const SizedBox(height: TriathlonDimens.paddingLarge),

                          // Allure
                          Text(
                            'Allure',
                            style: TextStyle(
                              color: TriathlonColors.running,
                              fontSize: TriathlonDimens.fontSizeXLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: TriathlonDimens.paddingSmall),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: TriathlonColors.running,
                                width: TriathlonDimens.borderWidth,
                              ),
                              borderRadius: BorderRadius.circular(
                                TriathlonDimens.borderRadiusMedium,
                              ),
                            ),
                            child: DropdownButtonFormField<int>(
                              value: _selectedAllure,
                              items:
                                  TriathlonStrings.allures.asMap().entries.map((
                                entry,
                              ) {
                                return DropdownMenuItem<int>(
                                  value: entry.key,
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      color: TriathlonColors.textPrimary,
                                      fontSize: TriathlonDimens.fontSizeLarge,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedAllure = value!;
                                });
                              },
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: TriathlonDimens.paddingMedium,
                                  vertical: TriathlonDimens.paddingMedium,
                                ),
                              ),
                            ),
                          ),

                          // Information si les données du profil sont utilisées
                          if (_useProfileVMA && hasProfileVMA)
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: TriathlonColors.running.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: TriathlonColors.running,
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

                          const SizedBox(height: TriathlonDimens.paddingXLarge),

                          // Bouton Calculer
                          SizedBox(
                            width: double.infinity,
                            height: TriathlonDimens.buttonHeightLarge,
                            child: ElevatedButton(
                              onPressed: _calculer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TriathlonColors.running,
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

                  const SizedBox(height: TriathlonDimens.paddingLarge),

                  // Carte résultat
                  AnimatedOpacity(
                    opacity: _showResult ? 1.0 : 0.0,
                    duration: TriathlonDimens.animationDurationMedium,
                    child: AnimatedContainer(
                      duration: TriathlonDimens.animationDurationMedium,
                      height: _showResult ? null : 0,
                      child: Card(
                        elevation: TriathlonDimens.elevationXLarge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TriathlonDimens.borderRadiusLarge,
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(
                            TriathlonDimens.paddingXLarge,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RÉSULTAT',
                                style: TextStyle(
                                  color: TriathlonColors.running,
                                  fontSize: TriathlonDimens.fontSizeXXLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                  height: TriathlonDimens.paddingLarge),
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  width: double.infinity,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: TriathlonColors.running,
                                      width: TriathlonDimens.borderWidth,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      TriathlonDimens.borderRadiusMedium,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _resultText,
                                      style: TextStyle(
                                        color: TriathlonColors.running,
                                        fontSize:
                                            TriathlonDimens.fontSizeXXXLarge,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        foregroundColor: TriathlonColors.running,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TriathlonDimens.borderRadiusXLarge,
                          ),
                          side: BorderSide(
                            color: TriathlonColors.running,
                            width: TriathlonDimens.borderWidth,
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

  void _calculer() {
    // Valider les entrées
    if (_vitesseController.text.isEmpty ||
        _distanceController.text.isEmpty ||
        _selectedAllure == 0) {
      _showError(TriathlonStrings.fillAllFields);
      return;
    }

    try {
      double vitesseKmh = double.parse(
        _vitesseController.text.replaceAll(',', '.'),
      );
      double distance = double.parse(
        _distanceController.text.replaceAll(',', '.'),
      );

      // Calculer les pourcentages selon l'allure
      double pourcentageMin, pourcentageMax;
      switch (_selectedAllure) {
        case 1: // Allure 1
          pourcentageMin = 60;
          pourcentageMax = 70;
          break;
        case 2: // Allure 2
          pourcentageMin = 70;
          pourcentageMax = 80;
          break;
        case 3: // Allure 3
          pourcentageMin = 80;
          pourcentageMax = 85;
          break;
        case 4: // Allure 4
          pourcentageMin = 85;
          pourcentageMax = 90;
          break;
        case 5: // Allure 5
          pourcentageMin = 90;
          pourcentageMax = 95;
          break;
        case 6: // VMA
          pourcentageMin = 100;
          pourcentageMax = 100;
          break;
        default:
          pourcentageMin = 80;
          pourcentageMax = 85;
      }

      // Calcul du temps de base (100%)
      double vitesseMs = vitesseKmh / 3.6;
      double tempsBase100 = distance / vitesseMs;

      // Calcul des temps min et max selon la tranche
      double tempsMax = tempsBase100 / (pourcentageMin / 100.0);
      double tempsMin = tempsBase100 / (pourcentageMax / 100.0);

      // Formater les résultats AVEC CENTIÈMES
      String tempsMinFormatted = _formatTimeAvecCentiemes(tempsMin);
      String tempsMaxFormatted = _formatTimeAvecCentiemes(tempsMax);

      // Préparer le texte du résultat
      String resultText;
      if (pourcentageMin == pourcentageMax) {
        resultText = 'Temps : $tempsMinFormatted';
      } else {
        resultText = 'Zone : $tempsMinFormatted à $tempsMaxFormatted';
      }

      // Mettre à jour l'état avec animation
      setState(() {
        _resultText = resultText;
        if (!_showResult) {
          _showResult = true;
        }
      });

      // Lancer l'animation
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      _showError('Valeurs numériques invalides');
    }
  }

  String _formatTimeAvecCentiemes(double seconds) {
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
