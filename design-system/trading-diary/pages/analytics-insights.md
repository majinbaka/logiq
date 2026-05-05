# Analytics And Insights Page Design

Overrides `MASTER.md` for statistics, grouped analysis, portfolio analytics,
and rule-based insight inbox.

## Purpose

Turn source records into readable performance patterns and actionable
recommendations without pretending to be predictive AI.

## Layout

- **Mobile:** KPI cards, chart sections, insight inbox, grouped lists.
- **Tablet/Desktop:** filter bar, KPI grid, two-column chart layout, insight
  side panel or inbox section.

## Filters

- Date range.
- Account.
- Strategy version.
- Instrument.
- Tag.
- Emotion.
- Followed plan.
- Risk violation.

Filters should be persistent while moving between analytics subviews.

## KPI Cards

- Total net PnL.
- Win rate.
- Winning and losing trade counts.
- Largest win and largest loss.
- Average win and average loss.
- Realized risk/reward.
- Average R-multiple.

## Charts

- Equity curve: line chart.
- Daily PnL: bar chart with positive/negative colors.
- Drawdown: area chart.
- Strategy comparison: horizontal bar chart.
- Instrument performance: table plus bar chart.
- Behavior/emotion analysis: grouped bars or compact table.
- R-multiple distribution: histogram.

Every chart needs an empty state and a table/list fallback for exact values.

## Insight Inbox

- Insight card fields:
  - Type.
  - Title.
  - Source metric.
  - Recommendation.
  - Period.
  - Status.
- Actions: Mark reviewed, Dismiss, View source.
- Dismissed insights remain recoverable if the data model supports status
  filtering.

## Visual Rules

- Use accent color for new insight attention, not for every card.
- Avoid red-only analytics pages during drawdowns; combine severity with
  explanation and context.
- Insights must cite source context such as strategy, emotion, tag, or period.

## States

- No facts built: Rebuild Analytics action.
- Rebuild running: progress or loading state without clearing existing data.
- No insights: show neutral state and explain that insights require enough data.
