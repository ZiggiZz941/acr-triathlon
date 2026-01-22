import 'package:flutter/material.dart';
import 'package:triathlon_app/models/sport_type.dart';
import '../../../constants/triathlon_colors.dart';
import '../../../constants/triathlon_dimens.dart';
import '../../../models/triathlon_seance.dart';
import '../../../widgets/exercice_liste_widget.dart';

class VisualisationSeanceScreen extends StatelessWidget {
  final TriathlonSeance seance;

  const VisualisationSeanceScreen({super.key, required this.seance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TriathlonColors.background,
      body: Column(
        children: [
          // Titre fixe avec couleur du sport
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: TriathlonDimens.paddingLarge,
              left: TriathlonDimens.paddingLarge,
              right: TriathlonDimens.paddingLarge,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _getGradientForSport(seance.sportType),
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
                    _getSportIcon(seance.sportType),
                    size: TriathlonDimens.iconSizeXXLarge,
                    color: Colors.white,
                  ),
                  const SizedBox(height: TriathlonDimens.paddingMedium),
                  Text(
                    seance.nom,
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
                    maxLines: 2,
                  ),
                  const SizedBox(height: TriathlonDimens.paddingXSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TriathlonDimens.paddingMedium,
                      vertical: TriathlonDimens.paddingXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        TriathlonDimens.borderRadiusLarge,
                      ),
                    ),
                    child: Text(
                      '${seance.exercices.length} exercice(s)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: TriathlonDimens.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu défilant
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations générales
                  Card(
                    elevation: TriathlonDimens.elevationMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        TriathlonDimens.borderRadiusMedium,
                      ),
                    ),
                    color: seance.sportType.color.withOpacity(0.1),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(TriathlonDimens.paddingMedium),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Durée totale estimée',
                                style: TextStyle(
                                  color: seance.sportType.color,
                                  fontSize: TriathlonDimens.fontSizeMedium,
                                ),
                              ),
                              const SizedBox(
                                  height: TriathlonDimens.paddingXSmall),
                              Text(
                                '${seance.getTempsTotalEstime().inMinutes} minutes',
                                style: TextStyle(
                                  color: seance.sportType.color,
                                  fontSize: TriathlonDimens.fontSizeXLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(
                            Icons.timer,
                            color: seance.sportType.color,
                            size: TriathlonDimens.iconSizeXLarge,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: TriathlonDimens.paddingLarge),

                  // Titre exercices
                  Text(
                    'Exercices :',
                    style: TextStyle(
                      color: seance.sportType.color,
                      fontSize: TriathlonDimens.fontSizeXXLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: TriathlonDimens.paddingMedium),

                  // Liste des exercices
                  if (seance.exercices.isEmpty)
                    Card(
                      elevation: TriathlonDimens.elevationSmall,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusMedium,
                        ),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(TriathlonDimens.paddingLarge),
                        child: Column(
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: TriathlonDimens.iconSizeXLarge,
                              color: TriathlonColors.textSecondary,
                            ),
                            const SizedBox(
                                height: TriathlonDimens.paddingMedium),
                            Text(
                              'Aucun exercice dans cette séance',
                              style: TextStyle(
                                color: TriathlonColors.textSecondary,
                                fontSize: TriathlonDimens.fontSizeLarge,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...seance.exercices.map((exercice) {
                      return ExerciceListeWidget(exercice: exercice);
                    }).toList(),

                  const SizedBox(height: TriathlonDimens.paddingXXLarge),
                ],
              ),
            ),
          ),

          // Bouton Retour fixe
          Container(
            padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: TriathlonDimens.elevationMedium,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: TriathlonDimens.buttonHeightLarge,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: seance.sportType.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      TriathlonDimens.borderRadiusXLarge,
                    ),
                  ),
                  elevation: TriathlonDimens.elevationLarge,
                ),
                child: const Text(
                  'RETOUR AU MENU',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour obtenir l'icône du sport
  IconData _getSportIcon(SportType sportType) {
    switch (sportType) {
      case SportType.swimming:
        return Icons.pool;
      case SportType.cycling:
        return Icons.directions_bike;
      case SportType.running:
        return Icons.directions_run;
    }
  }

  // Méthode pour obtenir le gradient approprié
  List<Color> _getGradientForSport(SportType sportType) {
    switch (sportType) {
      case SportType.swimming:
        return TriathlonColors.swimmingGradient;
      case SportType.cycling:
        return TriathlonColors.cyclingGradient;
      case SportType.running:
        return TriathlonColors.runningGradient;
    }
  }
}
