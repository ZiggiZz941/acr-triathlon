import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/data_manager.dart';
import 'services/data_migration.dart'; // AJOUTER CET IMPORT
import 'screens/main_triathlon_menu_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<DataManager> _dataManagerFuture;

  @override
  void initState() {
    super.initState();
    _dataManagerFuture = _initializeDataManager();
  }

  Future<DataManager> _initializeDataManager() async {
    // AJOUTER CETTE LIGNE POUR LA MIGRATION
    print("Démarrage de l'application...");
    print("Migration des données...");
    await DataMigration.migrateOldData();

    final dataManager = DataManager();
    await dataManager.init();

    // DEBUG: Afficher l'état initial
    print("DataManager initialisé");
    await dataManager.debugPrintData();

    return dataManager;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataManager>(
      future: _dataManagerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Chargement...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Migration des données en cours',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 60,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Erreur de chargement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Une erreur est survenue lors du chargement des données.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _dataManagerFuture = _initializeDataManager();
                        });
                      },
                      child: Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final dataManager = snapshot.data!;

        return ChangeNotifierProvider<DataManager>.value(
          value: dataManager,
          child: MaterialApp(
            title: 'ACR',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            home: const MainTriathlonMenuScreen(),
            debugShowCheckedModeBanner: false,
            // AJOUTER UNE ROUTE POUR LE DEBUG (optionnel)
            routes: {
              '/debug': (context) => DebugScreen(),
            },
          ),
        );
      },
    );
  }
}

// ÉCRAN DE DEBUG SIMPLE (optionnel - vous pouvez le supprimer si vous ne voulez pas)
class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Debug'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'État des données',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await dataManager.debugPrintData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Données affichées dans la console'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 8),
                          Text('Afficher état complet'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil utilisateur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    FutureBuilder(
                      future: dataManager.getUserNom(),
                      builder: (context, snapshot) {
                        return Text('Nom: ${snapshot.data ?? "Non défini"}');
                      },
                    ),
                    FutureBuilder(
                      future: dataManager.getUserPrenom(),
                      builder: (context, snapshot) {
                        return Text('Prénom: ${snapshot.data ?? "Non défini"}');
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil triathlon',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                        'FTP: ${dataManager.getCyclingFTP()?.toStringAsFixed(1) ?? "Non défini"}'),
                    Text(
                        'VMA: ${dataManager.getRunningVMA()?.toStringAsFixed(1) ?? "Non défini"}'),
                    Text(
                        'Temps 400m: ${dataManager.getSwimming400mTime()?.toStringAsFixed(2) ?? "Non défini"}'),
                    Text(
                        'Poids: ${dataManager.getPoids().toStringAsFixed(1)} kg'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Séances',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    FutureBuilder(
                      future: dataManager.getSeancesCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        return Text('Total: ${snapshot.data ?? 0} séances');
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions de debug',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        bool confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirmation'),
                                content: Text(
                                    'Voulez-vous vraiment effacer TOUTES les données ? Cette action est irréversible.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(
                                      'Effacer',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ) ??
                            false;

                        if (confirm) {
                          await dataManager.clearAllData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Toutes les données ont été effacées'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_forever),
                          SizedBox(width: 8),
                          Text('Effacer toutes les données'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
