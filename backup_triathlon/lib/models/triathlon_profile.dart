// Import seulement, pas de redéfinition

class TriathlonProfile {
  String id;
  String nom;
  String prenom;
  DateTime dateNaissance;
  Map<SportType, SportProfile> sportProfiles;

  TriathlonProfile({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    Map<SportType, SportProfile>? sportProfiles,
  }) : sportProfiles = sportProfiles ?? {};

  // Ajouter un profil sportif
  void setSportProfile(SportType sport, SportProfile profile) {
    sportProfiles[sport] = profile;
  }

  // Récupérer un profil sportif
  SportProfile? getSportProfile(SportType sport) {
    return sportProfiles[sport];
  }

  // Vérifier si un profil est complet
  bool isSportProfileComplete(SportType sport) {
    final profile = sportProfiles[sport];
    return profile != null && profile.isComplete();
  }

  // JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'dateNaissance': dateNaissance.toIso8601String(),
      'sportProfiles': sportProfiles.map(
        (key, value) => MapEntry(key.name, value.toJson()),
      ),
    };
  }

  factory TriathlonProfile.fromJson(Map<String, dynamic> json) {
    Map<SportType, SportProfile> profiles = {};

    if (json['sportProfiles'] != null) {
      (json['sportProfiles'] as Map).forEach((key, value) {
        SportType sport = SportType.values.firstWhere(
          (e) => e.name == key,
          orElse: () => SportType.running,
        );
        profiles[sport] = SportProfile.fromJson(value);
      });
    }

    return TriathlonProfile(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      dateNaissance: DateTime.parse(json['dateNaissance']),
      sportProfiles: profiles,
    );
  }
}

class SportProfile {
  double valeurReference;
  DateTime derniereMiseAJour;
  List<double> historique;

  SportProfile({
    required this.valeurReference,
    DateTime? derniereMiseAJour,
    List<double>? historique,
  })  : derniereMiseAJour = derniereMiseAJour ?? DateTime.now(),
        historique = historique ?? [];

  // Vérifier si le profil est complet
  bool isComplete() {
    return valeurReference > 0;
  }

  // Ajouter une nouvelle valeur à l'historique
  void ajouterValeur(double nouvelleValeur) {
    historique.insert(0, nouvelleValeur);
    valeurReference = nouvelleValeur;
    derniereMiseAJour = DateTime.now();

    // Garder seulement les 12 derniers mois
    if (historique.length > 12) {
      historique = historique.sublist(0, 12);
    }
  }

  // Obtenir la progression
  double getProgression() {
    if (historique.length < 2) return 0;

    double ancienne = historique.last;
    double nouvelle = historique.first;

    if (ancienne == 0) return 0;

    return ((nouvelle - ancienne) / ancienne) * 100;
  }

  // JSON
  Map<String, dynamic> toJson() {
    return {
      'valeurReference': valeurReference,
      'derniereMiseAJour': derniereMiseAJour.toIso8601String(),
      'historique': historique,
    };
  }

  factory SportProfile.fromJson(Map<String, dynamic> json) {
    return SportProfile(
      valeurReference: (json['valeurReference'] as num).toDouble(),
      derniereMiseAJour: DateTime.parse(json['derniereMiseAJour']),
      historique: List<double>.from(json['historique'] ?? []),
    );
  }
}

enum SportType {
  swimming('Natation', 'Temps 400m'),
  cycling('Cyclisme', 'FTP (watts)'),
  running('Course', 'VMA (km/h)');

  final String name;
  final String referenceLabel;

  const SportType(this.name, this.referenceLabel);
}
