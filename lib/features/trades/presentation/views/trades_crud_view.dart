import 'package:flutter/material.dart';
import 'package:trading_diary/core/database/models/trade_model.dart';
import 'package:trading_diary/core/widgets/trading_section_header.dart';
import 'package:trading_diary/core/widgets/trading_state_view.dart';
import 'package:trading_diary/core/widgets/trading_ui_tokens.dart';
import 'package:trading_diary/features/trades/presentation/viewmodels/trades_crud_viewmodel.dart';
import 'package:trading_diary/l10n/app_localizations.dart';
import 'package:trading_diary/repositories/local/local_trade_repository.dart';

class TradesCrudView extends StatefulWidget {
  const TradesCrudView({super.key});

  @override
  State<TradesCrudView> createState() => _TradesCrudViewState();
}

class _TradesCrudViewState extends State<TradesCrudView> {
  late final TradesCrudViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TradesCrudViewModel(repository: LocalTradeRepository());
    _viewModel.loadTrades();
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
                title: l10n.tradesCrudTitle,
                subtitle: l10n.tradesCrudSubtitle,
              ),
              const SizedBox(height: TradingUiSpacing.md),
              if (_viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_viewModel.error != null)
                TradingStateView(
                  title: l10n.tradesLoadErrorTitle,
                  message: l10n.tradesLoadErrorBody,
                  icon: Icons.error_outline,
                  actionLabel: l10n.tradesRetry,
                  onAction: _viewModel.loadTrades,
                )
              else if (_viewModel.trades.isEmpty)
                TradingStateView(
                  title: l10n.tradesEmptyTitle,
                  message: l10n.tradesEmptyBody,
                  icon: Icons.inbox_outlined,
                )
              else
                ..._viewModel.trades.map(
                  (trade) => _TradeListTile(
                    trade: trade,
                    onEdit: () => _openTradeForm(existing: trade),
                    onDelete: () => _viewModel.deleteTrade(trade),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openTradeForm,
            icon: const Icon(Icons.add),
            label: Text(l10n.tradesAddButton),
          ),
        );
      },
    );
  }

  Future<void> _openTradeForm({TradeModel? existing}) async {
    final l10n = AppLocalizations.of(context)!;
    final instrumentController = TextEditingController(
      text: existing?.instrumentId ?? 'ins_fpt',
    );
    var direction = existing?.direction.toLowerCase() ?? 'buy';
    var status = existing?.status.toLowerCase() ?? 'open';
    final openedAtController = TextEditingController(
      text: _formatDateInput(existing?.openedAt ?? DateTime.now()),
    );

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
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    existing == null
                        ? l10n.tradesCreateTitle
                        : l10n.tradesEditTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: TradingUiSpacing.md),
                  TextField(
                    controller: instrumentController,
                    decoration: InputDecoration(
                      labelText: l10n.tradesInstrumentLabel,
                    ),
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: direction,
                    items: [
                      DropdownMenuItem(
                        value: 'buy',
                        child: Text(l10n.tradesDirectionBuy),
                      ),
                      DropdownMenuItem(
                        value: 'sell',
                        child: Text(l10n.tradesDirectionSell),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => direction = value);
                    },
                    decoration: InputDecoration(
                      labelText: l10n.tradesDirectionLabel,
                    ),
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    items: [
                      DropdownMenuItem(
                        value: 'open',
                        child: Text(l10n.tradesStatusOpen),
                      ),
                      DropdownMenuItem(
                        value: 'closed',
                        child: Text(l10n.tradesStatusClosed),
                      ),
                      DropdownMenuItem(
                        value: 'draft',
                        child: Text(l10n.tradesStatusDraft),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => status = value);
                    },
                    decoration: InputDecoration(
                      labelText: l10n.tradesStatusLabel,
                    ),
                  ),
                  const SizedBox(height: TradingUiSpacing.sm),
                  TextField(
                    controller: openedAtController,
                    decoration: InputDecoration(
                      labelText: l10n.tradesOpenedAtLabel,
                      hintText: l10n.tradesOpenedAtHint,
                    ),
                  ),
                  const SizedBox(height: TradingUiSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.tradesCancel),
                        ),
                      ),
                      const SizedBox(width: TradingUiSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.tradesSave),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (result != true) {
      instrumentController.dispose();
      openedAtController.dispose();
      return;
    }

    final openedAt = DateTime.tryParse(openedAtController.text.trim());
    if (openedAt == null || instrumentController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tradesValidationMessage)));
      }
      instrumentController.dispose();
      openedAtController.dispose();
      return;
    }

    if (existing == null) {
      await _viewModel.createTrade(
        instrumentId: instrumentController.text.trim(),
        direction: direction,
        openedAt: openedAt,
      );
    } else {
      await _viewModel.updateTrade(
        trade: existing,
        instrumentId: instrumentController.text.trim(),
        direction: direction,
        status: status,
        openedAt: openedAt,
      );
    }

    instrumentController.dispose();
    openedAtController.dispose();
  }

  String _formatDateInput(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }
}

class _TradeListTile extends StatelessWidget {
  const _TradeListTile({
    required this.trade,
    required this.onEdit,
    required this.onDelete,
  });

  final TradeModel trade;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opened =
        trade.openedAt?.toLocal().toIso8601String().split('T').first ?? '-';

    return Card(
      child: ListTile(
        title: Text('${trade.instrumentId} • ${trade.direction.toUpperCase()}'),
        subtitle: Text('${trade.status.toUpperCase()} • $opened'),
        trailing: Wrap(
          spacing: TradingUiSpacing.xs,
          children: [
            IconButton(
              tooltip: AppLocalizations.of(context)!.tradesEditTooltip,
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context)!.tradesDeleteTooltip,
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}
