// lib/screens/seance/triathlon_visualisation_seance_screen.dart
import 'package:flutter/material.dart';
import 'package:triathlon_app/models/sport_type.dart';
import 'package:triathlon_app/screens/resultat/saisie_resultat_screen.dart';
import '../../models/triathlon_seance.dart';
import '../../constants/triathlon_colors.dart';
import '../../constants/triathlon_dimens.dart';

class TriathlonVisualisationSeanceScreen extends StatelessWidget {
  final TriathlonSeance seance;

  const TriathlonVisualisationSeanceScreen({
    super.key,
    required this.seance,
  });

  @override
  Widget build(BuildContext context) {
    final sportColor = seance.sportType.color;

    return Scaffold(
      backgroundColor: TriathlonColors.background,
      appBar: AppBar(
        backgroundColor: sportColor,
        title: Text(seance.nom),
        elevation: TriathlonDimens.elevationMedium,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations générales
            Card(
              elevation: TriathlonDimens.elevationMedium,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(TriathlonDimens.borderRadiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getSportIcon(seance.sportType),
                          color: sportColor,
                          size: TriathlonDimens.iconSizeLarge,
                        ),
                        const SizedBox(width: TriathlonDimens.paddingMedium),
                        Text(
                          seance.sportType.name,
                          style: TextStyle(
                            color: sportColor,
                            fontSize: TriathlonDimens.fontSizeXLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TriathlonDimens.paddingMedium),
                    Text(
                      'Créée le: ${seance.dateFormatee}',
                      style: TextStyle(
                        color: TriathlonColors.textSecondary,
                        fontSize: TriathlonDimens.fontSizeMedium,
                      ),
                    ),
                    const SizedBox(height: TriathlonDimens.paddingSmall),
                    Text(
                      '${seance.exercices.length} exercice${seance.exercices.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: TriathlonColors.textSecondary,
                        fontSize: TriathlonDimens.fontSizeMedium,
                      ),
                    ),
                    const SizedBox(height: TriathlonDimens.paddingSmall),
                    Text(
                      'Temps total estimé: ${_formatDuration(seance.getTempsTotalEstime())}',
                      style: TextStyle(
                        color: sportColor,
                        fontSize: TriathlonDimens.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TriathlonDimens.paddingLarge),

            // Liste des exercices
            Text(
              'Exercices',
              style: TextStyle(
                color: sportColor,
                fontSize: TriathlonDimens.fontSizeXXLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: TriathlonDimens.paddingMedium),

            ...seance.exercices.map((exercice) {
              return Card(
                margin: const EdgeInsets.only(
                    bottom: TriathlonDimens.paddingMedium),
                elevation: TriathlonDimens.elevationSmall,
                child: Padding(
                  padding: const EdgeInsets.all(TriathlonDimens.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercice.nom,
                        style: TextStyle(
                          color: sportColor,
                          fontSize: TriathlonDimens.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: TriathlonDimens.paddingSmall),
                      Text(
                        exercice.getDescription(),
                        style: TextStyle(
                          color: TriathlonColors.textPrimary,
                          fontSize: TriathlonDimens.fontSizeMedium,
                        ),
                      ),
                      if (exercice.tempsMin > 0)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: TriathlonDimens.paddingSmall),
                          child: Text(
                            'Temps: ${exercice.formatTemps(exercice.tempsMin)}',
                            style: TextStyle(
                              color: TriathlonColors.textSecondary,
                              fontSize: TriathlonDimens.fontSizeSmall,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: sportColor,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SaisieResultatScreen(
                          seance: seance,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sportColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.timer),
                  label: const Text('SAISIR LES RÉSULTATS'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
