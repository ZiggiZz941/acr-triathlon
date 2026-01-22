class CyclingConverter {
  // Calculer la puissance à partir du FTP
  static double calculatePower(double ftp, double intensityPercent) {
    if (ftp <= 0 || intensityPercent <= 0) return 0.0;
    return ftp * (intensityPercent / 100.0);
  }

  // Calculer la vitesse estimée
  static double calculateSpeed({
    required double power,
    required double weight,
    double elevation = 0,
    double wind = 0,
    double gradient = 0,
  }) {
    if (power <= 0 || weight <= 0) return 0.0;

    // Formule simplifiée basée sur la puissance
    double baseSpeed = 20.0 + (power * 0.1);

    // Ajustements
    if (elevation > 0) {
      double elevationFactor = elevation / 1000.0;
      baseSpeed *= (1.0 - (elevationFactor * 0.1));
    }

    if (gradient != 0) {
      baseSpeed *= (1.0 - (gradient.abs() * 0.05));
    }

    if (wind != 0) {
      baseSpeed *= (1.0 - (wind.abs() * 0.03));
    }

    // Limites réalistes
    return baseSpeed.clamp(10.0, 60.0);
  }

  // Calculer le temps pour une distance
  static double calculateTime({
    required double distance, // en km
    required double speed, // en km/h
  }) {
    if (distance <= 0 || speed <= 0) return 0.0;
    return (distance / speed) * 3600.0; // en secondes
  }

  // Formater le temps cyclisme
  static String formatCyclingTime(double seconds) {
    if (seconds <= 0) return "0:00";

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

  // Calculer les watts/kg
  static double calculateWattsPerKg(double power, double weight) {
    if (weight <= 0) return 0.0;
    return power / weight;
  }

  // Déterminer la zone d'entraînement
  static String determineTrainingZone(double ftp, double currentPower) {
    double percentage = (currentPower / ftp) * 100;

    if (percentage <= 75) return 'Zone 1';
    if (percentage <= 85) return 'Zone 2';
    if (percentage <= 95) return 'Zone 3';
    if (percentage <= 105) return 'Zone 4';
    if (percentage <= 120) return 'Zone 5';
    return 'Zone 6';
  }

  // Calculer les calories brûlées (estimation)
  static double estimateCalories({
    required double power,
    required double timeHours,
    required double weight,
  }) {
    // Estimation basée sur la puissance et le temps
    double caloriesPerHour = power * 3.6; // 1 watt ≈ 3.6 calories/heure
    return caloriesPerHour *
        timeHours *
        (weight / 70.0); // ajusté pour le poids
  }

  // Convertir la vitesse en allure (min/km)
  static String speedToPace(double speedKmh) {
    if (speedKmh <= 0) return "0:00";

    double minutesPerKm = 60.0 / speedKmh;
    int minutes = minutesPerKm.floor();
    int seconds = ((minutesPerKm - minutes) * 60).round();

    if (seconds == 60) {
      minutes++;
      seconds = 0;
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
