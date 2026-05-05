import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/trading_status_badge.dart';
import '../../../../../core/widgets/trading_ui_tokens.dart';
import 'trade_types.dart';

class TradeListCard extends StatelessWidget {
  const TradeListCard({required this.data, this.onTap, super.key});

  final TradeCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pnlColor = switch (data.pnlState) {
      TradePnlState.profit =>
        Theme.of(context).extension<TradingSemanticColors>()?.success ??
            theme.colorScheme.primary,
      TradePnlState.loss => theme.colorScheme.error,
      TradePnlState.neutral => theme.colorScheme.onSurface,
    };

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(TradingUiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${data.symbol} • ${data.name}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(data.status, style: theme.textTheme.labelMedium),
                ],
              ),
              const SizedBox(height: TradingUiSpacing.xs),
              Text(
                '${data.direction} • ${data.openDate} - ${data.closeDate}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              Row(
                children: [
                  Expanded(child: Text(data.strategyLabel)),
                  Text(
                    data.netPnl,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: pnlColor,
                    ),
                  ),
                  const SizedBox(width: TradingUiSpacing.sm),
                  Text(data.rMultiple),
                ],
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: TradingStatusBadge(
                  label: data.riskStatus,
                  tone: data.riskStatus.toLowerCase().contains('violation')
                      ? TradingStatusTone.danger
                      : TradingStatusTone.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
