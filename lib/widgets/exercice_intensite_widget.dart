import 'package:flutter/material.dart';
import '../models/sport_type.dart';
import '../models/triathlon_exercice.dart';
import '../constants/triathlon_colors.dart';
import '../utils/sport_icons.dart';

class TriathlonExerciceListe extends StatelessWidget {
  final TriathlonExercice exercice;

  const TriathlonExerciceListe({
    super.key,
    required this.exercice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: exercice.sportType.color.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom de l'exercice
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
                    child: Text(
                      SportIcons.getSportEmoji(exercice.sportType),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercice.nom,
                    style: TextStyle(
                      color: exercice.sportType.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description principale
            Text(
              exercice.getDescription(),
              style: TextStyle(
                color: TriathlonColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            // Détails
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Structure
                  Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 16,
                        color: exercice.sportType.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${exercice.nbSeries} séries',
                        style: TextStyle(
                          color: exercice.sportType.color,
                          fontSize: 14,
                        ),
                      ),
                      if (exercice.nbRepetitions > 1) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${exercice.nbRepetitions} répétitions',
                          style: TextStyle(
                            color: exercice.sportType.color,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Distance
                  Row(
                    children: [
                      Icon(
                        Icons.linear_scale,
                        size: 16,
                        color: exercice.sportType.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        exercice
                            .getDistanceFormatee(), // Utiliser la méthode publique du modèle
                        style: TextStyle(
                          color: exercice.sportType.color,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Temps
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: exercice.sportType.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        exercice.tempsMin == exercice.tempsMax
                            ? 'Temps: ${exercice.formatTemps(exercice.tempsMin)}' // Utiliser la méthode du modèle
                            : 'Temps: ${exercice.formatTemps(exercice.tempsMin)} - ${exercice.formatTemps(exercice.tempsMax)}',
                        style: TextStyle(
                          color: exercice.sportType.color,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  // Repos si défini
                  if (exercice.reposRepetitionsSec > 0 ||
                      (exercice.reposSeriesSec > 0 &&
                          exercice.nbSeries > 1)) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.pause,
                          size: 16,
                          color: exercice.sportType.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatRepos(exercice),
                          style: TextStyle(
                            color: exercice.sportType.color,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRepos(TriathlonExercice exercice) {
    List<String> repos = [];

    if (exercice.reposRepetitionsSec > 0) {
      repos.add(
          'rép: ${exercice.reposRepetitionsFormate}'); // Utiliser le getter
    }

    if (exercice.reposSeriesSec > 0 && exercice.nbSeries > 1) {
      repos.add('série: ${exercice.reposSeriesFormate}'); // Utiliser le getter
    }

    return repos.join(' / ');
  }
}
