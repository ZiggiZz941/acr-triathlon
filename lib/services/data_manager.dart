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

  Map<String, List<TriathlonResultat>> _resultats = {};
  Map<String, TriathlonSeanceCommentaire> _commentaires = {};

  // MODIFICATION IMPORTANTE : Stocker le profil dans JSON aussi
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
        print("Profil chargé: $_triathlonProfile");
        print(
            "Séances chargées: ${_seances.values.fold<int>(0, (sum, list) => sum + list.length)}");
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

  // ========== GESTION DES COMMENTAIRES ==========

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

  Future<void> saveResultatsForSeance(
      int seanceId, List<TriathlonResultat> resultats) async {
    try {
      final key = seanceId.toString();
      _resultats[key] = resultats;
      await _saveData();
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
      final key = seanceId.toString();
      _resultats[key] = resultats;

      // Sauvegarder le commentaire
      if (commentaireText != null && commentaireText.isNotEmpty) {
        final commentaire = TriathlonSeanceCommentaire(
          id: DateTime.now().millisecondsSinceEpoch,
          seanceId: seanceId,
          commentaire: commentaireText,
          dateCreation: DateTime.now(),
        );
        _commentaires[seanceId.toString()] = commentaire;
      } else if (commentaireText != null && commentaireText.isEmpty) {
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
  // MODIFICATION CRITIQUE : Toujours sauvegarder dans JSON
  Future<void> saveTriathlonProfile(Map<String, dynamic> profile) async {
    try {
      print("Sauvegarde du profil triathlon: $profile");

      // Mettre à jour le profil en mémoire
      for (var key in profile.keys) {
        _triathlonProfile[key] = profile[key];
      }

      // Sauvegarder dans le fichier JSON
      await _saveData();

      notifyListeners();
      print("Profil triathlon sauvegardé avec succès");
    } catch (e) {
      print("Erreur sauvegarde profil triathlon: $e");
      rethrow;
    }
  }

  Map<String, dynamic> getTriathlonProfile() {
    return Map<String, dynamic>.from(_triathlonProfile);
  }

  double? getSwimming400mTime() {
    final time = _triathlonProfile['swimming_400m_time'];
    return time != null
        ? (time is int ? time.toDouble() : time as double?)
        : null;
  }

  double? getCyclingFTP() {
    final ftp = _triathlonProfile['cycling_ftp'];
    return ftp != null ? (ftp is int ? ftp.toDouble() : ftp as double?) : null;
  }

  double? getRunningVMA() {
    final vma = _triathlonProfile['running_vma'];
    return vma != null ? (vma is int ? vma.toDouble() : vma as double?) : null;
  }

  double getPoids() {
    final poids = _triathlonProfile['poids'];
    if (poids == null) return 70.0;
    return poids is int ? poids.toDouble() : poids as double;
  }

  // ========== GESTION SÉANCES ==========
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$_fileName';
    print("Chemin du fichier JSON: $filePath");
    return File(filePath);
  }

  Future<bool> saveSeance(TriathlonSeance seance) async {
    try {
      print(
          "Sauvegarde de la séance: ${seance.nom} (${seance.sportType.name})");

      List<TriathlonSeance> sportSeances = _seances[seance.sportType] ?? [];

      // Assigner un ID si nécessaire
      if (seance.id == 0) {
        seance.id = DateTime.now().millisecondsSinceEpoch;
      }

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

      _seances[seance.sportType] = sportSeances;

      // Sauvegarder dans le fichier JSON
      bool saved = await _saveData();

      if (saved) {
        print("Séance sauvegardée avec succès");
        print(
            "Nombre de séances ${seance.sportType.name}: ${sportSeances.length}");
      }

      return saved;
    } catch (e) {
      print("Erreur sauvegarde séance: $e");
      print("Stack trace: ${e.toString()}");
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

      print("${allSeances.length} séances chargées");
      return allSeances;
    } catch (e) {
      print("Erreur chargement toutes séances: $e");
      return [];
    }
  }

  List<TriathlonSeance> getSeancesBySport(SportType sportType) {
    final seances = _seances[sportType] ?? [];
    print("${seances.length} séances récupérées pour ${sportType.name}");
    return List.from(seances);
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

          // Supprimer les données associées
          _resultats.remove(seanceId.toString());
          _commentaires.remove(seanceId.toString());

          print("Séance $seanceId supprimée");
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
    final count = _seances[sportType]?.length ?? 0;
    print("Nombre de séances ${sportType.name}: $count");
    return count;
  }

  Future<bool> isLimitReached(SportType sportType) async {
    int count = _seances[sportType]?.length ?? 0;
    final reached = count >= _maxSeances;
    print(
        "Limite atteinte pour ${sportType.name}? $reached ($count/$_maxSeances)");
    return reached;
  }

  Future<int> getSeancesCount() async {
    int total = 0;
    for (var sport in SportType.values) {
      total += _seances[sport]?.length ?? 0;
    }
    print("Total séances: $total");
    return total;
  }

  // ========== CHARGEMENT DES DONNÉES ==========
  Future<void> _loadData() async {
    try {
      final file = await _getLocalFile();

      if (!await file.exists()) {
        print("Fichier JSON n'existe pas, création avec valeurs par défaut");
        _triathlonProfile['poids'] = 70.0;
        return;
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        print("Fichier JSON vide");
        _triathlonProfile['poids'] = 70.0;
        return;
      }

      print("Chargement des données depuis JSON...");
      final jsonData = json.decode(contents) as Map<String, dynamic>;

      // Charger le profil
      if (jsonData['profile'] != null) {
        _triathlonProfile = Map<String, dynamic>.from(jsonData['profile']);

        // Conversion des types pour compatibilité
        _convertProfileTypes();

        print("Profil chargé: $_triathlonProfile");
      } else {
        _triathlonProfile['poids'] = 70.0;
        print("Profil non trouvé, valeurs par défaut utilisées");
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
            print(
                "${_seances[sport]!.length} séances chargées pour ${sport.name}");
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
            if (!map.containsKey('seanceId')) {
              map['seanceId'] = int.tryParse(seanceId) ?? 0;
            }
            return TriathlonResultat.fromJson(map);
          }).toList();
        }
        print("${_resultats.length} séries de résultats chargées");
      }

      // Charger les commentaires
      if (jsonData['commentaires'] != null) {
        final commentairesData =
            Map<String, dynamic>.from(jsonData['commentaires']);
        _commentaires.clear();

        for (var entry in commentairesData.entries) {
          final seanceId = entry.key;
          final commentaireJson = entry.value as Map<String, dynamic>;

          if (!commentaireJson.containsKey('seanceId')) {
            commentaireJson['seanceId'] = int.tryParse(seanceId) ?? 0;
          }

          _commentaires[seanceId] =
              TriathlonSeanceCommentaire.fromJson(commentaireJson);
        }
        print("${_commentaires.length} commentaires chargés");
      }

      print("Données chargées avec succès");
    } catch (e, stackTrace) {
      print("Erreur chargement données: $e");
      print("Stack trace: $stackTrace");

      // Réinitialiser avec valeurs par défaut en cas d'erreur
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
    }
  }

  void _convertProfileTypes() {
    // Convertir les types si nécessaire
    if (_triathlonProfile['swimming_400m_time'] is int) {
      _triathlonProfile['swimming_400m_time'] =
          (_triathlonProfile['swimming_400m_time'] as int).toDouble();
    }
    if (_triathlonProfile['cycling_ftp'] is int) {
      _triathlonProfile['cycling_ftp'] =
          (_triathlonProfile['cycling_ftp'] as int).toDouble();
    }
    if (_triathlonProfile['running_vma'] is int) {
      _triathlonProfile['running_vma'] =
          (_triathlonProfile['running_vma'] as int).toDouble();
    }
    if (_triathlonProfile['poids'] is int) {
      _triathlonProfile['poids'] =
          (_triathlonProfile['poids'] as int).toDouble();
    }
  }

  // ========== SAUVEGARDE DES DONNÉES ==========
  Future<bool> _saveData() async {
    try {
      final file = await _getLocalFile();

      // Préparer les données à sauvegarder
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

      // Convertir en JSON
      final jsonString = json.encode(dataToSave);

      // Sauvegarder dans le fichier
      await file.writeAsString(jsonString);

      print("Données sauvegardées avec succès");
      print("Taille du fichier: ${jsonString.length} caractères");

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print("Erreur sauvegarde données: $e");
      print("Stack trace: $stackTrace");
      return false;
    }
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
      print("Toutes les données ont été effacées");
    } catch (e) {
      print("Erreur suppression données: $e");
    }
  }

  Future<void> debugPrintData() async {
    print("=== ÉTAT DU DATAMANAGER ===");
    print("Profil: $_triathlonProfile");

    for (var sport in SportType.values) {
      final seances = _seances[sport] ?? [];
      print("${sport.name}: ${seances.length} séances");
      for (var seance in seances) {
        print("  - ${seance.nom} (ID: ${seance.id})");
      }
    }

    print("Résultats: ${_resultats.length} séances");
    print("Commentaires: ${_commentaires.length} séances");
    print("==========================");
  }
}
