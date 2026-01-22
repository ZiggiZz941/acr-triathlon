import 'package:flutter/material.dart';
import '../constants/triathlon_colors.dart';
import '../constants/triathlon_dimens.dart';
import '../models/triathlon_exercice.dart';
import '../models/sport_type.dart';

class ExerciceListeWidget extends StatelessWidget {
  final TriathlonExercice exercice;

  const ExerciceListeWidget({super.key, required this.exercice});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: TriathlonDimens.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TriathlonDimens.borderRadiusMedium),
      ),
      color: exercice.sportType.color.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: TriathlonDimens.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description principale avec icône
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: exercice.sportType.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Icon(
                      _getSportIcon(exercice.sportType),
                      color: exercice.sportType.color,
                      size: TriathlonDimens.iconSizeMedium,
                    ),
                  ),
                ),
                const SizedBox(width: TriathlonDimens.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercice.nom.isNotEmpty
                            ? exercice.nom
                            : 'Exercice ${exercice.sportType.name}',
                        style: TextStyle(
                          color: exercice.sportType.color,
                          fontSize: TriathlonDimens.fontSizeXLarge,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: TriathlonDimens.paddingXSmall),
                      Text(
                        _getDistanceDescription(),
                        style: TextStyle(
                          color: TriathlonColors.textSecondary,
                          fontSize: TriathlonDimens.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: TriathlonDimens.paddingMedium),

            // Détails de l'exercice
            Container(
              padding: const EdgeInsets.all(TriathlonDimens.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  TriathlonDimens.borderRadiusSmall,
                ),
                border: Border.all(
                  color: exercice.sportType.color.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Structure: ${exercice.nbSeries} × ${exercice.nbRepetitions}',
                    style: TextStyle(
                      color: TriathlonColors.textPrimary,
                      fontSize: TriathlonDimens.fontSizeMedium,
                    ),
                  ),
                  const SizedBox(height: TriathlonDimens.paddingXSmall),
                  Text(
                    'Temps: ${exercice.formatTemps(exercice.tempsMin)}',
                    style: TextStyle(
                      color: TriathlonColors.textPrimary,
                      fontSize: TriathlonDimens.fontSizeMedium,
                    ),
                  ),
                  if (exercice.reposRepetitionsSec > 0)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: TriathlonDimens.paddingXSmall),
                      child: Text(
                        'Repos répétitions: ${TriathlonExercice.formatTempsEnMinutes(exercice.reposRepetitionsSec)}',
                        style: TextStyle(
                          color: TriathlonColors.textSecondary,
                          fontSize: TriathlonDimens.fontSizeSmall,
                        ),
                      ),
                    ),
                  if (exercice.reposSeriesSec > 0 && exercice.nbSeries > 1)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: TriathlonDimens.paddingXSmall),
                      child: Text(
                        'Repos séries: ${TriathlonExercice.formatTempsEnMinutes(exercice.reposSeriesSec)}',
                        style: TextStyle(
                          color: TriathlonColors.textSecondary,
                          fontSize: TriathlonDimens.fontSizeSmall,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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

  // Méthode pour obtenir la description de la distance
  String _getDistanceDescription() {
    if (exercice.distance >= 1000) {
      return '${(exercice.distance / 1000).toStringAsFixed(2)} km';
    } else {
      return '${exercice.distance.toInt()} m';
    }
  }
}
