import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/premiere_connexion_screen.dart';
import 'screens/main_triathlon_menu_screen.dart';
import 'services/data_manager.dart';
import 'constants/triathlon_colors.dart';

class TriathlonApp extends StatelessWidget {
  const TriathlonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triathlon Coach',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: TriathlonColors.primary,
        scaffoldBackgroundColor: TriathlonColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: TriathlonColors.primary,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: TriathlonColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      home: _buildHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildHomeScreen() {
    return Consumer<DataManager>(
      builder: (context, dataManager, child) {
        // Vérifier si DataManager est initialisé
        return FutureBuilder<bool>(
          future: dataManager.isFirstLaunch(),
          builder: (context, snapshot) {
            // Pendant le chargement
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen();
            }

            // En cas d'erreur
            if (snapshot.hasError) {
              return _buildErrorScreen(snapshot.error.toString());
            }

            // Données disponibles
            final isFirstLaunch = snapshot.data ?? true;

            if (isFirstLaunch) {
              return const PremiereConnexionScreen();
            } else {
              return const MainTriathlonMenuScreen();
            }
          },
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: TriathlonColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: TriathlonColors.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Chargement...',
              style: TextStyle(
                color: TriathlonColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: TriathlonColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                'Une erreur est survenue',
                style: TextStyle(
                  color: TriathlonColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                error,
                style: TextStyle(
                  color: TriathlonColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Vous pourriez ajouter une logique de réessai ici
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
