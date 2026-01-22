class SwimmingConverter {
  // Convertir un temps en format natation (mm:ss.xx)
  static String formatSwimmingTime(double seconds) {
    if (seconds <= 0) return "0:00.00";

    int minutes = (seconds ~/ 60).toInt();
    double remainingSeconds = seconds % 60;

    if (remainingSeconds >= 60) {
      minutes += (remainingSeconds ~/ 60).toInt();
      remainingSeconds = remainingSeconds % 60;
    }

    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toStringAsFixed(2).padLeft(5, '0')}';
    } else {
      return '${remainingSeconds.toStringAsFixed(2)}';
    }
  }

  // Parser un temps natation
  static double parseSwimmingTime(String timeStr) {
    try {
      timeStr = timeStr.trim();
      if (timeStr.isEmpty) return 0.0;

      // Format mm:ss.xx ou ss.xx
      if (timeStr.contains(':')) {
        List<String> parts = timeStr.split(':');
        if (parts.length == 2) {
          double minutes = _parseDouble(parts[0]) ?? 0;
          double seconds = _parseDouble(parts[1]) ?? 0;

          if (minutes < 0 || seconds < 0 || seconds >= 60) {
            return 0.0;
          }

          return (minutes * 60.0) + seconds;
        }
      }

      // Format en secondes uniquement
      double seconds = _parseDouble(timeStr) ?? 0;
      return seconds >= 0 ? seconds : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Calculer l'allure au 100m à partir du temps 400m
  static double calculatePace100m(double time400m) {
    if (time400m <= 0) return 0.0;
    return time400m / 4.0;
  }

  // Calculer le temps pour une distance donnée
  static double calculateTimeForDistance({
    required double pace100m, // temps au 100m en secondes
    required double distance, // distance en mètres
    required double intensity,
    required double time400m, // intensité en pourcentage
  }) {
    if (pace100m <= 0 || distance <= 0 || intensity <= 0) {
      return 0.0;
    }

    double timeAt100 = (pace100m * distance) / 100.0;
    return (timeAt100 * 100.0) / intensity;
  }

  // Convertir en vitesse (m/s)
  static double calculateSpeedMs(double time100m) {
    if (time100m <= 0) return 0.0;
    return 100.0 / time100m;
  }

  // Convertir en vitesse (km/h)
  static double calculateSpeedKmh(double time100m) {
    double speedMs = calculateSpeedMs(time100m);
    return speedMs * 3.6;
  }

  // Déterminer le niveau du nageur
  static String determineSwimmerLevel(double time400m) {
    if (time400m <= 210) return 'Élite';
    if (time400m <= 240) return 'Compétition';
    if (time400m <= 300) return 'Avancé';
    if (time400m <= 360) return 'Intermédiaire';
    return 'Débutant';
  }

  // Helper pour parser les doubles
  static double? _parseDouble(String value) {
    try {
      value = value.replaceAll(',', '.');
      return double.parse(value);
    } catch (e) {
      return null;
    }
  }
}
