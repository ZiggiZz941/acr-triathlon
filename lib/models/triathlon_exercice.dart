import 'sport_type.dart';

class TriathlonExercice {
  int id;
  String nom;
  SportType sportType;
  double distance; // en mètres
  int nbSeries;
  int nbRepetitions;
  double
      valeurReference; // VMA (km/h) pour running, temps 100m (s) pour swimming, FTP (watts) pour cycling
  int? allure; // 1-6 pour running
  int? intensite; // % pour swimming/cycling
  int reposRepetitionsSec;
  int reposSeriesSec;
  double tempsMin;
  double tempsMax;
  DateTime dateCreation;
  double tempsReference;

  TriathlonExercice({
    required this.id,
    required this.nom,
    required this.sportType,
    required this.distance,
    required this.nbSeries,
    required this.nbRepetitions,
    required this.valeurReference,
    this.allure,
    this.intensite,
    this.reposRepetitionsSec = 0,
    this.reposSeriesSec = 0,
    this.tempsMin = 0,
    this.tempsMax = 0,
    DateTime? dateCreation,
    this.tempsReference = 0,
  }) : dateCreation = dateCreation ?? DateTime.now();

  // Getters pour les propriétés formatées
  String get reposRepetitionsFormate =>
      _formatTempsEnMinutes(reposRepetitionsSec);
  String get reposSeriesFormate => _formatTempsEnMinutes(reposSeriesSec);

  // Méthode pour formater la distance
  String getDistanceFormatee() {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    } else {
      return '${distance.toInt()} m';
    }
  }

  // Méthode pour formater le temps
  String formatTemps(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    double remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toStringAsFixed(0).padLeft(2, '0')}';
    } else {
      return '${remainingSeconds.toStringAsFixed(0)} sec';
    }
  }

  // Méthode pour parser le temps
  static int parseTempsEnSecondes(String tempsStr) {
    try {
      if (tempsStr.contains(":")) {
        List<String> parties = tempsStr.split(":");
        if (parties.length == 2) {
          int minutes = int.parse(parties[0]);
          int secondes = int.parse(parties[1]);
          return (minutes * 60) + secondes;
        }
      }
      return int.parse(tempsStr);
    } catch (e) {
      return 0;
    }
  }

  // Méthode pour formater le temps en minutes
  static String formatTempsEnMinutes(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '$remainingSeconds sec';
    }
  }

  // Méthode pour calculer les temps
  void calculerTemps() {
    switch (sportType) {
      case SportType.running:
        _calculerTempsRunning();
        break;
      case SportType.swimming:
        _calculerTempsSwimming();
        break;
      case SportType.cycling:
        _calculerTempsCycling();
        break;
    }
  }

  void _calculerTempsRunning() {
    // Calcul basé sur VMA et allure
    double vitesseKmh = valeurReference * (_getPourcentageAllure() / 100);
    double vitesseMs = vitesseKmh / 3.6;
    tempsMin = distance / vitesseMs;
    tempsMax = tempsMin; // Pour running, temps fixe
  }

  void _calculerTempsSwimming() {
    // Calcul basé sur temps 100m et intensité
    double temps100m = valeurReference;
    double intensitePourcentage = (intensite ?? 80) / 100.0;
    double tempsBase = (temps100m * distance) / 100.0;
    tempsMin = tempsBase / intensitePourcentage;
    tempsMax = tempsMin; // Pour swimming, temps fixe
  }

  void _calculerTempsCycling() {
    if (valeurReference <= 0 || distance <= 0) {
      tempsMin = 0;
      tempsMax = 0;
      return;
    }

    double puissance = valeurReference * ((intensite ?? 80) / 100.0);
    double vitesseKmh = (puissance * 0.1) + 20; // Formule simplifiée

    // Convertir la distance de mètres en km
    double distanceKm = distance / 1000.0;
    double tempsHeures = distanceKm / vitesseKmh;
    tempsMin = tempsHeures * 3600; // Convertir en secondes
    tempsMax = tempsMin;
  }

  double _getPourcentageAllure() {
    switch (allure ?? 3) {
      case 1:
        return 65; // Allure 1: 65%
      case 2:
        return 75; // Allure 2: 75%
      case 3:
        return 82; // Allure 3: 82%
      case 4:
        return 88; // Allure 4: 88%
      case 5:
        return 93; // Allure 5: 93%
      case 6:
        return 100; // Allure 6: 100% (VMA)
      default:
        return 82;
    }
  }

  // Description de l'exercice
  String getDescription() {
    String distanceStr = getDistanceFormatee();
    return '$nbSeries séries de $nbRepetitions x $distanceStr';
  }

  String getDescriptionDetaillee() {
    String distanceStr = getDistanceFormatee();
    String tempsStr = formatTemps(tempsMin);

    return '$nbSeries séries de $nbRepetitions x $distanceStr à $tempsStr\n'
        'Repos répétitions: $reposRepetitionsFormate\n'
        'Repos séries: $reposSeriesFormate';
  }

  // Méthode privée pour formater le temps
  String _formatTempsEnMinutes(int seconds) {
    return formatTempsEnMinutes(seconds);
  }

  // Conversion JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'sportType': sportType.name,
      'distance': distance,
      'nbSeries': nbSeries,
      'nbRepetitions': nbRepetitions,
      'valeurReference': valeurReference,
      'allure': allure,
      'intensite': intensite,
      'reposRepetitionsSec': reposRepetitionsSec,
      'reposSeriesSec': reposSeriesSec,
      'tempsMin': tempsMin,
      'tempsMax': tempsMax,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  factory TriathlonExercice.fromJson(Map<String, dynamic> json) {
    return TriathlonExercice(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      sportType: SportType.values.firstWhere(
        (e) => e.name == json['sportType'],
        orElse: () => SportType.running,
      ),
      distance: (json['distance'] ?? 0).toDouble(),
      nbSeries: json['nbSeries'] ?? 1,
      nbRepetitions: json['nbRepetitions'] ?? 1,
      valeurReference: (json['valeurReference'] ?? 0).toDouble(),
      allure: json['allure'],
      intensite: json['intensite'],
      reposRepetitionsSec: json['reposRepetitionsSec'] ?? 0,
      reposSeriesSec: json['reposSeriesSec'] ?? 0,
      tempsMin: (json['tempsMin'] ?? 0).toDouble(),
      tempsMax: (json['tempsMax'] ?? 0).toDouble(),
      dateCreation: DateTime.parse(
          json['dateCreation'] ?? DateTime.now().toIso8601String()),
    );
  }

  get vma => null;
}
