import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TriathlonResultat {
  int id;
  int seanceId;
  int exerciceId;
  int serieIndex;
  int repetitionIndex;
  double? tempsReel;
  double tempsAttendu;
  double? distanceReelle;
  int? fcMoyenne;
  int? fcMax;
  int? rpe;
  Map<String, dynamic>? donneesSpecifiques;
  String? commentaire;
  DateTime dateRealisation;
  bool estComplete;

  TriathlonResultat({
    this.id = 0,
    required this.seanceId,
    required this.exerciceId,
    required this.serieIndex,
    required this.repetitionIndex,
    this.tempsReel,
    required this.tempsAttendu,
    this.distanceReelle,
    this.fcMoyenne,
    this.fcMax,
    this.rpe,
    this.donneesSpecifiques,
    this.commentaire,
    DateTime? dateRealisation,
    this.estComplete = false,
  }) : dateRealisation = dateRealisation ?? DateTime.now();

  factory TriathlonResultat.fromJson(Map<String, dynamic> json) {
    return TriathlonResultat(
      id: json['id'] ?? 0,
      seanceId: json['seanceId'] as int,
      exerciceId: json['exerciceId'] ?? 0,
      serieIndex: json['serieIndex'] ?? 1,
      repetitionIndex: json['repetitionIndex'] ?? 1,
      tempsReel: json['tempsReel']?.toDouble(),
      tempsAttendu: (json['tempsAttendu'] as num?)?.toDouble() ?? 60.0,
      distanceReelle: json['distanceReelle']?.toDouble(),
      fcMoyenne: json['fcMoyenne'],
      fcMax: json['fcMax'],
      rpe: json['rpe'],
      donneesSpecifiques: json['donneesSpecifiques'] != null
          ? Map<String, dynamic>.from(json['donneesSpecifiques'])
          : null,
      commentaire: json['commentaire'],
      dateRealisation: json['dateRealisation'] != null
          ? DateTime.parse(json['dateRealisation'])
          : DateTime.now(),
      estComplete: json['estComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seanceId': seanceId,
      'exerciceId': exerciceId,
      'serieIndex': serieIndex,
      'repetitionIndex': repetitionIndex,
      'tempsReel': tempsReel,
      'tempsAttendu': tempsAttendu,
      'distanceReelle': distanceReelle,
      'fcMoyenne': fcMoyenne,
      'fcMax': fcMax,
      'rpe': rpe,
      'donneesSpecifiques': donneesSpecifiques,
      'commentaire': commentaire,
      'dateRealisation': dateRealisation.toIso8601String(),
      'estComplete': estComplete,
    };
  }

  String get tempsFormate {
    if (tempsReel == null) return '--:--';
    int minutes = (tempsReel! ~/ 60).toInt();
    int seconds = (tempsReel! % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get dateFormatee {
    return DateFormat('dd/MM/yy HH:mm').format(dateRealisation);
  }

  double get pourcentagePerformance {
    if (tempsReel == null || tempsReel! <= 0 || tempsAttendu <= 0) return 0;

    return (tempsAttendu / tempsReel!) * 100;
  }

  double get differenceTemps {
    if (tempsReel == null) return 0;
    return tempsReel! - tempsAttendu;
  }

  String get statutPerformance {
    final pourcentage = pourcentagePerformance;
    if (pourcentage >= 110) return 'Très rapide';
    if (pourcentage >= 95) return 'Dans les temps';
    return 'Trop lent';
  }

  Color get couleurPerformance {
    final pourcentage = pourcentagePerformance;
    if (pourcentage >= 110) return Colors.blue;
    if (pourcentage >= 95) return Colors.green;
    return Colors.red;
  }

  IconData get iconePerformance {
    final pourcentage = pourcentagePerformance;
    if (pourcentage >= 110) return Icons.rocket_launch;
    if (pourcentage >= 95) return Icons.check_circle;
    return Icons.warning;
  }
}
