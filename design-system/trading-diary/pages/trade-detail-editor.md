# Trade Detail And Editor Page Design

Overrides `MASTER.md` for trade creation, fills, plan, review, context, and risk
check details.

## Purpose

Support the complete trade lifecycle without hiding the source-of-truth fields:
plan, executions, review, and risk check.

## Layout

- **Mobile:** summary header, tabbed sections, sticky Save Draft / Save action.
- **Tablet/Desktop:** left summary rail, right tab content, optional fill table.

## Tabs

- Core
- Plan
- Orders/Fills
- Review
- Context
- Risk

Use tabs only when all sections belong to the same trade. Do not split this flow
into unrelated pages unless a section becomes too large.

## Summary Header

- Instrument, status, direction.
- Net PnL, PnL percent, R-multiple.
- Average entry, average exit, total quantity.
- Risk badge: Passed, Warning, Violation, Not checked.

## Form Rules

- Numeric fields align decimals and show units.
- Planned entry, stop loss, targets, fee, tax, and quantity validate inline.
- Confidence and discipline scores use sliders or steppers plus numeric values.
- Targets are reorderable only if target ordering is supported by the model.

## Orders And Fills

- Desktop: use an editable table for fills.
- Mobile: use repeatable fill cards with BUY/SELL segmented control.
- Calculated totals update in the summary, not only inside the fill section.

## Review And Privacy

- Review notes, lesson, mistake summary, and self review are private notes.
- Avoid print/log affordances.
- Behavior tags appear as semantic chips from theme mappings.

## States

- Unsaved changes: visible saved/draft timestamp and guarded navigation.
- Validation error: section tab shows error count.
- Risk violation: show reason and related rule without blocking save unless
  business rules later require it.
