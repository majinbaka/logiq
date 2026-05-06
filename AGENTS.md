# Codex Instructions for `logiq`

Last updated: 2026-05-06

## 1) Project Snapshot (Current Reality)

`logiq` is a Flutter trading diary app with a **local-first** architecture.

Current stack:

- Flutter + Dart SDK `^3.11.0`
- `hive ^2.2.3` for local storage
- `path_provider ^2.1.5`
- `flutter_localizations`
- `flutter_lints ^6.0.0`

Entrypoint and startup:

- `lib/main.dart` calls `bootstrap()`.
- `lib/bootstrap.dart` initializes storage and runs guarded startup fallback UI.
- `StorageInitializer` is singleton + idempotent, with schema versioning.

Current high-level structure:

```text
lib/
├── main.dart
├── bootstrap.dart
├── app/
│   ├── app.dart
│   ├── app_shell.dart
│   └── startup_error_app.dart
├── core/
│   ├── analytics/
│   ├── database/models/
│   ├── fund/
│   ├── risk/
│   ├── seed/
│   ├── storage/
│   ├── system/
│   ├── theme/
│   ├── trading/
│   ├── validation/
│   └── widgets/
├── features/
│   ├── account/
│   ├── cash_management/
│   ├── daily_journal/
│   ├── insights/
│   ├── portfolio/
│   ├── psychology/
│   ├── strategy/
│   └── trades/
├── l10n/
└── repositories/
    ├── contracts/
    └── local/
```

Notes:

- `lib/models`, `lib/services`, and `lib/screens` currently exist but are empty placeholders.
- Generated localization files already exist in `lib/l10n/app_localizations*.dart`.
- Current primary navigation tabs in `AppShell`: Trades, Portfolio, Strategy,
  Daily Journal, Psychology, Insights, Cash Management, Account Settings.

## 2) Product Scope Boundaries (Important)

This repo currently contains a Flutter app with local Hive storage. It does **not** contain:

- backend APIs/controllers
- SQL migrations
- RBAC/auth services
- broker integration services
- realtime WebSocket/SSE infra

When asked for those areas, do not invent non-existent modules. Either:

- implement a local equivalent inside current architecture, or
- document the gap clearly in docs/issues.

## 3) Architecture and Layering Rules

Preferred layering:

- View: `features/<feature>/presentation/views/` (UI only)
- ViewModel: `features/<feature>/presentation/viewmodels/` (`ChangeNotifier` state + flow)
- Feature widgets: `features/<feature>/presentation/widgets/` or `.../widgets/components/`
- Cross-feature/domain logic: `core/`
- Repository interfaces: `repositories/contracts/`
- Repository implementations: `repositories/local/`
- Data models: `core/database/models/`

Rules:

- Keep Hive/storage access inside repositories/services, not in UI widgets.
- Keep async work out of `build()`.
- Use smallest useful change; avoid broad unrelated refactors.
- Reuse existing modules first; add new folders only when needed.

## 4) Localization and Theme Rules

Localization is already enabled (`EN` + `VI`):

- User-visible strings must come from `AppLocalizations`.
- Update both `lib/l10n/app_en.arb` and `lib/l10n/app_vi.arb`.
- Run `flutter gen-l10n` after ARB changes.
- Never manually edit generated localization Dart files.

Theme usage:

- Prefer `Theme.of(context).colorScheme` and existing theme extensions.
- Current semantic extension: `TradingSemanticColors` in `lib/core/theme/app_theme.dart`.
- Avoid ad-hoc hardcoded colors in feature widgets unless intentionally expanding theme.

## 5) Storage and Data Rules

- Central box registration is in `lib/core/storage/storage_boxes.dart`.
- Startup/migration pipeline is in `lib/core/storage/storage_initializer.dart`.
- Current schema version is `2`.

When adding/changing persisted entities:

1. Update model in `core/database/models/`.
2. Update repository contract + local implementation.
3. Register/open new box via `StorageBoxes` + initializer.
4. Add/adjust migration step in initializer.
5. Add/adjust tests (model mapping + repository + flow tests as needed).

Data/security:

- Treat all journal/trade/note content as private user data.
- Do not log sensitive content.
- Never store secrets/tokens in plain local storage.

## 6) Code Quality Constraints

- Prefer the smallest change that solves the request clearly.
- Avoid dead code and duplicate logic.
- Do not edit generated files.
- Keep non-generated Dart files under 500 lines for new work.

Current repo has legacy files over 500 lines. Do not refactor them unless task requires; when touching heavily, split incrementally into smaller units.

## 7) Documentation Update Rules

Update docs when behavior/schema/architecture changes:

- `docs/FEATURES.md`: user-facing feature behavior
- `docs/DATABASE_ERD.md`: data model/schema semantics
- `docs/CASH_MANAGEMENT.md`: cash lifecycle and business rules
- `docs/PRODUCTION_READINESS_CHECKLIST.md`: quality/readiness status
- `.github/ISSUES.md`: issue lifecycle (OPEN/IN-PROGRESS/RESOLVED/WONT-FIX)
- `.github/investigation-notes/YYYY-MM-DD_<slug>.md`: non-obvious findings
- `.github/plans/YYYY-MM-DD_<slug>.md`: implementation plans
- `AGENTS.md`: architecture/convention updates

Issue entry format:

```text
## [STATUS] Short title  (STATUS: OPEN | IN-PROGRESS | RESOLVED | WONT-FIX)
- **Date found:** YYYY-MM-DD
- **Date resolved:** YYYY-MM-DD (if applicable)
- **Affected files:** list of files
- **Description:** what the issue is
- **Root cause:** brief root-cause note
- **Fix / workaround:** what was done
```

## 8) Validation Workflow

For code changes, run the narrowest useful verification first:

```sh
flutter analyze
flutter test
```

If localization changed:

```sh
flutter gen-l10n
flutter analyze
flutter test
```

If full test run is expensive, run targeted tests first, then broader suite before finalizing.

## 9) Editing and Git Safety

- Preserve unrelated user changes in working tree.
- Use non-destructive git commands.
- Avoid unrelated formatting churn.
- Do not amend history unless explicitly requested.

## 10) Smart Post-Change Workflow (Mandatory)

After every file change, run a smart closure loop before declaring done:

1. Classify impact from changed files (scope -> lane).
2. Run verification at the right depth (narrow first, broaden when required).
3. Update required docs/issues if behavior/schema/convention changed.
4. Report command evidence + residual risk.

Project skill to apply:

- `.codex/skills/smart-change-workflow/SKILL.md`
- Impact matrix: `.codex/skills/smart-change-workflow/references/change-impact-matrix.md`

Skill coordination rules:

- Use `code-change-test-check` for required post-edit verification.
- Use `issue-debug-playbook` when failures need root-cause debugging.
- Use `hive-test-stability` when Hive-related tests are flaky/hanging.
