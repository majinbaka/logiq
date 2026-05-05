# Trade List Page Design

Overrides `MASTER.md` for the trading journal list, filters, and quick summary.

## Purpose

Help users find, compare, and resume trades quickly across draft, open, closed,
and canceled states.

## Layout

- **Mobile:** KPI strip, filter chips, vertical trade cards.
- **Tablet/Desktop:** KPI strip, compact filter bar, dense table with optional
  split detail preview.

## Key Components

- Status segmented control: Draft, Open, Closed, Canceled, All.
- Filters: instrument, strategy, date range, PnL state, tag.
- KPI strip: open trades, closed trades, net PnL, win rate, average R.
- Trade row/card fields:
  - Instrument symbol and name.
  - Direction/status.
  - Open and close date.
  - Strategy version label.
  - Net PnL and R-multiple.
  - Risk rule status.

## Visual Rules

- Positive PnL uses success text plus `Profit` label.
- Negative PnL uses danger text plus `Loss` label.
- Draft rows use muted styling, not warning colors.
- Risk violations use danger outline and a short reason on detail/tooltip.

## States

- Empty filtered state: offer Clear Filters.
- Empty first-run state: primary action New Trade Draft.
- Loading: skeleton table rows or cards.
- Error: keep filters visible and show retry action.

## Mobile Behavior

- Trade cards place symbol, status, and net PnL in the first row.
- Secondary metadata wraps below; do not force a wide table.
- Filter sheet opens as a bottom sheet with Apply and Reset actions.
