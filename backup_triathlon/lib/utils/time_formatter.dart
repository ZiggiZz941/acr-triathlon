class TimeFormatter {
  // Convertir mm:ss en secondes
  static int parseTimeToSeconds(String timeStr) {
    if (timeStr.trim().isEmpty) return 0;

    try {
      if (timeStr.contains(':')) {
        List<String> parts = timeStr.split(':');
        if (parts.length == 2) {
          int minutes = int.parse(parts[0]);
          int seconds = int.parse(parts[1]);
          return (minutes * 60) + seconds;
        }
      }
      return int.parse(timeStr);
    } catch (e) {
      return 0;
    }
  }

  // Convertir secondes en mm:ss
  static String formatSecondsToMinutes(int seconds) {
    if (seconds <= 0) return '0:00';

    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  // Formater avec centièmes (pour les calculs)
  static String formatWithCentiemes(double seconds) {
    int minutes = (seconds ~/ 60).toInt();
    double decimalSeconds = seconds % 60;

    if (decimalSeconds >= 60) {
      minutes += (decimalSeconds ~/ 60).toInt();
      decimalSeconds = decimalSeconds % 60;
    }

    if (minutes > 0) {
      return '${minutes}:${decimalSeconds.toStringAsFixed(2).padLeft(5, '0')}';
    } else {
      return '${decimalSeconds.toStringAsFixed(2)} sec';
    }
  }

  // Formater pour l'affichage chronomètre (mm:ss.xx)
  static String formatChrono(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitsMillis(int n) => n.toString().padLeft(2, '0');

    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    int milliseconds = duration.inMilliseconds.remainder(1000) ~/ 10;

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}.${twoDigitsMillis(milliseconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}.${twoDigitsMillis(milliseconds)}';
    }
  }
}
