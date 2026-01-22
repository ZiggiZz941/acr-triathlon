import 'package:intl/intl.dart';
import 'sport_type.dart';
import 'triathlon_exercice.dart';

class TriathlonSeance {
  int id;
  String nom;
  DateTime dateCreation;
  SportType sportType;
  List<TriathlonExercice> exercices; // Doit exister
  String? description;

  TriathlonSeance({
    this.id = 0,
    required this.nom,
    required this.sportType,
    DateTime? dateCreation,
    List<TriathlonExercice>? exercices,
    this.description,
  })  : dateCreation = dateCreation ?? DateTime.now(),
        exercices = exercices ?? []; // Initialisé ici

  // Ajoutez cette méthode si elle n'existe pas
  void ajouterExercice(TriathlonExercice exercice) {
    exercices.add(exercice);
  }

  // Supprimer un exercice
  void supprimerExercice(int index) {
    if (index >= 0 && index < exercices.length) {
      exercices.removeAt(index);
    }
  }

  // Obtenir un résumé de la séance
  String getResume() {
    if (exercices.isEmpty) return "Aucun exercice";

    StringBuffer sb = StringBuffer();
    for (int i = 0; i < exercices.length && i < 3; i++) {
      sb.write("${exercices[i].getDescription()}");
      if (i < exercices.length - 1 && i < 2) sb.write(" • ");
    }

    if (exercices.length > 3) {
      sb.write(" • +${exercices.length - 3} autre(s)");
    }

    return sb.toString();
  }

  // Calculer le temps total estimé
  Duration getTempsTotalEstime() {
    int totalSeconds = 0;

    for (TriathlonExercice exercice in exercices) {
      // Temps pour toutes les répétitions
      double tempsMoyen = (exercice.tempsMin + exercice.tempsMax) / 2;
      int tempsRepetitions = (tempsMoyen * exercice.nbRepetitions).round();

      // Ajouter repos entre répétitions
      if (exercice.nbRepetitions > 1) {
        tempsRepetitions +=
            exercice.reposRepetitionsSec * (exercice.nbRepetitions - 1);
      }

      // Multiplier par le nombre de séries
      totalSeconds += tempsRepetitions * exercice.nbSeries;

      // Ajouter repos entre séries
      if (exercice.nbSeries > 1) {
        totalSeconds += exercice.reposSeriesSec * (exercice.nbSeries - 1);
      }
    }

    return Duration(seconds: totalSeconds);
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'sportType': sportType.name,
      'dateCreation': dateCreation.toIso8601String(),
      'exercices': exercices.map((e) => e.toJson()).toList(),
      'description': description,
      'resume': getResume(),
      'tempsTotalFormate': _formatDuration(getTempsTotalEstime()),
      'nbExercices': exercices.length,
    };
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  factory TriathlonSeance.fromJson(Map<String, dynamic> json) {
    List<TriathlonExercice> exercicesList = [];
    if (json['exercices'] != null) {
      List<dynamic> exercicesJson = json['exercices'] as List;
      exercicesList = exercicesJson
          .map((e) => TriathlonExercice.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TriathlonSeance(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? 'Séance sans nom',
      sportType: SportType.values.firstWhere(
        (e) => e.name == json['sportType'],
        orElse: () => SportType.running,
      ),
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : DateTime.now(),
      exercices: exercicesList,
      description: json['description'],
    );
  }

  // Getters utiles
  String get dateFormatee {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final seanceDay = DateTime(
      dateCreation.year,
      dateCreation.month,
      dateCreation.day,
    );

    if (seanceDay == today) {
      return "Aujourd'hui, ${DateFormat.Hm().format(dateCreation)}";
    } else if (seanceDay == today.subtract(const Duration(days: 1))) {
      return "Hier, ${DateFormat.Hm().format(dateCreation)}";
    } else {
      return DateFormat('dd/MM/yyyy, HH:mm').format(dateCreation);
    }
  }

  // Couleur selon le sport
  String get sportIcon {
    switch (sportType) {
      case SportType.swimming:
        return '🏊';
      case SportType.cycling:
        return '🚴';
      case SportType.running:
        return '🏃';
    }
  }
}
