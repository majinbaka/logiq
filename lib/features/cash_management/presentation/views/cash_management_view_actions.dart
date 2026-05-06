part of 'cash_management_view.dart';

mixin _CashManagementViewActions on State<CashManagementView> {
  CashManagementViewModel get _viewModel;
  GlobalKey<FormState> get _depositFormKey;
  GlobalKey<FormState> get _withdrawFormKey;
  TextEditingController get _depositAmountController;
  TextEditingController get _depositNoteController;
  TextEditingController get _withdrawAmountController;
  TextEditingController get _withdrawNoteController;
  CashMovementType get _depositType;
  // ignore: unused_element
  bool get _isDepositExpanded;
  set _isDepositExpanded(bool value);
  // ignore: unused_element
  bool get _isWithdrawExpanded;
  set _isWithdrawExpanded(bool value);
  ScrollController get _scrollController;
  int get _visibleMovementCount;
  set _visibleMovementCount(int value);

  // ignore: unused_element
  Future<void> _submitDeposit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_depositFormKey.currentState?.validate() != true) return;
    final amount = FormattedNumberInput.normalizeNumberText(
      _depositAmountController.text,
    );
    final confirmed = await _confirmCreateTransaction(
      amount: amount,
      isDeposit: true,
    );
    if (!confirmed) return;
    try {
      await _viewModel.createDepositPending(
        amount: amount,
        movementType: _depositType.value,
        note: _depositNoteController.text.trim().isEmpty
            ? null
            : _depositNoteController.text.trim(),
      );
      _depositFormKey.currentState?.reset();
      _depositAmountController.clear();
      _depositNoteController.clear();
      if (!mounted) return;
      setState(() => _isDepositExpanded = false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cashSubmitFailed)));
    }
  }

  // ignore: unused_element
  Future<void> _submitWithdraw() async {
    final l10n = AppLocalizations.of(context)!;
    if (_withdrawFormKey.currentState?.validate() != true) return;
    final amount = FormattedNumberInput.normalizeNumberText(
      _withdrawAmountController.text,
    );
    final confirmed = await _confirmCreateTransaction(
      amount: amount,
      isDeposit: false,
    );
    if (!confirmed) return;
    try {
      await _viewModel.createWithdrawalPending(
        amount: amount,
        note: _withdrawNoteController.text.trim().isEmpty
            ? null
            : _withdrawNoteController.text.trim(),
      );
      _withdrawFormKey.currentState?.reset();
      _withdrawAmountController.clear();
      _withdrawNoteController.clear();
      if (!mounted) return;
      setState(() => _isWithdrawExpanded = false);
    } on CashValidationException catch (error) {
      final message = error.code == 'insufficient_available_cash'
          ? l10n.cashInsufficientAvailable
          : l10n.cashValidationFailed;
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error, stackTrace) {
      debugPrint('createWithdrawalPending failed: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cashSubmitRetry)));
    }
  }

  Future<void> _confirmMovement(CashMovementModel movement) async {
    await _viewModel.confirmPendingMovement(movement);
  }

  Future<void> _reconcileNow() async {
    await _viewModel.reconcileNow();
  }

  Future<void> _openTransactionDetail(CashMovementModel movement) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(TradingUiSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cashTransactionDetail,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              Text(
                '${l10n.cashType}: ${_displayMovementType(movement.movementType)}',
              ),
              Text(
                '${l10n.cashAmount}: ${movement.amount} ${movement.currency}',
              ),
              Text(
                '${l10n.cashStatus}: ${_displayMovementStatus(movement.status)}',
              ),
              Text(
                '${l10n.cashBrokerReference}: ${movement.brokerReference ?? '-'}',
              ),
              Text(
                '${l10n.cashCreatedAt}: ${_fmtDateTime(movement.createdAt)}',
              ),
              Text(
                '${l10n.cashSettledAt}: ${movement.settledAt == null ? '-' : _fmtDateTime(movement.settledAt!)}',
              ),
              Text('${l10n.cashCreatedBy}: ${movement.createdBy ?? '-'}'),
              Text('${l10n.portfolioNoteLabel}: ${movement.note ?? '-'}'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteMovement(CashMovementModel movement) async {
    await _viewModel.deleteMovement(movement.id);
  }

  Future<bool> _confirmCreateTransaction({
    required String amount,
    required bool isDeposit,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final value = _toDouble(amount);
    final currentCash = _toDouble(_viewModel.balance?.currentCashBalance);
    final availableCash = _toDouble(_viewModel.balance?.availableCash);
    final nextPendingInflow = _viewModel.pendingInflow() + (isDeposit ? value : 0);
    final nextPendingOutflow = _viewModel.pendingOutflow() + (isDeposit ? 0 : value);
    final expectedAfterCompletion = isDeposit
        ? currentCash + value
        : currentCash - value;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.cashCreateConfirmTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l10n.cashCreateConfirmAmount}: $amount ${_viewModel.currency}'),
              const SizedBox(height: TradingUiSpacing.xs),
              Text('${l10n.cashCurrentCash}: ${currentCash.toStringAsFixed(2)}'),
              Text(
                '${l10n.cashPendingInflow}: +${nextPendingInflow.toStringAsFixed(2)}',
              ),
              Text(
                '${l10n.cashPendingOutflow}: -${nextPendingOutflow.toStringAsFixed(2)}',
              ),
              Text(
                '${l10n.cashExpectedAfterCompletion}: ${expectedAfterCompletion.toStringAsFixed(2)}',
              ),
              const SizedBox(height: TradingUiSpacing.xs),
              Text('${l10n.cashAvailableCash}: ${availableCash.toStringAsFixed(2)}'),
              Text(l10n.cashBalanceUpdateAfterCompletion),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.portfolioCancel),
            ),
            FilledButton(
              key: const Key('cash_create_confirm_submit'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.cashConfirm),
            ),
          ],
        );
      },
    );
    return ok == true;
  }

  double _toDouble(String? value) => double.tryParse(value ?? '0') ?? 0;

  String _displayMovementType(String raw) {
    final l10n = AppLocalizations.of(context)!;
    switch (raw.trim().toLowerCase()) {
      case 'deposit':
        return l10n.cashTypeDeposit;
      case 'withdrawal':
        return l10n.cashTypeWithdrawal;
      case 'initial_deposit':
        return l10n.cashTypeInitialDeposit;
      case 'dividend':
        return l10n.cashTypeDividend;
      case 'fee':
        return l10n.cashTypeFee;
      case 'fee_adjustment':
        return l10n.cashTypeFeeAdjustment;
      case 'broker_fee':
        return l10n.cashTypeBrokerFee;
      case 'commission':
        return l10n.cashTypeCommission;
      case 'adjustment':
        return l10n.cashTypeAdjustment;
      default:
        return l10n.cashTypeUnknown(raw);
    }
  }

  String _displayMovementStatus(String raw) {
    final l10n = AppLocalizations.of(context)!;
    switch (raw.trim().toLowerCase()) {
      case 'pending':
        return l10n.cashStatusPending;
      case 'completed':
        return l10n.cashStatusCompleted;
      case 'failed':
        return l10n.cashStatusFailed;
      case 'cancelled':
      case 'canceled':
        return l10n.cashStatusCancelled;
      default:
        return l10n.cashStatusUnknown(raw);
    }
  }

  String _displayActivityAction(String raw) {
    final l10n = AppLocalizations.of(context)!;
    switch (raw.trim().toLowerCase()) {
      case 'cash_movement_created':
        return l10n.cashAuditActionMovementCreated;
      case 'cash_movement_completed':
        return l10n.cashAuditActionMovementCompleted;
      case 'cash_reserved':
        return l10n.cashAuditActionReserved;
      case 'cash_released':
        return l10n.cashAuditActionReleased;
      case 'cash_deducted_on_fill':
        return l10n.cashAuditActionDeductedOnFill;
      case 'broker_reconciliation_completed':
        return l10n.cashAuditActionBrokerReconciled;
      default:
        return raw;
    }
  }

  String _fmtDateTime(DateTime value) {
    final local = value.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final n = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$m-$d $h:$n';
  }

  Future<void> _onScroll() async {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.extentAfter > 480) return;
    final movementCount = _viewModel.filteredMovements.length;
    if (_visibleMovementCount < movementCount) {
      if (!mounted) return;
      setState(() {
        _visibleMovementCount =
            (_visibleMovementCount + 30).clamp(0, movementCount).toInt();
      });
      return;
    }
    await _viewModel.loadMoreMovements();
  }
}
