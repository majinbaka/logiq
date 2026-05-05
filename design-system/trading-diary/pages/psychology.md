# Psychology Page Design

Overrides `MASTER.md` for emotion logs, behavior tags, discipline tracking, and
behavior timelines.

## Purpose

Help users identify behavior patterns without making the product feel clinical
or judgmental.

## Layout

- **Mobile:** discipline summary, emotion quick log, timeline.
- **Tablet/Desktop:** summary metrics, filters, timeline/table split.

## Components

- Emotion picker with fixed options:
  - Confident
  - Fearful
  - FOMO
  - Hesitant
  - Calm
  - Frustrated
- Intensity input: slider or stepper, 0-100.
- Behavior tag picker with searchable chips.
- Timeline grouped by date and linked trade/journal.
- Discipline trend placeholder until analytics charts are introduced.

## Visual Rules

- Emotion and behavior chips use semantic theme keys, not ad-hoc colors.
- High intensity does not automatically mean danger; label the emotion and show
  intensity separately.
- Use neutral copy and avoid shame-oriented language.

## States

- No logs: offer Add Emotion Log.
- No linked trade/journal: allow standalone log only if the model supports it.
- Filtered empty state: Clear Filters.

## Privacy

- Do not expose full emotion notes in compact cards; use first-line preview only
  if the user is already in the psychology module.
- Never add share/export affordances in this page without a separate design.
