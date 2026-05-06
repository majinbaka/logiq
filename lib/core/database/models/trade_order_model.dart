import 'db_types.dart';

class TradeOrderModel {
  const TradeOrderModel({
    required this.id,
    required this.tradeId,
    required this.orderSide,
    required this.orderType,
    this.intent,
    this.plannedPrice,
    this.stopPrice,
    this.limitPrice,
    this.quantity,
    required this.status,
    this.placedAt,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String tradeId;
  final String orderSide;
  final String orderType;
  final String? intent;
  final DbDecimal? plannedPrice;
  final DbDecimal? stopPrice;
  final DbDecimal? limitPrice;
  final DbDecimal? quantity;
  final String status;
  final DateTime? placedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  factory TradeOrderModel.fromMap(DbJson map) => TradeOrderModel(
    id: map['id'] as String,
    tradeId: map['trade_id'] as String,
    orderSide: map['order_side'] as String,
    orderType: map['order_type'] as String,
    intent: parseString(map['intent']),
    plannedPrice: parseDecimal(map['planned_price']),
    stopPrice: parseDecimal(map['stop_price']),
    limitPrice: parseDecimal(map['limit_price']),
    quantity: parseDecimal(map['quantity']),
    status: map['status'] as String,
    placedAt: parseDateTime(map['placed_at']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
    deletedAt: parseDateTime(map['deleted_at']),
  );

  DbJson toMap() => {
    'id': id,
    'trade_id': tradeId,
    'order_side': orderSide,
    'order_type': orderType,
    'intent': intent,
    'planned_price': plannedPrice,
    'stop_price': stopPrice,
    'limit_price': limitPrice,
    'quantity': quantity,
    'status': status,
    'placed_at': placedAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
}
