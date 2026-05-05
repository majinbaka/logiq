# Phase 04 Plan: Psychology Tracking And Instrument Notes

## Goal

Help users understand behavioral patterns by logging emotions, discipline, and
trade mistakes, while also maintaining structured research notes for each
instrument.

## ERD Tables

- `EMOTION_LOG`
- `TAG`
- `TRADE_TAG`
- `TRADE_REVIEW`
- `DAILY_JOURNAL`
- `INSTRUMENT`
- `INSTRUMENT_NOTE`
- `INSTRUMENT_NOTE_UPDATE`
- `TRADE`

## Psychology Scope

### Emotion Logs

- Log emotions for a trade, daily journal, or both.
- Supported system emotions for the first version:
  - confident
  - fearful
  - FOMO
  - hesitant
  - calm
  - frustrated
- Capture moment, emotion type, intensity, note, and created date.
- Validate intensity in a fixed range such as 0 to 100.

### Behavior Tags

Seed system tags for common behavior and mistake patterns:

- Entered outside plan.
- Held losing trade too long.
- Took profit too early.
- Moved stop loss.
- Overtraded.
- No clear setup.
- Followed plan.

Allow future custom tags through `TAG` without schema changes.

### Discipline Tracking

- Use `TRADE_REVIEW.discipline_score` for per-trade discipline.
- Use `DAILY_JOURNAL.discipline_score` for per-day discipline.
- Link behavior tags and emotions to trades so analytics can compare behavior
  and results later.

## Instrument Notes Scope

Each instrument can have:

- Thesis.
- Strengths.
- Weaknesses.
- Risks.
- Bull case.
- Bear case.
- Status.
- Timestamped updates.
- Linked trades through `instrument_id`.

`INSTRUMENT_NOTE` stores the current structured view. `INSTRUMENT_NOTE_UPDATE`
stores chronological updates without overwriting history.

## ViewModel Plan

- `EmotionLogViewModel`
- `BehaviorTagPickerViewModel`
- `PsychologySummaryViewModel`
- `InstrumentNoteListViewModel`
- `InstrumentNoteEditorViewModel`
- `InstrumentNoteTimelineViewModel`

## UI Plan

Screens and components:

- Emotion picker with intensity input.
- Behavior tag picker on trade review.
- Psychology timeline by date/trade.
- Discipline trend placeholder or compact list until analytics phase.
- Instrument note list grouped by watchlist/recently traded symbols.
- Instrument note detail with thesis sections, update timeline, and linked
  trade list.

Avoid free-floating hardcoded color constants for tags. Use semantic theme slots
or stored `color_key` values mapped by theme helpers.

## Privacy Requirements

- Do not print emotion notes, journal notes, lessons, self reviews, or
  instrument notes.
- Do not add telemetry around note contents.
- Export, cloud backup, or sync is out of scope until a separate security design
  is written.

## Testing

Unit tests:

- Emotion validation and persistence.
- Tag seeding idempotency.
- Trade tag add/remove behavior.
- Instrument note create/update/soft-delete.
- Instrument note update timeline ordering.
- Linked trades fetched by instrument id.

Widget tests:

- Add emotion to a trade.
- Add behavior tags during review.
- Create and update instrument note.
- View note update timeline.

## Acceptance Criteria

- A user can attach emotions and behavior tags to each trade.
- A user can track discipline at both trade and daily levels.
- A user can create structured notes for each instrument and append updates over
  time.
- Linked trades are visible from an instrument note.
- All strings are localized in English and Vietnamese.
- `flutter gen-l10n`, `flutter analyze`, and `flutter test` pass.

## Out Of Scope

- Machine-learning sentiment analysis.
- Cloud sync or shareable reports.
- Full analytics correlations, which belong to phase 05.
