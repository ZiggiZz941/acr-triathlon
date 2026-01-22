class RunningCalculator {
  // Convertir temps en secondes depuis format mm:ss.xx
  static double parseRunningTime(String timeStr) {
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

  // Formater secondes en mm:ss.xx
  static String formatRunningTime(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    double secs = seconds % 60;

    if (minutes > 0) {
      return '${minutes}:${secs.toStringAsFixed(2).padLeft(5, '0')}';
    } else {
      return '${secs.toStringAsFixed(2)} sec';
    }
  }

  // Calculer temps à partir de VMA et distance
  static double calculateTimeFromVMA(double vmaKmh, double distanceMeters) {
    if (vmaKmh <= 0) return 0;

    double vitesseMs = vmaKmh / 3.6;
    return distanceMeters / vitesseMs;
  }

  // Calculer VMA nécessaire pour un temps et distance donnés
  static double calculateVMAFromTime(
      double timeSeconds, double distanceMeters) {
    if (timeSeconds <= 0 || distanceMeters <= 0) return 0;

    double vitesseMs = distanceMeters / timeSeconds;
    return vitesseMs * 3.6;
  }

  // Calculer temps à une intensité donnée
  static double calculateTimeAtIntensity(
      double baseTimeSeconds, double intensityPercent) {
    if (baseTimeSeconds <= 0 || intensityPercent <= 0) return 0;
    return (baseTimeSeconds * 100.0) / intensityPercent;
  }

  // Calculer allures (pour les différentes zones)
  static Map<String, double> calculatePaces(double vmaKmh) {
    if (vmaKmh <= 0) return {};

    return {
      'Allure 1 (60-70%)': calculateTimeFromVMA(vmaKmh * 0.65, 1000),
      'Allure 2 (70-80%)': calculateTimeFromVMA(vmaKmh * 0.75, 1000),
      'Allure 3 (80-85%)': calculateTimeFromVMA(vmaKmh * 0.825, 1000),
      'Allure 4 (85-90%)': calculateTimeFromVMA(vmaKmh * 0.875, 1000),
      'Allure 5 (90-95%)': calculateTimeFromVMA(vmaKmh * 0.925, 1000),
      'Allure VMA (100%)': calculateTimeFromVMA(vmaKmh, 1000),
    };
  }

  // Convertir vitesse en allure (min/km)
  static double convertSpeedToPace(double speedKmh) {
    if (speedKmh <= 0) return 0;
    return 60.0 / speedKmh; // minutes per kilometer
  }

  // Convertir allure en vitesse
  static double convertPaceToSpeed(double paceMinPerKm) {
    if (paceMinPerKm <= 0) return 0;
    return 60.0 / paceMinPerKm; // km/h
  }
}
