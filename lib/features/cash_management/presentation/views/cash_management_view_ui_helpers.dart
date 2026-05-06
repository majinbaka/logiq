part of 'cash_management_view.dart';

mixin _CashManagementViewUiHelpers on State<CashManagementView> {
  CashManagementViewModel get _viewModel;
  GlobalKey<FormState> get _depositFormKey;
  GlobalKey<FormState> get _withdrawFormKey;
  TextEditingController get _depositAmountController;
  TextEditingController get _depositNoteController;
  TextEditingController get _withdrawAmountController;
  TextEditingController get _withdrawNoteController;
  CashMovementType get _depositType;
  set _depositType(CashMovementType value);
  // ignore: unused_element
  bool get _isDepositExpanded;
  set _isDepositExpanded(bool value);
  // ignore: unused_element
  bool get _isWithdrawExpanded;
  set _isWithdrawExpanded(bool value);
  // ignore: unused_element
  int get _visibleMovementCount;
  set _visibleMovementCount(int value);

  Future<void> _submitDeposit();
  Future<void> _submitWithdraw();
  String _displayMovementType(String raw);
  Widget _metricCard(String label, String value, {String? tooltip}) {
    final content = Padding(
      padding: const EdgeInsets.all(TradingUiSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: TradingUiSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
    return SizedBox(
      width: 180,
      child: Card(
        child: tooltip == null ? content : Tooltip(message: tooltip, child: content),
      ),
    );
  }

  Widget _buildDailyRiskBanner() {
    final l10n = AppLocalizations.of(context)!;
    final state = _viewModel.dailyRiskState();
    final used = _viewModel.dailyLossUsed();
    final limit = _viewModel.dailyLossLimit();
    final usagePercent = (_viewModel.dailyLossUsageRatio() * 100).clamp(0, 999);
    final colorScheme = Theme.of(context).colorScheme;
    final (bgColor, fgColor, statusLabel) = switch (state) {
      CashRiskState.ok => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        l10n.cashRiskStatusOk,
      ),
      CashRiskState.warning => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
        l10n.cashRiskStatusWarning,
      ),
      CashRiskState.breach => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        l10n.cashRiskStatusBreach,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TradingUiSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.cashDailyLossLabel}: ${used.toStringAsFixed(2)} / ${limit.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: fgColor),
          ),
          const SizedBox(height: TradingUiSpacing.xs),
          Text(
            '${l10n.cashRiskStatusLabel}: $statusLabel • ${usagePercent.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: fgColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncHealthChip() {
    final l10n = AppLocalizations.of(context)!;
    final health = _viewModel.syncHealth();
    final colorScheme = Theme.of(context).colorScheme;
    final (label, color) = switch (health) {
      CashSyncHealth.live => (l10n.cashSyncHealthLive, colorScheme.primary),
      CashSyncHealth.delayed => (l10n.cashSyncHealthDelayed, colorScheme.tertiary),
      CashSyncHealth.failed => (l10n.cashSyncHealthFailed, colorScheme.error),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ),
    );
  }

  Widget _filterChip(String label, CashMovementFilter filter) {
    return FilterChip(
      label: Text(label),
      selected: _viewModel.filter == filter,
      onSelected: (_) {
        _viewModel.setFilter(filter);
        setState(() => _visibleMovementCount = 30);
      },
    );
  }

  Widget _dateFilterChip(String label, CashMovementDateFilter filter) {
    return FilterChip(
      label: Text(label),
      selected: _viewModel.dateFilter == filter,
      onSelected: (_) {
        _viewModel.setDateFilter(filter);
        setState(() => _visibleMovementCount = 30);
      },
    );
  }

  Widget _buildDepositForm() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Form(
          key: _depositFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cashDepositTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              FormattedNumberInput(
                key: const Key('cash_deposit_amount'),
                controller: _depositAmountController,
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
              DropdownButtonFormField<CashMovementType>(
                key: const Key('cash_deposit_type'),
                initialValue: _depositType,
                decoration: InputDecoration(labelText: l10n.cashDepositType),
                items: [
                  DropdownMenuItem(
                    value: CashMovementType.initialDeposit,
                    child: Text(_displayMovementType('initial_deposit')),
                  ),
                  DropdownMenuItem(
                    value: CashMovementType.deposit,
                    child: Text(_displayMovementType('deposit')),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _depositType = value);
                },
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              TextFormField(
                key: const Key('cash_deposit_note'),
                controller: _depositNoteController,
                decoration: InputDecoration(labelText: l10n.portfolioNoteLabel),
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _viewModel.isSubmitting
                          ? null
                          : () {
                              _depositFormKey.currentState?.reset();
                              _depositAmountController.clear();
                              _depositNoteController.clear();
                              setState(() => _isDepositExpanded = false);
                            },
                      child: Text(l10n.portfolioCancel),
                    ),
                  ),
                  const SizedBox(width: TradingUiSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      key: const Key('cash_deposit_save'),
                      onPressed: _viewModel.isSubmitting ? null : _submitDeposit,
                      child: Text(l10n.portfolioSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawForm() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        child: Form(
          key: _withdrawFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                controller: _withdrawAmountController,
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
                controller: _withdrawNoteController,
                decoration: InputDecoration(labelText: l10n.portfolioNoteLabel),
              ),
              const SizedBox(height: TradingUiSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _viewModel.isSubmitting
                          ? null
                          : () {
                              _withdrawFormKey.currentState?.reset();
                              _withdrawAmountController.clear();
                              _withdrawNoteController.clear();
                              setState(() => _isWithdrawExpanded = false);
                            },
                      child: Text(l10n.portfolioCancel),
                    ),
                  ),
                  const SizedBox(width: TradingUiSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      key: const Key('cash_withdraw_save'),
                      onPressed: _viewModel.isSubmitting ? null : _submitWithdraw,
                      child: Text(l10n.portfolioSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
