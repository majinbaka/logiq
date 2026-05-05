import 'db_types.dart';

class AnalyticsTradeFactModel {
  const AnalyticsTradeFactModel({
    required this.id,
    required this.tradeId,
    required this.accountId,
    required this.instrumentId,
    this.strategyVersionId,
    this.openedDate,
    this.closedDate,
    required this.direction,
    this.netPnl,
    this.pnlPercent,
    this.rMultiple,
    this.totalFee,
    this.totalTax,
    this.holdingPeriodMinutes,
    this.followedPlan,
    this.disciplineScore,
    this.riskViolation,
    this.marketCondition,
    this.primaryEmotion,
    required this.generatedAt,
  });

  final String id;
  final String tradeId;
  final String accountId;
  final String instrumentId;
  final String? strategyVersionId;
  final DateTime? openedDate;
  final DateTime? closedDate;
  final String direction;
  final DbDecimal? netPnl;
  final DbDecimal? pnlPercent;
  final DbDecimal? rMultiple;
  final DbDecimal? totalFee;
  final DbDecimal? totalTax;
  final int? holdingPeriodMinutes;
  final bool? followedPlan;
  final int? disciplineScore;
  final bool? riskViolation;
  final String? marketCondition;
  final String? primaryEmotion;
  final DateTime generatedAt;

  factory AnalyticsTradeFactModel.fromMap(DbJson map) =>
      AnalyticsTradeFactModel(
        id: map['id'] as String,
        tradeId: map['trade_id'] as String,
        accountId: map['account_id'] as String,
        instrumentId: map['instrument_id'] as String,
        strategyVersionId: parseString(map['strategy_version_id']),
        openedDate: parseDateTime(map['opened_date']),
        closedDate: parseDateTime(map['closed_date']),
        direction: map['direction'] as String,
        netPnl: parseDecimal(map['net_pnl']),
        pnlPercent: parseDecimal(map['pnl_percent']),
        rMultiple: parseDecimal(map['r_multiple']),
        totalFee: parseDecimal(map['total_fee']),
        totalTax: parseDecimal(map['total_tax']),
        holdingPeriodMinutes: parseInt(map['holding_period_minutes']),
        followedPlan: parseBool(map['followed_plan']),
        disciplineScore: parseInt(map['discipline_score']),
        riskViolation: parseBool(map['risk_violation']),
        marketCondition: parseString(map['market_condition']),
        primaryEmotion: parseString(map['primary_emotion']),
        generatedAt: parseRequiredDateTime(map['generated_at'], 'generated_at'),
      );

  DbJson toMap() => {
    'id': id,
    'trade_id': tradeId,
    'account_id': accountId,
    'instrument_id': instrumentId,
    'strategy_version_id': strategyVersionId,
    'opened_date': openedDate?.toIso8601String(),
    'closed_date': closedDate?.toIso8601String(),
    'direction': direction,
    'net_pnl': netPnl,
    'pnl_percent': pnlPercent,
    'r_multiple': rMultiple,
    'total_fee': totalFee,
    'total_tax': totalTax,
    'holding_period_minutes': holdingPeriodMinutes,
    'followed_plan': followedPlan,
    'discipline_score': disciplineScore,
    'risk_violation': riskViolation,
    'market_condition': marketCondition,
    'primary_emotion': primaryEmotion,
    'generated_at': generatedAt.toIso8601String(),
  };
}
