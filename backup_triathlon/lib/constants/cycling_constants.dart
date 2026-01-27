class CyclingConstants {
  // Niveaux de cyclistes basés sur FTP
  static const Map<String, Map<String, double>> cyclistLevels = {
    'Débutant': {'ftp': 150, 'wkg': 2.0},
    'Intermédiaire': {'ftp': 200, 'wkg': 2.8},
    'Avancé': {'ftp': 250, 'wkg': 3.5},
    'Compétition': {'ftp': 300, 'wkg': 4.0},
    'Élite': {'ftp': 350, 'wkg': 4.5},
  };

  static const Map<String, Map<String, String>> ftpZones = {
    'Zone 1': {
      'name': 'Récupération active',
      'range': '55-75% FTP',
      'description': 'Pour la récupération, effort très léger',
    },
    'Zone 2': {
      'name': 'Endurance',
      'range': '75-85% FTP',
      'description': 'Base aérobie, conversation facile',
    },
    'Zone 3': {
      'name': 'Tempo',
      'range': '85-95% FTP',
      'description': 'Seuil aérobie, effort modéré',
    },
    'Zone 4': {
      'name': 'Seuil lactique',
      'range': '95-105% FTP',
      'description': 'Seuil anaérobie, effort soutenu',
    },
    'Zone 5': {
      'name': 'VO2 Max',
      'range': '105-120% FTP',
      'description': 'Puissance aérobie, effort intense',
    },
    'Zone 6': {
      'name': 'Anaérobie',
      'range': '>120% FTP',
      'description': 'Capacité anaérobie, effort maximal',
    },
  };

  // Distances standard
  static const List<double> standardDistances = [
    10,
    20,
    40,
    60,
    80,
    100,
    160,
  ];

  // Dénivelés standards
  static const Map<String, double> elevationProfiles = {
    'Plat': 0,
    'Vallonné': 500,
    'Montagneux': 1000,
    'Alpin': 2000,
  };

  // Types d'entraînement
  static const Map<String, Map<String, dynamic>> workoutTypes = {
    'Endurance': {
      'intensity': {'min': 65, 'max': 75},
      'duration': '2-4h',
      'description': 'Développement de la base aérobie',
    },
    'Tempo': {
      'intensity': {'min': 85, 'max': 95},
      'duration': '1-2h',
      'description': 'Amélioration du seuil aérobie',
    },
    'Intervalles': {
      'intensity': {'min': 100, 'max': 120},
      'duration': '1-1.5h',
      'description': 'Développement de la puissance',
    },
    'Sprint': {
      'intensity': {'min': 130, 'max': 150},
      'duration': '45-60min',
      'description': 'Travail de la capacité anaérobie',
    },
    'Récupération': {
      'intensity': {'min': 55, 'max': 65},
      'duration': '45-60min',
      'description': 'Active recovery',
    },
  };

  // Conseils
  static const List<String> cyclingTips = [
    'Maintenez une cadence de 80-100 rpm pour l\'efficacité',
    'Hydratez-vous régulièrement (500ml/heure)',
    'Mangez 30-60g de glucides par heure d\'effort',
    'Vérifiez la pression de vos pneus avant chaque sortie',
    'Portez toujours un casque',
  ];

  // Facteurs de conversion
  static const double wattsToKmhFactor = 0.1;
  static const double baseSpeedKmh = 20.0;
  static const double elevationImpactFactor = 0.1;
}
