import 'package:flutter/material.dart';

import '../../../../../core/widgets/trading_ui_tokens.dart';

class RiskRuleSummaryCard extends StatelessWidget {
  const RiskRuleSummaryCard({
    required this.riskPerTrade,
    required this.maxDailyLoss,
    required this.maxWeeklyLoss,
    required this.maxMonthlyLoss,
    super.key,
  });

  final String riskPerTrade;
  final String maxDailyLoss;
  final String maxWeeklyLoss;
  final String maxMonthlyLoss;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risk Rules', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TradingUiSpacing.sm),
            _RuleLine(label: 'Risk / Trade', value: riskPerTrade),
            _RuleLine(label: 'Max Daily Loss', value: maxDailyLoss),
            _RuleLine(label: 'Max Weekly Loss', value: maxWeeklyLoss),
            _RuleLine(label: 'Max Monthly Loss', value: maxMonthlyLoss),
          ],
        ),
      ),
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TradingUiSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value),
        ],
      ),
    );
  }
}
