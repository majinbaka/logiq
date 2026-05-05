# Phase 03 Plan: Portfolio Tracking And Daily Journal

## Goal

Implement current holdings, manual price tracking, daily account snapshots,
cash movements, and the pre-session/post-session daily journal workflow.

## ERD Tables

- `TRADING_ACCOUNT`
- `INSTRUMENT`
- `TRADE`
- `TRADE_FILL`
- `PORTFOLIO_SNAPSHOT`
- `POSITION_SNAPSHOT`
- `CASH_MOVEMENT`
- `PRICE_QUOTE`
- `DAILY_JOURNAL`
- `EMOTION_LOG`

## Portfolio Tracking Scope

### Holdings

- Show current instruments held by account.
- Show quantity, average cost, latest manual or synced price, market value,
  unrealized PnL, and weight percent.
- Support manual price entry through `PRICE_QUOTE`.
- Generate `POSITION_SNAPSHOT` records for each portfolio snapshot.

### Account Timeline

- Capture `PORTFOLIO_SNAPSHOT` by date.
- Store cash balance, positions market value, total equity, net deposit to date,
  daily PnL, cumulative PnL, drawdown percent, and notes.
- Use `CASH_MOVEMENT` for deposits, withdrawals, dividends, interest,
  adjustments, and fees not tied to fills.
- Keep deposits/withdrawals out of trading PnL.

### Snapshot Generation

Implement a service that can:

- Build holdings from trade fills.
- Apply latest price quotes by instrument.
- Combine cash movements and realized trade cash flows.
- Calculate total equity, daily PnL, cumulative PnL, and drawdown.
- Rebuild snapshots for a date range when historical fills, prices, or cash
  movements change.

## Daily Journal Scope

### Pre-Session

- Market view.
- Trading plan.
- Watchlist note.

### Post-Session

- Completed actions.
- Followed plan flag.
- Mistakes.
- Wins.
- Free note.
- Discipline score.

Daily journal must be unique by account and date.

## ViewModel Plan

- `PortfolioOverviewViewModel`
- `HoldingListViewModel`
- `PortfolioSnapshotViewModel`
- `CashMovementViewModel`
- `PriceQuoteViewModel`
- `DailyJournalViewModel`
- `DailyJournalCalendarViewModel`

## UI Plan

Screens:

- Portfolio overview with holdings table/cards and account summary.
- Manual quote entry for current price.
- Cash movement editor.
- Portfolio history chart placeholder or simple list until analytics charting is
  introduced.
- Daily journal calendar/list.
- Daily journal editor split into pre-session and post-session sections.

The UI should be efficient for repeated use: quick date switching, save draft,
and clear validation states.

## Calculation Rules

- Market value = quantity * market price.
- Unrealized PnL = market value - cost basis for current holding.
- Weight percent = position market value / total positions market value.
- Daily PnL must account for net deposits so added cash is not counted as
  profit.
- Drawdown percent should compare current total equity with previous equity
  peak.

## Testing

Unit tests:

- Holdings generated from multiple fills.
- Average cost after scale-in.
- Position removed or reduced after sell fills.
- Manual price quote affects market value and unrealized PnL.
- Cash movement does not inflate PnL.
- Daily snapshot uniqueness by account/date.
- Drawdown calculation.

Widget tests:

- Create daily journal for a date.
- Edit daily journal and verify localized validation.
- Add manual price quote and see holding values update.
- Add cash movement and see account summary update.

## Acceptance Criteria

- A user can see current holdings with average cost, current price, unrealized
  PnL, and weight.
- A user can input current prices manually.
- A user can record deposits/withdrawals separately from trading results.
- Daily account values can be recorded and viewed by date.
- A user can complete pre-session and post-session journal fields.
- `flutter gen-l10n`, `flutter analyze`, and `flutter test` pass.

## Out Of Scope

- External market data sync.
- Broker reconciliation.
- Complex charting beyond simple production-ready presentation.
