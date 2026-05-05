import 'db_types.dart';

class PositionSnapshotModel {
  const PositionSnapshotModel({
    required this.id,
    required this.snapshotId,
    required this.instrumentId,
    this.quantity,
    this.averageCost,
    this.marketPrice,
    this.marketValue,
    this.unrealizedPnl,
    this.weightPercent,
  });

  final String id;
  final String snapshotId;
  final String instrumentId;
  final DbDecimal? quantity;
  final DbDecimal? averageCost;
  final DbDecimal? marketPrice;
  final DbDecimal? marketValue;
  final DbDecimal? unrealizedPnl;
  final DbDecimal? weightPercent;

  factory PositionSnapshotModel.fromMap(DbJson map) => PositionSnapshotModel(
    id: map['id'] as String,
    snapshotId: map['snapshot_id'] as String,
    instrumentId: map['instrument_id'] as String,
    quantity: parseDecimal(map['quantity']),
    averageCost: parseDecimal(map['average_cost']),
    marketPrice: parseDecimal(map['market_price']),
    marketValue: parseDecimal(map['market_value']),
    unrealizedPnl: parseDecimal(map['unrealized_pnl']),
    weightPercent: parseDecimal(map['weight_percent']),
  );

  DbJson toMap() => {
    'id': id,
    'snapshot_id': snapshotId,
    'instrument_id': instrumentId,
    'quantity': quantity,
    'average_cost': averageCost,
    'market_price': marketPrice,
    'market_value': marketValue,
    'unrealized_pnl': unrealizedPnl,
    'weight_percent': weightPercent,
  };
}
