import 'triathlon_exercice.dart';
import 'triathlon_resultat.dart';

class ExerciceAvecResultats {
  final TriathlonExercice exercice;
  final List<TriathlonResultat> resultats;

  ExerciceAvecResultats({
    required this.exercice,
    List<TriathlonResultat>? resultats,
  }) : resultats = resultats ?? [];

  // Ajouter un résultat
  void ajouterResultat(TriathlonResultat resultat) {
    resultats.add(resultat);
  }

  // Obtenir les résultats pour une série spécifique
  List<TriathlonResultat> resultatsPourSerie(int serieIndex) {
    return resultats.where((r) => r.serieIndex == serieIndex).toList();
  }

  // Vérifier si l'exercice a des résultats
  bool get aDesResultats => resultats.isNotEmpty;

  // Nombre total de répétitions avec résultats
  int get repetitionsAvecResultats => resultats.length;

  // Calculer le temps moyen
  double? get tempsMoyen {
    if (resultats.isEmpty) return null;

    final tempsValides = resultats
        .where((r) => r.tempsReel != null)
        .map((r) => r.tempsReel!)
        .toList();

    if (tempsValides.isEmpty) return null;

    final somme = tempsValides.reduce((a, b) => a + b);
    return somme / tempsValides.length;
  }
}
