# Phase 02 Plan: Trading Journal, Strategy, And Risk Core

## Goal

Implement the source-of-truth trading workflow: create trades, record BUY/SELL
orders and fills, capture pre-trade plans, manage strategies, review exits, and
evaluate risk rules.

## ERD Tables

- `TRADING_ACCOUNT`
- `INSTRUMENT`
- `STRATEGY`
- `STRATEGY_VERSION`
- `TRADE`
- `TRADE_ORDER`
- `TRADE_FILL`
- `TRADE_PLAN`
- `TRADE_PLAN_TARGET`
- `TRADE_REVIEW`
- `TRADE_CONTEXT`
- `RISK_RULE`
- `RISK_CHECK`

## User Workflows

### Trading Journal

- Create a trade for an instrument and account.
- Select direction: long/short if supported, or BUY/SELL workflow for stock MVP.
- Add one or more orders.
- Add fills with executed date, price, quantity, fee, and tax.
- Calculate average entry price, average exit price, total fee, total tax,
  gross PnL, net PnL, PnL percent, and R-multiple.
- Mark trade status as draft, open, closed, or canceled.

### Pre-Trade Plan

- Capture thesis, strategy, planned entry zone, stop loss, targets, planned risk
  amount, confidence percent, and invalidation note.
- Support multiple targets through `TRADE_PLAN_TARGET`.
- Validate confidence from 0 to 100 and target ordering.

### Post-Trade Review

- Capture exit reason, followed plan, mistake summary, lesson, discipline score,
  and self review.
- Validate discipline score from 0 to 100.
- Preserve private notes without logging.

### Strategy Management

- Create, edit, archive, and restore strategies.
- Store rule changes as new `STRATEGY_VERSION` rows.
- Assign a specific strategy version to a trade.
- Show strategy details while making it clear that historical trades retain
  their assigned version.

### Risk Management

- Create active risk rules by account with effective dates.
- Configure risk percent per trade, max daily/weekly/monthly loss, and stop
  trading rule.
- Evaluate each trade plan/fill against the applicable `RISK_RULE`.
- Store planned risk, actual risk, max allowed risk, risk per share, planned
  position size, exceeded risk, followed risk rule, and violation reason in
  `RISK_CHECK`.

## Calculation Rules

- `TRADE_FILL` is the source of truth for price, quantity, fee, tax, gross
  value, and net cash flow.
- `TRADE` summary fields are cached display values and must be recalculated
  whenever fills or review/risk inputs change.
- Fees and taxes reduce net PnL.
- R-multiple should use actual net result divided by planned or actual risk
  amount, with clear handling when risk is missing or zero.
- For partial exits, closed quantity and average exit price must reflect only
  exit fills.

## ViewModel Plan

Create feature viewmodels under `features/trading_journal/presentation/viewmodels/`
and related feature folders:

- `TradeListViewModel`
- `TradeEditorViewModel`
- `TradePlanViewModel`
- `TradeReviewViewModel`
- `StrategyListViewModel`
- `StrategyEditorViewModel`
- `RiskRuleViewModel`
- `RiskCheckViewModel`

Widgets should only bind to viewmodel state and commands.

## UI Plan

Screens:

- Trade list with filters by status, instrument, strategy, date range, and PnL.
- Trade detail with tabs for fills, plan, review, context, and risk.
- Trade editor for core trade fields.
- Order/fill editor for BUY/SELL execution.
- Plan editor with target list.
- Review editor.
- Strategy list and editor.
- Risk rule setup and risk check detail.

Use dense dashboard-oriented layouts, responsive forms, and theme colors. Avoid
hardcoded widget colors.

## Testing

Unit tests:

- Trade PnL calculation with one entry and one exit.
- Partial fill and partial exit calculation.
- Fee/tax impact on net PnL.
- PnL percent and R-multiple edge cases.
- Strategy version creation on rule edits.
- Risk rule selection by effective date.
- Risk violation detection.

Widget tests:

- Create trade draft.
- Add plan and targets.
- Add fills and see summary update.
- Close trade and add review.
- Validation errors for missing symbol, invalid score, invalid percent, and
  negative values.

## Acceptance Criteria

- A user can fully record a trade lifecycle from plan to exit review.
- BUY/SELL fills recalculate trade summaries deterministically.
- Strategy versions are immutable for historical trades.
- Risk checks are generated or updated when relevant trade inputs change.
- All strings are localized in English and Vietnamese.
- `flutter gen-l10n`, `flutter analyze`, and `flutter test` pass.

## Out Of Scope

- Automated broker sync.
- Tax-lot optimization beyond average-cost stock workflow.
- Advanced analytics dashboard beyond values needed on trade detail.
