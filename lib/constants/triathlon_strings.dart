class TriathlonStrings {
  // Application
  static const String appName = 'Triathlon Coach';
  static const String appDescription =
      'Application d\'entraînement pour triathlon';

  // Sports
  static const String swimming = 'Natation';
  static const String cycling = 'Cyclisme';
  static const String running = 'Course à pied';

  // Messages
  static const String fillAllFields = 'Veuillez remplir tous les champs';
  static const String invalidValue = 'Valeur invalide';
  static const String saveSuccess = 'Sauvegarde réussie !';
  static const String saveError = 'Erreur lors de la sauvegarde';
  static const String deleteSuccess = 'Suppression réussie';
  static const String deleteError = 'Erreur lors de la suppression';

  // Allures natation/course
  static const List<String> allures = [
    'Sélectionner une allure',
    'Allure 1 (60-70%)',
    'Allure 2 (70-80%)',
    'Allure 3 (80-85%)',
    'Allure 4 (85-90%)',
    'Allure 5 (90-95%)',
    'Allure Max (100%)',
  ];

  static const List<String> alluresSimplifie = [
    'Allure 1 (60-70%)',
    'Allure 2 (70-80%)',
    'Allure 3 (80-85%)',
    'Allure 4 (85-90%)',
    'Allure 5 (90-95%)',
    'Allure Max (100%)',
  ];

  // Zones FTP cyclisme
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

  // Unités
  static const String unitMeters = 'm';
  static const String unitKilometers = 'km';
  static const String unitSeconds = 's';
  static const String unitMinutes = 'min';
  static const String unitHours = 'h';
  static const String unitWatts = 'W';
  static const String unitKmh = 'km/h';
  static const String unitPercent = '%';

  // Conseils
  static const String swimmingTip =
      'Le temps au 400m est votre référence pour tous les calculs de natation';
  static const String cyclingTip =
      'La FTP est la puissance maximale que vous pouvez maintenir pendant 1 heure';
  static const String runningTip =
      'La VMA est la vitesse à consommation maximale d\'oxygène';
}
