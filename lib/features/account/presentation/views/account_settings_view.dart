import 'package:flutter/material.dart';
import 'package:logiq/core/seed/account_master_data_seeder.dart';
import 'package:logiq/core/database/models/trading_account_model.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/core/widgets/trading_section_header.dart';
import 'package:logiq/core/widgets/trading_state_view.dart';
import 'package:logiq/core/widgets/trading_ui_tokens.dart';
import 'package:logiq/l10n/app_localizations.dart';
import 'package:logiq/repositories/contracts/account_repository.dart';
import 'package:logiq/repositories/local/local_account_repository.dart';
import 'package:logiq/repositories/local/local_risk_repository.dart';
import 'package:logiq/repositories/local/local_strategy_repository.dart';

class AccountSettingsView extends StatefulWidget {
  const AccountSettingsView({
    super.key,
    required this.selectedAccountId,
    required this.onSelectedAccountChanged,
    this.locale,
    this.onLocaleChanged,
    AccountRepository? accountRepository,
    this.masterDataSeeder,
  }) : _accountRepository = accountRepository;

  final String selectedAccountId;
  final ValueChanged<String> onSelectedAccountChanged;
  final Locale? locale;
  final ValueChanged<Locale>? onLocaleChanged;
  final AccountRepository? _accountRepository;
  final AccountMasterDataSeeder? masterDataSeeder;

  @override
  State<AccountSettingsView> createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<AccountSettingsView> {
  late final AccountRepository _accountRepository;
  late final AccountMasterDataSeeder _masterDataSeeder;
  List<TradingAccountModel> _accounts = const [];
  bool _isLoading = false;
  bool _isResetting = false;
  String? _error;
  String? _editingId;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    _accountRepository = widget._accountRepository ?? LocalAccountRepository();
    _masterDataSeeder =
        widget.masterDataSeeder ??
        AccountMasterDataSeeder(
          riskRepository: LocalRiskRepository(),
          strategyRepository: LocalStrategyRepository(),
        );
    _loadAccounts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final accounts = await _accountRepository.listActive();
      accounts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (!mounted) return;
      setState(() => _accounts = accounts);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'load_failed');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveEditingAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final editingId = _editingId;
    if (editingId == null) return;
    if (_nameController.text.trim().isEmpty ||
        _currencyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tradesRequiredFieldValidationError)),
      );
      return;
    }

    TradingAccountModel? existing;
    for (final item in _accounts) {
      if (item.id == editingId) {
        existing = item;
        break;
      }
    }
    final now = DateTime.now().toUtc();
    final account = TradingAccountModel(
      id: existing?.id ?? 'acc_${now.microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      baseCurrency: _currencyController.text.trim().toUpperCase(),
      status: _status,
      brokerName: existing?.brokerName,
      accountType: existing?.accountType,
      createdAt: existing?.createdAt ?? now,
      updatedAt: existing == null ? null : now,
      deletedAt: existing?.deletedAt,
    );

    await _accountRepository.upsert(account);
    await _masterDataSeeder.seedForNewAccount(account.id);
    await _loadAccounts();

    if (existing == null || widget.selectedAccountId == existing.id) {
      widget.onSelectedAccountChanged(account.id);
    }
    if (!mounted) return;
    setState(() => _editingId = null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.accountSettingsSavedMessage)));
  }

  void _startCreate() {
    final now = DateTime.now().toUtc();
    setState(() {
      _editingId = 'new_${now.microsecondsSinceEpoch}';
      _nameController.text = '';
      _currencyController.text = 'VND';
      _status = 'active';
    });
  }

  void _startEdit(TradingAccountModel account) {
    setState(() {
      _editingId = account.id;
      _nameController.text = account.name;
      _currencyController.text = account.baseCurrency;
      _status = account.status ?? 'active';
    });
  }

  void _cancelEditing() {
    setState(() => _editingId = null);
  }

  Future<void> _deleteAccount(TradingAccountModel account) async {
    final now = DateTime.now().toUtc();
    await _accountRepository.upsert(
      TradingAccountModel(
        id: account.id,
        name: account.name,
        baseCurrency: account.baseCurrency,
        status: account.status,
        brokerName: account.brokerName,
        accountType: account.accountType,
        createdAt: account.createdAt,
        updatedAt: now,
        deletedAt: now,
      ),
    );
    await _loadAccounts();
    if (widget.selectedAccountId == account.id && _accounts.isNotEmpty) {
      widget.onSelectedAccountChanged(_accounts.first.id);
    }
  }

  Future<void> _resetAllData() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountSettingsResetConfirmTitle),
        content: Text(l10n.accountSettingsResetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.tradesCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.accountSettingsResetConfirmAction),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isResetting = true);
    try {
      await StorageInitializer.instance.resetAllDataToSeed();
      final activeAccounts = await _accountRepository.listActive();
      if (activeAccounts.isNotEmpty) {
        await _masterDataSeeder.seedForNewAccount(activeAccounts.first.id);
      }
      await _loadAccounts();
      if (_accounts.isNotEmpty) {
        widget.onSelectedAccountChanged(_accounts.first.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountSettingsResetSuccess)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountSettingsResetFailed)));
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(TradingUiSpacing.md),
        children: [
          TradingSectionHeader(
            title: l10n.accountSettingsTitle,
            subtitle: l10n.accountSettingsSubtitle,
          ),
          const SizedBox(height: TradingUiSpacing.md),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(l10n.accountSettingsLanguageSectionTitle),
              subtitle: Text(l10n.accountSettingsLanguageSectionSubtitle),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  value: widget.locale ?? Localizations.localeOf(context),
                  onChanged: (locale) {
                    if (locale == null) return;
                    widget.onLocaleChanged?.call(locale);
                  },
                  items: [
                    DropdownMenuItem(
                      value: const Locale('en'),
                      child: Text(l10n.accountSettingsLanguageEnglish),
                    ),
                    DropdownMenuItem(
                      value: const Locale('vi'),
                      child: Text(l10n.accountSettingsLanguageVietnamese),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: TradingUiSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _isLoading || _isResetting ? null : _resetAllData,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: _isResetting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.restart_alt_outlined),
              label: Text(l10n.accountSettingsResetButton),
            ),
          ),
          const SizedBox(height: TradingUiSpacing.md),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            TradingStateView(
              title: l10n.accountSettingsLoadErrorTitle,
              message: l10n.accountSettingsLoadErrorBody,
              icon: Icons.error_outline,
              actionLabel: l10n.accountSettingsRetry,
              onAction: _loadAccounts,
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(TradingUiSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_accounts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: TradingUiSpacing.sm),
                        child: Text(l10n.accountSettingsEmptyBody),
                      ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text(l10n.accountSettingsNameLabel)),
                          DataColumn(
                            label: Text(l10n.accountSettingsCurrencyLabel),
                          ),
                          DataColumn(label: Text(l10n.accountSettingsStatusLabel)),
                          const DataColumn(label: Text('')),
                        ],
                        rows: [
                          ..._accounts.map((account) {
                            final isEditing = _editingId == account.id;
                            return DataRow(
                              selected: account.id == widget.selectedAccountId,
                              onSelectChanged: (_) =>
                                  widget.onSelectedAccountChanged(account.id),
                              cells: _buildRowCells(
                                l10n: l10n,
                                account: account,
                                isEditing: isEditing,
                              ),
                            );
                          }),
                          if (_editingId != null &&
                              !_accounts.any((item) => item.id == _editingId))
                            DataRow(
                              cells: _buildRowCells(
                                l10n: l10n,
                                account: null,
                                isEditing: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: TradingUiSpacing.sm),
                    FilledButton.icon(
                      onPressed: _editingId != null || _isResetting
                          ? null
                          : _startCreate,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.accountSettingsAddButton),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  List<DataCell> _buildRowCells({
    required AppLocalizations l10n,
    required TradingAccountModel? account,
    required bool isEditing,
  }) {
    final statusValue = _status;
    if (isEditing) {
      return [
        DataCell(
          SizedBox(
            width: 220,
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: l10n.accountSettingsNameLabel),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 130,
            child: TextField(
              controller: _currencyController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: l10n.accountSettingsCurrencyLabel,
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 130,
            child: DropdownButton<String>(
              value: statusValue,
              isExpanded: true,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _status = value);
              },
              items: [
                DropdownMenuItem(
                  value: 'active',
                  child: Text(l10n.accountSettingsStatusActive),
                ),
                DropdownMenuItem(
                  value: 'inactive',
                  child: Text(l10n.accountSettingsStatusInactive),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: l10n.tradesSave,
                onPressed: _saveEditingAccount,
                icon: const Icon(Icons.check_rounded),
              ),
              IconButton(
                tooltip: l10n.tradesCancel,
                onPressed: _cancelEditing,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
      ];
    }

    return [
      DataCell(Text(account?.name ?? '')),
      DataCell(Text(account?.baseCurrency ?? '')),
      DataCell(
        Text(
          (account?.status ?? 'active') == 'inactive'
              ? l10n.accountSettingsStatusInactive
              : l10n.accountSettingsStatusActive,
        ),
      ),
      DataCell(
        Row(
          children: [
            IconButton(
              tooltip: l10n.accountSettingsEditTooltip,
              onPressed: _editingId == null && account != null
                  ? () => _startEdit(account)
                  : null,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: l10n.tradesDeleteTooltip,
              onPressed: _editingId == null && account != null
                  ? () => _deleteAccount(account)
                  : null,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    ];
  }
}
