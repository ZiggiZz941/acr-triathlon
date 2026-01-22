import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sport_type.dart';
import '../models/triathlon_seance.dart';
import '../models/triathlon_resultat.dart';
import '../models/triathlon_seance_commentaire.dart';

class DataManager extends ChangeNotifier {
  static const String _keyUserNom = "triathlon_user_nom";
  static const String _keyUserPrenom = "triathlon_user_prenom";
  static const String _keyFirstLaunch = "triathlon_first_launch";
  static const String _fileName = "triathlon_data.json";
  static const int _maxSeances = 25;

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Map<SportType, List<TriathlonSeance>> _seances = {
    SportType.swimming: [],
    SportType.cycling: [],
    SportType.running: [],
  };

  // Stockage des résultats par ID de séance
  Map<String, List<TriathlonResultat>> _resultats = {};

  // Stockage des commentaires par ID de séance
  Map<String, TriathlonSeanceCommentaire> _commentaires = {};

  // Profil triathlon
  Map<String, dynamic> _triathlonProfile = {
    'swimming_400m_time': null,
    'cycling_ftp': null,
    'running_vma': null,
    'poids': 70.0,
  };

  DataManager();

  Future<void> init() async {
    if (!_isInitialized) {
      try {
        _prefs = await SharedPreferences.getInstance();
        await _loadData();
        _isInitialized = true;
        print("DataManager initialisé avec succès");
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

  // ========== GESTION DES COMMENTAIRES DE SÉANCE ==========

  Future<void> saveCommentaireForSeance(
      TriathlonSeanceCommentaire commentaire) async {
    try {
      _commentaires[commentaire.seanceId.toString()] = commentaire;
      await _saveData();
      notifyListeners();
      print("Commentaire sauvegardé pour séance ${commentaire.seanceId}");
    } catch (e) {
      print("Erreur sauvegarde commentaire: $e");
      rethrow;
    }
  }

  TriathlonSeanceCommentaire? getCommentaireForSeance(int seanceId) {
    return _commentaires[seanceId.toString()];
  }

  Future<void> deleteCommentaireForSeance(int seanceId) async {
    try {
      if (_commentaires.containsKey(seanceId.toString())) {
        _commentaires.remove(seanceId.toString());
        await _saveData();
        notifyListeners();
        print("Commentaire supprimé pour séance $seanceId");
      }
    } catch (e) {
      print("Erreur suppression commentaire: $e");
      rethrow;
    }
  }

  // ========== GESTION DES RÉSULTATS ==========

  // MÉTHODE POUR SAUVEGARDER LES RÉSULTATS POUR UNE SÉANCE SPÉCIFIQUE
  Future<void> saveResultatsForSeance(
      int seanceId, List<TriathlonResultat> resultats) async {
    try {
      final key = seanceId.toString();

      // Remplacer tous les résultats pour cette séance
      _resultats[key] = resultats;

      await _saveData();
      notifyListeners();
      print("${resultats.length} résultats sauvegardés pour séance $seanceId");
    } catch (e) {
      print("Erreur sauvegarde résultats: $e");
      rethrow;
    }
  }

  // NOUVELLE MÉTHODE : Sauvegarder les résultats et commentaire en une fois
  Future<void> saveResultatsWithCommentaire(
      int seanceId, List<TriathlonResultat> resultats,
      {String? commentaireText}) async {
    try {
      // Sauvegarder les résultats
      final key = seanceId.toString();
      _resultats[key] = resultats;

      // Sauvegarder le commentaire si fourni
      if (commentaireText != null && commentaireText.isNotEmpty) {
        final commentaire = TriathlonSeanceCommentaire(
          id: DateTime.now().millisecondsSinceEpoch,
          seanceId: seanceId,
          commentaire: commentaireText,
          dateCreation: DateTime.now(),
        );
        _commentaires[seanceId.toString()] = commentaire;
      } else if (commentaireText != null && commentaireText.isEmpty) {
        // Si commentaire vide, supprimer le commentaire existant
        _commentaires.remove(seanceId.toString());
      }

      await _saveData();
      notifyListeners();
      print(
          "${resultats.length} résultats et commentaire sauvegardés pour séance $seanceId");
    } catch (e) {
      print("Erreur sauvegarde résultats et commentaire: $e");
      rethrow;
    }
  }

  List<TriathlonResultat> getResultatsForSeance(int seanceId) {
    return _resultats[seanceId.toString()] ?? [];
  }

  // NOUVELLE MÉTHODE : Supprimer tous les résultats pour une séance
  Future<void> deleteAllResultatsForSeance(int seanceId) async {
    try {
      final key = seanceId.toString();
      if (_resultats.containsKey(key)) {
        _resultats.remove(key);
        await _saveData();
        notifyListeners();
        print("Tous les résultats supprimés pour séance $seanceId");
      }
    } catch (e) {
      print("Erreur suppression résultats: $e");
    }
  }

  // ========== GESTION UTILISATEUR ==========
  Future<void> saveUser(String nom, String prenom) async {
    await _ensurePrefsInitialized();
    await _prefs!.setString(_keyUserNom, nom);
    await _prefs!.setString(_keyUserPrenom, prenom);
    await _prefs!.setBool(_keyFirstLaunch, false);
    notifyListeners();
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

    for (var key in profile.keys) {
      _triathlonProfile[key] = profile[key];
    }

    await _saveData();
    notifyListeners();
  }

  Map<String, dynamic> getTriathlonProfile() {
    return Map<String, dynamic>.from(_triathlonProfile);
  }

  double? getSwimming400mTime() {
    return _triathlonProfile['swimming_400m_time'];
  }

  double? getCyclingFTP() {
    return _triathlonProfile['cycling_ftp'];
  }

  double? getRunningVMA() {
    return _triathlonProfile['running_vma'];
  }

  double getPoids() {
    return _triathlonProfile['poids'] ?? 70.0;
  }

  // ========== GESTION SÉANCES ==========
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$_fileName';
    return File(filePath);
  }

  Future<bool> saveSeance(TriathlonSeance seance) async {
    try {
      List<TriathlonSeance> sportSeances = _seances[seance.sportType] ?? [];

      if (seance.id == 0) {
        seance.id = DateTime.now().millisecondsSinceEpoch;
      }

      int existingIndex = sportSeances.indexWhere((s) => s.id == seance.id);

      if (existingIndex != -1) {
        sportSeances[existingIndex] = seance;
      } else {
        sportSeances.insert(0, seance);

        if (sportSeances.length > _maxSeances) {
          sportSeances = sportSeances.sublist(0, _maxSeances);
        }
      }

      _seances[seance.sportType] = sportSeances;

      bool saved = await _saveData();
      return saved;
    } catch (e) {
      print("Erreur sauvegarde séance: $e");
      return false;
    }
  }

  Future<List<TriathlonSeance>> loadAllSeances() async {
    try {
      if (!_isInitialized) {
        await init();
      }

      List<TriathlonSeance> allSeances = [];
      for (var sport in SportType.values) {
        allSeances.addAll(_seances[sport] ?? []);
      }

      allSeances.sort((a, b) => b.id.compareTo(a.id));

      return allSeances;
    } catch (e) {
      print("Erreur chargement toutes séances: $e");
      return [];
    }
  }

  List<TriathlonSeance> getSeancesBySport(SportType sportType) {
    return List.from(_seances[sportType] ?? []);
  }

  Future<bool> deleteSeanceById(int seanceId) async {
    try {
      bool deleted = false;
      for (var sport in SportType.values) {
        List<TriathlonSeance> sportSeances = _seances[sport] ?? [];
        int initialLength = sportSeances.length;
        sportSeances.removeWhere((seance) => seance.id == seanceId);

        if (sportSeances.length < initialLength) {
          _seances[sport] = sportSeances;
          deleted = true;

          // Supprimer aussi les résultats et commentaires associés
          _resultats.remove(seanceId.toString());
          _commentaires.remove(seanceId.toString());

          break;
        }
      }

      if (deleted) {
        bool saved = await _saveData();
        return saved;
      }
      return false;
    } catch (e) {
      print("Erreur suppression séance: $e");
      return false;
    }
  }

  Future<int> getSeancesCountBySport(SportType sportType) async {
    return _seances[sportType]?.length ?? 0;
  }

  Future<bool> isLimitReached(SportType sportType) async {
    int count = _seances[sportType]?.length ?? 0;
    return count >= _maxSeances;
  }

  Future<int> getSeancesCount() async {
    int total = 0;
    for (var sport in SportType.values) {
      total += _seances[sport]?.length ?? 0;
    }
    return total;
  }

  // ========== MÉTHODES PRIVÉES ==========
  Future<void> _loadData() async {
    try {
      final file = await _getLocalFile();

      if (!await file.exists()) {
        _triathlonProfile['poids'] = 70.0;
        return;
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return;
      }

      final jsonData = json.decode(contents) as Map<String, dynamic>;

      // Charger le profil
      if (jsonData['profile'] != null) {
        _triathlonProfile = Map<String, dynamic>.from(jsonData['profile']);

        if (!_triathlonProfile.containsKey('poids')) {
          _triathlonProfile['poids'] = 70.0;
        }
      } else {
        _triathlonProfile['poids'] = 70.0;
      }

      // Charger les séances
      if (jsonData['seances'] != null) {
        final seancesData = Map<String, dynamic>.from(jsonData['seances']);

        for (var sport in SportType.values) {
          if (seancesData[sport.name] != null) {
            final seancesJson = seancesData[sport.name] as List<dynamic>;
            _seances[sport] = seancesJson
                .map((json) => TriathlonSeance.fromJson(
                      Map<String, dynamic>.from(json),
                    ))
                .toList();
          }
        }
      }

      // Charger les résultats
      if (jsonData['resultats'] != null) {
        final resultatsData = Map<String, dynamic>.from(jsonData['resultats']);

        _resultats.clear();

        for (var entry in resultatsData.entries) {
          final seanceId = entry.key;
          final resultatsJson = entry.value as List<dynamic>;

          _resultats[seanceId] = resultatsJson.map((json) {
            final map = Map<String, dynamic>.from(json);
            // Pour la compatibilité avec les anciennes données
            if (!map.containsKey('seanceId')) {
              map['seanceId'] = int.tryParse(seanceId) ?? 0;
            }
            return TriathlonResultat.fromJson(map);
          }).toList();
        }
      }

      // Charger les commentaires
      if (jsonData['commentaires'] != null) {
        final commentairesData =
            Map<String, dynamic>.from(jsonData['commentaires']);

        _commentaires.clear();

        for (var entry in commentairesData.entries) {
          final seanceId = entry.key;
          final commentaireJson = entry.value as Map<String, dynamic>;

          // Pour la compatibilité avec les anciennes données
          if (!commentaireJson.containsKey('seanceId')) {
            commentaireJson['seanceId'] = int.tryParse(seanceId) ?? 0;
          }

          _commentaires[seanceId] =
              TriathlonSeanceCommentaire.fromJson(commentaireJson);
        }
      }
    } catch (e) {
      print("Erreur chargement données: $e");
      _triathlonProfile['poids'] = 70.0;
    }
  }

  Future<bool> _saveData() async {
    try {
      final file = await _getLocalFile();

      Map<String, dynamic> dataToSave = {
        'profile': _triathlonProfile,
        'seances': {
          for (var sport in SportType.values)
            sport.name: _seances[sport]?.map((s) => s.toJson()).toList() ?? [],
        },
        'resultats': {
          for (var entry in _resultats.entries)
            entry.key: entry.value.map((r) => r.toJson()).toList(),
        },
        'commentaires': {
          for (var entry in _commentaires.entries)
            entry.key: entry.value.toJson(),
        },
      };

      final jsonString = json.encode(dataToSave);
      await file.writeAsString(jsonString);

      notifyListeners();
      return true;
    } catch (e) {
      print("Erreur sauvegarde données: $e");
      return false;
    }
  }

  // ========== MÉTHODES DE COMPATIBILITÉ ==========
  Future<bool> saveTriathlonSeance(TriathlonSeance seance) async {
    return saveSeance(seance);
  }

  Future<List<TriathlonSeance>> loadAllTriathlonSeances() async {
    return loadAllSeances();
  }

  Future<bool> deleteTriathlonSeance(String id) async {
    int? seanceId = int.tryParse(id);
    if (seanceId != null) {
      return deleteSeanceById(seanceId);
    }
    return false;
  }

  Future<bool> isTriathlonLimitReached() async {
    int total = await getSeancesCount();
    return total >= _maxSeances;
  }

  // ========== MÉTHODES UTILITAIRES ==========
  Future<void> clearAllData() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        await file.delete();
      }

      await _ensurePrefsInitialized();
      await _prefs!.clear();

      _seances = {
        SportType.swimming: [],
        SportType.cycling: [],
        SportType.running: [],
      };

      _resultats = {};
      _commentaires = {};

      _triathlonProfile = {
        'swimming_400m_time': null,
        'cycling_ftp': null,
        'running_vma': null,
        'poids': 70.0,
      };

      notifyListeners();
    } catch (e) {
      print("Erreur suppression données: $e");
    }
  }
}
