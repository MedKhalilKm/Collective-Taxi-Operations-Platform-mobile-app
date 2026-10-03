import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Widget label;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? AppTheme.primaryYellow : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: value ? AppTheme.primaryYellow : AppTheme.inputBorder,
                width: 1.5,
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check,
                    size: 15,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(child: label),
        ],
      ),
    );
  }
}
