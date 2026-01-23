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
  int? intensite; // % pour swimming/cycling (stocke la valeur max)
  int? intensiteMin; // % min pour plage d'intensité (NOUVEAU)
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
    this.intensiteMin, // NOUVEAU
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
  String formatTemps(double seconds, {bool avecCentiemes = false}) {
    int minutes = (seconds ~/ 60).toInt();
    double remainingSeconds = seconds % 60;

    if (avecCentiemes) {
      if (minutes > 0) {
        return '${minutes}:${remainingSeconds.toStringAsFixed(2).padLeft(5, '0')}';
      } else {
        return '${remainingSeconds.toStringAsFixed(2)} sec';
      }
    } else {
      if (minutes > 0) {
        return '$minutes:${remainingSeconds.toStringAsFixed(0).padLeft(2, '0')}';
      } else {
        return '${remainingSeconds.toStringAsFixed(0)} sec';
      }
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
    if (valeurReference <= 0 || distance <= 0) {
      tempsMin = 0;
      tempsMax = 0;
      return;
    }

    // Définir les pourcentages selon l'allure (même que dans CalculSimpleScreen)
    double pourcentageMin, pourcentageMax;

    switch (allure ?? 3) {
      case 1: // Allure 1
        pourcentageMin = 60;
        pourcentageMax = 70;
        break;
      case 2: // Allure 2
        pourcentageMin = 70;
        pourcentageMax = 80;
        break;
      case 3: // Allure 3
        pourcentageMin = 80;
        pourcentageMax = 85;
        break;
      case 4: // Allure 4
        pourcentageMin = 85;
        pourcentageMax = 90;
        break;
      case 5: // Allure 5
        pourcentageMin = 90;
        pourcentageMax = 95;
        break;
      case 6: // VMA
        pourcentageMin = 100;
        pourcentageMax = 100;
        break;
      default:
        pourcentageMin = 80;
        pourcentageMax = 85;
    }

    // Calcul du temps de base (100%)
    double vitesseKmh = valeurReference;
    double vitesseMs = vitesseKmh / 3.6;
    double tempsBase100 = distance / vitesseMs;

    // Calcul des temps min et max selon la tranche
    tempsMax = tempsBase100 / (pourcentageMin / 100.0);
    tempsMin = tempsBase100 / (pourcentageMax / 100.0);

    // S'il s'agit d'une allure unique (VMA), garder seulement tempsMin
    if (pourcentageMin == pourcentageMax) {
      tempsMax = tempsMin;
    }
  }

  void _calculerTempsSwimming() {
    if (valeurReference <= 0 || distance <= 0) {
      tempsMin = 0;
      tempsMax = 0;
      return;
    }

    // Calcul basé sur temps 100m et intensité
    double temps100m = valeurReference;
    double tempsBase = (temps100m * distance) / 100.0;

    // Vérifier si on a une plage d'intensité
    if (intensiteMin != null &&
        intensite != null &&
        intensiteMin != intensite) {
      // Plage d'intensité (ex: 75-85%)
      double intensiteMinPourcentage = intensiteMin! / 100.0;
      double intensiteMaxPourcentage = intensite! / 100.0;

      // Plus rapide = intensité plus élevée = temps plus court
      tempsMin = tempsBase / intensiteMaxPourcentage;
      tempsMax = tempsBase / intensiteMinPourcentage;
    } else {
      // Intensité unique
      double intensitePourcentage = (intensite ?? 80) / 100.0;
      tempsMin = tempsBase / intensitePourcentage;
      tempsMax = tempsMin; // Pour swimming avec intensité unique
    }
  }

  void _calculerTempsCycling() {
    if (valeurReference <= 0 || distance <= 0) {
      tempsMin = 0;
      tempsMax = 0;
      return;
    }

    // Vérifier si on a une plage d'intensité
    if (intensiteMin != null &&
        intensite != null &&
        intensiteMin != intensite) {
      // Plage d'intensité (ex: 75-85%)
      double intensiteMinPourcentage = intensiteMin! / 100.0;
      double intensiteMaxPourcentage = intensite! / 100.0;

      double puissanceMin = valeurReference * intensiteMinPourcentage;
      double puissanceMax = valeurReference * intensiteMaxPourcentage;

      double vitesseMinKmh = (puissanceMin * 0.1) + 20; // Formule simplifiée
      double vitesseMaxKmh = (puissanceMax * 0.1) + 20;

      // Convertir la distance de mètres en km
      double distanceKm = distance / 1000.0;

      // Plus lent (min intensité) = temps max
      tempsMax = (distanceKm / vitesseMinKmh) * 3600;
      // Plus rapide (max intensité) = temps min
      tempsMin = (distanceKm / vitesseMaxKmh) * 3600;
    } else {
      // Intensité unique
      double puissance = valeurReference * ((intensite ?? 80) / 100.0);
      double vitesseKmh = (puissance * 0.1) + 20; // Formule simplifiée

      // Convertir la distance de mètres en km
      double distanceKm = distance / 1000.0;
      double tempsHeures = distanceKm / vitesseKmh;
      tempsMin = tempsHeures * 3600; // Convertir en secondes
      tempsMax = tempsMin;
    }
  }

  // Description de l'exercice
  String getDescription() {
    String distanceStr = getDistanceFormatee();
    return '$nbSeries séries de $nbRepetitions x $distanceStr';
  }

  String getDescriptionDetaillee() {
    String distanceStr = getDistanceFormatee();

    // Formater les temps avec centièmes
    String tempsMinFormatted = _formatTimeAvecCentiemes(tempsMin);
    String tempsMaxFormatted = _formatTimeAvecCentiemes(tempsMax);

    if (sportType == SportType.running) {
      String allureStr = _getAllureDescription();

      String resultText;
      if ((allure ?? 3) == 6) {
        // Allure 6 (VMA) - temps unique
        resultText = 'Temps : $tempsMinFormatted';
      } else {
        // Plage de temps pour les allures 1-5
        resultText = 'Temps : $tempsMinFormatted à $tempsMaxFormatted';
      }

      return '$nbSeries séries de $nbRepetitions x $distanceStr ($allureStr)\n'
          '$resultText\n'
          'Repos répétitions: $reposRepetitionsFormate\n'
          'Repos séries: $reposSeriesFormate';
    } else {
      // Pour swimming et cycling
      String intensiteStr = _getIntensiteDescription();

      String resultText;
      if (intensiteMin != null &&
          intensite != null &&
          intensiteMin != intensite) {
        // Plage d'intensité
        resultText = 'Temps : $tempsMinFormatted à $tempsMaxFormatted';
      } else {
        // Intensité unique
        resultText = 'Temps : $tempsMinFormatted';
      }

      return '$nbSeries séries de $nbRepetitions x $distanceStr à $intensiteStr\n'
          '$resultText\n'
          'Repos répétitions: $reposRepetitionsFormate\n'
          'Repos séries: $reposSeriesFormate';
    }
  }

  // Méthode pour obtenir la description de l'allure
  String _getAllureDescription() {
    final allureNum = allure ?? 3;
    switch (allureNum) {
      case 1:
        return 'Allure 1 (60-70% VMA)';
      case 2:
        return 'Allure 2 (70-80% VMA)';
      case 3:
        return 'Allure 3 (80-85% VMA)';
      case 4:
        return 'Allure 4 (85-90% VMA)';
      case 5:
        return 'Allure 5 (90-95% VMA)';
      case 6:
        return 'VMA (100%)';
      default:
        return 'Allure 3 (80-85% VMA)';
    }
  }

  // NOUVELLE méthode pour obtenir la description de l'intensité
  String _getIntensiteDescription() {
    if (intensiteMin != null &&
        intensite != null &&
        intensiteMin != intensite) {
      return '${intensiteMin}%-${intensite}%';
    } else {
      return '${intensite ?? 80}%';
    }
  }

  // Méthode pour formater le temps avec centièmes (identique à CalculSimpleScreen)
  String _formatTimeAvecCentiemes(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    double secondesDecimal = seconds % 60;

    if (secondesDecimal >= 60) {
      minutes += (secondesDecimal ~/ 60).toInt();
      secondesDecimal = secondesDecimal % 60;
    }

    if (minutes > 0) {
      return '${minutes}:${secondesDecimal.toStringAsFixed(2).padLeft(5, '0')}';
    } else {
      return '${secondesDecimal.toStringAsFixed(2)} sec';
    }
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
      'intensiteMin': intensiteMin, // NOUVEAU
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
      intensiteMin: json['intensiteMin'], // NOUVEAU
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
