import 'package:flutter/material.dart';
import 'package:logiq/features/account/presentation/views/account_settings_view.dart';
import 'package:logiq/features/daily_journal/presentation/views/daily_journal_view.dart';
import 'package:logiq/features/insights/presentation/views/insights_view.dart';
import 'package:logiq/features/portfolio/presentation/views/portfolio_crud_view.dart';
import 'package:logiq/features/psychology/presentation/views/psychology_view.dart';
import 'package:logiq/features/strategy/presentation/views/strategy_risk_view.dart';
import 'package:logiq/features/trades/presentation/views/trades_crud_view.dart';
import 'package:logiq/l10n/app_localizations.dart';
import 'package:logiq/core/seed/seed_fixtures.dart';
import 'package:logiq/repositories/local/local_account_repository.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.locale,
    this.onLocaleChanged,
  });

  final Locale? locale;
  final ValueChanged<Locale>? onLocaleChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final _accountRepository = LocalAccountRepository();
  String _selectedAccountId = '';
  VoidCallback? _onTradesAdd;
  VoidCallback? _onPortfolioAdd;
  VoidCallback? _onAccountAdd;
  String get _fallbackAccountId => SeedFixtures.account().id;

  @override
  void initState() {
    super.initState();
    _loadInitialAccount();
  }

  Future<void> _loadInitialAccount() async {
    final accounts = await _accountRepository.listActive();
    if (!mounted || accounts.isEmpty) return;
    setState(() => _selectedAccountId = accounts.first.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      _ShellTab(
        label: l10n.navTrades,
        icon: Icons.candlestick_chart,
        body: TradesCrudView(
          key: ValueKey<String>('trades_$_selectedAccountId'),
          defaultAccountId: _selectedAccountId.isEmpty
              ? _fallbackAccountId
              : _selectedAccountId,
          onAddActionChanged: _bindTradesAddAction,
          onMissingAccount: () => setState(() => _currentIndex = 6),
          onMissingInitialDeposit: () => setState(() => _currentIndex = 1),
          onMissingRiskRule: () => setState(() => _currentIndex = 2),
        ),
      ),
      _ShellTab(
        label: l10n.navPortfolio,
        icon: Icons.pie_chart_outline,
        body: PortfolioCrudView(
          key: ValueKey<String>('portfolio_$_selectedAccountId'),
          defaultAccountId: _selectedAccountId.isEmpty
              ? _fallbackAccountId
              : _selectedAccountId,
          onAddActionChanged: _bindPortfolioAddAction,
        ),
      ),
      _ShellTab(
        label: l10n.navStrategy,
        icon: Icons.rule_folder_outlined,
        body: StrategyRiskView(
          key: ValueKey<String>('strategy_$_selectedAccountId'),
          defaultAccountId: _selectedAccountId.isEmpty
              ? _fallbackAccountId
              : _selectedAccountId,
        ),
      ),
      _ShellTab(
        label: l10n.navJournal,
        icon: Icons.menu_book_outlined,
        body: DailyJournalView(
          key: ValueKey<String>('journal_$_selectedAccountId'),
          accountId: _selectedAccountId.isEmpty
              ? _fallbackAccountId
              : _selectedAccountId,
        ),
      ),
      _ShellTab(
        label: l10n.navPsychology,
        icon: Icons.psychology_alt_outlined,
        body: PsychologyView(
          key: ValueKey<String>('psychology_$_selectedAccountId'),
          accountId: _selectedAccountId.isEmpty
              ? _fallbackAccountId
              : _selectedAccountId,
        ),
      ),
      _ShellTab(
        label: l10n.navInsights,
        icon: Icons.insights_outlined,
        body: InsightsView(
          key: ValueKey<String>('insights_$_selectedAccountId'),
          accountId: _selectedAccountId.isEmpty
              ? _fallbackAccountId
              : _selectedAccountId,
        ),
      ),
      _ShellTab(
        label: l10n.navAccountSettings,
        icon: Icons.manage_accounts_outlined,
        body: AccountSettingsView(
          selectedAccountId: _selectedAccountId,
          onAddActionChanged: _bindAccountAddAction,
          locale: widget.locale,
          onLocaleChanged: widget.onLocaleChanged,
          onSelectedAccountChanged: (accountId) {
            setState(() => _selectedAccountId = accountId);
          },
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_graph_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(l10n.appTitle),
          ],
        ),
        actions: [_buildHeaderAddAction(context, l10n)],
      ),
      body: tabs[_currentIndex].body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }

  Widget _buildHeaderAddAction(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final config = switch (_currentIndex) {
      0 => (tooltip: l10n.tradesAddButton, icon: Icons.add_rounded),
      1 => (tooltip: l10n.portfolioAddButton, icon: Icons.add_chart_rounded),
      6 => (
        tooltip: l10n.accountSettingsAddButton,
        icon: Icons.person_add_alt_1_rounded,
      ),
      _ => null,
    };
    if (config == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: IconButton(
          onPressed: _invokeCurrentAddAction,
          tooltip: config.tooltip,
          icon: Icon(config.icon),
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  void _bindTradesAddAction(VoidCallback? action) {
    _onTradesAdd = action;
  }

  void _bindPortfolioAddAction(VoidCallback? action) {
    _onPortfolioAdd = action;
  }

  void _bindAccountAddAction(VoidCallback? action) {
    _onAccountAdd = action;
  }

  void _invokeCurrentAddAction() {
    final callback = switch (_currentIndex) {
      0 => _onTradesAdd,
      1 => _onPortfolioAdd,
      6 => _onAccountAdd,
      _ => null,
    };
    callback?.call();
  }
}

class _ShellTab {
  const _ShellTab({
    required this.label,
    required this.icon,
    required this.body,
  });

  final String label;
  final IconData icon;
  final Widget body;
}
