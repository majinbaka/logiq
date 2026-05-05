import 'db_types.dart';

class RiskRuleModel {
  const RiskRuleModel({
    required this.id,
    required this.accountId,
    required this.name,
    this.riskPercentPerTrade,
    this.maxDailyLossAmount,
    this.maxWeeklyLossAmount,
    this.maxMonthlyLossAmount,
    this.stopTradingRule,
    this.effectiveFrom,
    this.effectiveTo,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String accountId;
  final String name;
  final DbDecimal? riskPercentPerTrade;
  final DbDecimal? maxDailyLossAmount;
  final DbDecimal? maxWeeklyLossAmount;
  final DbDecimal? maxMonthlyLossAmount;
  final String? stopTradingRule;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory RiskRuleModel.fromMap(DbJson map) => RiskRuleModel(
    id: map['id'] as String,
    accountId: map['account_id'] as String,
    name: map['name'] as String,
    riskPercentPerTrade: parseDecimal(map['risk_percent_per_trade']),
    maxDailyLossAmount: parseDecimal(map['max_daily_loss_amount']),
    maxWeeklyLossAmount: parseDecimal(map['max_weekly_loss_amount']),
    maxMonthlyLossAmount: parseDecimal(map['max_monthly_loss_amount']),
    stopTradingRule: parseString(map['stop_trading_rule']),
    effectiveFrom: parseDateTime(map['effective_from']),
    effectiveTo: parseDateTime(map['effective_to']),
    isActive: parseBool(map['is_active']) ?? true,
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
  );

  DbJson toMap() => {
    'id': id,
    'account_id': accountId,
    'name': name,
    'risk_percent_per_trade': riskPercentPerTrade,
    'max_daily_loss_amount': maxDailyLossAmount,
    'max_weekly_loss_amount': maxWeeklyLossAmount,
    'max_monthly_loss_amount': maxMonthlyLossAmount,
    'stop_trading_rule': stopTradingRule,
    'effective_from': effectiveFrom?.toIso8601String(),
    'effective_to': effectiveTo?.toIso8601String(),
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
