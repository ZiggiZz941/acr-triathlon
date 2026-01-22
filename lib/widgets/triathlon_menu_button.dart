import 'package:flutter/material.dart';
import '../models/sport_type.dart';
import '../constants/triathlon_colors.dart';

class TriathlonMenuButton extends StatelessWidget {
  final SportType sportType;
  final VoidCallback onPressed;
  final double? width; // Nouveau paramètre

  const TriathlonMenuButton({
    super.key,
    required this.sportType,
    required this.onPressed,
    this.width, // Optionnel
  });

  // Méthode pour obtenir la couleur selon le sport
  Color _getSportColor() {
    switch (sportType) {
      case SportType.swimming:
        return TriathlonColors.swimming;
      case SportType.cycling:
        return TriathlonColors.cycling;
      case SportType.running:
        return TriathlonColors.running;
    }
  }

  // Méthode pour obtenir le nom du sport
  String _getSportName() {
    switch (sportType) {
      case SportType.swimming:
        return 'Natation';
      case SportType.cycling:
        return 'Cyclisme';
      case SportType.running:
        return 'Course à pied';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sportColor = _getSportColor();
    final sportName = _getSportName();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                sportColor.withOpacity(0.9),
                sportColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getSportIcon(),
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 15),
              Text(
                sportName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _getSportSubtitle(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSportIcon() {
    switch (sportType) {
      case SportType.swimming:
        return Icons.pool;
      case SportType.cycling:
        return Icons.directions_bike;
      case SportType.running:
        return Icons.directions_run;
    }
  }

  String _getSportSubtitle() {
    switch (sportType) {
      case SportType.swimming:
        return 'Calculs sur 400m';
      case SportType.cycling:
        return 'Calculs sur FTP';
      case SportType.running:
        return 'Calculs sur VMA';
    }
  }
}
