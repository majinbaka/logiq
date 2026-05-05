import 'db_types.dart';

class StrategyVersionModel {
  const StrategyVersionModel({
    required this.id,
    required this.strategyId,
    required this.versionNumber,
    this.entryRules,
    this.exitRules,
    this.suitableMarketCondition,
    this.commonMistakes,
    this.effectiveFrom,
    this.effectiveTo,
    required this.createdAt,
  });

  final String id;
  final String strategyId;
  final int versionNumber;
  final String? entryRules;
  final String? exitRules;
  final String? suitableMarketCondition;
  final String? commonMistakes;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final DateTime createdAt;

  factory StrategyVersionModel.fromMap(DbJson map) => StrategyVersionModel(
    id: map['id'] as String,
    strategyId: map['strategy_id'] as String,
    versionNumber: parseInt(map['version_number']) ?? 0,
    entryRules: parseString(map['entry_rules']),
    exitRules: parseString(map['exit_rules']),
    suitableMarketCondition: parseString(map['suitable_market_condition']),
    commonMistakes: parseString(map['common_mistakes']),
    effectiveFrom: parseDateTime(map['effective_from']),
    effectiveTo: parseDateTime(map['effective_to']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
  );

  DbJson toMap() => {
    'id': id,
    'strategy_id': strategyId,
    'version_number': versionNumber,
    'entry_rules': entryRules,
    'exit_rules': exitRules,
    'suitable_market_condition': suitableMarketCondition,
    'common_mistakes': commonMistakes,
    'effective_from': effectiveFrom?.toIso8601String(),
    'effective_to': effectiveTo?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}
