import 'package:flutter/material.dart';

import '../../../../../core/widgets/trading_ui_tokens.dart';

class TradeFilterChipsBar extends StatelessWidget {
  const TradeFilterChipsBar({
    required this.filters,
    required this.onRemoved,
    this.onClear,
    super.key,
  });

  final List<String> filters;
  final ValueChanged<String> onRemoved;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: TradingUiSpacing.sm,
      runSpacing: TradingUiSpacing.sm,
      children: [
        ...filters.map(
          (filter) => InputChip(
            label: Text(filter),
            onDeleted: () => onRemoved(filter),
          ),
        ),
        if (filters.isNotEmpty && onClear != null)
          TextButton(onPressed: onClear, child: const Text('Clear Filters')),
      ],
    );
  }
}
