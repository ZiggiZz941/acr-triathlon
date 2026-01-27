class SwimmingCalculator {
  // Calcul du temps à une intensité donnée basé sur le temps 400m
  static double calculateTimeAtIntensity(
    double time400m, // en secondes
    double distance, // en mètres
    double intensity, // en pourcentage (ex: 80.0)
  ) {
    if (intensity <= 0) return 0;

    // Temps pour 100m à 100%
    double timePer100m = time400m / 4.0;

    // Temps pour la distance à 100%
    double timeAt100 = (timePer100m * distance) / 100.0;

    // Temps à l'intensité donnée
    return (timeAt100 * 100.0) / intensity;
  }

  // Calcul de l'allure (temps/100m) à partir du temps 400m et de l'intensité
  static double calculatePacePer100m(
    double time400m,
    double intensity,
  ) {
    double timePer100mAt100 = time400m / 4.0;
    return (timePer100mAt100 * 100.0) / intensity;
  }

  // Conversion temps string en secondes (format: "mm:ss.xx" ou "ss.xx")
  static double parseSwimmingTime(String timeStr) {
    try {
      if (timeStr.contains(':')) {
        List<String> parts = timeStr.split(':');
        if (parts.length == 2) {
          double minutes = double.parse(parts[0].replaceAll(',', '.'));
          double seconds = double.parse(parts[1].replaceAll(',', '.'));
          return (minutes * 60) + seconds;
        }
      }
      return double.parse(timeStr.replaceAll(',', '.'));
    } catch (e) {
      return 0;
    }
  }

  // Formatage temps natation (secondes -> mm:ss.xx)
  static String formatSwimmingTime(double seconds) {
    if (seconds <= 0) return '0:00.00';

    int minutes = (seconds ~/ 60).toInt();
    double remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toStringAsFixed(2).padLeft(5, '0')}';
    } else {
      return '${remainingSeconds.toStringAsFixed(2)}';
    }
  }

  // Calcul de la VMA natation (vitesse moyenne sur 400m)
  static double calculateSwimmingVMA(double time400m) {
    if (time400m <= 0) return 0;
    double speedMps = 400 / time400m; // mètres par seconde
    return speedMps * 3.6; // km/h
  }
}
