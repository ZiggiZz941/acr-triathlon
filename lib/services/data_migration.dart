import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class DataMigration {
  static Future<void> migrateOldData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Vérifier si la migration a déjà été faite
      bool migrationDone = prefs.getBool('data_migration_done') ?? false;
      if (migrationDone) return;

      print("Début de la migration des données...");

      // Migrer les données du profil depuis SharedPreferences vers JSON
      await _migrateProfileData(prefs);

      // Marquer la migration comme faite
      await prefs.setBool('data_migration_done', true);

      print("Migration des données terminée");
    } catch (e) {
      print("Erreur lors de la migration: $e");
    }
  }

  static Future<void> _migrateProfileData(SharedPreferences prefs) async {
    try {
      // Vérifier si des données existent dans SharedPreferences
      final ftp = prefs.getString('cycling_ftp');
      final vma = prefs.getString('running_vma');
      final poids = prefs.getString('poids');
      final swimmingTime = prefs.getString('swimming_400m_time');

      if (ftp != null || vma != null || poids != null || swimmingTime != null) {
        print("Migration des données de profil depuis SharedPreferences...");

        // Lire le fichier JSON existant
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/triathlon_data.json');

        Map<String, dynamic> jsonData = {};

        if (await file.exists()) {
          final contents = await file.readAsString();
          if (contents.isNotEmpty) {
            jsonData = json.decode(contents) as Map<String, dynamic>;
          }
        }

        // Mettre à jour le profil
        if (!jsonData.containsKey('profile')) {
          jsonData['profile'] = {};
        }

        Map<String, dynamic> profile =
            Map<String, dynamic>.from(jsonData['profile']);

        if (ftp != null) {
          profile['cycling_ftp'] = double.tryParse(ftp);
          prefs.remove('cycling_ftp');
        }

        if (vma != null) {
          profile['running_vma'] = double.tryParse(vma);
          prefs.remove('running_vma');
        }

        if (poids != null) {
          profile['poids'] = double.tryParse(poids);
          prefs.remove('poids');
        }

        if (swimmingTime != null) {
          profile['swimming_400m_time'] = double.tryParse(swimmingTime);
          prefs.remove('swimming_400m_time');
        }

        jsonData['profile'] = profile;

        // Sauvegarder
        await file.writeAsString(json.encode(jsonData));

        print("Migration du profil terminée");
      }
    } catch (e) {
      print("Erreur migration profil: $e");
    }
  }
}
