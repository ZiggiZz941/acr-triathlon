import 'package:flutter/material.dart';
import 'package:triathlon_app/constants/triathlon_colors.dart';
import 'swimming_calcul_simple_screen.dart';
import 'swimming_calcul_intensite_screen.dart';
import 'swimming_creation_seance_screen.dart';

class SwimmingMainScreen extends StatelessWidget {
  const SwimmingMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Mettez le Container directement dans le body avec la couleur de fond
        color: TriathlonColors.swimming.withOpacity(0.1),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header natation
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
                      colors: TriathlonColors.swimmingGradient,
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
                        Icons.pool,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'NATATION',
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
                        'Calculs basés sur le temps au 400m',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Menu natation
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
                                  color: TriathlonColors.swimming,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Bouton Calcul simple
                              _buildMenuButton(
                                context,
                                icon: Icons.calculate,
                                text: 'Calcul simple',
                                description: 'Temps pour une distance donnée',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SwimmingCalculSimpleScreen(),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 10),

                              // Bouton Calcul par intensité
                              _buildMenuButton(
                                context,
                                icon: Icons.speed,
                                text: 'Calcul par intensité',
                                description: 'Basé sur le temps au 400m',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SwimmingCalculIntensiteScreen(),
                                    ),
                                  );
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
                                  color: TriathlonColors.swimming,
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
                                          const SwimmingCreationSeanceScreen(),
                                    ),
                                  );
                                },
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
                            backgroundColor: TriathlonColors.swimming,
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
          color: TriathlonColors.swimming.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: TriathlonColors.swimming.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: TriathlonColors.swimming, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: TriathlonColors.swimming,
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
              color: TriathlonColors.swimming,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
