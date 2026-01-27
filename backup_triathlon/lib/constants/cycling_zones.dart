class CyclingZone {
  final String name;
  final String description;
  final String percentageRange;
  final double minPercentage;
  final double maxPercentage;
  final int index;

  CyclingZone({
    required this.name,
    required this.description,
    required this.percentageRange,
    required this.minPercentage,
    required this.maxPercentage,
    required this.index,
  });

  static List<CyclingZone> get zones => [
        CyclingZone(
          name: 'Zone 1',
          description: 'Récupération active',
          percentageRange: '<55-75% FTP',
          minPercentage: 0,
          maxPercentage: 74.9,
          index: 0,
        ),
        CyclingZone(
          name: 'Zone 2',
          description: 'Endurance',
          percentageRange: '75-85% FTP',
          minPercentage: 75,
          maxPercentage: 84.9,
          index: 1,
        ),
        CyclingZone(
          name: 'Zone 3',
          description: 'Tempo',
          percentageRange: '85-95% FTP',
          minPercentage: 85,
          maxPercentage: 94.9,
          index: 2,
        ),
        CyclingZone(
          name: 'Zone 4',
          description: 'Seuil lactique',
          percentageRange: '95-105% FTP',
          minPercentage: 95,
          maxPercentage: 104.9,
          index: 3,
        ),
        CyclingZone(
          name: 'Zone 5',
          description: 'VO2 Max',
          percentageRange: '105-120% FTP',
          minPercentage: 105,
          maxPercentage: 120,
          index: 4,
        ),
        CyclingZone(
          name: 'Zone 6',
          description: 'Anaérobie',
          percentageRange: '>120% FTP',
          minPercentage: 120.1,
          maxPercentage: 200,
          index: 5,
        ),
      ];

  static CyclingZone getZoneByPercentage(double percentage) {
    return zones.firstWhere(
      (zone) =>
          percentage >= zone.minPercentage && percentage <= zone.maxPercentage,
      orElse: () => zones.first,
    );
  }

  static String getZoneLabelByPercentage(double percentage) {
    final zone = getZoneByPercentage(percentage);
    return zone.name;
  }

  static String getZoneDescriptionByPercentage(double percentage) {
    final zone = getZoneByPercentage(percentage);
    return zone.description;
  }

  static double getMidpointPercentageForZone(String zoneName) {
    final zone = zones.firstWhere(
      (z) => z.name == zoneName,
      orElse: () => zones[1], // Zone 2 par défaut
    );

    if (zone.name == 'Zone 1') return 65; // Milieu de Zone 1
    if (zone.name == 'Zone 6') return 130; // Valeur typique pour Zone 6

    return (zone.minPercentage + zone.maxPercentage) / 2;
  }
}
