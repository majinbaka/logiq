import 'package:flutter/material.dart';

import 'trade_types.dart';

class TradeStatusSegmentedControl extends StatelessWidget {
  const TradeStatusSegmentedControl({
    required this.selected,
    required this.onSelectionChanged,
    super.key,
  });

  final TradeStatusTab selected;
  final ValueChanged<TradeStatusTab> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TradeStatusTab>(
      segments: const [
        ButtonSegment(value: TradeStatusTab.draft, label: Text('Draft')),
        ButtonSegment(value: TradeStatusTab.open, label: Text('Open')),
        ButtonSegment(value: TradeStatusTab.closed, label: Text('Closed')),
        ButtonSegment(value: TradeStatusTab.canceled, label: Text('Canceled')),
        ButtonSegment(value: TradeStatusTab.all, label: Text('All')),
      ],
      selected: {selected},
      onSelectionChanged: (value) => onSelectionChanged(value.first),
      showSelectedIcon: false,
    );
  }
}
