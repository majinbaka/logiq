# Cash Management Review And Implementation Notes

Date: 2026-05-06

## A. Codebase Scan Summary

Related modules found:

- Storage/Hive schema boxes: `lib/core/storage/storage_boxes.dart`,
  `lib/core/storage/storage_initializer.dart`.
- Logical money/account models: `TradingAccountModel`, `CashMovementModel`,
  `CashLedgerModel`, `AccountBalanceModel`, `PortfolioSnapshotModel`.
- Cash/balance engine entry points: `AccountBalanceSyncService` and
  `LocalPortfolioRepository`.
- Order integration: `TradesCrudViewModel` validates buying power before trade
  creation and calls reserve/release/fill cash methods for pending order
  lifecycle.
- Portfolio UI: portfolio CRUD view has cash movement entry/history, quotes,
  holdings and snapshots. Trades view has a funding-flow card that displays
  current, available, reserved cash and buying power.

What already exists:

- Hive-backed local tables/boxes for trading accounts, cash movements, cash
  ledgers, account balances, portfolio snapshots, orders, fills and risk checks.
- Decimal values are stored as strings at the model boundary.
- Completed ledger entries update `ACCOUNT_BALANCE` through a centralized
  `AccountBalanceSyncService`.
- Order flow already has hooks to reserve, release and settle reserved cash.
- Trading flow validation checks that an account has initial deposit and a risk
  rule before creating trades.

Gaps and architectural risks found:

- `CASH_MOVEMENT` had no status/idempotency/broker confirmation fields, so a
  movement could not remain pending before broker confirmation.
- Cash movement history reconstructed from ledger hardcoded `VND`, which was a
  multi-currency reporting risk.
- Reservation and activity/audit data were implicit balance mutations, not
  durable first-class records.
- The app is currently Flutter + local Hive storage; there is no backend API,
  SQL migration framework, RBAC layer, WebSocket/SSE channel, broker integration
  service or FX-rate service in this repository.
- Buying power currently equals available cash for cash accounts. Margin account
  leverage and maintenance-margin policy are documented as follow-up schema and
  engine work instead of being hardcoded.

## B. Safe Migration Plan

Implemented in this increment:

- Extend `CASH_MOVEMENT` backward-compatibly with nullable/defaulted fields:
  `status`, `idempotency_key`, `broker_reference`, `created_by`, `settled_at`.
- Add Hive boxes/models for `ACCOUNT_ACTIVITY_LOG` and `CASH_RESERVATION`.
- Bump local schema version to open the new boxes while preserving existing
  records.
- Keep existing `upsertCashMovement` API backward-compatible: omitted status
  still means `completed` for legacy callers.
- Add a broker-confirmation method on the local repository so pending movements
  become completed before affecting balance.

Recommended next migrations when backend/SQL exists:

- Add uniqueness constraints for `(account_id, currency)` on account balance and
  `(account_id, idempotency_key)` on cash movement when idempotency key is not
  null.
- Add approved reconciliation tables/fields before any broker reconciliation can
  adjust balances.
- Add settlement tracking and unsettled-fund fields with explicit settlement
  status and date.
- Add account leverage and maintenance-margin policy fields, then move buying
  power to a margin-aware risk/balance engine.

## C. Current Cash Flow Contract

Initial deposit flow now supported locally:

1. Create `CashMovementModel(status: 'pending')` after validation.
2. Pending movement is persisted and logged but does not change
   `ACCOUNT_BALANCE`.
3. Broker confirmation calls `completeCashMovement(...)` with broker reference.
4. Completed movement writes a completed ledger entry.
5. `AccountBalanceSyncService` updates current cash, available cash and buying
   power.
6. An account activity log is written for both creation and completion.

Balance calculation for a completed cash-account deposit:

- `current_cash_balance = previous_balance + deposit_amount`
- `available_cash = current_cash_balance - reserved_cash`
- `buying_power = available_cash`

Order cash lifecycle:

- Pending order reserves cash and writes `CASH_RESERVATION` + audit log.
- Cancelled order releases reserved cash and closes the reservation as
  `released`.
- Filled order deducts execution cost, releases the reserved amount and closes
  the reservation as `filled`.

## D. API/UI Scope Notes

This repository does not currently contain backend controllers, DTOs, RBAC,
SQL migrations, WebSocket/SSE infrastructure, React components or broker APIs.
For that reason, this increment keeps all changes inside the existing Flutter +
Hive architecture and does not invent a separate backend module.

Frontend UX status:

- Existing portfolio UI has cash movement input/history but not a dedicated
  production-grade Cash Management page with dashboard cards, reconciliation,
  settlement tracking and transaction detail drawer.
- Existing trades UI displays balance, available cash, reserved cash and buying
  power in its funding-flow card.
- Deposit modal currently maps to the existing cash movement sheet; a dedicated
  pending/completed broker-confirmation UX remains a follow-up.

## E. Known Limitations

- No SQL database migration files exist because storage is Hive-based.
- No RBAC/idempotency headers exist because no backend API layer exists.
- No realtime channel exists; local state refresh is still the UI update model.
- Multi-currency storage is supported at the balance/movement boundary, but
  there is no FX conversion service and no base-currency reporting conversion.
- Margin leverage, maintenance margin and unsettled funds are not yet computed.

## Update 2026-05-06 (Cash Screen Upgrade)

Delivered in this slice:

- Added dedicated `Cash Management` navigation tab in `AppShell`.
- Added cash dashboard screen with cards for: current cash, available cash,
  reserved cash, buying power, leverage usage, unsettled funds.
- Added action bar: Deposit, Withdraw, Reconcile.
- Added deposit and withdrawal modal flows with validator-backed checks.
- Added transaction list with filters: all/deposit/withdrawal/fee/dividend.
- Added pending transaction confirmation action to complete movement by broker
  reference.
- Added transaction detail sheet with amount/status/reference/timestamps/actor.
- Added reserved-cash section for pending-order reservation details.
- Added reconciliation and settlement tracking cards in the cash screen.

Architecture notes:

- Extended `PortfolioRepository` with backward-compatible read methods for
  reservations and activity logs, plus `completeCashMovement` contract.
- Kept all changes inside existing Flutter + Hive architecture; no backend API
  assumptions introduced.

Known gaps after this UI upgrade:

- Reconciliation is still a local/manual flow (no broker API approval workflow).
- Settlement tracking currently uses pending movements as local unsettled proxy;
  dedicated settlement table/status engine is still pending.

## Update 2026-05-06 (Risk Banner, Audit Log, Sync Health)

Delivered in this slice:

- Added daily-loss risk banner in `Cash Management` with status tiers:
  `OK` (<80%), `Warning` (>=80%), `Breach` (>=100%) against
  `maxDailyLossAmount` when available.
- Added sync health chip to reconciliation card with stale thresholds:
  `Live` (<=5m), `Delayed` (<=30m), `Failed` (>30m or never synced).
- Added audit log section in cash screen showing recent account activity events
  with actor, timestamp, and before/after values.

Notes:

- Risk banner safely degrades to `0 / 0` when analytics/risk sources are not
  provided in the current runtime context.
