// lib/models/sport_type.dart
import 'package:flutter/material.dart';
import '../constants/triathlon_colors.dart';

enum SportType {
  swimming,
  cycling,
  running,
}

extension SportTypeExtension on SportType {
  // Noms d'affichage
  String get displayName {
    switch (this) {
      case SportType.swimming:
        return 'Natation';
      case SportType.cycling:
        return 'Cyclisme';
      case SportType.running:
        return 'Course à pied';
    }
  }

  // Labels de référence
  String get referenceLabel {
    switch (this) {
      case SportType.swimming:
        return 'Temps 400m';
      case SportType.cycling:
        return 'FTP (watts)';
      case SportType.running:
        return 'VMA (km/h)';
    }
  }

  // Couleurs
  Color get color {
    switch (this) {
      case SportType.swimming:
        return TriathlonColors.swimming;
      case SportType.cycling:
        return TriathlonColors.cycling;
      case SportType.running:
        return TriathlonColors.running;
    }
  }

  // Chemins d'icônes
  String get iconPath {
    switch (this) {
      case SportType.swimming:
        return 'assets/images/swimming_icon.png';
      case SportType.cycling:
        return 'assets/images/cycling_icon.png';
      case SportType.running:
        return 'assets/images/running_icon.png';
    }
  }

  // Emojis
  String get emoji {
    switch (this) {
      case SportType.swimming:
        return '🏊';
      case SportType.cycling:
        return '🚴';
      case SportType.running:
        return '🏃';
    }
  }

  // Titres pour création de séance
  String get creationTitle {
    switch (this) {
      case SportType.swimming:
        return 'Création natation par intensité';
      case SportType.cycling:
        return 'Création cyclisme par intensité';
      case SportType.running:
        return 'Création course par intensité';
    }
  }

  // Textes d'aide pour les champs
  String get hintText {
    switch (this) {
      case SportType.swimming:
        return 'Ex: Séance crawl intensité avancée';
      case SportType.cycling:
        return 'Ex: Séance FTP intensité avancée';
      case SportType.running:
        return 'Ex: Séance VMA intensité avancée';
    }
  }

  // Textes d'aide simplifiés
  String get simpleHintText {
    switch (this) {
      case SportType.swimming:
        return 'Ex: Séance crawl intensité';
      case SportType.cycling:
        return 'Ex: Séance FTP intensité';
      case SportType.running:
        return 'Ex: Séance VMA intensité';
    }
  }

  // Valeurs par défaut
  double get defaultDistance {
    switch (this) {
      case SportType.swimming:
        return 100.0;
      case SportType.cycling:
        return 1000.0;
      case SportType.running:
        return 400.0;
    }
  }

  double get defaultValue {
    switch (this) {
      case SportType.swimming:
        return 90.0; // Temps 100m en secondes
      case SportType.cycling:
        return 200.0; // FTP en watts
      case SportType.running:
        return 16.0; // VMA en km/h
    }
  }

  int get defaultReposRep {
    switch (this) {
      case SportType.swimming:
        return 30;
      case SportType.cycling:
        return 60;
      case SportType.running:
        return 45;
    }
  }

  int get defaultReposSer {
    switch (this) {
      case SportType.swimming:
        return 90;
      case SportType.cycling:
        return 180;
      case SportType.running:
        return 120;
    }
  }
}
