import 'package:flutter/material.dart';
import '../../constants/triathlon_colors.dart';
import '../../constants/triathlon_dimens.dart';

class SwimmingAllureInput extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController secController;
  final TextEditingController centController;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const SwimmingAllureInput({
    super.key,
    required this.minController,
    required this.secController,
    required this.centController,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            enabled ? Colors.white : TriathlonColors.swimming.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TriathlonDimens.borderRadiusMedium),
        border: Border.all(
          color: TriathlonColors.swimming,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Minutes
          Expanded(
            child: TextField(
              controller: minController,
              enabled: enabled,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: onChanged,
              style: TextStyle(
                color: TriathlonColors.swimming,
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                hintText: '0',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Séparateur :
          Container(
            color: TriathlonColors.swimming,
            width: 1,
            height: 40,
            child: Center(
              child: Text(
                ':',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Secondes
          Expanded(
            child: TextField(
              controller: secController,
              enabled: enabled,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: onChanged,
              style: TextStyle(
                color: TriathlonColors.swimming,
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                hintText: '00',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Séparateur .
          Container(
            color: TriathlonColors.swimming,
            width: 1,
            height: 40,
            child: Center(
              child: Text(
                '.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Centièmes
          Expanded(
            child: TextField(
              controller: centController,
              enabled: enabled,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: onChanged,
              style: TextStyle(
                color: TriathlonColors.swimming,
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                hintText: '00',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
