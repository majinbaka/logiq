import 'db_types.dart';

class PortfolioSnapshotModel {
  const PortfolioSnapshotModel({
    required this.id,
    required this.accountId,
    required this.snapshotDate,
    this.cashBalance,
    this.positionsMarketValue,
    this.totalEquity,
    this.netDepositToDate,
    this.dailyPnl,
    this.cumulativePnl,
    this.drawdownPercent,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String accountId;
  final DateTime snapshotDate;
  final DbDecimal? cashBalance;
  final DbDecimal? positionsMarketValue;
  final DbDecimal? totalEquity;
  final DbDecimal? netDepositToDate;
  final DbDecimal? dailyPnl;
  final DbDecimal? cumulativePnl;
  final DbDecimal? drawdownPercent;
  final String? note;
  final DateTime createdAt;

  factory PortfolioSnapshotModel.fromMap(DbJson map) => PortfolioSnapshotModel(
    id: map['id'] as String,
    accountId: map['account_id'] as String,
    snapshotDate: parseRequiredDateTime(map['snapshot_date'], 'snapshot_date'),
    cashBalance: parseDecimal(map['cash_balance']),
    positionsMarketValue: parseDecimal(map['positions_market_value']),
    totalEquity: parseDecimal(map['total_equity']),
    netDepositToDate: parseDecimal(map['net_deposit_to_date']),
    dailyPnl: parseDecimal(map['daily_pnl']),
    cumulativePnl: parseDecimal(map['cumulative_pnl']),
    drawdownPercent: parseDecimal(map['drawdown_percent']),
    note: parseString(map['note']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
  );

  DbJson toMap() => {
    'id': id,
    'account_id': accountId,
    'snapshot_date': snapshotDate.toIso8601String(),
    'cash_balance': cashBalance,
    'positions_market_value': positionsMarketValue,
    'total_equity': totalEquity,
    'net_deposit_to_date': netDepositToDate,
    'daily_pnl': dailyPnl,
    'cumulative_pnl': cumulativePnl,
    'drawdown_percent': drawdownPercent,
    'note': note,
    'created_at': createdAt.toIso8601String(),
  };
}
