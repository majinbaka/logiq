import 'db_types.dart';

class TradePlanModel {
  const TradePlanModel({
    required this.id,
    required this.tradeId,
    this.thesis,
    this.entryZoneLow,
    this.entryZoneHigh,
    this.stopLossPrice,
    this.plannedRiskAmount,
    this.confidencePercent,
    this.invalidationNote,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tradeId;
  final String? thesis;
  final DbDecimal? entryZoneLow;
  final DbDecimal? entryZoneHigh;
  final DbDecimal? stopLossPrice;
  final DbDecimal? plannedRiskAmount;
  final int? confidencePercent;
  final String? invalidationNote;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory TradePlanModel.fromMap(DbJson map) => TradePlanModel(
    id: map['id'] as String,
    tradeId: map['trade_id'] as String,
    thesis: parseString(map['thesis']),
    entryZoneLow: parseDecimal(map['entry_zone_low']),
    entryZoneHigh: parseDecimal(map['entry_zone_high']),
    stopLossPrice: parseDecimal(map['stop_loss_price']),
    plannedRiskAmount: parseDecimal(map['planned_risk_amount']),
    confidencePercent: parseInt(map['confidence_percent']),
    invalidationNote: parseString(map['invalidation_note']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
  );

  DbJson toMap() => {
    'id': id,
    'trade_id': tradeId,
    'thesis': thesis,
    'entry_zone_low': entryZoneLow,
    'entry_zone_high': entryZoneHigh,
    'stop_loss_price': stopLossPrice,
    'planned_risk_amount': plannedRiskAmount,
    'confidence_percent': confidencePercent,
    'invalidation_note': invalidationNote,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
