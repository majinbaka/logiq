import 'db_types.dart';

class TradeFillModel {
  const TradeFillModel({
    required this.id,
    required this.tradeId,
    this.orderId,
    required this.executedAt,
    required this.price,
    required this.quantity,
    this.fee,
    this.tax,
    this.grossValue,
    this.netCashFlow,
    this.source,
    required this.createdAt,
  });

  final String id;
  final String tradeId;
  final String? orderId;
  final DateTime executedAt;
  final DbDecimal price;
  final DbDecimal quantity;
  final DbDecimal? fee;
  final DbDecimal? tax;
  final DbDecimal? grossValue;
  final DbDecimal? netCashFlow;
  final String? source;
  final DateTime createdAt;

  factory TradeFillModel.fromMap(DbJson map) => TradeFillModel(
    id: map['id'] as String,
    tradeId: map['trade_id'] as String,
    orderId: parseString(map['order_id']),
    executedAt: parseRequiredDateTime(map['executed_at'], 'executed_at'),
    price: parseDecimal(map['price']) ?? '0',
    quantity: parseDecimal(map['quantity']) ?? '0',
    fee: parseDecimal(map['fee']),
    tax: parseDecimal(map['tax']),
    grossValue: parseDecimal(map['gross_value']),
    netCashFlow: parseDecimal(map['net_cash_flow']),
    source: parseString(map['source']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
  );

  DbJson toMap() => {
    'id': id,
    'trade_id': tradeId,
    'order_id': orderId,
    'executed_at': executedAt.toIso8601String(),
    'price': price,
    'quantity': quantity,
    'fee': fee,
    'tax': tax,
    'gross_value': grossValue,
    'net_cash_flow': netCashFlow,
    'source': source,
    'created_at': createdAt.toIso8601String(),
  };
}
