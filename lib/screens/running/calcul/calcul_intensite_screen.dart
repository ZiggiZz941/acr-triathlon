import 'package:flutter/material.dart';
import '../../../constants/triathlon_colors.dart';
import '../../../constants/triathlon_dimens.dart';

class CalculIntensiteScreen extends StatefulWidget {
  const CalculIntensiteScreen({super.key});

  @override
  _CalculIntensiteScreenState createState() => _CalculIntensiteScreenState();
}

class _CalculIntensiteScreenState extends State<CalculIntensiteScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _tempsController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _intensiteController = TextEditingController();
  String _resultText = '--:--.--';
  bool _showResult = false;

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
        curve: Curves.bounceOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tempsController.dispose();
    _distanceController.dispose();
    _intensiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  'Calcul par intensité',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: TriathlonDimens.fontSizeXXXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Convertir un temps à une intensité donnée',
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
                          // Temps
                          Text(
                            'Temps de référence',
                            style: TextStyle(
                              color: TriathlonColors.running,
                              fontSize: TriathlonDimens.fontSizeXLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: TriathlonDimens.paddingSmall),
                          TextField(
                            controller: _tempsController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Ex: 12.50 ou 1:12.50',
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
                              hintText: 'Ex: 100',
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

                          // Intensité
                          Text(
                            'Intensité (%)',
                            style: TextStyle(
                              color: TriathlonColors.running,
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
                              fillColor: Colors.white,
                              hintText: 'Ex: 80.0',
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
    // Récupérer les valeurs
    String tempsStr = _tempsController.text.trim();
    String distanceStr = _distanceController.text.trim();
    String intensiteStr = _intensiteController.text.trim();

    // Validation
    if (tempsStr.isEmpty || distanceStr.isEmpty || intensiteStr.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    // Parser les valeurs
    double? distance = _parseDouble(distanceStr);
    double? intensite = _parseDouble(intensiteStr);

    if (distance == null || intensite == null) {
      _showError('Valeurs numériques invalides');
      return;
    }

    if (intensite <= 0 || intensite > 100) {
      _showError('L\'intensité doit être entre 1 et 100%');
      return;
    }

    // Convertir le temps (format mm:ss.xx ou ss.xx)
    double tempsSecondes = _convertirTempsEnSecondes(tempsStr);
    if (tempsSecondes < 0) {
      _showError('Format de temps invalide. Utilisez mm:ss.xx ou ss.xx');
      return;
    }

    // Calcul : Temps à l'intensité = (Temps * 100) / Intensité
    double tempsFinal = (tempsSecondes * 100.0) / intensite;

    // Formater le résultat
    String resultText = _formatResultAvecCentiemes(tempsFinal);

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
  }

  double _convertirTempsEnSecondes(String tempsStr) {
    try {
      // Si le temps contient ':' (format mm:ss.xx)
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
      // Sinon, c'est en secondes (format ss.xx)
      double secondes = _parseDouble(tempsStr) ?? 0;
      if (secondes < 0) {
        return -1;
      }
      return secondes;
    } catch (e) {
      return -1; // Erreur
    }
  }

  String _formatResultAvecCentiemes(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    double secondesDecimal = seconds % 60;

    // Correction: gérer le cas où secondesDecimal >= 60
    if (secondesDecimal >= 60) {
      minutes += (secondesDecimal ~/ 60).toInt();
      secondesDecimal = secondesDecimal % 60;
    }

    // Formater avec 2 décimales
    if (minutes > 0) {
      return '${minutes}:${secondesDecimal.toStringAsFixed(2).padLeft(5, '0')}';
    } else {
      return '${secondesDecimal.toStringAsFixed(2)} sec';
    }
  }

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    try {
      // Gérer la virgule française
      value = value.replaceAll(',', '.');
      return double.parse(value);
    } catch (e) {
      return null;
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
