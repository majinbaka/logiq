import 'package:flutter/material.dart';
import 'package:logiq/core/database/models/instrument_model.dart';
import 'package:logiq/core/database/models/risk_check_model.dart';
import 'package:logiq/core/database/models/trade_model.dart';
import 'package:logiq/core/database/models/trade_order_model.dart';
import 'package:logiq/core/database/models/trading_account_model.dart';
import 'package:logiq/core/widgets/trading_ui_tokens.dart';
import 'package:logiq/features/trades/presentation/widgets/components/trade_order_form_sheet.dart';
import 'package:logiq/l10n/app_localizations.dart';

class TradeDetailView extends StatefulWidget {
  const TradeDetailView({
    super.key,
    required this.trade,
    required this.account,
    required this.instrument,
    required this.riskCheck,
    required this.formatDateInput,
    required this.onEdit,
    required this.loadOrders,
    required this.onSaveOrder,
    required this.onDeleteOrder,
  });

  final TradeModel trade;
  final TradingAccountModel? account;
  final InstrumentModel? instrument;
  final RiskCheckModel? riskCheck;
  final String Function(DateTime value) formatDateInput;
  final VoidCallback onEdit;
  final Future<List<TradeOrderModel>> Function(String tradeId) loadOrders;
  final Future<void> Function({
    required String status,
    required String? plannedPrice,
    required String? quantity,
    TradeOrderModel? existing,
  })
  onSaveOrder;
  final Future<void> Function(String orderId) onDeleteOrder;

  @override
  State<TradeDetailView> createState() => _TradeDetailViewState();
}

class _TradeDetailViewState extends State<TradeDetailView> {
  bool _isLoadingOrders = false;
  List<TradeOrderModel> _orders = const [];

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() => _isLoadingOrders = true);
    final orders = await widget.loadOrders(widget.trade.id);
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _isLoadingOrders = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final riskCheck = widget.riskCheck;
    final hasViolation =
        riskCheck?.exceededRisk == true ||
        riskCheck?.followedRiskRule == false ||
        ((riskCheck?.violationReason ?? '').trim().isNotEmpty);
    final riskStatus = hasViolation
        ? l10n.tradesRiskStatusViolation
        : l10n.tradesRiskStatusFollowed;
    final reason = (riskCheck?.violationReason ?? '').trim();
    final riskReason = hasViolation && reason.isNotEmpty
        ? reason
        : l10n.tradesRiskReasonNotApplicable;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tradesDetailTitle),
        actions: [
          IconButton(
            tooltip: l10n.tradesEditTooltip,
            onPressed: widget.onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        children: [
          _DetailRow(
            label: l10n.tradesAccountLabel,
            value: widget.account?.name ?? widget.trade.accountId,
          ),
          _DetailRow(
            label: l10n.tradesInstrumentLabel,
            value: widget.instrument?.symbol ?? widget.trade.instrumentId,
          ),
          _DetailRow(
            label: l10n.tradesDirectionLabel,
            value: widget.trade.direction.toUpperCase(),
          ),
          _DetailRow(
            label: l10n.tradesStatusLabel,
            value: widget.trade.status.toUpperCase(),
          ),
          _DetailRow(
            label: l10n.tradesOpenedAtLabel,
            value: widget.formatDateInput(
              widget.trade.openedAt ?? widget.trade.createdAt,
            ),
          ),
          _DetailRow(
            label: l10n.tradesQuantityLabel,
            value: widget.trade.quantityOpened ?? '-',
          ),
          _DetailRow(
            label: l10n.tradesEntryPriceLabel,
            value: widget.trade.avgEntryPrice ?? '-',
          ),
          _DetailRow(
            label: l10n.tradesExitPriceLabel,
            value: widget.trade.avgExitPrice ?? '-',
          ),
          _DetailRow(
            label: l10n.tradesFeeLabel,
            value: widget.trade.totalFee ?? '-',
          ),
          _DetailRow(
            label: l10n.tradesTaxLabel,
            value: widget.trade.totalTax ?? '-',
          ),
          _DetailRow(label: l10n.tradesRiskStatusLabel, value: riskStatus),
          _DetailRow(label: l10n.tradesRiskReasonLabel, value: riskReason),
          const SizedBox(height: TradingUiSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.tradesOrdersSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openOrderForm(),
                icon: const Icon(Icons.add),
                label: Text(l10n.tradesOrdersAddButton),
              ),
            ],
          ),
          const SizedBox(height: TradingUiSpacing.sm),
          if (_isLoadingOrders)
            const Center(child: CircularProgressIndicator())
          else if (_orders.isEmpty)
            Text(l10n.tradesOrdersEmptyState)
          else
            ..._orders.map(
              (order) => _OrderCard(
                order: order,
                onEdit: () {
                  _openOrderForm(existing: order);
                },
                onDelete: () {
                  _deleteOrder(order.id);
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openOrderForm({TradeOrderModel? existing}) async {
    final result = await showModalBottomSheet<TradeOrderFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => TradeOrderFormSheet(existing: existing),
    );
    if (result == null) return;
    await widget.onSaveOrder(
      status: result.status,
      plannedPrice: result.plannedPrice,
      quantity: result.quantity,
      existing: existing,
    );
    await _refreshOrders();
  }

  Future<void> _deleteOrder(String orderId) async {
    await widget.onDeleteOrder(orderId);
    await _refreshOrders();
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TradingUiSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          const SizedBox(width: TradingUiSpacing.sm),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onEdit,
    required this.onDelete,
  });

  final TradeOrderModel order;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: TradingUiSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.sm),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.status.toUpperCase(),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: l10n.tradesEditTooltip,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: l10n.tradesDeleteTooltip,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            _DetailRow(
              label: l10n.tradesOrderPlannedPriceLabel,
              value: order.plannedPrice ?? '-',
            ),
            _DetailRow(
              label: l10n.tradesQuantityLabel,
              value: order.quantity ?? '-',
            ),
          ],
        ),
      ),
    );
  }
}
