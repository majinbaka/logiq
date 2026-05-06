import 'package:flutter/material.dart';
import 'package:logiq/core/database/models/cash_movement_model.dart';
import 'package:logiq/core/database/models/portfolio_input_enums.dart';
import 'package:logiq/core/fund/cash_request_validator.dart';
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
part 'cash_management_view_ui_helpers.dart';
part 'cash_management_view_actions.dart';

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

class _CashManagementViewState extends State<CashManagementView> with _CashManagementViewUiHelpers, _CashManagementViewActions {
  @override
  late final CashManagementViewModel _viewModel;
  @override
  final GlobalKey<FormState> _depositFormKey = GlobalKey<FormState>();
  @override
  final GlobalKey<FormState> _withdrawFormKey = GlobalKey<FormState>();
  @override
  late final TextEditingController _depositAmountController;
  @override
  late final TextEditingController _depositNoteController;
  @override
  late final TextEditingController _withdrawAmountController;
  @override
  late final TextEditingController _withdrawNoteController;
  @override
  CashMovementType _depositType = CashMovementType.deposit;
  @override
  bool _isDepositExpanded = false;
  @override
  bool _isWithdrawExpanded = false;
  bool _isTransactionsExpanded = false;
  bool _isAuditLogExpanded = false;
  @override
  late final ScrollController _scrollController;
  @override
  int _visibleMovementCount = 30;

  @override
  void initState() {
    super.initState();
    _depositAmountController = TextEditingController();
    _depositNoteController = TextEditingController();
    _withdrawAmountController = TextEditingController();
    _withdrawNoteController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
    _viewModel = CashManagementViewModel(
      repository: widget._repository ?? LocalPortfolioRepository(),
      accountRepository: widget._accountRepository ?? LocalAccountRepository(),
      accountId: widget.accountId,
    );
    _viewModel.load();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _depositAmountController.dispose();
    _depositNoteController.dispose();
    _withdrawAmountController.dispose();
    _withdrawNoteController.dispose();
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

        final filteredMovements = _viewModel.filteredMovements;
        final visibleMovements = filteredMovements
            .take(_visibleMovementCount)
            .toList(growable: false);
        final balance = _viewModel.balance;
        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(TradingUiSpacing.md),
          children: [
            TradingSectionHeader(
              title: l10n.cashTitle,
              subtitle: l10n.cashSubtitle,
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            _buildDailyRiskBanner(),
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
                  tooltip:
                      '${l10n.cashPendingInflow}: +${_viewModel.pendingInflow().toStringAsFixed(2)}\n'
                      '${l10n.cashPendingOutflow}: -${_viewModel.pendingOutflow().toStringAsFixed(2)}\n'
                      '${l10n.cashNetPendingCash}: ${_viewModel.netPendingCash().toStringAsFixed(2)}',
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
                  onPressed: _viewModel.isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _isDepositExpanded = !_isDepositExpanded;
                            if (_isDepositExpanded) _isWithdrawExpanded = false;
                          });
                        },
                  icon: const Icon(Icons.south_west_rounded),
                  label: Text(l10n.cashDeposit),
                ),
                FilledButton.tonalIcon(
                  key: const Key('cash_action_withdraw'),
                  onPressed: _viewModel.isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _isWithdrawExpanded = !_isWithdrawExpanded;
                            if (_isWithdrawExpanded) _isDepositExpanded = false;
                          });
                        },
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
            if (_isDepositExpanded) ...[
              const SizedBox(height: TradingUiSpacing.sm),
              _buildDepositForm(),
            ],
            if (_isWithdrawExpanded) ...[
              const SizedBox(height: TradingUiSpacing.sm),
              _buildWithdrawForm(),
            ],
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
            ExpansionTile(
              key: const Key('cash_transactions_expand'),
              title: Text(
                l10n.cashTransactionsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              initiallyExpanded: _isTransactionsExpanded,
              onExpansionChanged: (expanded) {
                setState(() => _isTransactionsExpanded = expanded);
              },
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: TradingUiSpacing.sm,
              ),
              children: [
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
                const SizedBox(height: TradingUiSpacing.xs),
                Wrap(
                  spacing: TradingUiSpacing.xs,
                  children: [
                    _dateFilterChip(
                      l10n.cashFilterTimeAll,
                      CashMovementDateFilter.all,
                    ),
                    _dateFilterChip(
                      l10n.cashFilterTime7d,
                      CashMovementDateFilter.last7Days,
                    ),
                    _dateFilterChip(
                      l10n.cashFilterTime30d,
                      CashMovementDateFilter.last30Days,
                    ),
                    _dateFilterChip(
                      l10n.cashFilterTime90d,
                      CashMovementDateFilter.last90Days,
                    ),
                  ],
                ),
                const SizedBox(height: TradingUiSpacing.sm),
                if (filteredMovements.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.cashNoTransactions),
                  )
                else
                  ...visibleMovements.map((movement) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          '${_displayMovementType(movement.movementType)} • ${movement.amount} ${movement.currency}',
                        ),
                        subtitle: Text(
                          '${_displayMovementStatus(movement.status)} • ${_fmtDateTime(movement.movementDate)}',
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
                            IconButton(
                              key: Key('cash_delete_${movement.id}'),
                              onPressed: _viewModel.isSubmitting
                                  ? null
                                  : () => _deleteMovement(movement),
                              icon: const Icon(Icons.delete_outline),
                              tooltip: l10n.tradesDeleteTooltip,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                if (visibleMovements.length < filteredMovements.length)
                  Padding(
                    padding: const EdgeInsets.only(top: TradingUiSpacing.sm),
                    child: Center(
                      child: Text(
                        l10n.cashLoadingMoreTransactions,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: TradingUiSpacing.md),
            Card(
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(child: Text(l10n.cashReconciliationTitle)),
                    _buildSyncHealthChip(),
                  ],
                ),
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
            const SizedBox(height: TradingUiSpacing.md),
            ExpansionTile(
              key: const Key('cash_audit_log_expand'),
              title: Text(
                l10n.cashAuditLogTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              initiallyExpanded: _isAuditLogExpanded,
              onExpansionChanged: (expanded) {
                setState(() => _isAuditLogExpanded = expanded);
              },
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: TradingUiSpacing.sm,
              ),
              children: [
                if (_viewModel.activityLogs.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.cashAuditLogEmpty),
                  )
                else
                  ..._viewModel.activityLogs.take(10).map((item) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(_displayActivityAction(item.action)),
                      subtitle: Text(
                        '${item.actorId} • ${_fmtDateTime(item.createdAt)}',
                      ),
                      trailing: Text('${item.beforeValue} → ${item.afterValue}'),
                    );
                  }),
              ],
            ),
          ],
        );
      },
    );
  }
}
