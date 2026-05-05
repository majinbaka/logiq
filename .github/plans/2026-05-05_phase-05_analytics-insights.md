# Phase 05 Plan: Analytics And Rule-Based Insights

## Goal

Turn recorded trading, portfolio, risk, strategy, emotion, and journal data into
actionable analytics and rule-based improvement suggestions.

## ERD Tables

- `ANALYTICS_TRADE_FACT`
- `ANALYTICS_DAILY_ACCOUNT_FACT`
- `INSIGHT`
- Source tables:
  - `TRADE`
  - `TRADE_FILL`
  - `TRADE_PLAN`
  - `TRADE_REVIEW`
  - `TRADE_CONTEXT`
  - `TRADE_TAG`
  - `TAG`
  - `RISK_CHECK`
  - `STRATEGY_VERSION`
  - `PORTFOLIO_SNAPSHOT`
  - `POSITION_SNAPSHOT`
  - `EMOTION_LOG`

## Analytics Scope

### Basic Statistics

- Total net PnL.
- Win rate.
- Number of winning trades.
- Number of losing trades.
- Largest win.
- Largest loss.
- Average winning trade.
- Average losing trade.
- Realized risk/reward.
- R-multiple distribution.

### Grouped Analysis

Group results by:

- Strategy version.
- Instrument.
- Date, week, and month.
- Market condition.
- Timeframe.
- Setup tag.
- Behavior tag.
- Primary emotion.
- Followed plan vs did not follow plan.
- Risk violation vs no risk violation.
- Disciplined vs low-discipline trade review.

### Portfolio Analytics

- Equity curve.
- Daily PnL.
- Cumulative PnL.
- Drawdown percent.
- Net deposit-adjusted performance.
- Current allocation by instrument.

## Analytics Fact Rebuild Plan

Implement rebuildable materialization services:

- `AnalyticsTradeFactBuilder`
- `AnalyticsDailyAccountFactBuilder`
- `AnalyticsRebuildService`

Facts are cache tables, not source of truth. The rebuild service must support:

- Full rebuild by account.
- Date-range rebuild after edits.
- Trade-level rebuild after fill/plan/review/risk changes.
- Safe clearing and regeneration of analytics cache.

## Insight Scope

Generate rule-based `INSIGHT` records from analytics and source data:

- Repeated mistake appears above threshold.
- A strategy has materially better results than alternatives.
- Trades without plans perform worse than trades with plans.
- Trades with low discipline perform worse than disciplined trades.
- Emotional trades have worse average PnL or R-multiple.
- Stop-loss violations create outsized losses.
- Low-confidence trades underperform.
- A market condition produces better or worse results.

Each insight must store:

- Type.
- Title.
- Description.
- Source metric.
- Source entity type/id where relevant.
- Recommendation.
- Period start/end.
- Generated time.
- Status and dismissed time.

## Rule Examples

- If a user has multiple losses where actual exit is worse than stop loss, create
  a recommendation to cut losses earlier.
- If trades tagged `No clear setup` have negative expectancy, recommend avoiding
  trades without a setup.
- If trades with FOMO emotion have worse average R-multiple, recommend reducing
  size or skipping trades when emotion intensity is high.
- If one strategy has higher win rate and average R than the account average,
  surface it as the strongest strategy for the selected period.

## ViewModel Plan

- `AnalyticsDashboardViewModel`
- `TradeStatsViewModel`
- `StrategyPerformanceViewModel`
- `BehaviorAnalyticsViewModel`
- `PortfolioAnalyticsViewModel`
- `InsightListViewModel`
- `InsightDetailViewModel`

## UI Plan

Screens:

- Analytics overview with key metrics.
- PnL and equity timeline.
- Strategy comparison.
- Instrument performance.
- Behavior and emotion analysis.
- Risk and discipline analysis.
- Insight inbox with dismiss/action states.

Charts should be simple, readable, responsive, and tested for empty states. If a
chart package is introduced, document the reason and keep the dependency
surface small.

## Testing

Unit tests:

- Fact rebuild from seed trades.
- Win rate and count calculations.
- Average win/loss and largest win/loss.
- Risk/reward and R-multiple calculations.
- Grouped strategy performance.
- Behavior tag and emotion correlation calculations.
- Drawdown from daily account facts.
- Rule-based insight thresholds and deduplication.
- Insight dismissal.

Widget tests:

- Analytics empty state.
- Dashboard with seed data.
- Strategy comparison with multiple strategy versions.
- Insight inbox showing generated recommendation.

## Acceptance Criteria

- Analytics can be fully rebuilt from source records.
- Dashboard metrics match deterministic fixture expectations.
- A user can compare performance by strategy, time, behavior, and emotion.
- A user can see rule-based improvement suggestions with clear source context.
- Dismissing an insight does not delete source records or analytics facts.
- All strings are localized in English and Vietnamese.
- `flutter gen-l10n`, `flutter analyze`, and `flutter test` pass.

## Out Of Scope

- Predictive AI recommendations.
- External benchmarking.
- Sharing or exporting reports without a separate privacy/security design.
