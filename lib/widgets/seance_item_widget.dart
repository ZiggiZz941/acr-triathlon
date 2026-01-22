import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:triathlon_app/constants/triathlon_strings.dart';
import '../constants/triathlon_colors.dart'; // CHANGER
import '../constants/triathlon_dimens.dart'; // CHANGER
import '../models/triathlon_seance.dart';
import '../models/sport_type.dart';

class SeanceItemWidget extends StatelessWidget {
  final TriathlonSeance seance;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const SeanceItemWidget({
    super.key,
    required this.seance,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Formater la date
    DateFormat sdf = DateFormat("dd/MM/yyyy HH:mm");
    String dateFormatted = sdf.format(seance.dateCreation);

    // Limiter le résumé
    String resume = seance.getResume();
    if (resume.length > 100) {
      resume = '${resume.substring(0, 97)}...';
    }

    return Card(
      elevation: TriathlonDimens.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TriathlonDimens.borderRadiusMedium),
      ),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: TriathlonDimens.paddingMedium),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(TriathlonDimens.borderRadiusMedium),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: seance.sportType.color,
                width: TriathlonDimens.borderWidthThick,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec type de sport
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: seance.sportType.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          _getSportIcon(seance.sportType),
                          color: seance.sportType.color,
                          size: TriathlonDimens.iconSizeMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: TriathlonDimens.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  seance.nom,
                                  style: TextStyle(
                                    color: TriathlonColors.textPrimary,
                                    fontSize: TriathlonDimens.fontSizeXLarge,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: TriathlonDimens.paddingSmall,
                                  vertical: TriathlonDimens.paddingXSmall,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      seance.sportType.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    TriathlonDimens.borderRadiusSmall,
                                  ),
                                  border: Border.all(
                                    color:
                                        seance.sportType.color.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  '${seance.exercices.length} ex.',
                                  style: TextStyle(
                                    color: seance.sportType.color,
                                    fontSize: TriathlonDimens.fontSizeSmall,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: TriathlonDimens.paddingXSmall),
                          Text(
                            dateFormatted,
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

                // Résumé des exercices
                Text(
                  resume,
                  style: TextStyle(
                    color: TriathlonColors.textPrimary,
                    fontSize: TriathlonDimens.fontSizeMedium,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: TriathlonDimens.paddingMedium),

                // Footer avec durée
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: TriathlonDimens.iconSizeSmall,
                      color: TriathlonColors.textSecondary,
                    ),
                    const SizedBox(width: TriathlonDimens.paddingXSmall),
                    Text(
                      seance.getTempsTotalEstime().inMinutes > 0
                          ? '${seance.getTempsTotalEstime().inMinutes} ${TriathlonStrings.unitMinutes}'
                          : '${seance.getTempsTotalEstime().inSeconds} ${TriathlonStrings.unitSeconds}',
                      style: TextStyle(
                        color: TriathlonColors.textSecondary,
                        fontSize: TriathlonDimens.fontSizeSmall,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TriathlonDimens.paddingSmall,
                        vertical: TriathlonDimens.paddingXSmall,
                      ),
                      decoration: BoxDecoration(
                        color: seance.sportType.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusSmall,
                        ),
                        border: Border.all(
                          color: seance.sportType.color.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _getSportShortName(seance.sportType),
                        style: TextStyle(
                          color: seance.sportType.color,
                          fontSize: TriathlonDimens.fontSizeXSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

  // Méthode pour obtenir le nom court du sport
  String _getSportShortName(SportType sportType) {
    switch (sportType) {
      case SportType.swimming:
        return 'NAT';
      case SportType.cycling:
        return 'CYC';
      case SportType.running:
        return 'RUN';
    }
  }
}
