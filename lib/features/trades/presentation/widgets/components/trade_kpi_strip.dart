import 'package:flutter/material.dart';

import '../../../../../core/widgets/trading_ui_tokens.dart';
import 'trade_types.dart';

class TradeKpiStrip extends StatelessWidget {
  const TradeKpiStrip({required this.items, super.key});

  final List<TradeKpiItemData> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: TradingUiSpacing.sm,
      runSpacing: TradingUiSpacing.sm,
      children: items
          .map(
            (item) => SizedBox(
              width: 180,
              child: _MetricCard(label: item.label, value: item.value),
            ),
          )
          .toList(),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: TradingUiSpacing.xs),
            Text(value, style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
