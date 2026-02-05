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
  double tempsAttenduMin;
  double tempsAttenduMax;
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
    required this.tempsAttenduMin,
    required this.tempsAttenduMax,
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
      tempsAttenduMin: (json['tempsAttenduMin'] as num?)?.toDouble() ??
          (json['tempsAttendu'] as num?)?.toDouble() ??
          60.0,
      tempsAttenduMax: (json['tempsAttenduMax'] as num?)?.toDouble() ??
          (json['tempsAttendu'] as num?)?.toDouble() ??
          60.0,
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
      'tempsAttenduMin': tempsAttenduMin,
      'tempsAttenduMax': tempsAttenduMax,
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

  String get plageAttendueFormatee {
    final minStr = _formatTemps(tempsAttenduMin);
    final maxStr = _formatTemps(tempsAttenduMax);

    if (tempsAttenduMin == tempsAttenduMax) {
      return minStr;
    }
    return '$minStr à $maxStr';
  }

  String get tempsAttenduMinFormate => _formatTemps(tempsAttenduMin);
  String get tempsAttenduMaxFormate => _formatTemps(tempsAttenduMax);

  String get dateFormatee {
    return DateFormat('dd/MM/yy HH:mm').format(dateRealisation);
  }

  String get statutPerformance {
    if (tempsReel == null) return 'Non mesuré';

    final pourcentage = pourcentagePerformance;

    if (pourcentage >= 110) {
      return 'Très rapide';
    } else if (pourcentage >= 100) {
      return 'Dans les temps';
    } else {
      return 'Trop lent';
    }
  }

  IconData get iconePerformance {
    if (tempsReel == null) return Icons.timer;

    final pourcentage = pourcentagePerformance;

    if (pourcentage >= 110) {
      return Icons.rocket_launch;
    } else if (pourcentage >= 100) {
      return Icons.check_circle;
    } else {
      return Icons.warning;
    }
  }

  Color get couleurPerformance {
    if (tempsReel == null) return Colors.grey;

    final pourcentage = pourcentagePerformance;

    if (pourcentage >= 110) {
      return Colors.blue;
    } else if (pourcentage >= 100) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  double get pourcentagePerformance {
    if (tempsReel == null || tempsAttenduMin <= 0) return 0;

    // Calcul du pourcentage par rapport au temps minimum
    // Si plus rapide que le temps min: pourcentage > 100%
    // Si égal au temps min: pourcentage = 100%
    // Si entre temps min et max: pourcentage entre 95% et 100%
    // Si plus lent que temps max: pourcentage < 95%

    if (tempsReel! < tempsAttenduMin) {
      // Plus rapide que le temps min
      return (tempsAttenduMin / tempsReel! * 100).clamp(100, 150).toDouble();
    } else if (tempsReel! <= tempsAttenduMax) {
      // Entre temps min et temps max
      return 100 -
          ((tempsReel! - tempsAttenduMin) /
              (tempsAttenduMax - tempsAttenduMin) *
              5);
    } else {
      // Plus lent que le temps max
      return 95 - ((tempsReel! - tempsAttenduMax) / tempsAttenduMax * 15);
    }
  }

  String _formatTemps(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    int secs = (seconds % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get differenceTemps {
    if (tempsReel == null) return 0;
    double milieuPlage = (tempsAttenduMin + tempsAttenduMax) / 2;
    return tempsReel! - milieuPlage;
  }

  double get tempsAttendu => tempsAttenduMin;
}
