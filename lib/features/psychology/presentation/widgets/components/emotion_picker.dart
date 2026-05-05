import 'package:flutter/material.dart';

import '../../../../../core/widgets/trading_ui_tokens.dart';

class EmotionPicker extends StatelessWidget {
  const EmotionPicker({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: TradingUiSpacing.sm,
      runSpacing: TradingUiSpacing.sm,
      children: options
          .map(
            (emotion) => ChoiceChip(
              label: Text(emotion),
              selected: selected == emotion,
              onSelected: (_) => onSelected(emotion),
            ),
          )
          .toList(),
    );
  }
}
