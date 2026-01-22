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
    // Filtrer uniquement les résultats avec temps
    final resultatsAvecTemps =
        resultats.where((r) => r.tempsReel != null).toList();

    if (resultatsAvecTemps.isEmpty) {
      return _buildAucunResultat();
    }

    // Calculer le nombre total attendu de répétitions
    final totalAttendu = seance.exercices.fold(
        0, (sum, exercice) => sum + exercice.nbSeries * exercice.nbRepetitions);
    final pourcentageComplete = totalAttendu > 0
        ? ((resultatsAvecTemps.length / totalAttendu) * 100).toInt()
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et statistiques
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

                  // Statistiques globales
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
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Commentaire de la séance (si présent)
          if (commentaireSeance != null) ...[
            _buildCommentaireSection(commentaireSeance),
            const SizedBox(height: 20),
          ],

          // Grille des résultats avec icônes
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

                  // Légende
                  _buildLegende(),
                  const SizedBox(height: 16),

                  // Grille des résultats
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

          // Liste détaillée
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
            'Performance vs temps attendu :',
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
                  '≥110% : Très rapide (plus de 10% plus rapide)',
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
                  '95-110% : Dans les temps',
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
                  '<95% : Trop lent (plus de 5% plus lent)',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
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
          'Attendu: ${_formatTemps(resultat.tempsAttendu)}\n'
          'Performance: ${pourcentage.toStringAsFixed(0)}%',
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
                size: 24,
                color: iconColor,
              ),
              const SizedBox(height: 2),
              Text(
                '${pourcentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
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
    final pourcentage = resultat.pourcentagePerformance;
    final difference = resultat.differenceTemps;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300] ?? Colors.grey),
        borderRadius: BorderRadius.circular(8),
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
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'S${resultat.serieIndex}R${resultat.repetitionIndex}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                    Icon(
                      icon,
                      size: 20,
                      color: iconColor,
                    ),
                  ],
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
                                'Attendu: ${_formatTemps(resultat.tempsAttendu)}',
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
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${pourcentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: iconColor,
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
                      resultat.dateFormatee,
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
          if (resultat.rpe != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text('RPE: ${resultat.rpe}'),
                  backgroundColor: _getRpeColor(resultat.rpe!),
                  labelStyle: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ],
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

  Color _getRpeColor(int rpe) {
    if (rpe <= 3) return Colors.green.shade100;
    if (rpe <= 6) return Colors.yellow.shade100;
    return Colors.red.shade100;
  }

  String _formatTemps(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    int secs = (seconds % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
}
