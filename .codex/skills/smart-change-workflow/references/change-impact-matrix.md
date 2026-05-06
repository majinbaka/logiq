# Change Impact Matrix

Use this matrix to decide verification depth and required tracking updates.

## Impact Mapping

| File pattern / signal | Lane | Required verification | Required tracking updates |
| --- | --- | --- | --- |
| `*.md`, `.github/**` only | `docs-only` | No Flutter command required | Update related docs section only |
| `lib/l10n/app_en.arb`, `lib/l10n/app_vi.arb` | `l10n` | `flutter gen-l10n` -> `flutter analyze` -> targeted tests | Mention localization change in final report |
| `features/**/presentation/**` | `feature-ui` | `flutter analyze` -> targeted widget/unit tests | Update `docs/FEATURES.md` when behavior changes |
| `core/**`, `repositories/**`, `lib/bootstrap.dart`, `lib/core/storage/**` | `domain-core` | `flutter analyze` -> targeted tests -> `flutter test -r expanded` | Update schema/architecture docs as needed |
| `test/**` only | `debug-fix` | Targeted tests first; escalate to broader suite if shared helpers changed | Add note if this fixes flaky/failing issue |
| Mixed lanes or wide diff (`>8 files` across modules) | `high-impact` | `flutter analyze` -> targeted tests -> `flutter test -r expanded` | Update docs + issue tracking when applicable |

## Escalation Rules

1. If any verification step fails, stop closure and apply `issue-debug-playbook`.
2. If Hive tests hang or teardown is flaky, apply `hive-test-stability`.
3. If ARB changed, never skip `flutter gen-l10n`.
4. If change touches storage/schema, do not skip broader tests.

## Closure Checklist

- Scope is classified into a lane.
- Verification commands and outcomes are logged.
- Required docs/issues are updated.
- Residual risks are explicitly stated if coverage is partial.
