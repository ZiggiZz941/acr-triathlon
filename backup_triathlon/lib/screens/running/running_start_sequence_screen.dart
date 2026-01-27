// lib/screens/running/running_start_sequence_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../constants/triathlon_colors.dart';
import '../../constants/triathlon_dimens.dart';

class RunningStartSequenceScreen extends StatefulWidget {
  const RunningStartSequenceScreen({super.key});

  @override
  _RunningStartSequenceScreenState createState() =>
      _RunningStartSequenceScreenState();
}

class _RunningStartSequenceScreenState
    extends State<RunningStartSequenceScreen> {
  // Contrôleurs
  final TextEditingController _attenteController = TextEditingController();
  final TextEditingController _avantPretController = TextEditingController();
  final TextEditingController _avantPartezController = TextEditingController();
  final TextEditingController _variationController = TextEditingController();

  // Valeurs
  double _tempsAttente = 2.0;
  double _tempsAvantPret = 4.0;
  double _tempsAvantPartez = 2.0;
  double _variationPartez = 0.5;

  // État
  bool _sequenceEnCours = false;
  bool _pretJoue = false;
  bool _partezJoue = false;
  String _etapeActuelle = 'Prêt à démarrer';
  double _tempsRestant = 0;
  double _tempsPartezAleatoire = 0;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _attenteController.text = _tempsAttente.toStringAsFixed(1);
    _avantPretController.text = _tempsAvantPret.toStringAsFixed(1);
    _avantPartezController.text = _tempsAvantPartez.toStringAsFixed(1);
    _variationController.text = _variationPartez.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  // DÉMARRER LA SÉQUENCE COMPLÈTE
  void _demarrerSequence() {
    if (_sequenceEnCours) return;

    // Lire les valeurs
    _tempsAttente = double.parse(_attenteController.text.replaceAll(',', '.'));
    _tempsAvantPret =
        double.parse(_avantPretController.text.replaceAll(',', '.'));
    _tempsAvantPartez =
        double.parse(_avantPartezController.text.replaceAll(',', '.'));
    _variationPartez =
        double.parse(_variationController.text.replaceAll(',', '.'));

    // Générer le temps aléatoire pour Partez
    final random = Random();
    double variation =
        (random.nextDouble() * 2 * _variationPartez) - _variationPartez;
    _tempsPartezAleatoire = (_tempsAvantPartez + variation).clamp(0.5, 10.0);

    setState(() {
      _sequenceEnCours = true;
      _pretJoue = false;
      _partezJoue = false;
      _etapeActuelle = 'Attente initiale...';
      _tempsRestant = _tempsAttente;
    });

    // COMMENCER LA SÉQUENCE
    _executerEtape1();
  }

  // ÉTAPE 1: Attente initiale
  void _executerEtape1() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_sequenceEnCours) {
        timer.cancel();
        return;
      }

      setState(() {
        _tempsRestant -= 0.1;
        if (_tempsRestant <= 0) {
          _tempsRestant = 0;
          timer.cancel();
          _executerEtape2(); // Passer à l'étape 2
        }
      });
    });
  }

  // ÉTAPE 2: Jouer "À vos marques" + démarrer délai avant "Prêt"
  void _executerEtape2() async {
    // Jouer le son "À vos marques"
    await _jouerSon('a_vos_marques');

    setState(() {
      _etapeActuelle = 'À vos marques !';
      _tempsRestant = _tempsAvantPret;
    });

    // Démarrer le délai avant "Prêt"
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_sequenceEnCours) {
        timer.cancel();
        return;
      }

      setState(() {
        _tempsRestant -= 0.1;
        if (_tempsRestant <= 0) {
          _tempsRestant = 0;
          timer.cancel();
          _executerEtape3(); // Passer à l'étape 3
        }
      });
    });
  }

  // ÉTAPE 3: Jouer "Prêt" + démarrer délai avant "Partez"
  void _executerEtape3() async {
    // Jouer le son "Prêt"
    await _jouerSon('pret');

    setState(() {
      _etapeActuelle = 'Prêt !';
      _pretJoue = true;
      _tempsRestant = _tempsPartezAleatoire;
    });

    // Démarrer le délai avant "Partez" (avec temps aléatoire)
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_sequenceEnCours) {
        timer.cancel();
        return;
      }

      setState(() {
        _tempsRestant -= 0.1;
        if (_tempsRestant <= 0) {
          _tempsRestant = 0;
          timer.cancel();
          _executerEtape4(); // Passer à l'étape 4
        }
      });
    });
  }

  // ÉTAPE 4: Jouer "Partez" + fin
  void _executerEtape4() async {
    // Jouer le son "Partez"
    await _jouerSon('partez');

    setState(() {
      _etapeActuelle = 'PARTEZ !';
      _partezJoue = true;
    });

    // Attendre 3 secondes puis réinitialiser
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      _reinitialiser();
    }
  }

  // JOUER UN SON
  Future<void> _jouerSon(String nom) async {
    try {
      await _audioPlayer.play(AssetSource('audio/$nom.mp3'));
    } catch (e) {
      print('Erreur audio $nom: $e');
    }
  }

  // ARRÊTER
  void _arreter() {
    _timer?.cancel();
    setState(() {
      _sequenceEnCours = false;
      _etapeActuelle = 'Arrêté';
      _tempsRestant = 0;
    });
  }

  // RÉINITIALISER
  void _reinitialiser() {
    _arreter();
    setState(() {
      _etapeActuelle = 'Prêt à démarrer';
      _pretJoue = false;
      _partezJoue = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TriathlonColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: TriathlonColors.runningGradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: TriathlonDimens.elevationMedium,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'SÉQUENCE DE DÉPART',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: TriathlonDimens.fontSizeXXXLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: TriathlonDimens.paddingXSmall),
                  Text(
                    'Départ par starter',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: TriathlonDimens.fontSizeSmall,
                    ),
                  ),
                ],
              ),
            ),

            // CONTENU
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
                child: Column(
                  children: [
                    // CONFIGURATION
                    Card(
                      elevation: TriathlonDimens.elevationMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusLarge,
                        ),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(TriathlonDimens.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CONFIGURATION DES TEMPS',
                              style: TextStyle(
                                fontSize: TriathlonDimens.fontSizeXLarge,
                                fontWeight: FontWeight.bold,
                                color: TriathlonColors.running,
                              ),
                            ),
                            SizedBox(height: TriathlonDimens.paddingLarge),

                            // 1. Attente initiale
                            _buildParametre(
                              label: 'Attente avant "À vos marques"',
                              controller: _attenteController,
                              hint: 'Secondes de silence avant le 1er son',
                              valeur: _tempsAttente,
                            ),

                            SizedBox(height: TriathlonDimens.paddingMedium),

                            // 2. Délai avant "Prêt"
                            _buildParametre(
                              label: 'Délai avant "Prêt"',
                              controller: _avantPretController,
                              hint: 'Délai après "À vos marques"',
                              valeur: _tempsAvantPret,
                            ),

                            SizedBox(height: TriathlonDimens.paddingMedium),

                            // 3. Délai avant "Partez"
                            _buildParametre(
                              label: 'Délai avant "Partez"',
                              controller: _avantPartezController,
                              hint: 'Délai de base après "Prêt"',
                              valeur: _tempsAvantPartez,
                            ),

                            SizedBox(height: TriathlonDimens.paddingMedium),

                            // 4. Variation aléatoire
                            _buildParametre(
                              label: 'Variation aléatoire "Partez"',
                              controller: _variationController,
                              hint: '± secondes autour du délai de base',
                              valeur: _variationPartez,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: TriathlonDimens.paddingXLarge),

                    // AFFICHAGE SÉQUENCE
                    if (_sequenceEnCours)
                      Card(
                        elevation: TriathlonDimens.elevationMedium,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TriathlonDimens.borderRadiusLarge,
                          ),
                        ),
                        child: Container(
                          padding:
                              EdgeInsets.all(TriathlonDimens.paddingXLarge),
                          width: double.infinity,
                          child: Column(
                            children: [
                              // ÉTAPE ACTUELLE
                              Text(
                                _etapeActuelle,
                                style: TextStyle(
                                  fontSize: TriathlonDimens.fontSizeXXXLarge,
                                  fontWeight: FontWeight.bold,
                                  color: _partezJoue
                                      ? Colors.red
                                      : _pretJoue
                                          ? Colors.orange
                                          : TriathlonColors.running,
                                ),
                              ),

                              SizedBox(height: TriathlonDimens.paddingXLarge),

                              // INDICATEURS DES SONS JOUÉS
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildIndicateurSon('À vos marques', true),
                                  SizedBox(width: TriathlonDimens.paddingLarge),
                                  _buildIndicateurSon('Prêt', _pretJoue),
                                  SizedBox(width: TriathlonDimens.paddingLarge),
                                  _buildIndicateurSon('Partez', _partezJoue),
                                ],
                              ),

                              SizedBox(height: TriathlonDimens.paddingLarge),

                              // SCHÉMA VISUEL
                            ],
                          ),
                        ),
                      ),

                    SizedBox(height: TriathlonDimens.paddingXXLarge),

                    // BOUTONS DE CONTRÔLE
                    Column(
                      children: [
                        // DÉMARRER / ARRÊTER
                        SizedBox(
                          width: double.infinity,
                          height: TriathlonDimens.buttonHeightLarge,
                          child: ElevatedButton(
                            onPressed:
                                _sequenceEnCours ? _arreter : _demarrerSequence,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _sequenceEnCours
                                  ? Colors.orange
                                  : TriathlonColors.running,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  TriathlonDimens.borderRadiusXLarge,
                                ),
                              ),
                              elevation: TriathlonDimens.elevationMedium,
                            ),
                            child: Text(
                              _sequenceEnCours
                                  ? 'ARRÊTER LA SÉQUENCE'
                                  : 'DÉMARRER LA SÉQUENCE',
                              style: TextStyle(
                                fontSize: TriathlonDimens.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: TriathlonDimens.paddingMedium),

                        // RÉINITIALISER
                        if (_sequenceEnCours)
                          SizedBox(
                            width: double.infinity,
                            height: TriathlonDimens.buttonHeight,
                            child: ElevatedButton(
                              onPressed: _reinitialiser,
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
                              child: Text(
                                'RÉINITIALISER',
                                style: TextStyle(
                                  fontSize: TriathlonDimens.fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: TriathlonDimens.paddingMedium),

                        // RETOUR
                        SizedBox(
                          width: double.infinity,
                          height: TriathlonDimens.buttonHeight,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  TriathlonDimens.borderRadiusXLarge,
                                ),
                              ),
                            ),
                            child: Text(
                              'RETOUR',
                              style: TextStyle(
                                fontSize: TriathlonDimens.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: TriathlonDimens.paddingXXLarge),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParametre({
    required String label,
    required TextEditingController controller,
    required String hint,
    required double valeur,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: TriathlonDimens.fontSizeMedium,
          ),
        ),
        SizedBox(height: TriathlonDimens.paddingXSmall),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          enabled: !_sequenceEnCours,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                TriathlonDimens.borderRadiusMedium,
              ),
              borderSide: BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: _sequenceEnCours ? Colors.grey[100] : Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: TriathlonDimens.paddingMedium,
              vertical: TriathlonDimens.paddingMedium,
            ),
            suffixText: 'secondes',
          ),
        ),
      ],
    );
  }

  Widget _buildIndicateurSon(String texte, bool active) {
    return Column(
      children: [
        Container(
          width: TriathlonDimens.iconSizeXLarge,
          height: TriathlonDimens.iconSizeXLarge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.red : Color(0xFFE0E0E0),
            border: Border.all(
              color: active ? Colors.red : Color(0xFFBDBDBD),
              width: TriathlonDimens.borderWidth,
            ),
          ),
          child: Icon(
            Icons.volume_up,
            color: active ? Colors.white : Color(0xFF9E9E9E),
            size: TriathlonDimens.iconSizeMedium,
          ),
        ),
        SizedBox(height: TriathlonDimens.paddingXSmall),
        Text(
          texte,
          style: TextStyle(
            color: active ? Colors.red : Color(0xFF757575),
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: TriathlonDimens.fontSizeSmall,
          ),
        ),
      ],
    );
  }
}
