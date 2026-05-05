import 'package:flutter/material.dart';
import 'package:trading_diary/core/database/models/portfolio_snapshot_model.dart';
import 'package:trading_diary/core/widgets/trading_section_header.dart';
import 'package:trading_diary/core/widgets/trading_state_view.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';
import 'package:trading_diary/features/portfolio/presentation/viewmodels/portfolio_crud_viewmodel.dart';
import 'package:trading_diary/features/portfolio/presentation/views/components/portfolio_view_components.dart';
import 'package:trading_diary/l10n/app_localizations.dart';
import 'package:trading_diary/repositories/contracts/portfolio_repository.dart';
import 'package:trading_diary/repositories/local/local_portfolio_repository.dart';

class PortfolioCrudView extends StatefulWidget {
  const PortfolioCrudView({super.key, PortfolioRepository? repository})
    : _repository = repository;

  final PortfolioRepository? _repository;

  @override
  State<PortfolioCrudView> createState() => _PortfolioCrudViewState();
}

class _PortfolioCrudViewState extends State<PortfolioCrudView> {
  late final PortfolioCrudViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PortfolioCrudViewModel(
      repository: widget._repository ?? LocalPortfolioRepository(),
    );
    _viewModel.loadSnapshots();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(TradingUiSpacing.md),
            children: [
              TradingSectionHeader(
                title: l10n.portfolioCrudTitle,
                subtitle: l10n.portfolioCrudSubtitle,
              ),
              const SizedBox(height: TradingUiSpacing.md),
              PortfolioSectionCard(
                title: l10n.portfolioHoldingsTitle,
                child: _buildHoldingsTable(l10n),
              ),
              const SizedBox(height: TradingUiSpacing.md),
              PortfolioSectionCard(
                title: l10n.portfolioInputsTitle,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: _openQuoteForm,
                        child: Text(l10n.portfolioAddQuoteButton),
                      ),
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: _openCashMovementForm,
                        child: Text(l10n.portfolioAddCashMovementButton),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TradingUiSpacing.md),
              PortfolioSectionCard(
                title: l10n.portfolioSnapshotsTitle,
                child: _buildSnapshotList(l10n),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openSnapshotForm,
            icon: const Icon(Icons.add_chart_outlined),
            label: Text(l10n.portfolioAddButton),
          ),
        );
      },
    );
  }

  Widget _buildHoldingsTable(AppLocalizations l10n) {
    if (_viewModel.holdings.isEmpty) {
      return Text(l10n.portfolioNoHoldings);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(l10n.portfolioHoldingInstrument)),
          DataColumn(label: Text(l10n.portfolioHoldingQuantity)),
          DataColumn(label: Text(l10n.portfolioHoldingAvgCost)),
          DataColumn(label: Text(l10n.portfolioHoldingMarketValue)),
          DataColumn(label: Text(l10n.portfolioHoldingUnrealizedPnl)),
          DataColumn(label: Text(l10n.portfolioHoldingWeight)),
        ],
        rows: _viewModel.holdings
            .map(
              (holding) => DataRow(
                cells: [
                  DataCell(Text(holding.instrumentId)),
                  DataCell(Text(holding.quantity)),
                  DataCell(Text(holding.averageCost)),
                  DataCell(Text(holding.marketValue)),
                  DataCell(Text(holding.unrealizedPnl)),
                  DataCell(Text('${holding.weightPercent}%')),
                ],
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _buildSnapshotList(AppLocalizations l10n) {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.error != null) {
      return TradingStateView(
        title: l10n.portfolioLoadErrorTitle,
        message: l10n.portfolioLoadErrorBody,
        icon: Icons.error_outline,
        actionLabel: l10n.portfolioRetry,
        onAction: _viewModel.loadSnapshots,
      );
    }
    if (_viewModel.snapshots.isEmpty) {
      return TradingStateView(
        title: l10n.portfolioEmptyTitle,
        message: l10n.portfolioEmptyBody,
        icon: Icons.timeline_outlined,
      );
    }

    return Column(
      children: _viewModel.snapshots
          .map(
            (snapshot) => PortfolioSnapshotListTile(
              snapshot: snapshot,
              onTap: () => _openSnapshotDetail(snapshot),
              onEdit: () => _openSnapshotForm(existing: snapshot),
              onDelete: () => _viewModel.deleteSnapshot(snapshot),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> _openSnapshotDetail(PortfolioSnapshotModel snapshot) async {
    await _viewModel.loadSnapshotDetail(snapshot);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(TradingUiSpacing.md),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.portfolioSnapshotDetailTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TradingUiSpacing.sm),
                Text('${l10n.portfolioDailyPnlLabel}: ${snapshot.dailyPnl ?? '0'}'),
                Text(
                  '${l10n.portfolioCumulativePnlLabel}: ${snapshot.cumulativePnl ?? '0'}',
                ),
                Text(
                  '${l10n.portfolioDrawdownLabel}: ${snapshot.drawdownPercent ?? '0'}%',
                ),
                const SizedBox(height: TradingUiSpacing.md),
                Text(
                  l10n.portfolioPositionsTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: TradingUiSpacing.sm),
                if (_viewModel.snapshotPositions.isEmpty)
                  Text(l10n.portfolioNoPositions)
                else
                  ..._viewModel.snapshotPositions.map(
                    (position) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(position.instrumentId),
                      subtitle: Text(
                        '${l10n.portfolioHoldingQuantity}: ${position.quantity ?? '0'} • '
                        '${l10n.portfolioHoldingMarketValue}: ${position.marketValue ?? '0'}',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    await _viewModel.clearSnapshotDetail();
  }

  Future<void> _openSnapshotForm({PortfolioSnapshotModel? existing}) async {
    final l10n = AppLocalizations.of(context)!;
    final dateController = TextEditingController(
      text: _formatDateInput(existing?.snapshotDate ?? DateTime.now()),
    );
    final noteController = TextEditingController(text: existing?.note ?? '');

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: EdgeInsets.only(
            left: TradingUiSpacing.md,
            right: TradingUiSpacing.md,
            top: TradingUiSpacing.md,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + TradingUiSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                existing == null
                    ? l10n.portfolioCreateTitle
                    : l10n.portfolioEditTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: TradingUiSpacing.md),
              TextField(
                key: const Key('portfolio_form_date'),
                controller: dateController,
                enabled: existing == null,
                decoration: InputDecoration(
                  labelText: l10n.portfolioSnapshotDateLabel,
                  hintText: l10n.portfolioSnapshotDateHint,
                ),
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              TextField(
                key: const Key('portfolio_form_note'),
                controller: noteController,
                decoration: InputDecoration(labelText: l10n.portfolioNoteLabel),
              ),
              const SizedBox(height: TradingUiSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.portfolioCancel),
                    ),
                  ),
                  const SizedBox(width: TradingUiSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      key: const Key('portfolio_form_save'),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.portfolioSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result != true) {
      return;
    }

    if (existing == null) {
      final date = DateTime.tryParse(dateController.text.trim());
      if (date == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.portfolioValidationMessage)),
          );
        }
        return;
      }
      await _viewModel.createSnapshot(
        snapshotDate: date,
        note: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
      );
    } else {
      await _viewModel.updateSnapshot(
        snapshot: existing,
        note: noteController.text.trim(),
      );
    }

  }

  Future<void> _openQuoteForm() async {
    final l10n = AppLocalizations.of(context)!;
    final instrumentController = TextEditingController();
    final priceController = TextEditingController();
    final dateController = TextEditingController(text: _formatDateInput(DateTime.now()));

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return PortfolioSimpleFormSheet(
          title: l10n.portfolioQuoteFormTitle,
          fields: [
            PortfolioSimpleFieldConfig(
              key: const Key('portfolio_quote_instrument'),
              controller: instrumentController,
              label: l10n.portfolioQuoteInstrumentLabel,
            ),
            PortfolioSimpleFieldConfig(
              key: const Key('portfolio_quote_price'),
              controller: priceController,
              label: l10n.portfolioQuotePriceLabel,
            ),
            PortfolioSimpleFieldConfig(
              key: const Key('portfolio_quote_date'),
              controller: dateController,
              label: l10n.portfolioSnapshotDateLabel,
            ),
          ],
        );
      },
    );

    if (result == true) {
      final date = DateTime.tryParse(dateController.text.trim());
      final priceValue = double.tryParse(priceController.text.trim());
      if (date == null || instrumentController.text.trim().isEmpty || priceValue == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.portfolioValidationMessage)),
          );
        }
      } else {
        await _viewModel.addOrUpdateQuote(
          instrumentId: instrumentController.text,
          quotedAt: date,
          price: priceController.text,
        );
      }
    }

  }

  Future<void> _openCashMovementForm() async {
    final l10n = AppLocalizations.of(context)!;
    final amountController = TextEditingController();
    final dateController = TextEditingController(text: _formatDateInput(DateTime.now()));
    final noteController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return PortfolioSimpleFormSheet(
          title: l10n.portfolioCashFormTitle,
          fields: [
            PortfolioSimpleFieldConfig(
              key: const Key('portfolio_cash_amount'),
              controller: amountController,
              label: l10n.portfolioCashAmountLabel,
            ),
            PortfolioSimpleFieldConfig(
              key: const Key('portfolio_cash_date'),
              controller: dateController,
              label: l10n.portfolioSnapshotDateLabel,
            ),
            PortfolioSimpleFieldConfig(
              key: const Key('portfolio_cash_note'),
              controller: noteController,
              label: l10n.portfolioNoteLabel,
            ),
          ],
        );
      },
    );

    if (result == true) {
      final date = DateTime.tryParse(dateController.text.trim());
      final amountValue = double.tryParse(amountController.text.trim());
      if (date == null || amountValue == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.portfolioValidationMessage)),
          );
        }
      } else {
        await _viewModel.addOrUpdateCashMovement(
          movementDate: date,
          movementType: 'deposit',
          amount: amountController.text,
          note: noteController.text,
        );
      }
    }

  }

  String _formatDateInput(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }
}
