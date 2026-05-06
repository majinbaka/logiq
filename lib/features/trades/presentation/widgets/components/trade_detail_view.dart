import 'package:flutter/material.dart';
import 'package:logiq/core/database/models/instrument_model.dart';
import 'package:logiq/core/database/models/risk_check_model.dart';
import 'package:logiq/core/database/models/trade_model.dart';
import 'package:logiq/core/database/models/trade_order_model.dart';
import 'package:logiq/core/database/models/trade_plan_target_model.dart';
import 'package:logiq/core/database/models/trading_account_model.dart';
import 'package:logiq/core/widgets/formatted_number_input.dart';
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
    required this.loadPlanTargets,
    required this.onSavePlanTarget,
    required this.onDeletePlanTarget,
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
  final Future<List<TradePlanTargetModel>> Function(String tradeId)
  loadPlanTargets;
  final Future<void> Function({
    required int targetOrder,
    required String targetPrice,
    required String? plannedQuantityPercent,
    required String? note,
    TradePlanTargetModel? existing,
  })
  onSavePlanTarget;
  final Future<void> Function(String targetId) onDeletePlanTarget;

  @override
  State<TradeDetailView> createState() => _TradeDetailViewState();
}

class _TradeDetailViewState extends State<TradeDetailView> {
  bool _isLoadingOrders = false;
  bool _isLoadingPlanTargets = false;
  List<TradeOrderModel> _orders = const [];
  List<TradePlanTargetModel> _planTargets = const [];

  @override
  void initState() {
    super.initState();
    _refreshOrders();
    _refreshPlanTargets();
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

  Future<void> _refreshPlanTargets() async {
    setState(() => _isLoadingPlanTargets = true);
    final targets = await widget.loadPlanTargets(widget.trade.id);
    if (!mounted) return;
    setState(() {
      _planTargets = targets;
      _isLoadingPlanTargets = false;
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
                  l10n.tradesPlanSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openPlanTargetForm(),
                icon: const Icon(Icons.add),
                label: Text(l10n.tradesPlanAddTargetButton),
              ),
            ],
          ),
          const SizedBox(height: TradingUiSpacing.sm),
          if (_isLoadingPlanTargets)
            const Center(child: CircularProgressIndicator())
          else if (_planTargets.isEmpty)
            Text(l10n.tradesPlanTargetsEmptyState)
          else
            ..._planTargets.map(
              (target) => _PlanTargetCard(
                target: target,
                onEdit: () {
                  _openPlanTargetForm(existing: target);
                },
                onDelete: () {
                  _deletePlanTarget(target.id);
                },
              ),
            ),
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

  Future<void> _openPlanTargetForm({TradePlanTargetModel? existing}) async {
    final result = await showModalBottomSheet<TradePlanTargetFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => TradePlanTargetFormSheet(existing: existing),
    );
    if (result == null) return;
    await widget.onSavePlanTarget(
      targetOrder: result.targetOrder,
      targetPrice: result.targetPrice,
      plannedQuantityPercent: result.plannedQuantityPercent,
      note: result.note,
      existing: existing,
    );
    await _refreshPlanTargets();
  }

  Future<void> _deletePlanTarget(String targetId) async {
    await widget.onDeletePlanTarget(targetId);
    await _refreshPlanTargets();
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

class _PlanTargetCard extends StatelessWidget {
  const _PlanTargetCard({
    required this.target,
    required this.onEdit,
    required this.onDelete,
  });

  final TradePlanTargetModel target;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
                    '${l10n.tradesPlanTargetTag} ${target.targetOrder}',
                    style: Theme.of(context).textTheme.titleSmall,
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
              label: l10n.tradesPlanTargetOrderLabel,
              value: target.targetOrder.toString(),
            ),
            _DetailRow(
              label: l10n.tradesPlanTargetPriceLabel,
              value: target.targetPrice,
            ),
            _DetailRow(
              label: l10n.tradesPlanTargetQtyLabel,
              value: target.plannedQuantityPercent ?? '-',
            ),
            _DetailRow(
              label: l10n.tradesPlanTargetNoteLabel,
              value: target.note ?? '-',
            ),
          ],
        ),
      ),
    );
  }
}

class TradePlanTargetFormResult {
  const TradePlanTargetFormResult({
    required this.targetOrder,
    required this.targetPrice,
    required this.plannedQuantityPercent,
    required this.note,
  });

  final int targetOrder;
  final String targetPrice;
  final String? plannedQuantityPercent;
  final String? note;
}

class TradePlanTargetFormSheet extends StatefulWidget {
  const TradePlanTargetFormSheet({super.key, required this.existing});

  final TradePlanTargetModel? existing;

  @override
  State<TradePlanTargetFormSheet> createState() => _TradePlanTargetFormSheetState();
}

class _TradePlanTargetFormSheetState extends State<TradePlanTargetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _targetOrderController;
  late final TextEditingController _targetPriceController;
  late final TextEditingController _targetQtyController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _targetOrderController = TextEditingController(
      text: widget.existing?.targetOrder.toString() ?? '',
    );
    _targetPriceController = TextEditingController(
      text: widget.existing?.targetPrice ?? '',
    );
    _targetQtyController = TextEditingController(
      text: widget.existing?.plannedQuantityPercent ?? '',
    );
    _noteController = TextEditingController(text: widget.existing?.note ?? '');
  }

  @override
  void dispose() {
    _targetOrderController.dispose();
    _targetPriceController.dispose();
    _targetQtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: TradingUiSpacing.md,
        right: TradingUiSpacing.md,
        top: TradingUiSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + TradingUiSpacing.md,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existing == null
                  ? l10n.tradesPlanTargetCreateTitle
                  : l10n.tradesPlanTargetEditTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TradingUiSpacing.md),
            TextFormField(
              controller: _targetOrderController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${l10n.tradesPlanTargetOrderLabel} *',
              ),
              validator: (value) {
                final raw = value?.trim() ?? '';
                if (raw.isEmpty) return l10n.tradesRequiredFieldValidationError;
                final parsed = int.tryParse(raw);
                if (parsed == null) return l10n.tradesNumberValidationError;
                if (parsed <= 0) {
                  return l10n.tradesPositiveNumberValidationError;
                }
                return null;
              },
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            FormattedNumberInput(
              controller: _targetPriceController,
              label: l10n.tradesPlanTargetPriceLabel,
              requiredErrorText: l10n.tradesRequiredFieldValidationError,
              numberErrorText: l10n.tradesNumberValidationError,
              positiveNumberErrorText: l10n.tradesPositiveNumberValidationError,
              nonNegativeNumberErrorText:
                  l10n.tradesNonNegativeNumberValidationError,
              suffixText: l10n.tradesUnitCurrency,
              required: true,
              mustBePositive: true,
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            FormattedNumberInput(
              controller: _targetQtyController,
              label: l10n.tradesPlanTargetQtyLabel,
              requiredErrorText: l10n.tradesRequiredFieldValidationError,
              numberErrorText: l10n.tradesNumberValidationError,
              positiveNumberErrorText: l10n.tradesPositiveNumberValidationError,
              nonNegativeNumberErrorText:
                  l10n.tradesNonNegativeNumberValidationError,
              suffixText: l10n.tradesPlanTargetQtyUnit,
              required: false,
              mustBePositive: true,
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(labelText: l10n.tradesPlanTargetNoteLabel),
              maxLines: 2,
            ),
            const SizedBox(height: TradingUiSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.tradesCancel),
                  ),
                ),
                const SizedBox(width: TradingUiSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(l10n.tradesSave),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final targetOrder = int.parse(_targetOrderController.text.trim());
    final targetPrice = FormattedNumberInput.normalizeNumberText(
      _targetPriceController.text,
    );
    final targetQty = FormattedNumberInput.normalizeNumberText(
      _targetQtyController.text,
    );
    final note = _noteController.text.trim();
    Navigator.pop(
      context,
      TradePlanTargetFormResult(
        targetOrder: targetOrder,
        targetPrice: targetPrice,
        plannedQuantityPercent: targetQty.isEmpty ? null : targetQty,
        note: note.isEmpty ? null : note,
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
