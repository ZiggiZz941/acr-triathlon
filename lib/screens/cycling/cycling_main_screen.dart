import 'package:flutter/material.dart';
import '../../constants/triathlon_colors.dart';
import 'cycling_calcul_simple_screen.dart';
import 'cycling_calcul_intensite_screen.dart';
import 'cycling_creation_seance_screen.dart';

class CyclingMainScreen extends StatelessWidget {
  const CyclingMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Mettez le Container directement dans le body avec la couleur de fond
        color: TriathlonColors.cycling.withOpacity(0.1),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header cyclisme
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 20,
                    bottom: 30,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: TriathlonColors.cyclingGradient,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.directions_bike,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'CYCLISME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Calculs basés sur la FTP (Functional Threshold Power)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Menu cyclisme
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Calculateurs
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CALCULATEURS',
                                style: TextStyle(
                                  color: TriathlonColors.cycling,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Bouton Calcul simple
                              _buildMenuButton(
                                context,
                                icon: Icons.speed,
                                text: 'Calcul puissance/vitesse',
                                description: 'Convertir watts en vitesse',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CyclingCalculSimpleScreen(),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 10),

                              // Bouton Calcul par intensité
                              _buildMenuButton(
                                context,
                                icon: Icons.power,
                                text: 'Calcul par intensité FTP',
                                description: 'Basé sur votre FTP',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CyclingCalculIntensiteScreen(),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 10),

                              // Bouton Zones d'entraînement
                              _buildMenuButton(
                                context,
                                icon: Icons.insights,
                                text: 'Zones d\'entraînement',
                                description: 'Basées sur votre FTP',
                                onPressed: () {
                                  _showTrainingZones(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Séances
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SÉANCES',
                                style: TextStyle(
                                  color: TriathlonColors.cycling,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Bouton Créer séance
                              _buildMenuButton(
                                context,
                                icon: Icons.add_circle,
                                text: 'Créer une séance',
                                description: 'Concevoir un entraînement',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CyclingCreationSeanceScreen(),
                                    ),
                                  );
                                },
                              ),

                              // Bouton Historique
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Informations FTP
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: TriathlonColors.cycling,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'La FTP (Functional Threshold Power) est la puissance maximale que vous pouvez maintenir pendant une heure.',
                                  style: TextStyle(
                                    color: TriathlonColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Bouton Retour
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TriathlonColors.cycling,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 4,
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
                      const SizedBox(height: 20),
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TriathlonColors.cycling.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: TriathlonColors.cycling.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: TriathlonColors.cycling, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: TriathlonColors.cycling,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: TriathlonColors.cycling,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainingZones(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zones d\'entraînement FTP'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildZoneInfo('Zone 1', 'Récupération active', '<55-75% FTP'),
              _buildZoneInfo('Zone 2', 'Endurance', '75-85% FTP'),
              _buildZoneInfo('Zone 3', 'Tempo', '85-95% FTP'),
              _buildZoneInfo('Zone 4', 'Seuil lactique', '95-105% FTP'),
              _buildZoneInfo('Zone 5', 'VO2 Max', '105-120% FTP'),
              _buildZoneInfo('Zone 6', 'Anaérobie', '>120% FTP'),
              const SizedBox(height: 15),
              const Text(
                'Ces zones vous aident à structurer votre entraînement selon vos objectifs.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneInfo(String zone, String name, String range) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: TriathlonColors.cycling.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              zone,
              style: TextStyle(
                color: TriathlonColors.cycling,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  range,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
