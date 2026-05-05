import 'package:flutter/material.dart';

import 'trading_ui_tokens.dart';

class TradingSkeletonCard extends StatelessWidget {
  const TradingSkeletonCard({
    this.lines = 3,
    this.showHeader = true,
    super.key,
  });

  final int lines;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              _SkeletonBlock(width: 140, color: theme.colorScheme.surfaceContainerHighest),
              const SizedBox(height: TradingUiSpacing.sm),
            ],
            ...List.generate(
              lines,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: TradingUiSpacing.xs),
                child: _SkeletonBlock(
                  width: index.isEven ? double.infinity : 220,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const SizedBox(height: 12),
      ),
    );
  }
}
