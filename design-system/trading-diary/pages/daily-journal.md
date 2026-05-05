# Daily Journal Page Design

Overrides `MASTER.md` for pre-session and post-session journal workflows.

## Purpose

Make daily planning and review fast enough for repeated use before and after a
trading session.

## Layout

- **Mobile:** date selector, pre-session section, post-session section, sticky
  Save Draft action.
- **Tablet/Desktop:** calendar/list on the left, editor on the right.

## Sections

- Pre-session:
  - Market view.
  - Trading plan.
  - Watchlist note.
- Post-session:
  - Completed actions.
  - Followed plan flag.
  - Mistakes.
  - Wins.
  - Free note.
  - Discipline score.

## Components

- Date switcher with previous/next day buttons.
- Followed plan toggle.
- Discipline score slider or stepper with numeric value.
- Autosave or explicit save indicator if implemented.

## Visual Rules

- Keep notes in large, quiet text fields.
- Do not use decorative prompt cards.
- Wins and mistakes should be separate sections, not competing colored panels.
- Private note content must not appear in logs or analytics preview text unless
  explicitly summarized by a source-backed insight.

## States

- No journal for date: create draft in place.
- Saved state: show timestamp.
- Validation: discipline score must stay 0-100.
