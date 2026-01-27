class SwimmingConstants {
  // Niveaux de nageurs
  static const Map<String, double> swimmerLevels = {
    'Débutant': 480.0, // 8:00 au 400m
    'Intermédiaire': 360.0, // 6:00 au 400m
    'Avancé': 300.0, // 5:00 au 400m
    'Compétition': 240.0, // 4:00 au 400m
    'Élite': 210.0, // 3:30 au 400m
  };

  // Distances standard
  static const List<double> standardDistances = [
    25,
    50,
    100,
    200,
    400,
    800,
    1500,
  ];

  // Intensités d'entraînement
  static const Map<String, Map<String, double>> trainingIntensities = {
    'Récupération': {'min': 60, 'max': 70},
    'Endurance': {'min': 70, 'max': 80},
    'Seuil aérobie': {'min': 80, 'max': 85},
    'Seuil anaérobie': {'min': 85, 'max': 90},
    'VO2 Max': {'min': 90, 'max': 95},
    'Sprint': {'min': 95, 'max': 100},
  };

  // Styles de nage
  static const List<String> swimStyles = [
    'Crawl',
    'Brasse',
    'Dos',
    'Papillon',
    '4 Nages',
  ];

  // Conseils d'entraînement
  static const List<String> trainingTips = [
    'Échauffez-vous toujours 10-15 minutes avant de nager',
    'Travaillez votre technique régulièrement',
    'Variez les styles de nage pour un développement complet',
    'Hydratez-vous même en natation',
    'Utilisez des accessoires (palmes, plaquettes, pull-buoy)',
  ];
}
