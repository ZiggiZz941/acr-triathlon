import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sport_type.dart';
import '../services/data_manager.dart';
import '../constants/triathlon_colors.dart';
import '../constants/triathlon_images.dart';
import '../widgets/triathlon_menu_button.dart';
import 'running/running_main_screen.dart';
import 'swimming/swimming_main_screen.dart';
import 'cycling/cycling_main_screen.dart';
import 'profil/triathlon_profil_screen.dart';
import 'historique/historique_triathlon_screen.dart'; // IMPORT AJOUTÉ

class MainTriathlonMenuScreen extends StatelessWidget {
  const MainTriathlonMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TriathlonColors.background,
      body: SafeArea(
        child: FutureBuilder<Map<String, String>>(
          future: _loadUserData(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final userName = snapshot.data?['nom'] ?? '';
            final userFirstName = snapshot.data?['prenom'] ?? '';

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          TriathlonColors.primary,
                          TriathlonColors.secondary,
                        ],
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
                        // Logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(60),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Image.asset(
                              TriathlonImages.triathlonLogo,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback si l'image n'est pas trouvée
                                return const Icon(
                                  Icons.directions_bike,
                                  size: 60,
                                  color: TriathlonColors.primary,
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Titre
                        Text(
                          'ACR Triathlon',
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

                        // Message de bienvenue
                        if (userFirstName.isNotEmpty || userName.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              _getWelcomeMessage(userName, userFirstName),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Menu principal
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Première ligne : Natation et Cyclisme
                        Row(
                          children: [
                            Expanded(
                              child: TriathlonMenuButton(
                                sportType: SportType.swimming,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SwimmingMainScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TriathlonMenuButton(
                                sportType: SportType.cycling,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CyclingMainScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Deuxième ligne : Course à pied
                        SizedBox(
                          width: double
                              .infinity, // Prend toute la largeur disponible
                          child: TriathlonMenuButton(
                            sportType: SportType.running,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RunningMainScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Boutons supplémentaires
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // BOUTON HISTORIQUE AJOUTÉ ICI
                                ListTile(
                                  leading: const Icon(Icons.history,
                                      color: TriathlonColors.primary),
                                  title: const Text('Historique des séances'),
                                  subtitle: const Text(
                                      'Consultez toutes vos séances sauvegardées'),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HistoriqueTriathlonScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 1),

                                ListTile(
                                  leading: const Icon(Icons.person,
                                      color: TriathlonColors.primary),
                                  title: const Text('Mon Profil Triathlon'),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TriathlonProfilScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 1),

                                ListTile(
                                  leading: const Icon(Icons.info,
                                      color: TriathlonColors.primary),
                                  title: const Text('À propos'),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    _showAboutDialog(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20), // Espace pour le scroll
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Méthode pour charger les données utilisateur
  Future<Map<String, String>> _loadUserData(BuildContext context) async {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final nom = await dataManager.getUserNom();
    final prenom = await dataManager.getUserPrenom();
    return {'nom': nom, 'prenom': prenom};
  }

  // Méthode pour formater le message de bienvenue
  String _getWelcomeMessage(String userName, String userFirstName) {
    if (userName.isNotEmpty && userFirstName.isNotEmpty) {
      return 'Bonjour $userFirstName $userName !';
    } else if (userName.isNotEmpty) {
      return 'Bonjour $userName !';
    } else if (userFirstName.isNotEmpty) {
      return 'Bonjour $userFirstName !';
    }
    return 'Bienvenue !';
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ACR Triathlon'),
        content: const Text('Application d\'entraînement pour triathlon\n\n'
            'Natation - Cyclisme - Course à pied\n\n'
            'Développé pour les athlètes de tous niveaux\n\n'
            'Version 1.5.1'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
