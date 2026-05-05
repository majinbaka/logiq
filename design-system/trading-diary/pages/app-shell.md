# App Shell Page Design

Overrides `design-system/trading-diary/MASTER.md` for bootstrap navigation,
account context, and module placeholders.

## Purpose

Give the user a stable command center for local trading data. The shell should
make the current account, selected date range, and active module obvious.

## Layout

- **Mobile:** top app bar with account selector, bottom navigation, full-width
  content stack.
- **Tablet:** navigation rail, page title row, content max width by module.
- **Desktop:** left sidebar, persistent account/date controls, two-column
  layouts when a list/detail split is useful.

## Primary Destinations

- Journal
- Portfolio
- Analytics
- Psychology
- More

The More destination groups Strategies, Risk Rules, Instruments, Settings, and
storage/about screens until those modules need first-level navigation.

## Header Components

- Current trading account selector.
- Date range picker or current session date when relevant.
- Sync/storage status placeholder only if a real service exists.
- Primary page action, such as New Trade, Add Snapshot, or New Note.

## Empty And Placeholder States

- For modules not implemented yet, show a compact placeholder with the planned
  action and no marketing copy.
- First-run state should prioritize creating or selecting a trading account.
- Avoid fake metrics unless seed/demo mode is explicitly enabled.

## Interaction Rules

- Navigation must preserve draft state in the current flow where possible.
- Selected nav item uses primary container and clear label.
- Disabled destinations should explain why only when tapped or focused.

## Implementation Notes

- Use `NavigationBar` on mobile and `NavigationRail` on wider layouts.
- Do not put the entire app content inside a decorative card.
- Keep top-level scaffold strings localized once l10n is introduced.
