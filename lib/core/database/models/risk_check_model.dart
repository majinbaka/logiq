import 'db_types.dart';

class RiskCheckModel {
  const RiskCheckModel({
    required this.id,
    required this.tradeId,
    required this.riskRuleId,
    this.plannedRiskAmount,
    this.actualRiskAmount,
    this.maxAllowedRiskAmount,
    this.riskPerShare,
    this.plannedPositionSize,
    this.exceededRisk,
    this.followedRiskRule,
    this.violationReason,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tradeId;
  final String riskRuleId;
  final DbDecimal? plannedRiskAmount;
  final DbDecimal? actualRiskAmount;
  final DbDecimal? maxAllowedRiskAmount;
  final DbDecimal? riskPerShare;
  final DbDecimal? plannedPositionSize;
  final bool? exceededRisk;
  final bool? followedRiskRule;
  final String? violationReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory RiskCheckModel.fromMap(DbJson map) => RiskCheckModel(
    id: map['id'] as String,
    tradeId: map['trade_id'] as String,
    riskRuleId: map['risk_rule_id'] as String,
    plannedRiskAmount: parseDecimal(map['planned_risk_amount']),
    actualRiskAmount: parseDecimal(map['actual_risk_amount']),
    maxAllowedRiskAmount: parseDecimal(map['max_allowed_risk_amount']),
    riskPerShare: parseDecimal(map['risk_per_share']),
    plannedPositionSize: parseDecimal(map['planned_position_size']),
    exceededRisk: parseBool(map['exceeded_risk']),
    followedRiskRule: parseBool(map['followed_risk_rule']),
    violationReason: parseString(map['violation_reason']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
  );

  DbJson toMap() => {
    'id': id,
    'trade_id': tradeId,
    'risk_rule_id': riskRuleId,
    'planned_risk_amount': plannedRiskAmount,
    'actual_risk_amount': actualRiskAmount,
    'max_allowed_risk_amount': maxAllowedRiskAmount,
    'risk_per_share': riskPerShare,
    'planned_position_size': plannedPositionSize,
    'exceeded_risk': exceededRisk,
    'followed_risk_rule': followedRiskRule,
    'violation_reason': violationReason,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
