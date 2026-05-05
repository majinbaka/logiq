import 'db_types.dart';

class AnalyticsDailyAccountFactModel {
  const AnalyticsDailyAccountFactModel({
    required this.id,
    required this.accountId,
    required this.metricDate,
    this.totalEquity,
    this.dailyPnl,
    this.cumulativePnl,
    this.netDeposit,
    this.drawdownPercent,
    this.tradeCount,
    this.winCount,
    this.lossCount,
    required this.generatedAt,
  });

  final String id;
  final String accountId;
  final DateTime metricDate;
  final DbDecimal? totalEquity;
  final DbDecimal? dailyPnl;
  final DbDecimal? cumulativePnl;
  final DbDecimal? netDeposit;
  final DbDecimal? drawdownPercent;
  final int? tradeCount;
  final int? winCount;
  final int? lossCount;
  final DateTime generatedAt;

  factory AnalyticsDailyAccountFactModel.fromMap(DbJson map) =>
      AnalyticsDailyAccountFactModel(
        id: map['id'] as String,
        accountId: map['account_id'] as String,
        metricDate: parseRequiredDateTime(map['metric_date'], 'metric_date'),
        totalEquity: parseDecimal(map['total_equity']),
        dailyPnl: parseDecimal(map['daily_pnl']),
        cumulativePnl: parseDecimal(map['cumulative_pnl']),
        netDeposit: parseDecimal(map['net_deposit']),
        drawdownPercent: parseDecimal(map['drawdown_percent']),
        tradeCount: parseInt(map['trade_count']),
        winCount: parseInt(map['win_count']),
        lossCount: parseInt(map['loss_count']),
        generatedAt: parseRequiredDateTime(map['generated_at'], 'generated_at'),
      );

  DbJson toMap() => {
    'id': id,
    'account_id': accountId,
    'metric_date': metricDate.toIso8601String(),
    'total_equity': totalEquity,
    'daily_pnl': dailyPnl,
    'cumulative_pnl': cumulativePnl,
    'net_deposit': netDeposit,
    'drawdown_percent': drawdownPercent,
    'trade_count': tradeCount,
    'win_count': winCount,
    'loss_count': lossCount,
    'generated_at': generatedAt.toIso8601String(),
  };
}
