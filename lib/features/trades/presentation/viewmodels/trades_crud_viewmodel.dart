import 'package:flutter/foundation.dart';
import 'package:trading_diary/core/database/models/trade_model.dart';
import 'package:trading_diary/repositories/contracts/trade_repository.dart';

class TradesCrudViewModel extends ChangeNotifier {
  TradesCrudViewModel({
    required TradeRepository repository,
    this.accountId = 'acc_1',
  }) : _repository = repository;

  final TradeRepository _repository;
  final String accountId;

  List<TradeModel> _trades = const [];
  bool _isLoading = false;
  String? _error;

  List<TradeModel> get trades => _trades;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTrades() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now().toUtc();
      final start = DateTime.utc(now.year - 1, now.month, now.day);
      final fetched = await _repository.listByAccountAndDateRange(
        accountId,
        start,
        now,
      );
      fetched.sort((a, b) {
        final aTime = a.openedAt ?? a.createdAt;
        final bTime = b.openedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      _trades = fetched;
    } catch (_) {
      _error = 'load_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTrade({
    required String instrumentId,
    required String direction,
    required DateTime openedAt,
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
        accountId: draft.accountId,
        instrumentId: instrumentId,
        strategyVersionId: draft.strategyVersionId,
        direction: normalizedDirection,
        status: 'open',
        openedAt: openedAt.toUtc(),
        closedAt: null,
        quantityOpened: draft.quantityOpened,
        quantityClosed: draft.quantityClosed,
        avgEntryPrice: draft.avgEntryPrice,
        avgExitPrice: draft.avgExitPrice,
        totalFee: draft.totalFee,
        totalTax: draft.totalTax,
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
    required String instrumentId,
    required String direction,
    required String status,
    required DateTime openedAt,
  }) async {
    await _repository.upsertTrade(
      TradeModel(
        id: trade.id,
        accountId: trade.accountId,
        instrumentId: instrumentId,
        strategyVersionId: trade.strategyVersionId,
        direction: direction.toLowerCase(),
        status: status.toLowerCase(),
        openedAt: openedAt.toUtc(),
        closedAt: trade.closedAt,
        quantityOpened: trade.quantityOpened,
        quantityClosed: trade.quantityClosed,
        avgEntryPrice: trade.avgEntryPrice,
        avgExitPrice: trade.avgExitPrice,
        totalFee: trade.totalFee,
        totalTax: trade.totalTax,
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
}
