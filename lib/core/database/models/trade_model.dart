import 'db_types.dart';

class TradeModel {
  const TradeModel({
    required this.id,
    required this.accountId,
    required this.instrumentId,
    this.strategyVersionId,
    required this.direction,
    required this.status,
    this.openedAt,
    this.closedAt,
    this.quantityOpened,
    this.quantityClosed,
    this.avgEntryPrice,
    this.avgExitPrice,
    this.totalFee,
    this.totalTax,
    this.grossPnl,
    this.netPnl,
    this.pnlPercent,
    this.rMultiple,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String accountId;
  final String instrumentId;
  final String? strategyVersionId;
  final String direction;
  final String status;
  final DateTime? openedAt;
  final DateTime? closedAt;
  final DbDecimal? quantityOpened;
  final DbDecimal? quantityClosed;
  final DbDecimal? avgEntryPrice;
  final DbDecimal? avgExitPrice;
  final DbDecimal? totalFee;
  final DbDecimal? totalTax;
  final DbDecimal? grossPnl;
  final DbDecimal? netPnl;
  final DbDecimal? pnlPercent;
  final DbDecimal? rMultiple;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  factory TradeModel.fromMap(DbJson map) => TradeModel(
    id: map['id'] as String,
    accountId: map['account_id'] as String,
    instrumentId: map['instrument_id'] as String,
    strategyVersionId: parseString(map['strategy_version_id']),
    direction: map['direction'] as String,
    status: map['status'] as String,
    openedAt: parseDateTime(map['opened_at']),
    closedAt: parseDateTime(map['closed_at']),
    quantityOpened: parseDecimal(map['quantity_opened']),
    quantityClosed: parseDecimal(map['quantity_closed']),
    avgEntryPrice: parseDecimal(map['avg_entry_price']),
    avgExitPrice: parseDecimal(map['avg_exit_price']),
    totalFee: parseDecimal(map['total_fee']),
    totalTax: parseDecimal(map['total_tax']),
    grossPnl: parseDecimal(map['gross_pnl']),
    netPnl: parseDecimal(map['net_pnl']),
    pnlPercent: parseDecimal(map['pnl_percent']),
    rMultiple: parseDecimal(map['r_multiple']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
    deletedAt: parseDateTime(map['deleted_at']),
  );

  DbJson toMap() => {
    'id': id,
    'account_id': accountId,
    'instrument_id': instrumentId,
    'strategy_version_id': strategyVersionId,
    'direction': direction,
    'status': status,
    'opened_at': openedAt?.toIso8601String(),
    'closed_at': closedAt?.toIso8601String(),
    'quantity_opened': quantityOpened,
    'quantity_closed': quantityClosed,
    'avg_entry_price': avgEntryPrice,
    'avg_exit_price': avgExitPrice,
    'total_fee': totalFee,
    'total_tax': totalTax,
    'gross_pnl': grossPnl,
    'net_pnl': netPnl,
    'pnl_percent': pnlPercent,
    'r_multiple': rMultiple,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
}
