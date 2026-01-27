class RunningConstants {
  // Niveaux de coureurs basés sur VMA
  static const Map<String, double> runnerLevels = {
    'Débutant': 10.0,
    'Intermédiaire': 13.0,
    'Avancé': 16.0,
    'Compétition': 19.0,
    'Élite': 22.0,
  };

  // Distances standard
  static const List<double> standardDistances = [
    100,
    200,
    400,
    800,
    1000,
    1500,
    3000,
    5000,
    10000,
  ];

  // Allures d'entraînement
  static const Map<String, Map<String, double>> trainingPaces = {
    'Récupération': {'min': 60, 'max': 70},
    'Endurance': {'min': 70, 'max': 80},
    'Seuil': {'min': 80, 'max': 85},
    'VO2 Max': {'min': 90, 'max': 95},
    'Sprint': {'min': 95, 'max': 100},
  };

  // Types de séances
  static const Map<String, Map<String, dynamic>> workoutTypes = {
    'Footing': {
      'intensity': '60-70% VMA',
      'duration': '30-60min',
      'purpose': 'Récupération active',
    },
    'Endurance': {
      'intensity': '70-80% VMA',
      'duration': '45-90min',
      'purpose': 'Développement aérobie',
    },
    'Seuil': {
      'intensity': '80-90% VMA',
      'duration': '20-40min',
      'purpose': 'Amélioration du seuil lactique',
    },
    'Intervalles': {
      'intensity': '90-100% VMA',
      'duration': '30-60min',
      'purpose': 'Développement de la VMA',
    },
    'Fartlek': {
      'intensity': 'Variable',
      'duration': '30-60min',
      'purpose': 'Variation d\'allures',
    },
  };

  // Conseils
  static const List<String> runningTips = [
    'Échauffez-vous 10-15 minutes avant chaque séance',
    'Augmentez votre volume progressivement (+10%/semaine)',
    'Incluez des séances de renforcement musculaire',
    'Écoutez votre corps et respectez les jours de repos',
    'Hydratez-vous avant, pendant et après l\'effort',
  ];

  // Formules de calcul
  static const double msToKmh = 3.6;
  static const double kmhToMs = 0.2778;
}
