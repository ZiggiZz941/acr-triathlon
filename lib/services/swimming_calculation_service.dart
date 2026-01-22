// swimming_calculation_service.dart CORRIGÉ
class SwimmingCalculationService {
  double? parseSwimmingTime(String timeString) {
    try {
      if (timeString.contains(':')) {
        List<String> parts = timeString.split(':');
        if (parts.length == 2) {
          int minutes = int.parse(parts[0]);
          double seconds = double.parse(parts[1].replaceAll(',', '.'));
          return (minutes * 60.0) + seconds;
        }
      }
      return double.parse(timeString.replaceAll(',', '.'));
    } catch (e) {
      return null;
    }
  }

  String formatSwimmingTime(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    double remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toStringAsFixed(2).padLeft(5, '0')}';
    } else {
      return remainingSeconds.toStringAsFixed(2);
    }
  }

  double? calculateTimeForDistance({
    required double base400mTime,
    required double distance,
    required double intensityPercent,
  }) {
    if (intensityPercent <= 0) return null;

    // Formule CORRECTE : temps pour 100m à 100% = temps_400m / 4
    double timeFor100mAt100Percent = base400mTime / 4;

    // Temps pour la distance à 100% = temps_100m * (distance / 100)
    double timeAt100Percent = timeFor100mAt100Percent * (distance / 100);

    // À une intensité plus faible, le temps est PLUS LONG
    // intensité = 80% => temps = temps_100% / 0.80
    double resultTime = timeAt100Percent / (intensityPercent / 100);

    return resultTime;
  }

  // Méthode utile pour calculer la fourchette de temps
  List<double> calculateTimeRange({
    required double base400mTime,
    required double distance,
    required double minIntensityPercent,
    required double maxIntensityPercent,
  }) {
    double minTime = calculateTimeForDistance(
          base400mTime: base400mTime,
          distance: distance,
          intensityPercent:
              maxIntensityPercent, // Note: intensité MAX donne temps MIN
        ) ??
        0;

    double maxTime = calculateTimeForDistance(
          base400mTime: base400mTime,
          distance: distance,
          intensityPercent:
              minIntensityPercent, // Note: intensité MIN donne temps MAX
        ) ??
        0;

    return [minTime, maxTime];
  }
}
