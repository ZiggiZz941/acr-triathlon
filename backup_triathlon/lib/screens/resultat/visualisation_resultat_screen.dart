import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triathlon_app/models/sport_type.dart';
import '../../models/triathlon_seance.dart';
import '../../models/triathlon_resultat.dart';
import '../../models/triathlon_seance_commentaire.dart';
import '../../services/data_manager.dart';
import '../../constants/triathlon_colors.dart';
import '../../constants/triathlon_dimens.dart';

class VisualisationResultatScreen extends StatelessWidget {
  final TriathlonSeance seance;

  const VisualisationResultatScreen({
    super.key,
    required this.seance,
  });

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final resultats = dataManager.getResultatsForSeance(seance.id);
    final commentaireSeance = dataManager.getCommentaireForSeance(seance.id);
    final sportColor = seance.sportType.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats de la séance'),
        backgroundColor: sportColor,
      ),
      body: resultats.isEmpty
          ? _buildAucunResultat()
          : _buildAvecResultats(resultats, commentaireSeance, sportColor),
    );
  }

  Widget _buildAucunResultat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment,
            size: 80,
            color: TriathlonColors.textSecondary,
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun résultat enregistré',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildAvecResultats(List<TriathlonResultat> resultats,
      TriathlonSeanceCommentaire? commentaireSeance, Color sportColor) {
    final resultatsAvecTemps =
        resultats.where((r) => r.tempsReel != null).toList();

    if (resultatsAvecTemps.isEmpty) {
      return _buildAucunResultat();
    }

    final totalAttendu = seance.exercices.fold(
        0, (sum, exercice) => sum + exercice.nbSeries * exercice.nbRepetitions);
    final pourcentageComplete = totalAttendu > 0
        ? ((resultatsAvecTemps.length / totalAttendu) * 100).toInt()
        : 0;

    // Calculer le pourcentage moyen de performance
    double pourcentagePerformanceMoyen = 0;
    if (resultatsAvecTemps.isNotEmpty) {
      final totalPourcentage = resultatsAvecTemps.fold(
          0.0, (sum, resultat) => sum + resultat.pourcentagePerformance);
      pourcentagePerformanceMoyen =
          totalPourcentage / resultatsAvecTemps.length;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seance.nom,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: sportColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    seance.sportType.displayName,
                    style: TextStyle(
                      color: TriathlonColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Répétitions',
                        '${resultatsAvecTemps.length}/$totalAttendu',
                        Icons.repeat,
                        sportColor,
                      ),
                      _buildStatCard(
                        'Complété',
                        '$pourcentageComplete%',
                        Icons.check_circle,
                        pourcentageComplete >= 100
                            ? Colors.green
                            : Colors.orange,
                      ),
                      // NOUVEAU: Carte pour le pourcentage moyen de performance
                      _buildStatCard(
                        'Performance',
                        '${pourcentagePerformanceMoyen.toStringAsFixed(0)}%',
                        Icons.trending_up,
                        _getPerformanceColor(pourcentagePerformanceMoyen),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (commentaireSeance != null) ...[
            _buildCommentaireSection(commentaireSeance),
            const SizedBox(height: 20),
          ],
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Détail par répétition',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLegende(),
                  const SizedBox(height: 16),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: 400,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: resultatsAvecTemps.length,
                      itemBuilder: (context, index) {
                        final resultat = resultatsAvecTemps[index];
                        return _buildCaseResultat(resultat);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Détail des résultats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...resultatsAvecTemps.map((resultat) {
                    return _buildResultatItem(resultat, sportColor);
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCommentaireSection(TriathlonSeanceCommentaire commentaire) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.comment,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Commentaire de la séance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ajouté le ${commentaire.dateFormatee}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (commentaire.dateModification != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Modifié le ${commentaire.dateModificationFormatee}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Text(
                commentaire.commentaire,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegende() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200] ?? Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance par rapport à la plage :',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.rocket_launch, color: Colors.blue),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Plus rapide que le temps minimum',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Dans la plage des temps attendus',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Plus lent que le temps maximum',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.yellow),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange[800]),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Le pourcentage de performance est calculé par rapport à la plage cible',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseResultat(TriathlonResultat resultat) {
    final iconColor = resultat.couleurPerformance;
    final icon = resultat.iconePerformance;
    final pourcentage = resultat.pourcentagePerformance;

    return Tooltip(
      message: 'S${resultat.serieIndex}R${resultat.repetitionIndex}\n'
          'Réalisé: ${resultat.tempsFormate}\n'
          'Attendu: ${resultat.plageAttendueFormatee}\n'
          'Performance: ${pourcentage.toStringAsFixed(0)}%\n'
          'Statut: ${resultat.statutPerformance}',
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: iconColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(6),
          color: iconColor.withOpacity(0.1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'S${resultat.serieIndex}R${resultat.repetitionIndex}',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 2),
              Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
              const SizedBox(height: 2),
              // NOUVEAU: Affichage du pourcentage avec mise en évidence
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: _getPerformanceColor(pourcentage).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _getPerformanceColor(pourcentage).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${pourcentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getPerformanceColor(pourcentage),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                resultat.statutPerformance,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                  color: iconColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultatItem(TriathlonResultat resultat, Color sportColor) {
    final iconColor = resultat.couleurPerformance;
    final icon = resultat.iconePerformance;
    final statut = resultat.statutPerformance;
    final difference = resultat.differenceTemps;
    final pourcentage = resultat.pourcentagePerformance;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: iconColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: iconColor.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: iconColor, size: 20),
                      const SizedBox(height: 2),
                      // NOUVEAU: Pourcentage dans l'icône
                      Text(
                        '${pourcentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Réalisé: ${resultat.tempsFormate}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Attendu: ${resultat.plageAttendueFormatee}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TriathlonColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            children: [
                              Text(
                                statut,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: iconColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // NOUVEAU: Pourcentage mis en évidence
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.yellow.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${pourcentage.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ),
                              Text(
                                _formatDifference(difference),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: iconColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'S${resultat.serieIndex}R${resultat.repetitionIndex} • ${resultat.dateFormatee}',
                      style: TextStyle(
                        fontSize: 11,
                        color: TriathlonColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (resultat.tempsAttenduMin != resultat.tempsAttenduMax)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.info, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Temps min: ${resultat.tempsAttenduMinFormate} • max: ${resultat.tempsAttenduMaxFormate}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String titre, String valeur, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            valeur,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            titre,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDifference(double difference) {
    if (difference == 0) return '±0s';

    final absDiff = difference.abs();
    final minutes = (absDiff ~/ 60).toInt();
    final seconds = (absDiff % 60).toInt();

    String timeStr = '';
    if (minutes > 0) {
      timeStr += '${minutes}m';
    }
    timeStr += '${seconds}s';

    return '${difference > 0 ? '+' : '-'}$timeStr';
  }

  // NOUVELLE MÉTHODE: Obtenir la couleur en fonction du pourcentage de performance
  Color _getPerformanceColor(double pourcentage) {
    if (pourcentage >= 110) {
      return Colors.blue; // Très rapide
    } else if (pourcentage >= 95) {
      return Colors.green; // Dans la plage
    } else if (pourcentage >= 80) {
      return Colors.orange; // Un peu lent
    } else {
      return Colors.red; // Trop lent
    }
  }
}
