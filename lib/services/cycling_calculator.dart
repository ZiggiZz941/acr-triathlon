// Classe CyclingCalculator améliorée
class CyclingCalculator {
  // Calculer la puissance pour une intensité donnée
  static double calculatePowerFromFTP({
    required double ftp, // FTP en watts
    required double intensity, // Intensité en pourcentage (70 = 70% FTP)
  }) {
    return ftp * (intensity / 100.0);
  }

  // Calculer le temps pour une distance avec une puissance donnée
  static double calculateTimeForDistance({
    required double power, // Puissance en watts
    required double distance, // Distance en km
    required double weight, // Poids du cycliste en kg
    required double elevation, // Dénivelé en mètres
  }) {
    // Calculer la vitesse avec une formule plus réaliste
    double speedKmh = _calculateRealisticSpeed(
      power: power,
      weight: weight,
      elevation: elevation,
    );

    // Calcul du temps
    double timeHours = distance / speedKmh;
    return timeHours * 3600; // Convertir en secondes
  }

  // Calculer la vitesse moyenne avec formule plus réaliste
  static double calculateAverageSpeed({
    required double power,
    required double weight,
    double elevation = 0,
  }) {
    return _calculateRealisticSpeed(
      power: power,
      weight: weight,
      elevation: elevation,
    );
  }

  // Formule réaliste de calcul de vitesse
  static double _calculateRealisticSpeed({
    required double power,
    required double weight,
    double elevation = 0,
  }) {
    // Constantes pour le calcul
    const double g = 9.81; // gravité en m/s²
    const double rho = 1.225; // densité de l'air en kg/m³
    const double cdA =
        0.4; // coefficient de traînée x surface (m²) - valeur typique pour vélo de route
    const double crr = 0.005; // coefficient de résistance au roulement
    const double drivetrainLoss = 0.03; // perte de transmission (3%)

    // Convertir la puissance en watts effectifs
    double effectivePower = power * (1 - drivetrainLoss);

    // Calcul de la pente à partir du dénivelé (pour 1km)
    double slope = elevation / 1000; // pente en m/m

    // Vitesse en m/s (on résout l'équation de puissance)
    // Puissance = Résistance de l'air + Résistance au roulement + Résistance gravitationnelle

    // On utilise une méthode itérative pour résoudre l'équation
    double v = 5.0; // vitesse initiale en m/s (18 km/h)

    for (int i = 0; i < 20; i++) {
      // 20 itérations suffisent
      // Résistance de l'air
      double airResistance = 0.5 * cdA * rho * v * v * v;

      // Résistance au roulement
      double rollingResistance = crr * weight * g * v;

      // Résistance gravitationnelle
      double gravitationalResistance = slope * weight * g * v;

      // Puissance totale requise
      double requiredPower =
          airResistance + rollingResistance + gravitationalResistance;

      // Ajuster la vitesse
      double deltaV = (effectivePower - requiredPower) /
          (3 * 0.5 * cdA * rho * v * v + crr * weight * g + slope * weight * g);
      v += deltaV * 0.3; // facteur de relaxation pour stabilité

      if (v < 0) v = 0.1;
      if (v > 30) v = 30; // limite à ~108 km/h (réaliste)
    }

    // Convertir en km/h
    double speedKmh = v * 3.6;

    // Ajustements pour pente forte
    if (slope > 0.08) {
      // pente > 8%
      // Réduction significative de vitesse en montée raide
      speedKmh *= (1 - (slope - 0.08) * 5);
    } else if (slope < -0.05) {
      // descente > 5%
      // Augmentation modérée en descente
      speedKmh *= (1 - slope * 2);
    }

    // Limites réalistes
    if (slope > 0.10) {
      // pente > 10%
      speedKmh = speedKmh.clamp(5, 25);
    } else if (slope > 0.05) {
      // pente > 5%
      speedKmh = speedKmh.clamp(10, 35);
    } else if (slope < -0.08) {
      // descente > 8%
      speedKmh = speedKmh.clamp(30, 80);
    } else if (slope < -0.03) {
      // descente > 3%
      speedKmh = speedKmh.clamp(25, 60);
    } else {
      // Terrain plat ou légèrement vallonné
      speedKmh = speedKmh.clamp(15, 50);
    }

    return speedKmh;
  }

  // Calculer la puissance nécessaire pour une vitesse donnée
  static double calculatePowerForSpeed({
    required double targetSpeed, // Vitesse cible en km/h
    required double weight,
    double elevation = 0,
  }) {
    // Vitesse en m/s
    double v = targetSpeed / 3.6;

    // Constantes
    const double g = 9.81;
    const double rho = 1.225;
    const double cdA = 0.4;
    const double crr = 0.005;
    const double drivetrainLoss = 0.03;

    // Calcul de la pente
    double slope = elevation / 1000;

    // Résistance de l'air
    double airResistance = 0.5 * cdA * rho * v * v * v;

    // Résistance au roulement
    double rollingResistance = crr * weight * g * v;

    // Résistance gravitationnelle
    double gravitationalResistance = slope * weight * g * v;

    // Puissance requise sur la roue arrière
    double requiredPower =
        airResistance + rollingResistance + gravitationalResistance;

    // Ajouter les pertes de transmission
    double power = requiredPower / (1 - drivetrainLoss);

    return power.clamp(50, 1000); // Limites réalistes
  }

  // Convertir des watts en watts/kg
  static double calculateWattsPerKg({
    required double power,
    required double weight,
  }) {
    if (weight <= 0) return 0;
    return power / weight;
  }

  // Formater le temps cyclisme
  static String formatCyclingTime(double seconds) {
    int hours = (seconds ~/ 3600).toInt();
    int minutes = ((seconds % 3600) ~/ 60).toInt();
    int secs = (seconds % 60).toInt();

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}min ${secs.toString().padLeft(2, '0')}s';
    } else if (minutes > 0) {
      return '${minutes}min ${secs.toString().padLeft(2, '0')}s';
    } else {
      return '${secs}s';
    }
  }

  // Calculer les zones d'entraînement basées sur FTP
  static Map<String, Map<String, dynamic>> getTrainingZones(double ftp) {
    return {
      'Zone 1': {
        'name': 'Récupération active',
        'min': ftp * 0.55,
        'max': ftp * 0.75,
        'description': 'Pour la récupération',
      },
      'Zone 2': {
        'name': 'Endurance',
        'min': ftp * 0.75,
        'max': ftp * 0.85,
        'description': 'Base aérobie',
      },
      'Zone 3': {
        'name': 'Tempo',
        'min': ftp * 0.85,
        'max': ftp * 0.95,
        'description': 'Seuil aérobie',
      },
      'Zone 4': {
        'name': 'Seuil lactique',
        'min': ftp * 0.95,
        'max': ftp * 1.05,
        'description': 'Seuil anaérobie',
      },
      'Zone 5': {
        'name': 'VO2 Max',
        'min': ftp * 1.05,
        'max': ftp * 1.20,
        'description': 'Puissance aérobie',
      },
      'Zone 6': {
        'name': 'Anaérobie',
        'min': ftp * 1.20,
        'max': ftp * 1.50,
        'description': 'Capacité anaérobie',
      },
    };
  }
}
