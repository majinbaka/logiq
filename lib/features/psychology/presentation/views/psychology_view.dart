import 'package:flutter/material.dart';
import 'package:trading_diary/core/widgets/trading_section_header.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';
import 'package:trading_diary/l10n/app_localizations.dart';

class PsychologyView extends StatefulWidget {
  const PsychologyView({super.key});

  @override
  State<PsychologyView> createState() => _PsychologyViewState();
}

enum _ReviewScope { all, trade, journal }

class _PsychologyViewState extends State<PsychologyView> {
  final List<_DisciplineReviewEntry> _entries = [];
  _ReviewScope _filter = _ReviewScope.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredEntries = _entries
        .where((item) {
          if (_filter == _ReviewScope.all) return true;
          if (_filter == _ReviewScope.trade) return item.scope == _ReviewScope.trade;
          return item.scope == _ReviewScope.journal;
        })
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.all(TradingUiSpacing.md),
      children: [
        TradingSectionHeader(
          title: l10n.psychologyTitle,
          subtitle: l10n.psychologySubtitle,
          trailing: FilledButton.icon(
            onPressed: _openCreateReviewForm,
            icon: const Icon(Icons.add),
            label: Text(l10n.psychologyAddReviewButton),
          ),
        ),
        const SizedBox(height: TradingUiSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(TradingUiSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.psychologyDisciplineSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TradingUiSpacing.xs),
                Text(l10n.psychologyDisciplineSectionSubtitle),
                const SizedBox(height: TradingUiSpacing.md),
                Text(l10n.psychologyFilterLabel),
                const SizedBox(height: TradingUiSpacing.sm),
                Wrap(
                  spacing: TradingUiSpacing.sm,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.psychologyFilterAll),
                      selected: _filter == _ReviewScope.all,
                      onSelected: (_) => setState(() => _filter = _ReviewScope.all),
                    ),
                    ChoiceChip(
                      label: Text(l10n.psychologyFilterTrade),
                      selected: _filter == _ReviewScope.trade,
                      onSelected: (_) =>
                          setState(() => _filter = _ReviewScope.trade),
                    ),
                    ChoiceChip(
                      label: Text(l10n.psychologyFilterJournal),
                      selected: _filter == _ReviewScope.journal,
                      onSelected: (_) =>
                          setState(() => _filter = _ReviewScope.journal),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: TradingUiSpacing.sm),
        if (filteredEntries.isEmpty)
          Card(
            child: ListTile(
              leading: const Icon(Icons.rate_review_outlined),
              title: Text(l10n.psychologyEmptyDiscipline),
            ),
          )
        else
          ...filteredEntries.map(
            (entry) => Card(
              child: ListTile(
                leading: Icon(
                  entry.scope == _ReviewScope.trade
                      ? Icons.candlestick_chart
                      : Icons.menu_book_outlined,
                ),
                title: Text(
                  l10n.psychologyScoreLabel(entry.score),
                ),
                subtitle: Text(entry.review),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openCreateReviewForm() async {
    final l10n = AppLocalizations.of(context)!;
    var scope = _ReviewScope.trade;
    var score = 5.0;
    var reviewText = '';

    final isSaved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: TradingUiSpacing.md,
                right: TradingUiSpacing.md,
                top: TradingUiSpacing.md,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + TradingUiSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.psychologyCreateReviewTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: TradingUiSpacing.md),
                  Text(l10n.psychologyScopeLabel),
                  const SizedBox(height: TradingUiSpacing.sm),
                  DropdownButtonFormField<_ReviewScope>(
                    initialValue: scope,
                    items: [
                      DropdownMenuItem(
                        value: _ReviewScope.trade,
                        child: Text(l10n.psychologyFilterTrade),
                      ),
                      DropdownMenuItem(
                        value: _ReviewScope.journal,
                        child: Text(l10n.psychologyFilterJournal),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => scope = value);
                    },
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  Text(l10n.psychologyDisciplineScoreLabel),
                  Slider(
                    min: 1,
                    max: 10,
                    divisions: 9,
                    value: score,
                    label: score.round().toString(),
                    onChanged: (value) => setModalState(() => score = value),
                  ),
                  TextField(
                    maxLines: 3,
                    onChanged: (value) => reviewText = value,
                    decoration: InputDecoration(
                      labelText: l10n.psychologySelfReviewLabel,
                    ),
                  ),
                  const SizedBox(height: TradingUiSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.psychologyCancel),
                        ),
                      ),
                      const SizedBox(width: TradingUiSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.psychologySave),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (isSaved != true) {
      return;
    }

    final review = reviewText.trim();
    if (review.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.psychologyValidationMessage)),
        );
      }
      return;
    }

    setState(() {
      _entries.insert(
        0,
        _DisciplineReviewEntry(
          scope: scope,
          score: score.round(),
          review: review,
        ),
      );
    });
  }
}

class _DisciplineReviewEntry {
  const _DisciplineReviewEntry({
    required this.scope,
    required this.score,
    required this.review,
  });

  final _ReviewScope scope;
  final int score;
  final String review;
}
