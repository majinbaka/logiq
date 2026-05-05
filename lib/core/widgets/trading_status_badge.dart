import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TradingStatusBadge extends StatelessWidget {
  const TradingStatusBadge({
    required this.label,
    this.tone = TradingStatusTone.neutral,
    super.key,
  });

  final String label;
  final TradingStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = theme.extension<TradingSemanticColors>();

    final colors = switch (tone) {
      TradingStatusTone.neutral => (
          background: theme.colorScheme.surfaceContainer,
          foreground: theme.colorScheme.onSurfaceVariant,
          border: theme.colorScheme.outlineVariant,
        ),
      TradingStatusTone.success => (
          background:
              (semanticColors?.success ?? theme.colorScheme.primary).withValues(
            alpha: 0.12,
          ),
          foreground: semanticColors?.success ?? theme.colorScheme.primary,
          border: (semanticColors?.success ?? theme.colorScheme.primary)
              .withValues(alpha: 0.28),
        ),
      TradingStatusTone.danger => (
          background: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          foreground: theme.colorScheme.error,
          border: theme.colorScheme.error.withValues(alpha: 0.28),
        ),
      TradingStatusTone.warning => (
          background:
              theme.colorScheme.tertiaryContainer.withValues(alpha: 0.32),
          foreground: theme.colorScheme.tertiary,
          border: theme.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: colors.foreground),
      ),
    );
  }
}

enum TradingStatusTone {
  neutral,
  success,
  danger,
  warning,
}
