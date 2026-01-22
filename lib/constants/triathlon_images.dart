class TriathlonImages {
  // Chemins vers les images
  static const String triathlonLogo = 'assets/images/triathlon_logo.png';
  static const String cyclingIcon = 'assets/images/cycling_icon.png';
  static const String runningIcon = 'assets/images/running_icon.png';
  static const String swimmingIcon = 'assets/images/swimming_icon.png';

  // Méthode pour obtenir l'icône d'un sport
  static String getSportIcon(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'cycling':
      case 'cyclisme':
        return cyclingIcon;
      case 'running':
      case 'course':
        return runningIcon;
      case 'swimming':
      case 'natation':
        return swimmingIcon;
      default:
        return triathlonLogo;
    }
  }
}
