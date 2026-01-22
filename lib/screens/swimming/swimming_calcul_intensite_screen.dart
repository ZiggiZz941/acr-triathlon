import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/triathlon_colors.dart';
import '../../constants/triathlon_dimens.dart';
import '../../services/data_manager.dart';
import '../../services/swimming_calculation_service.dart';

class SwimmingCalculIntensiteScreen extends StatefulWidget {
  const SwimmingCalculIntensiteScreen({super.key});

  @override
  _SwimmingCalculIntensiteScreenState createState() =>
      _SwimmingCalculIntensiteScreenState();
}

class _SwimmingCalculIntensiteScreenState
    extends State<SwimmingCalculIntensiteScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _temps400mController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _intensiteController = TextEditingController();

  String _resultText = '--:--.--';
  bool _showResult = false;
  bool _useProfileTime = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final SwimmingCalculationService _calculationService =
      SwimmingCalculationService();

  @override
  void initState() {
    super.initState();

    // Initialiser l'animation
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

    _intensiteController.text = '80.0';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileTime();
  }

  void _loadProfileTime() {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final profileTime = dataManager.getSwimming400mTime();

    if (profileTime != null) {
      final formattedTime = _calculationService.formatSwimmingTime(profileTime);
      setState(() {
        _temps400mController.text = formattedTime;
        _useProfileTime = true;
      });
    }
  }

  // SUPPRIMEZ cette méthode car elle est maintenant dans le service
  // String _formatSwimmingTime(double seconds) {
  //   return _calculationService.formatSwimmingTime(seconds);
  // }

  double? _parseSwimmingTime(String timeStr) {
    return _calculationService.parseSwimmingTime(timeStr);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _temps400mController.dispose();
    _distanceController.dispose();
    _intensiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final profileTime = dataManager.getSwimming400mTime();
    final hasProfileTime = profileTime != null;

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
                colors: TriathlonColors.swimmingGradient,
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
                    Icons.pool,
                    size: TriathlonDimens.iconSizeXXLarge,
                    color: Colors.white,
                  ),
                  const SizedBox(height: TriathlonDimens.paddingMedium),
                  Text(
                    'Calcul Natation par Intensité',
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
                    'Basé sur votre temps au 400m',
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
                          // Section Temps au 400m avec option profil
                          if (hasProfileTime)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Temps au 400m',
                                    style: TextStyle(
                                      color: TriathlonColors.swimming,
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
                                        color: TriathlonColors.swimming,
                                        fontSize: TriathlonDimens.fontSizeSmall,
                                      ),
                                    ),
                                    Switch(
                                      value: _useProfileTime,
                                      onChanged: (value) {
                                        setState(() {
                                          _useProfileTime = value;
                                          if (value) {
                                            _loadProfileTime();
                                          } else {
                                            _temps400mController.clear();
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
                                fontSize: TriathlonDimens.fontSizeXLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          const SizedBox(height: TriathlonDimens.paddingSmall),

                          TextField(
                            controller: _temps400mController,
                            enabled: !_useProfileTime || !hasProfileTime,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _useProfileTime && hasProfileTime
                                  ? TriathlonColors.swimming.withOpacity(0.1)
                                  : TriathlonColors.background,
                              hintText: _useProfileTime && hasProfileTime
                                  ? 'Utilisation du temps du profil'
                                  : 'Ex: 6:30.50 (mm:ss.xx)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  TriathlonDimens.borderRadiusMedium,
                                ),
                                borderSide: BorderSide(
                                  color: TriathlonColors.swimming,
                                  width: TriathlonDimens.borderWidth,
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
                                          _loadProfileTime();
                                        });
                                      },
                                      tooltip: 'Utiliser le temps du profil',
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: TriathlonDimens.paddingMedium,
                                vertical: TriathlonDimens.paddingMedium,
                              ),
                            ),
                          ),

                          if (!hasProfileTime)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: TriathlonDimens.paddingSmall),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.orange,
                                    size: TriathlonDimens.iconSizeSmall,
                                  ),
                                  const SizedBox(
                                      width: TriathlonDimens.paddingSmall),
                                  Expanded(
                                    child: Text(
                                      'Aucun temps défini dans le profil. '
                                      'Veuillez saisir manuellement ou définir un temps dans le profil.',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: TriathlonDimens.fontSizeSmall,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/profile');
                                    },
                                    child: Text(
                                      'PROFIL',
                                      style: TextStyle(
                                        color: TriathlonColors.swimming,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: TriathlonDimens.paddingLarge),

                          // Distance
                          Text(
                            'Distance (mètres)',
                            style: TextStyle(
                              color: TriathlonColors.swimming,
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
                              fillColor: TriathlonColors.background,
                              hintText: 'Ex: 100, 200, 400, 800...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  TriathlonDimens.borderRadiusMedium,
                                ),
                                borderSide: BorderSide(
                                  color: TriathlonColors.swimming,
                                  width: TriathlonDimens.borderWidth,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.linear_scale,
                                color: TriathlonColors.swimming,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: TriathlonDimens.paddingMedium,
                                vertical: TriathlonDimens.paddingMedium,
                              ),
                            ),
                          ),

                          const SizedBox(height: TriathlonDimens.paddingLarge),

                          // Intensité
                          Text(
                            'Intensité (%)',
                            style: TextStyle(
                              color: TriathlonColors.swimming,
                              fontSize: TriathlonDimens.fontSizeXLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: TriathlonDimens.paddingSmall),
                          TextField(
                            controller: _intensiteController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: TriathlonColors.background,
                              hintText: 'Ex: 80.0 (pour 80%)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  TriathlonDimens.borderRadiusMedium,
                                ),
                                borderSide: BorderSide(
                                  color: TriathlonColors.swimming,
                                  width: TriathlonDimens.borderWidth,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.speed,
                                color: TriathlonColors.swimming,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: TriathlonDimens.paddingMedium,
                                vertical: TriathlonDimens.paddingMedium,
                              ),
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
                                backgroundColor: TriathlonColors.swimming,
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
                                'RÉSULTAT',
                                style: TextStyle(
                                  color: TriathlonColors.swimming,
                                  fontSize: TriathlonDimens.fontSizeXXLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                  height: TriathlonDimens.paddingMedium),
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(
                                      TriathlonDimens.paddingLarge),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: TriathlonColors.swimming,
                                      width: TriathlonDimens.borderWidth,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      TriathlonDimens.borderRadiusMedium,
                                    ),
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
                                          fontSize:
                                              TriathlonDimens.fontSizeXXXLarge,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: TriathlonDimens.paddingSmall),
                                      Text(
                                        'Temps estimé',
                                        style: TextStyle(
                                          color: TriathlonColors.textSecondary,
                                          fontSize:
                                              TriathlonDimens.fontSizeMedium,
                                        ),
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

                  const SizedBox(height: TriathlonDimens.paddingXXLarge),

                  // Bouton Retour
                  SizedBox(
                    width: double.infinity,
                    height: TriathlonDimens.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: TriathlonColors.swimming,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TriathlonDimens.borderRadiusXLarge,
                          ),
                          side: BorderSide(
                            color: TriathlonColors.swimming,
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

  void _calculer() {
    // Validation
    if ((!_useProfileTime && _temps400mController.text.isEmpty) ||
        _distanceController.text.isEmpty ||
        _intensiteController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    try {
      double time400m;

      // Utiliser le temps du profil si activé
      if (_useProfileTime) {
        final dataManager = Provider.of<DataManager>(context, listen: false);
        final profileTime = dataManager.getSwimming400mTime();

        if (profileTime == null) {
          _showError('Aucun temps défini dans le profil');
          return;
        }

        time400m = profileTime;
      } else {
        // Parser le temps saisi manuellement
        final parsedTime = _parseSwimmingTime(_temps400mController.text);
        if (parsedTime == null) {
          _showError('Format de temps invalide. Utilisez mm:ss.xx');
          return;
        }
        time400m = parsedTime;
      }

      // Parser les autres valeurs
      double distance = double.parse(
        _distanceController.text.replaceAll(',', '.'),
      );
      double intensity = double.parse(
        _intensiteController.text.replaceAll(',', '.'),
      );

      // Validation des valeurs
      if (time400m <= 0) {
        _showError('Temps au 400m invalide');
        return;
      }

      if (distance <= 0) {
        _showError('Distance invalide');
        return;
      }

      if (intensity <= 0 || intensity > 100) {
        _showError('L\'intensité doit être entre 1 et 100%');
        return;
      }

      // Calculer le temps
      final calculatedTime = _calculationService.calculateTimeForDistance(
        base400mTime: time400m,
        distance: distance,
        intensityPercent: intensity,
      );

      if (calculatedTime == null) {
        _showError('Impossible de calculer le temps');
        return;
      }

      // Formater le résultat
      final formattedResult =
          _calculationService.formatSwimmingTime(calculatedTime);

      setState(() {
        _resultText = formattedResult;
        _showResult = true;
      });

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
