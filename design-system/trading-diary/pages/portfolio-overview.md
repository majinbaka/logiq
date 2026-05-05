# Portfolio Overview Page Design

Overrides `MASTER.md` for holdings, account timeline, manual quotes, cash
movements, and snapshots.

## Purpose

Show current account health while separating trading performance from deposits
and withdrawals.

## Layout

- **Mobile:** account summary, holdings cards, quick quote/cash actions,
  snapshot list.
- **Tablet/Desktop:** summary KPI row, holdings table, side panel for latest
  snapshot and cash movement actions.

## Key Components

- KPI row: total equity, cash balance, positions value, daily PnL, cumulative
  PnL, drawdown.
- Holdings table/card:
  - Symbol.
  - Quantity.
  - Average cost.
  - Latest price.
  - Market value.
  - Unrealized PnL.
  - Weight percent.
- Manual quote bottom sheet/dialog.
- Cash movement editor.
- Snapshot history list or simple equity chart placeholder.

## Visual Rules

- Deposits and withdrawals use neutral styling, not profit/loss colors.
- Daily PnL and unrealized PnL use success/danger with text labels.
- Drawdown uses danger scale only when severity increases.
- Stale manual quote should show timestamp.

## Chart Guidance

- Equity curve: line chart.
- Drawdown: area chart below equity or compact sparkline.
- Allocation: horizontal stacked bar or donut with list fallback.

## States

- No holdings: explain that holdings come from fills, then offer New Trade.
- No quote: show Add Price action in the row/card.
- No snapshot: offer Create Snapshot for selected date.
