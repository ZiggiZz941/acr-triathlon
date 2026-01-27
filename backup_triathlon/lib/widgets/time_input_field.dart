import 'package:flutter/material.dart';
import '../constants/triathlon_colors.dart';
import '../constants/triathlon_dimens.dart';

class TimeInputField extends StatefulWidget {
  final String label;
  final int initialSeconds;
  final ValueChanged<int> onChanged;
  final Color color;
  final bool showLabel;

  const TimeInputField({
    super.key,
    required this.label,
    required this.initialSeconds,
    required this.onChanged,
    required this.color,
    this.showLabel = true,
  });

  @override
  _TimeInputFieldState createState() => _TimeInputFieldState();
}

class _TimeInputFieldState extends State<TimeInputField> {
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    int totalSeconds = widget.initialSeconds;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    _minutesController = TextEditingController(text: minutes.toString());
    _secondsController =
        TextEditingController(text: seconds.toString().padLeft(2, '0'));

    // Écouter les changements pour la validation en temps réel
    _minutesController.addListener(_validateAndNotify);
    _secondsController.addListener(_validateAndNotify);
  }

  @override
  void didUpdateWidget(covariant TimeInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSeconds != widget.initialSeconds) {
      _initializeControllers();
    }
  }

  void _validateAndNotify() {
    int minutes = int.tryParse(_minutesController.text) ?? 0;
    int seconds = int.tryParse(_secondsController.text) ?? 0;

    // Valider les secondes (doivent être entre 0 et 59)
    if (seconds >= 60) {
      seconds = 59;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _secondsController.text = '59';
      });
    }

    // Valider les minutes (pas de négatif)
    if (minutes < 0) {
      minutes = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _minutesController.text = '0';
      });
    }

    // Valider les secondes (pas de négatif)
    if (seconds < 0) {
      seconds = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _secondsController.text = '00';
      });
    }

    // Formater les secondes pour toujours avoir 2 chiffres
    if (_secondsController.text.isNotEmpty &&
        _secondsController.text.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _secondsController.text = _secondsController.text.padLeft(2, '0');
      });
    }

    int totalSeconds = (minutes * 60) + seconds;
    widget.onChanged(totalSeconds);
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: TextStyle(
              color: widget.color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
        ],
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.showLabel)
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: TriathlonColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Min',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusMedium,
                        ),
                        borderSide: BorderSide(
                          color: widget.color,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: TriathlonDimens.paddingMedium,
                        vertical: TriathlonDimens.paddingMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: TriathlonDimens.paddingSmall),
            Text(
              ':',
              style: TextStyle(
                color: widget.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: TriathlonDimens.paddingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.showLabel)
                    const SizedBox(height: 12), // Pour aligner avec le label
                  TextField(
                    controller: _secondsController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Sec',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          TriathlonDimens.borderRadiusMedium,
                        ),
                        borderSide: BorderSide(
                          color: widget.color,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: TriathlonDimens.paddingMedium,
                        vertical: TriathlonDimens.paddingMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Format: minutes:secondes',
          style: TextStyle(
            color: TriathlonColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
