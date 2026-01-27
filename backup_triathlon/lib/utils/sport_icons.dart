import 'package:flutter/material.dart';
import '../models/sport_type.dart';

class SportIcons {
  static IconData getSportIcon(SportType sportType) {
    switch (sportType) {
      case SportType.swimming:
        return Icons.pool;
      case SportType.cycling:
        return Icons.directions_bike;
      case SportType.running:
        return Icons.directions_run;
    }
  }

  static String getSportEmoji(SportType sportType) {
    switch (sportType) {
      case SportType.swimming:
        return '🏊';
      case SportType.cycling:
        return '🚴';
      case SportType.running:
        return '🏃';
    }
  }

  static Widget buildSportHeader(SportType sportType) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getSportGradient(sportType),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Icon(
            getSportIcon(sportType),
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            sportType.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<Color> _getSportGradient(SportType sportType) {
    switch (sportType) {
      case SportType.swimming:
        return const [
          Color(0xFF00ACC1),
          Color(0xFF26C6DA),
        ];
      case SportType.cycling:
        return const [
          Color(0xFF4CAF50),
          Color(0xFF66BB6A),
        ];
      case SportType.running:
        return const [
          Color(0xFFE53935),
          Color(0xFFEF5350),
        ];
    }
  }

  static Color getSportColor(SportType sportType) {
    switch (sportType) {
      case SportType.swimming:
        return const Color(0xFF00ACC1);
      case SportType.cycling:
        return const Color(0xFF4CAF50);
      case SportType.running:
        return const Color(0xFFE53935);
    }
  }

  static Widget buildSportLabel(SportType sportType, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: getSportColor(sportType).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: getSportColor(sportType),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getSportIcon(sportType),
            size: 16,
            color: getSportColor(sportType),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: getSportColor(sportType),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
