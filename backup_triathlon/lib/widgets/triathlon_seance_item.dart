import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/triathlon_colors.dart';
import '../models/triathlon_seance.dart';
import '../models/sport_type.dart'; // Ajout de cette importation
import '../utils/sport_icons.dart';

class TriathlonSeanceItem extends StatelessWidget {
  final TriathlonSeance seance;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TriathlonSeanceItem({
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: seance.sportType.color,
                width: 5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec sport et date
                Row(
                  children: [
                    // Sport icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: seance.sportType.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          SportIcons.getSportEmoji(seance.sportType),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Informations
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      seance.sportType.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${seance.exercices.length} ex.',
                                  style: TextStyle(
                                    color: seance.sportType.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormatted,
                            style: TextStyle(
                              color: TriathlonColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Résumé
                Text(
                  resume,
                  style: TextStyle(
                    color: TriathlonColors.textPrimary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // Footer avec durée
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: TriathlonColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      seance.getTempsTotalEstime().inMinutes > 0
                          ? '${seance.getTempsTotalEstime().inMinutes} min'
                          : '${seance.getTempsTotalEstime().inSeconds} sec',
                      style: TextStyle(
                        color: TriathlonColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),

                    const Spacer(),

                    // Indicateur de sport
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: seance.sportType.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: seance.sportType.color.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        seance.sportType.name.substring(0, 3),
                        style: TextStyle(
                          color: seance.sportType.color,
                          fontSize: 10,
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
}
