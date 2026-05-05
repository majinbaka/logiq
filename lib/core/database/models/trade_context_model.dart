import 'db_types.dart';

class TradeContextModel {
  const TradeContextModel({
    required this.id,
    required this.tradeId,
    this.marketCondition,
    this.trendDirection,
    this.volatilityLevel,
    this.timeframe,
    this.setupQualityScore,
    this.note,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tradeId;
  final String? marketCondition;
  final String? trendDirection;
  final String? volatilityLevel;
  final String? timeframe;
  final int? setupQualityScore;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory TradeContextModel.fromMap(DbJson map) => TradeContextModel(
    id: map['id'] as String,
    tradeId: map['trade_id'] as String,
    marketCondition: parseString(map['market_condition']),
    trendDirection: parseString(map['trend_direction']),
    volatilityLevel: parseString(map['volatility_level']),
    timeframe: parseString(map['timeframe']),
    setupQualityScore: parseInt(map['setup_quality_score']),
    note: parseString(map['note']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
  );

  DbJson toMap() => {
    'id': id,
    'trade_id': tradeId,
    'market_condition': marketCondition,
    'trend_direction': trendDirection,
    'volatility_level': volatilityLevel,
    'timeframe': timeframe,
    'setup_quality_score': setupQualityScore,
    'note': note,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
