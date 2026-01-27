import 'package:intl/intl.dart';

class TriathlonSeanceCommentaire {
  int id;
  int seanceId;
  String commentaire;
  DateTime dateCreation;
  DateTime? dateModification;

  TriathlonSeanceCommentaire({
    this.id = 0,
    required this.seanceId,
    required this.commentaire,
    DateTime? dateCreation,
    this.dateModification,
  }) : dateCreation = dateCreation ?? DateTime.now();

  factory TriathlonSeanceCommentaire.fromJson(Map<String, dynamic> json) {
    return TriathlonSeanceCommentaire(
      id: json['id'] ?? 0,
      seanceId: json['seanceId'] as int,
      commentaire: json['commentaire'] as String,
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : DateTime.now(),
      dateModification: json['dateModification'] != null
          ? DateTime.parse(json['dateModification'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seanceId': seanceId,
      'commentaire': commentaire,
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification': dateModification?.toIso8601String(),
    };
  }

  String get dateFormatee {
    return DateFormat('dd/MM/yy HH:mm').format(dateCreation);
  }

  String get dateModificationFormatee {
    if (dateModification == null) return '';
    return DateFormat('dd/MM/yy HH:mm').format(dateModification!);
  }

  // Méthode pour mettre à jour le commentaire
  void updateCommentaire(String nouveauCommentaire) {
    commentaire = nouveauCommentaire;
    dateModification = DateTime.now();
  }
}
