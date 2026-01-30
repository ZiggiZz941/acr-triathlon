import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/data_manager.dart';
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
    print("Initialisation DataManager...");
    final dataManager = DataManager();
    await dataManager.init();
    print("DataManager initialisé avec SharedPreferences");
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
            ),
            home: const MainTriathlonMenuScreen(),
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
