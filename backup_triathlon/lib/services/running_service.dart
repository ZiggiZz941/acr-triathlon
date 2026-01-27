import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/triathlon_seance.dart';
import '../models/sport_type.dart';

class RunningService {
  static const String _fileName = "running_seances.json";
  static const int _maxSeances = 25;

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<bool> saveSeance(TriathlonSeance seance) async {
    try {
      List<TriathlonSeance> seances = await loadAllSeances();

      // Chercher si la séance existe déjà
      bool found = false;
      for (int i = 0; i < seances.length; i++) {
        if (seances[i].id == seance.id) {
          seances[i] = seance;
          found = true;
          break;
        }
      }

      // Si nouvelle séance
      if (!found) {
        seances.insert(0, seance);

        // Limiter à _maxSeances
        if (seances.length > _maxSeances) {
          seances = seances.sublist(0, _maxSeances);
        }
      }

      // Sauvegarder toutes les séances
      return await _saveAllSeances(seances);
    } catch (e) {
      print("Erreur sauvegarde séance course: $e");
      return false;
    }
  }

  Future<List<TriathlonSeance>> loadAllSeances() async {
    try {
      final file = await _getLocalFile();

      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return [];
      }

      List<dynamic> jsonArray = json.decode(contents);
      return jsonArray
          .map((json) => TriathlonSeance.fromJson(json as Map<String, dynamic>))
          .where((seance) => seance.sportType == SportType.running)
          .toList();
    } catch (e) {
      print("Erreur chargement séances course: $e");
      return [];
    }
  }

  Future<bool> deleteSeance(int seanceId) async {
    try {
      List<TriathlonSeance> seances = await loadAllSeances();
      int initialSize = seances.length;
      seances.removeWhere((seance) => seance.id == seanceId);

      if (seances.length < initialSize) {
        return await _saveAllSeances(seances);
      }
      return false;
    } catch (e) {
      print("Erreur suppression séance course: $e");
      return false;
    }
  }

  Future<int> getSeancesCount() async {
    List<TriathlonSeance> seances = await loadAllSeances();
    return seances.length;
  }

  Future<bool> isLimitReached() async {
    int count = await getSeancesCount();
    return count >= _maxSeances;
  }

  // Méthode privée
  Future<bool> _saveAllSeances(List<TriathlonSeance> seances) async {
    try {
      final file = await _getLocalFile();
      List<Map<String, dynamic>> jsonList =
          seances.map((seance) => seance.toJson()).toList();

      String jsonString = json.encode(jsonList);
      await file.writeAsString(jsonString);
      return true;
    } catch (e) {
      print("Erreur sauvegarde toutes séances course: $e");
      return false;
    }
  }

  // Statistiques
  Future<Map<String, dynamic>> getStats() async {
    List<TriathlonSeance> seances = await loadAllSeances();

    int totalSeances = seances.length;
    int totalExercices =
        seances.fold(0, (sum, seance) => sum + seance.exercices.length);

    double totalDistance = seances.fold(0.0, (sum, seance) {
      return sum +
          seance.exercices.fold(0.0, (s, exercice) => s + exercice.distance);
    });

    double totalVMA = seances.fold(0.0, (sum, seance) {
      return sum +
          seance.exercices
              .fold(0.0, (s, exercice) => s + exercice.valeurReference);
    });

    return {
      'totalSeances': totalSeances,
      'totalExercices': totalExercices,
      'totalDistance': totalDistance,
      'moyenneVMA': totalExercices > 0 ? totalVMA / totalExercices : 0,
      'moyenneDistanceParSeance':
          totalSeances > 0 ? totalDistance / totalSeances : 0,
    };
  }
}
