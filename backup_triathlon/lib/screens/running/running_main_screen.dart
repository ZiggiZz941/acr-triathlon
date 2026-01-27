import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/triathlon_colors.dart';
import '../../constants/triathlon_dimens.dart';
import '../../constants/triathlon_strings.dart';
import '../../constants/triathlon_images.dart';
import '../../models/sport_type.dart';
import '../../services/data_manager.dart';
import 'calcul/calcul_simple_screen.dart';
import 'calcul/calcul_intensite_screen.dart';
import 'calcul/chronometre_screen.dart';
import 'creation/creation_seance_screen.dart';
import 'creation/creation_seance_intensite_avancee_screen.dart';
import 'running_start_sequence_screen.dart'; // AJOUTEZ CET IMPORT

class RunningMainScreen extends StatelessWidget {
  const RunningMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final vmaProfile = dataManager.getRunningVMA();

    return Scaffold(
      backgroundColor: TriathlonColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            color: TriathlonColors.background,
            child: Column(
              children: [
                // Header course
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: 20,
                    bottom: TriathlonDimens.paddingXXLarge,
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
                      bottomLeft:
                          Radius.circular(TriathlonDimens.borderRadiusXLarge),
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
                  child: Column(
                    children: [
                      // Icône personnalisée de course
                      Container(
                        width: TriathlonDimens.iconSizeXXLarge + 20,
                        height: TriathlonDimens.iconSizeXXLarge + 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                              (TriathlonDimens.iconSizeXXLarge + 20) / 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ClipOval(
                            child: Image.asset(
                              TriathlonImages.runningIcon,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.transparent,
                                  child: Icon(
                                    Icons.directions_run,
                                    size: TriathlonDimens.iconSizeXXLarge,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: TriathlonDimens.paddingMedium),

                      Text(
                        'COURSE À PIED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: TriathlonDimens.fontSizeXXXLarge,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: TriathlonDimens.paddingXSmall),

                      Text(
                        'Calculs basés sur la VMA',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: TriathlonDimens.fontSizeLarge,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (vmaProfile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
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
                              'VMA actuelle: ${vmaProfile.toStringAsFixed(1)} ${TriathlonStrings.unitKmh}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: TriathlonDimens.fontSizeMedium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Menu course
                Padding(
                  padding: const EdgeInsets.all(TriathlonDimens.paddingLarge),
                  child: Column(
                    children: [
                      // Calculateurs
                      Card(
                        elevation: TriathlonDimens.elevationLarge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TriathlonDimens.borderRadiusLarge,
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(
                              TriathlonDimens.paddingLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CALCULATEURS',
                                style: TextStyle(
                                  color: TriathlonColors.running,
                                  fontSize: TriathlonDimens.fontSizeXXLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                  height: TriathlonDimens.paddingLarge),

                              // Bouton Calcul simple
                              _buildMenuButton(
                                context,
                                icon: Icons.calculate,
                                text: 'Calcul simple (allure)',
                                description: 'Temps pour une distance donnée',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CalculSimpleScreen(),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(
                                  height: TriathlonDimens.paddingMedium),

                              // Bouton Calcul par intensité
                              _buildMenuButton(
                                context,
                                icon: Icons.speed,
                                text: 'Calcul par intensité',
                                description: 'Basé sur un temps de référence',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CalculIntensiteScreen(),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(
                                  height: TriathlonDimens.paddingMedium),

                              // Bouton Chronomètre
                              _buildMenuButton(
                                context,
                                icon: Icons.timer,
                                text: 'Chronomètre',
                                description: 'Mesurez vos performances',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ChronometreScreen(),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(
                                  height: TriathlonDimens.paddingMedium),

                              // NOUVEAU BOUTON : Séquence de départ
                              _buildMenuButton(
                                context,
                                icon: Icons.play_circle_fill,
                                text: 'Séquence de départ',
                                description: 'À vos marques, Prêt, Partez',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RunningStartSequenceScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: TriathlonDimens.paddingLarge),

                      // Séances
                      Card(
                        elevation: TriathlonDimens.elevationLarge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TriathlonDimens.borderRadiusLarge,
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(
                              TriathlonDimens.paddingLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SÉANCES',
                                style: TextStyle(
                                  color: TriathlonColors.running,
                                  fontSize: TriathlonDimens.fontSizeXXLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                  height: TriathlonDimens.paddingLarge),

                              // Bouton Créer séance classique
                              _buildMenuButton(
                                context,
                                icon: Icons.add_circle,
                                text: 'Créer une séance',
                                description: 'Version classique',
                                onPressed: () async {
                                  bool limitReached =
                                      await dataManager.isLimitReached(
                                    SportType.running,
                                  );
                                  if (limitReached && context.mounted) {
                                    _showLimitWarning(context, 'classique');
                                  } else if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CreationSeanceScreen(),
                                      ),
                                    );
                                  }
                                },
                              ),

                              const SizedBox(
                                  height: TriathlonDimens.paddingMedium),

                              // Bouton Créer séance intensité
                              _buildMenuButton(
                                context,
                                icon: Icons.timeline,
                                text: 'Créer séance par intensité',
                                description: 'Version avancée',
                                onPressed: () async {
                                  bool limitReached =
                                      await dataManager.isLimitReached(
                                    SportType.running,
                                  );
                                  if (limitReached && context.mounted) {
                                    _showIntensityLimitWarning(context);
                                  } else if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CreationSeanceIntensiteAvanceeScreen(
                                          sportType: SportType.running,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),

                              const SizedBox(
                                  height: TriathlonDimens.paddingMedium),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: TriathlonDimens.paddingLarge),

                      // Information VMA
                      if (vmaProfile == null)
                        Card(
                          elevation: TriathlonDimens.elevationMedium,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              TriathlonDimens.borderRadiusMedium,
                            ),
                          ),
                          color: TriathlonColors.running.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(
                                TriathlonDimens.paddingMedium),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: TriathlonColors.running,
                                  size: TriathlonDimens.iconSizeMedium,
                                ),
                                const SizedBox(
                                    width: TriathlonDimens.paddingMedium),
                                Expanded(
                                  child: Text(
                                    TriathlonStrings.runningTip,
                                    style: TextStyle(
                                      color: TriathlonColors.textSecondary,
                                      fontSize: TriathlonDimens.fontSizeSmall,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: TriathlonDimens.paddingLarge),

                      // Bouton Retour
                      SizedBox(
                        width: double.infinity,
                        height: TriathlonDimens.buttonHeightLarge,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
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
                            'RETOUR AU MENU TRIATHLON',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: TriathlonDimens.paddingLarge),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required String description,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(TriathlonDimens.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.all(TriathlonDimens.paddingMedium),
        decoration: BoxDecoration(
          color: TriathlonColors.running.withOpacity(0.05),
          borderRadius:
              BorderRadius.circular(TriathlonDimens.borderRadiusMedium),
          border: Border.all(
            color: TriathlonColors.running.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: TriathlonColors.running,
              size: TriathlonDimens.iconSizeLarge,
            ),
            const SizedBox(width: TriathlonDimens.paddingLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: TriathlonColors.running,
                      fontSize: TriathlonDimens.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: TriathlonColors.textSecondary,
                      fontSize: TriathlonDimens.fontSizeSmall,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: TriathlonColors.running,
              size: TriathlonDimens.iconSizeMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _showLimitWarning(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limite atteinte'),
        content: const Text(
          'Vous avez déjà 25 séances sauvegardées en course à pied.\n\n'
          'La création d\'une nouvelle séance supprimera automatiquement la plus ancienne.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (type == 'classique' && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreationSeanceScreen(),
                  ),
                );
              }
            },
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showIntensityLimitWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limite atteinte'),
        content: const Text(
          'Vous avez déjà 25 séances sauvegardées en course à pied.\n\n'
          'La création d\'une nouvelle séance supprimera automatiquement la plus ancienne.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreationSeanceIntensiteAvanceeScreen(
                      sportType: SportType.running,
                    ),
                  ),
                );
              }
            },
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
