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
    required double weight, // Poids du cycliste en kg (optionnel)
    required double elevation, // Dénivelé en mètres (optionnel)
  }) {
    // Formule simplifiée basée sur la puissance
    // Vitesse approximative (km/h) = (Puissance * 0.1) + 20
    // C'est une approximation - dans la réalité c'est plus complexe

    double speedKmh = (power * 0.1) + 20;

    // Ajuster pour le dénivelé
    if (elevation > 0) {
      double elevationFactor = elevation / 1000; // pour 1000m de dénivelé
      speedKmh *= (1 - (elevationFactor * 0.1));
    }

    // Limiter la vitesse
    speedKmh = speedKmh.clamp(10, 50);

    // Calcul du temps
    double timeHours = distance / speedKmh;
    return timeHours * 3600; // Convertir en secondes
  }

  // Calculer la vitesse moyenne
  static double calculateAverageSpeed({
    required double power,
    required double weight,
    double elevation = 0,
  }) {
    double baseSpeed = (power * 0.1) + 20;

    if (elevation > 0) {
      double elevationFactor = elevation / 1000;
      baseSpeed *= (1 - (elevationFactor * 0.1));
    }

    return baseSpeed.clamp(10, 50);
  }

  // Calculer la puissance nécessaire pour une vitesse donnée
  static double calculatePowerForSpeed({
    required double targetSpeed, // Vitesse cible en km/h
    required double weight,
    double elevation = 0,
  }) {
    // Formule inverse
    double adjustedSpeed = targetSpeed;

    if (elevation > 0) {
      double elevationFactor = elevation / 1000;
      adjustedSpeed /= (1 - (elevationFactor * 0.1));
    }

    double power = (adjustedSpeed - 20) / 0.1;
    return power.clamp(50, 500); // Limites réalistes
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
      return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
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
