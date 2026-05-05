import 'package:flutter/foundation.dart';
import 'package:trading_diary/core/database/models/instrument_model.dart';
import 'package:trading_diary/core/database/models/risk_check_model.dart';
import 'package:trading_diary/core/database/models/trade_model.dart';
import 'package:trading_diary/core/database/models/trading_account_model.dart';
import 'package:trading_diary/repositories/contracts/account_repository.dart';
import 'package:trading_diary/repositories/contracts/instrument_repository.dart';
import 'package:trading_diary/repositories/contracts/risk_repository.dart';
import 'package:trading_diary/repositories/contracts/trade_repository.dart';

class TradesCrudViewModel extends ChangeNotifier {
  TradesCrudViewModel({
    required TradeRepository repository,
    required AccountRepository accountRepository,
    required InstrumentRepository instrumentRepository,
    required RiskRepository riskRepository,
    this.defaultAccountId = 'acc_1',
  }) : _repository = repository,
       _accountRepository = accountRepository,
       _instrumentRepository = instrumentRepository,
       _riskRepository = riskRepository;

  final TradeRepository _repository;
  final AccountRepository _accountRepository;
  final InstrumentRepository _instrumentRepository;
  final RiskRepository _riskRepository;
  final String defaultAccountId;

  List<TradeModel> _trades = const [];
  Map<String, RiskCheckModel> _riskChecksByTradeId = const {};
  List<TradingAccountModel> _accounts = const [];
  List<InstrumentModel> _instruments = const [];
  bool _isLoading = false;
  String? _error;

  List<TradeModel> get trades => _trades;
  RiskCheckModel? riskCheckForTrade(String tradeId) => _riskChecksByTradeId[tradeId];
  List<TradingAccountModel> get accounts => _accounts;
  List<InstrumentModel> get instruments => _instruments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get activeAccountId {
    if (_accounts.isEmpty) return defaultAccountId;
    final matched = _accounts.any((item) => item.id == defaultAccountId);
    return matched ? defaultAccountId : _accounts.first.id;
  }

  Future<void> loadTrades() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _accounts = await _accountRepository.listActive();
      _instruments = await _instrumentRepository.listActive();

      final now = DateTime.now().toUtc();
      final start = DateTime.utc(now.year - 1, now.month, now.day);
      final fetched = await _repository.listByAccountAndDateRange(
        activeAccountId,
        start,
        now,
      );
      fetched.sort((a, b) {
        final aTime = a.openedAt ?? a.createdAt;
        final bTime = b.openedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      _trades = fetched;
      _riskChecksByTradeId = await _loadRiskChecksByTradeId();
    } catch (_) {
      _error = 'load_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTrade({
    required String accountId,
    required String instrumentId,
    required String direction,
    required DateTime openedAt,
    String? quantityOpened,
    String? avgEntryPrice,
    String? avgExitPrice,
    String? totalFee,
    String? totalTax,
    String? planNote,
    String? reviewNote,
  }) async {
    final normalizedDirection = direction.toLowerCase();
    final draft = await _repository.saveTradeDraft(
      accountId: accountId,
      instrumentId: instrumentId,
      direction: normalizedDirection,
    );

    await _repository.upsertTrade(
      TradeModel(
        id: draft.id,
        accountId: accountId,
        instrumentId: instrumentId,
        strategyVersionId: draft.strategyVersionId,
        direction: normalizedDirection,
        status: 'open',
        openedAt: openedAt.toUtc(),
        closedAt: null,
        quantityOpened: quantityOpened,
        quantityClosed: draft.quantityClosed,
        avgEntryPrice: avgEntryPrice,
        avgExitPrice: avgExitPrice,
        totalFee: totalFee,
        totalTax: totalTax,
        planNote: planNote,
        reviewNote: reviewNote,
        grossPnl: draft.grossPnl,
        netPnl: draft.netPnl,
        pnlPercent: draft.pnlPercent,
        rMultiple: draft.rMultiple,
        createdAt: draft.createdAt,
        updatedAt: DateTime.now().toUtc(),
        deletedAt: null,
      ),
    );

    await loadTrades();
  }

  Future<void> updateTrade({
    required TradeModel trade,
    required String accountId,
    required String instrumentId,
    required String direction,
    required String status,
    required DateTime openedAt,
    String? quantityOpened,
    String? avgEntryPrice,
    String? avgExitPrice,
    String? totalFee,
    String? totalTax,
    String? planNote,
    String? reviewNote,
  }) async {
    await _repository.upsertTrade(
      TradeModel(
        id: trade.id,
        accountId: accountId,
        instrumentId: instrumentId,
        strategyVersionId: trade.strategyVersionId,
        direction: direction.toLowerCase(),
        status: status.toLowerCase(),
        openedAt: openedAt.toUtc(),
        closedAt: trade.closedAt,
        quantityOpened: quantityOpened,
        quantityClosed: trade.quantityClosed,
        avgEntryPrice: avgEntryPrice,
        avgExitPrice: avgExitPrice,
        totalFee: totalFee,
        totalTax: totalTax,
        planNote: planNote,
        reviewNote: reviewNote,
        grossPnl: trade.grossPnl,
        netPnl: trade.netPnl,
        pnlPercent: trade.pnlPercent,
        rMultiple: trade.rMultiple,
        createdAt: trade.createdAt,
        updatedAt: DateTime.now().toUtc(),
        deletedAt: trade.deletedAt,
      ),
    );

    await loadTrades();
  }

  Future<void> deleteTrade(TradeModel trade) async {
    await _repository.softDeleteTrade(trade.id, DateTime.now().toUtc());
    await loadTrades();
  }

  Future<Map<String, RiskCheckModel>> _loadRiskChecksByTradeId() async {
    final checks = await _riskRepository.listRiskChecks();
    final activeTradeIds = _trades.map((item) => item.id).toSet();
    final byTrade = <String, RiskCheckModel>{};
    for (final check in checks) {
      if (!activeTradeIds.contains(check.tradeId)) continue;
      byTrade.putIfAbsent(check.tradeId, () => check);
    }
    return byTrade;
  }
}
