import '../constants/running_constants.dart';

class RunningConverter {
  // Convertir VMA en vitesse m/s
  static double vmaToMs(double vmaKmh) {
    return vmaKmh * RunningConstants.kmhToMs;
  }

  // Convertir vitesse m/s en VMA km/h
  static double msToVma(double speedMs) {
    return speedMs * RunningConstants.msToKmh;
  }

  // Calculer le temps pour une distance à une allure donnée
  static double calculateTime({
    required double vmaKmh,
    required double distance,
    required double intensityPercent,
  }) {
    if (vmaKmh <= 0 || distance <= 0 || intensityPercent <= 0) {
      return 0.0;
    }

    double speedMs = vmaToMs(vmaKmh) * (intensityPercent / 100.0);
    return distance / speedMs;
  }

  // Calculer la VMA nécessaire pour un temps donné
  static double calculateRequiredVma({
    required double distance,
    required double timeSeconds,
    required double intensityPercent,
  }) {
    if (distance <= 0 || timeSeconds <= 0 || intensityPercent <= 0) {
      return 0.0;
    }

    double requiredSpeedMs = distance / timeSeconds;
    double vmaMs = requiredSpeedMs / (intensityPercent / 100.0);
    return msToVma(vmaMs);
  }

  // Formater le temps course
  static String formatRunningTime(double seconds) {
    if (seconds <= 0) return "0:00";

    int minutes = (seconds ~/ 60).toInt();
    int secs = (seconds % 60).toInt();

    if (minutes > 60) {
      int hours = minutes ~/ 60;
      minutes = minutes % 60;
      return '${hours}h ${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }

    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  // Calculer l'allure (min/km)
  static String calculatePace({
    required double distance,
    required double timeSeconds,
  }) {
    if (distance <= 0 || timeSeconds <= 0) return "0:00";

    double paceSecondsPerKm = (timeSeconds / distance) * 1000;
    int minutes = (paceSecondsPerKm ~/ 60).toInt();
    int seconds = (paceSecondsPerKm % 60).toInt();

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Déterminer le niveau du coureur
  static String determineRunnerLevel(double vmaKmh) {
    if (vmaKmh >= 22) return 'Élite';
    if (vmaKmh >= 19) return 'Compétition';
    if (vmaKmh >= 16) return 'Avancé';
    if (vmaKmh >= 13) return 'Intermédiaire';
    return 'Débutant';
  }

  // Convertir en pourcentage VMA
  static double calculateVmaPercentage(double currentSpeedKmh, double vmaKmh) {
    if (vmaKmh <= 0) return 0.0;
    return (currentSpeedKmh / vmaKmh) * 100.0;
  }

  // Calculer les calories brûlées (estimation)
  static double estimateCalories({
    required double weight,
    required double distance,
    required double speedKmh,
  }) {
    // Formule simplifiée: 1 kcal par kg par km
    double baseCalories = weight * (distance / 1000);

    // Ajustement pour la vitesse
    double speedFactor = 1.0 + ((speedKmh - 10) * 0.05);
    speedFactor = speedFactor.clamp(0.8, 1.5);

    return baseCalories * speedFactor;
  }
}
