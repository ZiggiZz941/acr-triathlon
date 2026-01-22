// running_calculation_service.dart
class RunningCalculationService {
  double? calculateSpeedForIntensity({
    required double vma,
    required double intensityPercent,
  }) {
    return vma * (intensityPercent / 100);
  }

  String calculatePaceForSpeed(double speedKmh) {
    if (speedKmh <= 0) return '--:-- min/km';

    double minutesPerKm = 60.0 / speedKmh;
    int minutes = minutesPerKm.floor();
    double secondsDecimal = (minutesPerKm - minutes) * 60;
    int seconds = secondsDecimal.round();

    if (seconds >= 60) {
      minutes += 1;
      seconds -= 60;
    }

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} min/km';
  }

  Map<String, dynamic> getTrainingZones(double vma) {
    return {
      'Marche/Recup': {
        'min': vma * 0.50,
        'max': vma * 0.65,
        'pace': calculatePaceForSpeed(vma * 0.575),
        'description': 'Récupération active, échauffement'
      },
      'Endurance fondamentale': {
        'min': vma * 0.65,
        'max': vma * 0.75,
        'pace': calculatePaceForSpeed(vma * 0.70),
        'description': 'Sortie longue, développement aérobie'
      },
      'Endurance active': {
        'min': vma * 0.75,
        'max': vma * 0.85,
        'pace': calculatePaceForSpeed(vma * 0.80),
        'description': 'Allure marathon, conversation difficile'
      },
      'Résistance douce': {
        'min': vma * 0.85,
        'max': vma * 0.90,
        'pace': calculatePaceForSpeed(vma * 0.875),
        'description': 'Allure semi-marathon'
      },
      'Seuil aérobie': {
        'min': vma * 0.90,
        'max': vma * 1.00,
        'pace': calculatePaceForSpeed(vma * 0.95),
        'description': 'Allure 10km, seuil lactique'
      },
      'VMA': {
        'min': vma * 1.00,
        'max': vma * 1.05,
        'pace': calculatePaceForSpeed(vma * 1.025),
        'description': 'Allure 5km, intervails VMA'
      },
      'Supra-VMA': {
        'min': vma * 1.05,
        'pace': calculatePaceForSpeed(vma * 1.10),
        'description': 'Allure 1500m-3000m, sprint'
      },
    };
  }

  String formatSpeed(double speed) {
    return '${speed.toStringAsFixed(1)} km/h';
  }

  String formatIntensity(double intensityPercent) {
    return '${intensityPercent.toStringAsFixed(1)}%';
  }
}
