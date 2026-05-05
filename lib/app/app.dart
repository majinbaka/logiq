import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/trading_section_header.dart';
import '../core/widgets/trading_skeleton.dart';
import '../core/widgets/trading_state_view.dart';
import '../core/widgets/trading_status_badge.dart';
import '../core/widgets/trading_ui_tokens.dart';
import '../features/psychology/presentation/widgets/psychology_widgets.dart';
import '../features/strategy/presentation/widgets/strategy_widgets.dart';
import '../features/trades/presentation/widgets/trade_widgets.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _WidgetGalleryPage(),
    );
  }
}

class _WidgetGalleryPage extends StatefulWidget {
  const _WidgetGalleryPage();

  @override
  State<_WidgetGalleryPage> createState() => _WidgetGalleryPageState();
}

class _WidgetGalleryPageState extends State<_WidgetGalleryPage> {
  TradeStatusTab selectedTab = TradeStatusTab.open;
  String? emotion = 'Calm';
  double intensity = 35;
  final selectedTags = <String>{'Followed Plan'};
  final filters = <String>['VN30', 'Swing', 'Profit'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trading Diary Widget Kit')),
      body: ListView(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        children: [
          const TradingSectionHeader(
            title: 'Design System Components',
            subtitle: 'Trading diary base widgets and feature primitives.',
            trailing: TradingStatusBadge(
              label: 'Draft Kit',
              tone: TradingStatusTone.warning,
            ),
          ),
          const SizedBox(height: TradingUiSpacing.md),
          TradeKpiStrip(
            items: const [
              TradeKpiItemData(label: 'Open Trades', value: '8'),
              TradeKpiItemData(label: 'Closed Trades', value: '124'),
              TradeKpiItemData(label: 'Net PnL', value: '+42.5M'),
              TradeKpiItemData(label: 'Win Rate', value: '58%'),
              TradeKpiItemData(label: 'Avg R', value: '1.42R'),
            ],
          ),
          const SizedBox(height: TradingUiSpacing.md),
          TradeStatusSegmentedControl(
            selected: selectedTab,
            onSelectionChanged: (value) => setState(() => selectedTab = value),
          ),
          const SizedBox(height: TradingUiSpacing.md),
          TradeFilterChipsBar(
            filters: filters,
            onRemoved: (value) => setState(() => filters.remove(value)),
            onClear: () => setState(filters.clear),
          ),
          const SizedBox(height: TradingUiSpacing.md),
          const TradeListCard(
            data: TradeCardData(
              symbol: 'FPT',
              name: 'FPT Corp',
              status: 'Closed',
              direction: 'BUY',
              openDate: '2026-04-01',
              closeDate: '2026-04-08',
              strategyLabel: 'Breakout v3',
              netPnl: '+3,240,000 VND',
              rMultiple: '1.8R',
              pnlState: TradePnlState.profit,
              riskStatus: 'Risk: Passed',
            ),
          ),
          const SizedBox(height: TradingUiSpacing.sm),
          const TradeListCard(
            data: TradeCardData(
              symbol: 'SSI',
              name: 'SSI Securities',
              status: 'Closed',
              direction: 'SELL',
              openDate: '2026-04-15',
              closeDate: '2026-04-18',
              strategyLabel: 'Mean Reversion v2',
              netPnl: '-1,120,000 VND',
              rMultiple: '-0.7R',
              pnlState: TradePnlState.loss,
              riskStatus: 'Risk Violation: Oversized',
            ),
          ),
          const SizedBox(height: TradingUiSpacing.md),
          const StrategyListTile(
            name: 'Breakout Confirmation',
            description: 'Trade momentum breakouts with volume confirmation.',
            isActive: true,
          ),
          const SizedBox(height: TradingUiSpacing.sm),
          const RiskRuleSummaryCard(
            riskPerTrade: '1.0%',
            maxDailyLoss: '2.5%',
            maxWeeklyLoss: '6.0%',
            maxMonthlyLoss: '12.0%',
          ),
          const SizedBox(height: TradingUiSpacing.md),
          EmotionPicker(
            options: const [
              'Confident',
              'Fearful',
              'FOMO',
              'Hesitant',
              'Calm',
              'Frustrated',
            ],
            selected: emotion,
            onSelected: (value) => setState(() => emotion = value),
          ),
          const SizedBox(height: TradingUiSpacing.sm),
          IntensitySliderField(
            value: intensity,
            onChanged: (value) => setState(() => intensity = value),
          ),
          const SizedBox(height: TradingUiSpacing.sm),
          BehaviorTagPicker(
            tags: const [
              'Followed Plan',
              'Early Exit',
              'Overtrading',
              'Revenge Trade',
              'Ignored Stop Loss',
              'Added Without Setup',
            ],
            selected: selectedTags,
            onToggle: (value) {
              setState(() {
                if (selectedTags.contains(value)) {
                  selectedTags.remove(value);
                } else {
                  selectedTags.add(value);
                }
              });
            },
          ),
          const SizedBox(height: TradingUiSpacing.md),
          TradingStateView(
            title: 'No trades found',
            message: 'Try adjusting filters or create a new draft trade.',
            icon: Icons.inbox_outlined,
            actionLabel: 'New Trade Draft',
            onAction: () {},
          ),
          const SizedBox(height: TradingUiSpacing.md),
          const TradingSkeletonCard(lines: 4),
        ],
      ),
    );
  }
}
