# Phase 01 Plan: Foundation And Storage

## Goal

Create the production foundation required before feature work: bootstrap,
localization, theme, navigation, persistence, repositories, and test fixtures.
This phase should not build all trading features yet; it should make later
features safe to implement.

## Current Inputs

- Current app entry is minimal in `lib/main.dart`.
- Logical models exist in `lib/core/database/models/`.
- ERD is documented in `docs/DATABASE_ERD.md`.
- Hive is already declared in `pubspec.yaml`, but no repository or storage
  layer exists.

## Scope

- Add `bootstrap.dart` and move `MainApp` into `lib/app/app.dart`.
- Add ARB-based localization with English and Vietnamese.
- Add a restrained theme baseline aligned with `design-system/trading-diary/MASTER.md`.
- Add a navigation shell with placeholder destinations for the planned modules.
- Add persistence interfaces and local storage adapters.
- Add repository contracts for all ERD aggregate roots.
- Add seed data utilities for tests and local development.

## Storage Plan

Use the current model `toMap` / `fromMap` methods as the persistence boundary
for the first implementation. If Hive remains the chosen storage, keep each
logical ERD table as a separate box or a clearly named feature box. Relations
must be stored by id, not by deeply nested objects.

Required storage boxes or equivalent collections:

- `trading_accounts`
- `instruments`
- `strategies`
- `strategy_versions`
- `trades`
- `trade_orders`
- `trade_fills`
- `trade_plans`
- `trade_plan_targets`
- `trade_reviews`
- `trade_contexts`
- `emotion_logs`
- `tags`
- `trade_tags`
- `risk_rules`
- `risk_checks`
- `portfolio_snapshots`
- `position_snapshots`
- `cash_movements`
- `price_quotes`
- `daily_journals`
- `instrument_notes`
- `instrument_note_updates`
- `insights`
- `analytics_trade_facts`
- `analytics_daily_account_facts`

## Repository Boundaries

Create interfaces before UI depends on storage:

- `AccountRepository`
- `InstrumentRepository`
- `StrategyRepository`
- `TradeRepository`
- `PortfolioRepository`
- `DailyJournalRepository`
- `PsychologyRepository`
- `InstrumentNoteRepository`
- `RiskRepository`
- `AnalyticsRepository`
- `InsightRepository`

Repositories should expose feature-oriented methods, not raw box handles.
Examples:

- `watchOpenTrades(accountId)`
- `saveTradeDraft(...)`
- `listPortfolioSnapshots(accountId, range)`
- `getDailyJournal(accountId, date)`
- `rebuildAnalyticsFacts(accountId, range)`

## Validation And Data Integrity

Add shared validators for:

- Required ids and symbols.
- Date ordering such as opened date before closed date.
- Percent ranges from 0 to 100.
- Score ranges from 0 to 100.
- Non-negative price, fee, tax, and quantity values.
- Soft-deleted records excluded from default queries.

## Implementation Steps

1. Create app bootstrap and move `runApp` out of feature code.
2. Add localization config and initial keys for app shell labels.
3. Add theme files for colors, typography, spacing, and component defaults.
4. Add storage initialization service with schema version metadata.
5. Add repository interfaces and local implementations.
6. Add deterministic id/time abstractions for tests.
7. Add seed fixtures covering one account, instruments, strategies, trades,
   fills, daily journal, portfolio snapshot, emotion logs, and tags.
8. Add unit tests for model mapping, repository CRUD, soft delete behavior, and
   validation failures.

## Acceptance Criteria

- App starts through `bootstrap()` and renders the app shell.
- `flutter gen-l10n`, `flutter analyze`, and `flutter test` pass.
- All user-visible app shell strings come from localization.
- Storage initialization is idempotent.
- Repository tests can create, read, update, soft-delete, and query records by
  account/date/instrument.
- No widget directly imports Hive or storage implementation classes.

## Out Of Scope

- Full trading forms.
- Portfolio dashboard metrics.
- Rule-based insight generation.
- External quote synchronization.
