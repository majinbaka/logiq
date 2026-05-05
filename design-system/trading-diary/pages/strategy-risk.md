# Strategy And Risk Page Design

Overrides `MASTER.md` for strategy management, strategy versions, risk rules,
and risk check inspection.

## Purpose

Make trading rules explicit and keep historical strategy versions auditable.

## Layout

- **Mobile:** two entry cards: Strategies and Risk Rules, then lists.
- **Tablet/Desktop:** split view with list on the left and editor/detail on the
  right.

## Strategy Components

- Strategy list with active/archived status.
- Strategy detail with current rule summary and version timeline.
- Editor fields: name, description, setup rules, entry rules, exit rules, risk
  notes.
- Version history clearly labels effective date and whether it is assigned to
  historical trades.

## Risk Components

- Active risk rule card for selected account.
- Rule editor fields:
  - Risk percent per trade.
  - Max daily, weekly, monthly loss.
  - Stop trading rule.
  - Effective date range.
- Risk check detail: planned risk, actual risk, max allowed risk, position size,
  exceeded risk, followed rule, violation reason.

## Visual Rules

- Active strategy/rule uses primary container.
- Archived strategy uses muted text and restore action.
- Risk violation uses danger styling plus reason text.
- Effective-date conflicts use inline validation before save.

## States

- Empty strategy state: Create Strategy.
- Empty risk state: Create Risk Rule.
- No active rule: warn gently on trade plan, but allow draft creation.
