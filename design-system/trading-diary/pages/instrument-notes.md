# Instrument Notes Page Design

Overrides `MASTER.md` for structured instrument research notes and update
timelines.

## Purpose

Keep an instrument thesis current while preserving update history and linked
trade context.

## Layout

- **Mobile:** instrument search/list, note detail, update timeline.
- **Tablet/Desktop:** instrument list on the left, structured note detail in the
  center, linked trades/timeline on the right when space allows.

## Components

- Instrument search grouped by watchlist/recently traded.
- Structured note sections:
  - Thesis.
  - Strengths.
  - Weaknesses.
  - Risks.
  - Bull case.
  - Bear case.
  - Status.
- Update composer and chronological update timeline.
- Linked trades list with PnL and status.

## Visual Rules

- Status chips use theme semantic keys.
- Bull and bear cases can use bullish/bearish accents, but must include labels.
- Long notes use readable line height and avoid dense table styling.

## States

- No instrument note: show Create Note for selected symbol.
- No updates: show Add Update in the timeline area.
- No linked trades: show neutral empty row, not an error.

## Privacy

- Treat thesis and updates as private research. No print, export, or share
  action by default.
