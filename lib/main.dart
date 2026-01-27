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
    final dataManager = DataManager();
    await dataManager.init();
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
                child: Text('Erreur: ${snapshot.error}'),
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
