import 'db_types.dart';

class TradePlanTargetModel {
  const TradePlanTargetModel({
    required this.id,
    required this.tradePlanId,
    required this.targetOrder,
    required this.targetPrice,
    this.plannedQuantityPercent,
    this.note,
  });

  final String id;
  final String tradePlanId;
  final int targetOrder;
  final DbDecimal targetPrice;
  final DbDecimal? plannedQuantityPercent;
  final String? note;

  factory TradePlanTargetModel.fromMap(DbJson map) => TradePlanTargetModel(
    id: map['id'] as String,
    tradePlanId: map['trade_plan_id'] as String,
    targetOrder: parseInt(map['target_order']) ?? 0,
    targetPrice: parseDecimal(map['target_price']) ?? '0',
    plannedQuantityPercent: parseDecimal(map['planned_quantity_percent']),
    note: parseString(map['note']),
  );

  DbJson toMap() => {
    'id': id,
    'trade_plan_id': tradePlanId,
    'target_order': targetOrder,
    'target_price': targetPrice,
    'planned_quantity_percent': plannedQuantityPercent,
    'note': note,
  };
}
