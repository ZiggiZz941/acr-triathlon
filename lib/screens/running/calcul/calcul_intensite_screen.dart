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
  // Contrôleurs pour les champs séparés
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondesController = TextEditingController();
  final TextEditingController _centiemesController = TextEditingController();

  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _intensiteController = TextEditingController();

  String _resultText = '--:--.--';
  bool _showResult = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialiser avec des valeurs par défaut
    _minutesController.text = '0';
    _secondesController.text = '00';
    _centiemesController.text = '00';

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
    _minutesController.dispose();
    _secondesController.dispose();
    _centiemesController.dispose();
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
                          // Temps de référence (nouveau format avec 3 champs)
                          Text(
                            'Temps de référence',
                            style: TextStyle(
                              color: TriathlonColors.running,
                              fontSize: TriathlonDimens.fontSizeXLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: TriathlonDimens.paddingSmall),
                          Row(
                            children: [
                              // Minutes
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Minutes',
                                      style: TextStyle(
                                        color: TriathlonColors.textSecondary,
                                        fontSize: TriathlonDimens.fontSizeSmall,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _minutesController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        _validerEtCorrigerMinutes();
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: '0',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            TriathlonDimens.borderRadiusMedium,
                                          ),
                                          borderSide: BorderSide(
                                            color: TriathlonColors.running,
                                            width: TriathlonDimens.borderWidth,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal:
                                              TriathlonDimens.paddingSmall,
                                          vertical:
                                              TriathlonDimens.paddingMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Séparateur :
                              Container(
                                alignment: Alignment.bottomCenter,
                                height: 72,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    ':',
                                    style: TextStyle(
                                      color: TriathlonColors.running,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              // Secondes
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Secondes',
                                      style: TextStyle(
                                        color: TriathlonColors.textSecondary,
                                        fontSize: TriathlonDimens.fontSizeSmall,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _secondesController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        _validerEtCorrigerSecondes();
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: '00',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            TriathlonDimens.borderRadiusMedium,
                                          ),
                                          borderSide: BorderSide(
                                            color: TriathlonColors.running,
                                            width: TriathlonDimens.borderWidth,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal:
                                              TriathlonDimens.paddingSmall,
                                          vertical:
                                              TriathlonDimens.paddingMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Séparateur .
                              Container(
                                alignment: Alignment.bottomCenter,
                                height: 72,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    '.',
                                    style: TextStyle(
                                      color: TriathlonColors.running,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              // Centièmes
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Centièmes',
                                      style: TextStyle(
                                        color: TriathlonColors.textSecondary,
                                        fontSize: TriathlonDimens.fontSizeSmall,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _centiemesController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        _validerEtCorrigerCentiemes();
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: '00',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            TriathlonDimens.borderRadiusMedium,
                                          ),
                                          borderSide: BorderSide(
                                            color: TriathlonColors.running,
                                            width: TriathlonDimens.borderWidth,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal:
                                              TriathlonDimens.paddingSmall,
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

                          // Information sur le format
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              'Format: minutes:secondes.centièmes (ex: 1:30.50)',
                              style: TextStyle(
                                color: TriathlonColors.textSecondary,
                                fontSize: TriathlonDimens.fontSizeSmall,
                                fontStyle: FontStyle.italic,
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: TriathlonColors.running,
                                      width: TriathlonDimens.borderWidth,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      TriathlonDimens.borderRadiusMedium,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Affichage principal du résultat
                                      Text(
                                        _resultText,
                                        style: TextStyle(
                                          color: TriathlonColors.running,
                                          fontSize:
                                              TriathlonDimens.fontSizeXXXLarge,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Affichage en secondes avec centièmes
                                      if (_showResult &&
                                          _resultText != '--:--.--')
                                        Text(
                                          '(${_getResultEnSecondes()} secondes)',
                                          style: TextStyle(
                                            color:
                                                TriathlonColors.textSecondary,
                                            fontSize:
                                                TriathlonDimens.fontSizeMedium,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // Information sur le calcul
                              if (_showResult && _resultText != '--:--.--')
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                    'Temps obtenu à ${_intensiteController.text}% de l\'intensité de référence',
                                    style: TextStyle(
                                      color: TriathlonColors.textSecondary,
                                      fontSize: TriathlonDimens.fontSizeSmall,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
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

  // Méthodes de validation et correction automatique
  void _validerEtCorrigerMinutes() {
    try {
      int minutes = int.tryParse(_minutesController.text) ?? 0;
      if (minutes < 0) {
        _minutesController.text = '0';
      } else if (minutes > 59) {
        _minutesController.text = '59';
      }
    } catch (e) {
      _minutesController.text = '0';
    }
  }

  void _validerEtCorrigerSecondes() {
    try {
      int secondes = int.tryParse(_secondesController.text) ?? 0;

      // Si secondes >= 60, ajuster les minutes
      if (secondes >= 60) {
        int minutes = int.tryParse(_minutesController.text) ?? 0;
        int newMinutes = minutes + (secondes ~/ 60);
        secondes = secondes % 60;

        setState(() {
          _minutesController.text = newMinutes.toString();
          _secondesController.text = secondes.toString().padLeft(2, '0');
        });
      } else if (secondes < 0) {
        _secondesController.text = '00';
      } else if (secondes < 10 && _secondesController.text.length == 1) {
        // Formatage à 2 chiffres
        _secondesController.text = '0$secondes';
      }
    } catch (e) {
      _secondesController.text = '00';
    }
  }

  void _validerEtCorrigerCentiemes() {
    try {
      int centiemes = int.tryParse(_centiemesController.text) ?? 0;

      // Si centièmes >= 100, ajuster les secondes
      if (centiemes >= 100) {
        int secondes = int.tryParse(_secondesController.text) ?? 0;
        int minutes = int.tryParse(_minutesController.text) ?? 0;

        secondes += centiemes ~/ 100;
        centiemes = centiemes % 100;

        // Si secondes >= 60 après ajustement, ajuster les minutes
        if (secondes >= 60) {
          minutes += secondes ~/ 60;
          secondes = secondes % 60;
          setState(() {
            _minutesController.text = minutes.toString();
          });
        }

        setState(() {
          _secondesController.text = secondes.toString().padLeft(2, '0');
          _centiemesController.text = centiemes.toString().padLeft(2, '0');
        });
      } else if (centiemes < 0) {
        _centiemesController.text = '00';
      } else if (centiemes < 10 && _centiemesController.text.length == 1) {
        // Formatage à 2 chiffres
        _centiemesController.text = '0$centiemes';
      }
    } catch (e) {
      _centiemesController.text = '00';
    }
  }

  void _calculer() {
    // Récupérer les valeurs
    String minutesStr = _minutesController.text.trim();
    String secondesStr = _secondesController.text.trim();
    String centiemesStr = _centiemesController.text.trim();
    String distanceStr = _distanceController.text.trim();
    String intensiteStr = _intensiteController.text.trim();

    // Validation
    if (minutesStr.isEmpty ||
        secondesStr.isEmpty ||
        centiemesStr.isEmpty ||
        distanceStr.isEmpty ||
        intensiteStr.isEmpty) {
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

    if (distance <= 0) {
      _showError('La distance doit être positive');
      return;
    }

    // Convertir le temps en secondes
    double? tempsSecondes =
        _convertirTempsEnSecondes(minutesStr, secondesStr, centiemesStr);

    if (tempsSecondes == null || tempsSecondes <= 0) {
      _showError('Temps de référence invalide');
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

  double? _convertirTempsEnSecondes(
      String minutes, String secondes, String centiemes) {
    try {
      int minutesInt = int.tryParse(minutes) ?? 0;
      int secondesInt = int.tryParse(secondes) ?? 0;
      int centiemesInt = int.tryParse(centiemes) ?? 0;

      // Validation des plages
      if (minutesInt < 0 ||
          secondesInt < 0 ||
          secondesInt >= 60 ||
          centiemesInt < 0 ||
          centiemesInt >= 100) {
        return null;
      }

      // Calcul du temps total en secondes
      double totalSecondes =
          (minutesInt * 60) + secondesInt + (centiemesInt / 100.0);

      return totalSecondes > 0 ? totalSecondes : null;
    } catch (e) {
      return null;
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

  // Méthode pour obtenir le résultat en secondes
  String _getResultEnSecondes() {
    if (_resultText == '--:--.--') return '0.00';

    try {
      if (_resultText.contains(':')) {
        List<String> parties = _resultText.split(':');
        if (parties.length == 2) {
          int minutes = int.tryParse(parties[0]) ?? 0;
          double secondes = double.tryParse(parties[1]) ?? 0;
          double total = (minutes * 60) + secondes;
          return total.toStringAsFixed(2);
        }
      } else if (_resultText.contains('sec')) {
        String secStr = _resultText.replaceAll(' sec', '');
        return double.tryParse(secStr)?.toStringAsFixed(2) ?? '0.00';
      }
    } catch (e) {
      return '0.00';
    }

    return '0.00';
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
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
