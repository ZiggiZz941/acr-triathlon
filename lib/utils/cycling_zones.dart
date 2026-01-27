import 'package:flutter/material.dart';

class CyclingZones {
  static final List<Map<String, dynamic>> zones = [
    {
      'id': 'zone1',
      'name': 'Zone 1',
      'description': 'Récupération active',
      'range': '<55-75% FTP',
      'min': 55,
      'max': 75,
      'color': Colors.blue,
    },
    {
      'id': 'zone2',
      'name': 'Zone 2',
      'description': 'Endurance',
      'range': '75-85% FTP',
      'min': 75,
      'max': 85,
      'color': Colors.green,
    },
    {
      'id': 'zone3',
      'name': 'Zone 3',
      'description': 'Tempo',
      'range': '85-95% FTP',
      'min': 85,
      'max': 95,
      'color': Colors.yellow,
    },
    {
      'id': 'zone4',
      'name': 'Zone 4',
      'description': 'Seuil lactique',
      'range': '95-105% FTP',
      'min': 95,
      'max': 105,
      'color': Colors.orange,
    },
    {
      'id': 'zone5',
      'name': 'Zone 5',
      'description': 'VO2 Max',
      'range': '105-120% FTP',
      'min': 105,
      'max': 120,
      'color': Colors.red,
    },
    {
      'id': 'zone6',
      'name': 'Zone 6',
      'description': 'Anaérobie',
      'range': '>120% FTP',
      'min': 120,
      'max': 130,
      'color': Colors.purple,
    },
  ];

  static Map<String, dynamic>? getZoneById(String zoneId) {
    try {
      return zones.firstWhere((zone) => zone['id'] == zoneId);
    } catch (e) {
      return null;
    }
  }

  // MODIFIÉ : Retourne une List<int> au lieu d'un tuple
  static List<int> getIntensityRangeForZone(String zoneId) {
    final zone = getZoneById(zoneId);
    if (zone != null) {
      return [zone['min'] as int, zone['max'] as int];
    }
    return [85, 95]; // Zone 3 par défaut
  }

  static String getZoneName(String zoneId) {
    return getZoneById(zoneId)?['name'] ?? 'Zone 3';
  }

  static Color getZoneColor(String zoneId) {
    return getZoneById(zoneId)?['color'] ?? Colors.yellow;
  }
}
