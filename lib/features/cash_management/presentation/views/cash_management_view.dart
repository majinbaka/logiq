import 'package:flutter/material.dart';
import 'package:logiq/core/database/models/cash_movement_model.dart';
import 'package:logiq/core/widgets/formatted_number_input.dart';
import 'package:logiq/core/widgets/trading_section_header.dart';
import 'package:logiq/core/widgets/trading_state_view.dart';
import 'package:logiq/core/widgets/trading_ui_tokens.dart';
import 'package:logiq/features/cash_management/presentation/viewmodels/cash_management_viewmodel.dart';
import 'package:logiq/l10n/app_localizations.dart';
import 'package:logiq/repositories/contracts/account_repository.dart';
import 'package:logiq/repositories/contracts/portfolio_repository.dart';
import 'package:logiq/repositories/local/local_account_repository.dart';
import 'package:logiq/repositories/local/local_portfolio_repository.dart';

class CashManagementView extends StatefulWidget {
  const CashManagementView({
    super.key,
    required this.accountId,
    PortfolioRepository? repository,
    AccountRepository? accountRepository,
  }) : _repository = repository,
       _accountRepository = accountRepository;

  final String accountId;
  final PortfolioRepository? _repository;
  final AccountRepository? _accountRepository;

  @override
  State<CashManagementView> createState() => _CashManagementViewState();
}

class _CashManagementViewState extends State<CashManagementView> {
  late final CashManagementViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CashManagementViewModel(
      repository: widget._repository ?? LocalPortfolioRepository(),
      accountRepository: widget._accountRepository ?? LocalAccountRepository(),
      accountId: widget.accountId,
    );
    _viewModel.load();
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
        if (_viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_viewModel.error != null) {
          return TradingStateView(
            title: l10n.cashLoadErrorTitle,
            message: l10n.cashLoadErrorBody,
            icon: Icons.error_outline,
            actionLabel: l10n.cashRetry,
            onAction: _viewModel.load,
          );
        }

        final balance = _viewModel.balance;
        return ListView(
          padding: const EdgeInsets.all(TradingUiSpacing.md),
          children: [
            TradingSectionHeader(
              title: l10n.cashTitle,
              subtitle: l10n.cashSubtitle,
            ),
            const SizedBox(height: TradingUiSpacing.md),
            Wrap(
              spacing: TradingUiSpacing.sm,
              runSpacing: TradingUiSpacing.sm,
              children: [
                _metricCard(
                  l10n.cashCurrentCash,
                  balance?.currentCashBalance ?? '0',
                ),
                _metricCard(
                  l10n.cashAvailableCash,
                  balance?.availableCash ?? '0',
                ),
                _metricCard(
                  l10n.cashReservedCash,
                  balance?.reservedCash ?? '0',
                ),
                _metricCard(l10n.cashBuyingPower, balance?.buyingPower ?? '0'),
                _metricCard(
                  l10n.cashLeverageUsage,
                  '${_viewModel.leverageUsage().toStringAsFixed(2)}%',
                ),
                _metricCard(
                  l10n.cashUnsettledFunds,
                  _viewModel.totalUnsettledFunds().toStringAsFixed(2),
                ),
              ],
            ),
            const SizedBox(height: TradingUiSpacing.md),
            Wrap(
              spacing: TradingUiSpacing.sm,
              runSpacing: TradingUiSpacing.sm,
              children: [
                FilledButton.tonalIcon(
                  key: const Key('cash_action_deposit'),
                  onPressed: _viewModel.isSubmitting ? null : _openDepositModal,
                  icon: const Icon(Icons.south_west_rounded),
                  label: Text(l10n.cashDeposit),
                ),
                FilledButton.tonalIcon(
                  key: const Key('cash_action_withdraw'),
                  onPressed: _viewModel.isSubmitting
                      ? null
                      : _openWithdrawModal,
                  icon: const Icon(Icons.north_east_rounded),
                  label: Text(l10n.cashWithdraw),
                ),
                FilledButton.tonalIcon(
                  key: const Key('cash_action_reconcile'),
                  onPressed: _viewModel.isSubmitting ? null : _reconcileNow,
                  icon: const Icon(Icons.sync_rounded),
                  label: Text(l10n.cashReconcile),
                ),
              ],
            ),
            const SizedBox(height: TradingUiSpacing.md),
            Text(
              l10n.cashTransactionsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            Wrap(
              spacing: TradingUiSpacing.xs,
              children: [
                _filterChip(l10n.cashFilterAll, CashMovementFilter.all),
                _filterChip(l10n.cashFilterDeposit, CashMovementFilter.deposit),
                _filterChip(
                  l10n.cashFilterWithdrawal,
                  CashMovementFilter.withdrawal,
                ),
                _filterChip(l10n.cashFilterFee, CashMovementFilter.fee),
                _filterChip(
                  l10n.cashFilterDividend,
                  CashMovementFilter.dividend,
                ),
              ],
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            if (_viewModel.filteredMovements.isEmpty)
              Text(l10n.cashNoTransactions)
            else
              ..._viewModel.filteredMovements.take(30).map((movement) {
                return Card(
                  child: ListTile(
                    title: Text(
                      '${movement.movementType} • ${movement.amount} ${movement.currency}',
                    ),
                    subtitle: Text(
                      '${movement.status} • ${_fmtDateTime(movement.movementDate)}',
                    ),
                    trailing: Wrap(
                      spacing: TradingUiSpacing.xs,
                      children: [
                        if (movement.status.toLowerCase() == 'pending')
                          IconButton(
                            key: Key('cash_confirm_${movement.id}'),
                            onPressed: _viewModel.isSubmitting
                                ? null
                                : () => _confirmMovement(movement),
                            icon: const Icon(Icons.check_circle_outline),
                            tooltip: l10n.cashConfirm,
                          ),
                        IconButton(
                          onPressed: () => _openTransactionDetail(movement),
                          icon: const Icon(Icons.info_outline),
                          tooltip: l10n.cashTransactionDetail,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: TradingUiSpacing.md),
            Text(
              l10n.cashReservedDetailsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            if (_viewModel.reservations.isEmpty)
              Text(l10n.cashNoReservedCash)
            else
              ..._viewModel.reservations.take(10).map((item) {
                return Tooltip(
                  message:
                      '${l10n.cashPendingOrder}: ${item.orderId}\n${l10n.cashAmount}: ${item.amount}',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${item.orderId} • ${item.amount} ${item.currency}',
                    ),
                    subtitle: Text('${item.reason} • ${item.status}'),
                  ),
                );
              }),
            const SizedBox(height: TradingUiSpacing.md),
            Card(
              child: ListTile(
                title: Text(l10n.cashReconciliationTitle),
                subtitle: Text(
                  '${l10n.cashLastSync}: ${_viewModel.lastReconciledAt == null ? '-' : _fmtDateTime(_viewModel.lastReconciledAt!)}',
                ),
                trailing: OutlinedButton(
                  onPressed: _viewModel.isSubmitting ? null : _reconcileNow,
                  child: Text(l10n.cashSyncNow),
                ),
              ),
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            Card(
              child: ListTile(
                title: Text(l10n.cashSettlementTrackingTitle),
                subtitle: Text(
                  '${l10n.cashUnsettledFunds}: ${_viewModel.totalUnsettledFunds().toStringAsFixed(2)} • T+2',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _metricCard(String label, String value) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(TradingUiSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: TradingUiSpacing.xs),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, CashMovementFilter filter) {
    return FilterChip(
      label: Text(label),
      selected: _viewModel.filter == filter,
      onSelected: (_) => _viewModel.setFilter(filter),
    );
  }

  Future<void> _openDepositModal() async {
    final l10n = AppLocalizations.of(context)!;
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final typeController = TextEditingController(text: 'deposit');

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return Padding(
          padding: EdgeInsets.only(
            left: TradingUiSpacing.md,
            right: TradingUiSpacing.md,
            top: TradingUiSpacing.md,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + TradingUiSpacing.md,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.cashDepositTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TradingUiSpacing.sm),
                FormattedNumberInput(
                  key: const Key('cash_deposit_amount'),
                  controller: amountController,
                  label: '${l10n.cashAmount} *',
                  required: true,
                  mustBePositive: true,
                  suffixText: _viewModel.currency,
                  requiredErrorText: l10n.portfolioRequiredFieldValidationError,
                  numberErrorText: l10n.portfolioNumberValidationError,
                  positiveNumberErrorText:
                      l10n.portfolioPositiveNumberValidationError,
                  nonNegativeNumberErrorText:
                      l10n.portfolioPositiveNumberValidationError,
                ),
                const SizedBox(height: TradingUiSpacing.sm),
                TextFormField(
                  key: const Key('cash_deposit_type'),
                  controller: typeController,
                  decoration: InputDecoration(labelText: l10n.cashDepositType),
                ),
                const SizedBox(height: TradingUiSpacing.sm),
                TextFormField(
                  key: const Key('cash_deposit_note'),
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: l10n.portfolioNoteLabel,
                  ),
                ),
                const SizedBox(height: TradingUiSpacing.sm),
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
                        key: const Key('cash_deposit_save'),
                        onPressed: () {
                          if (formKey.currentState?.validate() != true) return;
                          Navigator.pop(context, true);
                        },
                        child: Text(l10n.portfolioSave),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok == true) {
      try {
        await _viewModel.createDepositPending(
          amount: FormattedNumberInput.normalizeNumberText(
            amountController.text,
          ),
          movementType: typeController.text.trim().isEmpty
              ? 'deposit'
              : typeController.text.trim(),
          note: noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim(),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.cashSubmitFailed)));
      }
    }
  }

  Future<void> _openWithdrawModal() async {
    final l10n = AppLocalizations.of(context)!;
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return Padding(
          padding: EdgeInsets.only(
            left: TradingUiSpacing.md,
            right: TradingUiSpacing.md,
            top: TradingUiSpacing.md,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + TradingUiSpacing.md,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.cashWithdrawalTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TradingUiSpacing.xs),
                Text(
                  '${l10n.cashAvailableCash}: ${_viewModel.balance?.availableCash ?? '0'} ${_viewModel.currency}',
                ),
                const SizedBox(height: TradingUiSpacing.sm),
                FormattedNumberInput(
                  key: const Key('cash_withdraw_amount'),
                  controller: amountController,
                  label: '${l10n.cashAmount} *',
                  required: true,
                  mustBePositive: true,
                  suffixText: _viewModel.currency,
                  requiredErrorText: l10n.portfolioRequiredFieldValidationError,
                  numberErrorText: l10n.portfolioNumberValidationError,
                  positiveNumberErrorText:
                      l10n.portfolioPositiveNumberValidationError,
                  nonNegativeNumberErrorText:
                      l10n.portfolioPositiveNumberValidationError,
                ),
                const SizedBox(height: TradingUiSpacing.sm),
                TextFormField(
                  key: const Key('cash_withdraw_note'),
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: l10n.portfolioNoteLabel,
                  ),
                ),
                const SizedBox(height: TradingUiSpacing.sm),
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
                        key: const Key('cash_withdraw_save'),
                        onPressed: () {
                          if (formKey.currentState?.validate() != true) return;
                          Navigator.pop(context, true);
                        },
                        child: Text(l10n.portfolioSave),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok == true) {
      try {
        await _viewModel.createWithdrawalPending(
          amount: FormattedNumberInput.normalizeNumberText(
            amountController.text,
          ),
          note: noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim(),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.cashInsufficientAvailable)));
      }
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
              Text('${l10n.cashType}: ${movement.movementType}'),
              Text(
                '${l10n.cashAmount}: ${movement.amount} ${movement.currency}',
              ),
              Text('${l10n.cashStatus}: ${movement.status}'),
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

  String _fmtDateTime(DateTime value) {
    final local = value.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final n = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$m-$d $h:$n';
  }
}
