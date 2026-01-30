import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sport_type.dart';
import '../models/triathlon_seance.dart';
import '../models/triathlon_resultat.dart';
import '../models/triathlon_seance_commentaire.dart';

class DataManager extends ChangeNotifier {
  // Clés pour SharedPreferences
  static const String _keyUserNom = "triathlon_user_nom";
  static const String _keyUserPrenom = "triathlon_user_prenom";
  static const String _keyFirstLaunch = "triathlon_first_launch";

  // Clés pour le profil
  static const String _keySwimmingTime = "triathlon_swimming_400m_time";
  static const String _keyCyclingFTP = "triathlon_cycling_ftp";
  static const String _keyRunningVMA = "triathlon_running_vma";
  static const String _keyPoids = "triathlon_poids";

  // Clés pour les séances (par sport)
  static const String _keySeancesSwimming = "triathlon_seances_swimming";
  static const String _keySeancesCycling = "triathlon_seances_cycling";
  static const String _keySeancesRunning = "triathlon_seances_running";

  // Clés pour les résultats et commentaires
  static const String _keyResultats = "triathlon_resultats";
  static const String _keyCommentaires = "triathlon_commentaires";

  static const int _maxSeances = 25;

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  DataManager();

  Future<void> init() async {
    if (!_isInitialized) {
      try {
        _prefs = await SharedPreferences.getInstance();
        _isInitialized = true;
        print("DataManager initialisé avec SharedPreferences");
      } catch (e) {
        print("Erreur d'initialisation DataManager: $e");
        rethrow;
      }
    }
  }

  Future<void> _ensurePrefsInitialized() async {
    if (!_isInitialized) {
      await init();
    }
    if (_prefs == null) {
      throw Exception("SharedPreferences n'a pas pu être initialisé");
    }
  }

  // ========== GESTION UTILISATEUR ==========
  Future<void> saveUser(String nom, String prenom) async {
    await _ensurePrefsInitialized();
    await _prefs!.setString(_keyUserNom, nom);
    await _prefs!.setString(_keyUserPrenom, prenom);
    await _prefs!.setBool(_keyFirstLaunch, false);
    notifyListeners();
    print("Utilisateur sauvegardé: $nom $prenom");
  }

  Future<String> getUserNom() async {
    await _ensurePrefsInitialized();
    return _prefs!.getString(_keyUserNom) ?? "";
  }

  Future<String> getUserPrenom() async {
    await _ensurePrefsInitialized();
    return _prefs!.getString(_keyUserPrenom) ?? "";
  }

  Future<bool> isFirstLaunch() async {
    await _ensurePrefsInitialized();
    return _prefs!.getBool(_keyFirstLaunch) ?? true;
  }

  // ========== PROFIL TRIATHLON ==========
  Future<void> saveTriathlonProfile(Map<String, dynamic> profile) async {
    await _ensurePrefsInitialized();

    if (profile.containsKey('swimming_400m_time') &&
        profile['swimming_400m_time'] != null) {
      await _prefs!
          .setDouble(_keySwimmingTime, profile['swimming_400m_time'] as double);
    }

    if (profile.containsKey('cycling_ftp') && profile['cycling_ftp'] != null) {
      await _prefs!.setDouble(_keyCyclingFTP, profile['cycling_ftp'] as double);
    }

    if (profile.containsKey('running_vma') && profile['running_vma'] != null) {
      await _prefs!.setDouble(_keyRunningVMA, profile['running_vma'] as double);
    }

    if (profile.containsKey('poids') && profile['poids'] != null) {
      await _prefs!.setDouble(_keyPoids, profile['poids'] as double);
    } else {
      // Valeur par défaut
      await _prefs!.setDouble(_keyPoids, 70.0);
    }

    notifyListeners();
    print("Profil triathlon sauvegardé: $profile");
  }

  double? getSwimming400mTime() {
    return _prefs?.getDouble(_keySwimmingTime);
  }

  double? getCyclingFTP() {
    return _prefs?.getDouble(_keyCyclingFTP);
  }

  double? getRunningVMA() {
    return _prefs?.getDouble(_keyRunningVMA);
  }

  double getPoids() {
    return _prefs?.getDouble(_keyPoids) ?? 70.0;
  }

  // ========== GESTION SÉANCES ==========
  Future<bool> saveSeance(TriathlonSeance seance) async {
    try {
      await _ensurePrefsInitialized();

      print(
          "Sauvegarde de la séance: ${seance.nom} (${seance.sportType.name})");

      // Déterminer la clé selon le sport
      String key;
      switch (seance.sportType) {
        case SportType.swimming:
          key = _keySeancesSwimming;
          break;
        case SportType.cycling:
          key = _keySeancesCycling;
          break;
        case SportType.running:
          key = _keySeancesRunning;
          break;
      }

      // Assigner un ID si nécessaire
      if (seance.id == 0) {
        seance.id = DateTime.now().millisecondsSinceEpoch;
      }

      // Récupérer les séances existantes
      String? seancesJson = _prefs!.getString(key);
      List<TriathlonSeance> sportSeances = [];

      if (seancesJson != null && seancesJson.isNotEmpty) {
        try {
          List<dynamic> jsonList = json.decode(seancesJson) as List<dynamic>;
          sportSeances = jsonList
              .map((json) =>
                  TriathlonSeance.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        } catch (e) {
          print("Erreur parsing séances existantes: $e");
          sportSeances = [];
        }
      }

      // Mettre à jour ou ajouter la séance
      int existingIndex = sportSeances.indexWhere((s) => s.id == seance.id);

      if (existingIndex != -1) {
        sportSeances[existingIndex] = seance;
        print("Séance mise à jour");
      } else {
        sportSeances.insert(0, seance);
        print("Nouvelle séance ajoutée");

        // Limiter le nombre de séances
        if (sportSeances.length > _maxSeances) {
          sportSeances = sportSeances.sublist(0, _maxSeances);
          print("Limite de $_maxSeances séances atteinte");
        }
      }

      // Sauvegarder
      String newSeancesJson =
          json.encode(sportSeances.map((s) => s.toJson()).toList());
      bool saved = await _prefs!.setString(key, newSeancesJson);

      if (saved) {
        print("Séance sauvegardée avec succès");
        print(
            "Nombre de séances ${seance.sportType.name}: ${sportSeances.length}");
        notifyListeners();
      }

      return saved;
    } catch (e) {
      print("Erreur sauvegarde séance: $e");
      print("Stack trace: ${e.toString()}");
      return false;
    }
  }

  List<TriathlonSeance> getSeancesBySport(SportType sportType) {
    try {
      String key;
      switch (sportType) {
        case SportType.swimming:
          key = _keySeancesSwimming;
          break;
        case SportType.cycling:
          key = _keySeancesCycling;
          break;
        case SportType.running:
          key = _keySeancesRunning;
          break;
      }

      String? seancesJson = _prefs?.getString(key);

      if (seancesJson == null || seancesJson.isEmpty) {
        return [];
      }

      List<dynamic> jsonList = json.decode(seancesJson) as List<dynamic>;
      List<TriathlonSeance> seances = jsonList
          .map((json) =>
              TriathlonSeance.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      print("${seances.length} séances récupérées pour ${sportType.name}");
      return seances;
    } catch (e) {
      print("Erreur récupération séances: $e");
      return [];
    }
  }

  Future<List<TriathlonSeance>> loadAllSeances() async {
    try {
      List<TriathlonSeance> allSeances = [];

      for (var sport in SportType.values) {
        allSeances.addAll(getSeancesBySport(sport));
      }

      allSeances.sort((a, b) => b.id.compareTo(a.id));

      print("${allSeances.length} séances chargées au total");
      return allSeances;
    } catch (e) {
      print("Erreur chargement toutes séances: $e");
      return [];
    }
  }

  Future<bool> deleteSeanceById(int seanceId) async {
    try {
      bool deleted = false;

      for (var sport in SportType.values) {
        List<TriathlonSeance> sportSeances = getSeancesBySport(sport);
        int initialLength = sportSeances.length;

        sportSeances.removeWhere((seance) => seance.id == seanceId);

        if (sportSeances.length < initialLength) {
          deleted = true;

          // Sauvegarder la liste mise à jour
          String key;
          switch (sport) {
            case SportType.swimming:
              key = _keySeancesSwimming;
              break;
            case SportType.cycling:
              key = _keySeancesCycling;
              break;
            case SportType.running:
              key = _keySeancesRunning;
              break;
          }

          String newSeancesJson =
              json.encode(sportSeances.map((s) => s.toJson()).toList());
          await _prefs!.setString(key, newSeancesJson);

          // Supprimer les résultats et commentaires associés
          await _deleteResultatsForSeance(seanceId);
          await _deleteCommentaireForSeance(seanceId);

          print("Séance $seanceId supprimée de ${sport.name}");
          break;
        }
      }

      if (deleted) {
        notifyListeners();
      }

      return deleted;
    } catch (e) {
      print("Erreur suppression séance: $e");
      return false;
    }
  }

  Future<int> getSeancesCountBySport(SportType sportType) async {
    final seances = getSeancesBySport(sportType);
    final count = seances.length;
    print("Nombre de séances ${sportType.name}: $count");
    return count;
  }

  Future<bool> isLimitReached(SportType sportType) async {
    int count = getSeancesBySport(sportType).length;
    final reached = count >= _maxSeances;
    print(
        "Limite atteinte pour ${sportType.name}? $reached ($count/$_maxSeances)");
    return reached;
  }

  Future<int> getSeancesCount() async {
    int total = 0;
    for (var sport in SportType.values) {
      total += getSeancesBySport(sport).length;
    }
    print("Total séances: $total");
    return total;
  }

  // ========== GESTION RÉSULTATS ==========
  Future<void> saveResultatsForSeance(
      int seanceId, List<TriathlonResultat> resultats) async {
    try {
      await _ensurePrefsInitialized();

      // Récupérer tous les résultats
      String? resultatsJson = _prefs!.getString(_keyResultats);
      Map<String, dynamic> allResultats = {};

      if (resultatsJson != null && resultatsJson.isNotEmpty) {
        try {
          allResultats = Map<String, dynamic>.from(json.decode(resultatsJson));
        } catch (e) {
          print("Erreur parsing résultats existants: $e");
        }
      }

      // Mettre à jour les résultats pour cette séance
      allResultats[seanceId.toString()] =
          resultats.map((r) => r.toJson()).toList();

      // Sauvegarder
      String newResultatsJson = json.encode(allResultats);
      await _prefs!.setString(_keyResultats, newResultatsJson);

      notifyListeners();
      print("${resultats.length} résultats sauvegardés pour séance $seanceId");
    } catch (e) {
      print("Erreur sauvegarde résultats: $e");
      rethrow;
    }
  }

  Future<void> saveResultatsWithCommentaire(
      int seanceId, List<TriathlonResultat> resultats,
      {String? commentaireText}) async {
    try {
      // Sauvegarder les résultats
      await saveResultatsForSeance(seanceId, resultats);

      // Sauvegarder le commentaire si fourni
      if (commentaireText != null && commentaireText.isNotEmpty) {
        final commentaire = TriathlonSeanceCommentaire(
          id: DateTime.now().millisecondsSinceEpoch,
          seanceId: seanceId,
          commentaire: commentaireText,
          dateCreation: DateTime.now(),
        );
        await _saveCommentaireForSeance(commentaire);
      } else if (commentaireText != null && commentaireText.isEmpty) {
        // Si commentaire vide, supprimer le commentaire existant
        await _deleteCommentaireForSeance(seanceId);
      }

      print(
          "${resultats.length} résultats et commentaire sauvegardés pour séance $seanceId");
    } catch (e) {
      print("Erreur sauvegarde résultats et commentaire: $e");
      rethrow;
    }
  }

  List<TriathlonResultat> getResultatsForSeance(int seanceId) {
    try {
      String? resultatsJson = _prefs?.getString(_keyResultats);

      if (resultatsJson == null || resultatsJson.isEmpty) {
        return [];
      }

      Map<String, dynamic> allResultats =
          Map<String, dynamic>.from(json.decode(resultatsJson));
      List<dynamic>? seanceResultats =
          allResultats[seanceId.toString()] as List<dynamic>?;

      if (seanceResultats == null) {
        return [];
      }

      return seanceResultats
          .map((json) =>
              TriathlonResultat.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      print("Erreur récupération résultats: $e");
      return [];
    }
  }

  Future<void> _deleteResultatsForSeance(int seanceId) async {
    try {
      String? resultatsJson = _prefs!.getString(_keyResultats);

      if (resultatsJson != null && resultatsJson.isNotEmpty) {
        Map<String, dynamic> allResultats =
            Map<String, dynamic>.from(json.decode(resultatsJson));

        if (allResultats.containsKey(seanceId.toString())) {
          allResultats.remove(seanceId.toString());

          String newResultatsJson = json.encode(allResultats);
          await _prefs!.setString(_keyResultats, newResultatsJson);

          print("Résultats supprimés pour séance $seanceId");
        }
      }
    } catch (e) {
      print("Erreur suppression résultats: $e");
    }
  }

  // ========== GESTION COMMENTAIRES ==========
  Future<void> _saveCommentaireForSeance(
      TriathlonSeanceCommentaire commentaire) async {
    try {
      await _ensurePrefsInitialized();

      // Récupérer tous les commentaires
      String? commentairesJson = _prefs!.getString(_keyCommentaires);
      Map<String, dynamic> allCommentaires = {};

      if (commentairesJson != null && commentairesJson.isNotEmpty) {
        try {
          allCommentaires =
              Map<String, dynamic>.from(json.decode(commentairesJson));
        } catch (e) {
          print("Erreur parsing commentaires existants: $e");
        }
      }

      // Mettre à jour le commentaire pour cette séance
      allCommentaires[commentaire.seanceId.toString()] = commentaire.toJson();

      // Sauvegarder
      String newCommentairesJson = json.encode(allCommentaires);
      await _prefs!.setString(_keyCommentaires, newCommentairesJson);

      print("Commentaire sauvegardé pour séance ${commentaire.seanceId}");
    } catch (e) {
      print("Erreur sauvegarde commentaire: $e");
      rethrow;
    }
  }

  TriathlonSeanceCommentaire? getCommentaireForSeance(int seanceId) {
    try {
      String? commentairesJson = _prefs?.getString(_keyCommentaires);

      if (commentairesJson == null || commentairesJson.isEmpty) {
        return null;
      }

      Map<String, dynamic> allCommentaires =
          Map<String, dynamic>.from(json.decode(commentairesJson));
      Map<String, dynamic>? commentaireData =
          allCommentaires[seanceId.toString()] as Map<String, dynamic>?;

      if (commentaireData == null) {
        return null;
      }

      return TriathlonSeanceCommentaire.fromJson(commentaireData);
    } catch (e) {
      print("Erreur récupération commentaire: $e");
      return null;
    }
  }

  Future<void> _deleteCommentaireForSeance(int seanceId) async {
    try {
      String? commentairesJson = _prefs!.getString(_keyCommentaires);

      if (commentairesJson != null && commentairesJson.isNotEmpty) {
        Map<String, dynamic> allCommentaires =
            Map<String, dynamic>.from(json.decode(commentairesJson));

        if (allCommentaires.containsKey(seanceId.toString())) {
          allCommentaires.remove(seanceId.toString());

          String newCommentairesJson = json.encode(allCommentaires);
          await _prefs!.setString(_keyCommentaires, newCommentairesJson);

          print("Commentaire supprimé pour séance $seanceId");
        }
      }
    } catch (e) {
      print("Erreur suppression commentaire: $e");
    }
  }

  // ========== MÉTHODES UTILITAIRES ==========
  Future<void> clearAllData() async {
    try {
      await _ensurePrefsInitialized();

      // Effacer toutes les clés
      await _prefs!.remove(_keyUserNom);
      await _prefs!.remove(_keyUserPrenom);
      await _prefs!.remove(_keyFirstLaunch);

      await _prefs!.remove(_keySwimmingTime);
      await _prefs!.remove(_keyCyclingFTP);
      await _prefs!.remove(_keyRunningVMA);
      await _prefs!.remove(_keyPoids);

      await _prefs!.remove(_keySeancesSwimming);
      await _prefs!.remove(_keySeancesCycling);
      await _prefs!.remove(_keySeancesRunning);

      await _prefs!.remove(_keyResultats);
      await _prefs!.remove(_keyCommentaires);

      notifyListeners();
      print("Toutes les données ont été effacées");
    } catch (e) {
      print("Erreur suppression données: $e");
    }
  }

  Future<void> debugPrintData() async {
    print("=== ÉTAT DU DATAMANAGER ===");

    // Profil
    print("Profil:");
    print("  FTP: ${getCyclingFTP()}");
    print("  VMA: ${getRunningVMA()}");
    print("  Temps 400m: ${getSwimming400mTime()}");
    print("  Poids: ${getPoids()}");

    // Séances
    for (var sport in SportType.values) {
      final seances = getSeancesBySport(sport);
      print("${sport.name}: ${seances.length} séances");
      for (var seance in seances) {
        print("  - ${seance.nom} (ID: ${seance.id})");
      }
    }

    // Résultats
    String? resultatsJson = _prefs?.getString(_keyResultats);
    if (resultatsJson != null && resultatsJson.isNotEmpty) {
      try {
        Map<String, dynamic> allResultats =
            Map<String, dynamic>.from(json.decode(resultatsJson));
        print("Résultats: ${allResultats.length} séances avec résultats");
      } catch (e) {
        print("Résultats: Erreur parsing");
      }
    }

    print("==========================");
  }
}
