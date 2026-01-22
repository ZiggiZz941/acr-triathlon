import 'package:flutter/material.dart';
import '../../../constants/triathlon_colors.dart';
import '../../../constants/triathlon_dimens.dart';
import '../creation/creation_seance_screen.dart';
import 'package:triathlon_app/screens/main_triathlon_menu_screen.dart';

class ListeSeancesScreen extends StatelessWidget {
  const ListeSeancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // CHANGER AppColors.blanc par Colors.white
      body: Padding(
        padding: const EdgeInsets.all(TriathlonDimens.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 150,
              height: 150,
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: TriathlonColors.running, // CHANGER AppColors.rougeAcr
                borderRadius: BorderRadius.circular(75),
              ),
              child: const Icon(
                Icons.directions_run,
                size: 80,
                color: Colors.white, // CHANGER AppColors.blanc par Colors.white
              ),
            ),

            // Titre
            Text(
              'Mes Séances',
              style: TextStyle(
                color:
                    TriathlonColors.running, // CHANGER AppColors.rougeAcrDark
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // Message
            Text(
              'Consultez vos séances sauvegardées',
              style: TextStyle(
                color: TriathlonColors
                    .textSecondary, // CHANGER AppColors.textSecondary
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 50),

            // Bouton Nouvelle Séance
            SizedBox(
              width: double.infinity,
              height: TriathlonDimens.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreationSeanceScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      TriathlonColors.running, // CHANGER AppColors.rougeAcr
                  foregroundColor: Colors.white, // CHANGER AppColors.blanc
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      TriathlonDimens.borderRadiusXLarge,
                    ),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'Créer une nouvelle séance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bouton Retour
            SizedBox(
              width: double.infinity,
              height: TriathlonDimens.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MainTriathlonMenuScreen(), // CHANGER MainMenuScreen
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      TriathlonColors.running, // CHANGER AppColors.rougeAcr
                  foregroundColor: Colors.white, // CHANGER AppColors.blanc
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      TriathlonDimens.borderRadiusXLarge,
                    ),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'Retour au menu',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
