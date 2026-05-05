import 'package:flutter/foundation.dart';
import 'package:trading_diary/core/database/models/cash_movement_model.dart';
import 'package:trading_diary/core/database/models/position_snapshot_model.dart';
import 'package:trading_diary/core/database/models/portfolio_snapshot_model.dart';
import 'package:trading_diary/core/database/models/price_quote_model.dart';
import 'package:trading_diary/repositories/contracts/portfolio_repository.dart';

class PortfolioCrudViewModel extends ChangeNotifier {
  PortfolioCrudViewModel({
    required PortfolioRepository repository,
    this.accountId = 'acc_1',
  }) : _repository = repository;

  final PortfolioRepository _repository;
  final String accountId;

  List<PortfolioSnapshotModel> _snapshots = const [];
  List<PortfolioHolding> _holdings = const [];
  List<PositionSnapshotModel> _snapshotPositions = const [];
  PortfolioSnapshotModel? _selectedSnapshot;
  bool _isLoading = false;
  String? _error;

  List<PortfolioSnapshotModel> get snapshots => _snapshots;
  List<PortfolioHolding> get holdings => _holdings;
  List<PositionSnapshotModel> get snapshotPositions => _snapshotPositions;
  PortfolioSnapshotModel? get selectedSnapshot => _selectedSnapshot;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSnapshots() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now().toUtc();
      final start = DateTime.utc(now.year - 1, now.month, now.day);
      final fetched = await _repository.listPortfolioSnapshots(
        accountId,
        start,
        now,
      );
      final builtHoldings = await _repository.buildHoldings(accountId, now);
      fetched.sort((a, b) => b.snapshotDate.compareTo(a.snapshotDate));
      _snapshots = fetched;
      _holdings = builtHoldings;
      if (_selectedSnapshot != null) {
        final refreshed = fetched.where((item) => item.id == _selectedSnapshot!.id);
        if (refreshed.isEmpty) {
          _selectedSnapshot = null;
          _snapshotPositions = const [];
        } else {
          _selectedSnapshot = refreshed.first;
          _snapshotPositions = await _repository.listPositionSnapshots(
            refreshed.first.id,
          );
        }
      }
    } catch (_) {
      _error = 'load_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSnapshot({
    required DateTime snapshotDate,
    String? note,
  }) async {
    await _repository.generateSnapshot(
      accountId: accountId,
      snapshotDate: snapshotDate.toUtc(),
      note: note,
    );
    await loadSnapshots();
  }

  Future<void> updateSnapshot({
    required PortfolioSnapshotModel snapshot,
    required String note,
  }) async {
    await _repository.upsertSnapshot(
      PortfolioSnapshotModel(
        id: snapshot.id,
        accountId: snapshot.accountId,
        snapshotDate: snapshot.snapshotDate,
        cashBalance: snapshot.cashBalance,
        positionsMarketValue: snapshot.positionsMarketValue,
        totalEquity: snapshot.totalEquity,
        netDepositToDate: snapshot.netDepositToDate,
        dailyPnl: snapshot.dailyPnl,
        cumulativePnl: snapshot.cumulativePnl,
        drawdownPercent: snapshot.drawdownPercent,
        note: note,
        createdAt: snapshot.createdAt,
      ),
    );
    await loadSnapshots();
  }

  Future<void> deleteSnapshot(PortfolioSnapshotModel snapshot) async {
    await _repository.deleteSnapshot(snapshot.id);
    await loadSnapshots();
  }

  Future<void> loadSnapshotDetail(PortfolioSnapshotModel snapshot) async {
    _selectedSnapshot = snapshot;
    _snapshotPositions = await _repository.listPositionSnapshots(snapshot.id);
    notifyListeners();
  }

  Future<void> clearSnapshotDetail() async {
    _selectedSnapshot = null;
    _snapshotPositions = const [];
    notifyListeners();
  }

  Future<void> addOrUpdateQuote({
    required String instrumentId,
    required DateTime quotedAt,
    required String price,
  }) async {
    final normalizedInstrumentId = instrumentId.trim();
    final normalizedPrice = price.trim();
    await _repository.upsertPriceQuote(
      PriceQuoteModel(
        id: 'quote_${normalizedInstrumentId}_${quotedAt.toUtc().toIso8601String()}',
        instrumentId: normalizedInstrumentId,
        quotedAt: quotedAt.toUtc(),
        price: normalizedPrice,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    await loadSnapshots();
  }

  Future<void> addOrUpdateCashMovement({
    required DateTime movementDate,
    required String movementType,
    required String amount,
    String? note,
  }) async {
    await _repository.upsertCashMovement(
      CashMovementModel(
        id: 'cash_${movementType}_${movementDate.toUtc().toIso8601String()}',
        accountId: accountId,
        movementDate: movementDate.toUtc(),
        movementType: movementType,
        amount: amount.trim(),
        currency: 'USD',
        note: note?.trim().isEmpty == true ? null : note?.trim(),
        createdAt: DateTime.now().toUtc(),
      ),
    );
    await loadSnapshots();
  }
}
