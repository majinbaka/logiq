import 'package:logiq/core/database/models/risk_rule_model.dart';
import 'package:logiq/core/database/models/strategy_model.dart';
import 'package:logiq/core/database/models/strategy_version_model.dart';
import 'package:logiq/repositories/contracts/risk_repository.dart';
import 'package:logiq/repositories/contracts/strategy_repository.dart';

class AccountMasterDataSeeder {
  AccountMasterDataSeeder({
    required RiskRepository riskRepository,
    required StrategyRepository strategyRepository,
  }) : _riskRepository = riskRepository,
       _strategyRepository = strategyRepository;

  final RiskRepository _riskRepository;
  final StrategyRepository _strategyRepository;

  Future<void> seedForNewAccount(String accountId) async {
    final now = DateTime.now().toUtc();
    await _seedRiskRuleTemplates(accountId: accountId, now: now);
    await _seedStrategyTemplates(now: now);
  }

  Future<void> _seedRiskRuleTemplates({
    required String accountId,
    required DateTime now,
  }) async {
    final existingRules = await _riskRepository.listRiskRulesByAccount(accountId);
    if (existingRules.isNotEmpty) return;

    for (final template in _riskTemplates) {
      await _riskRepository.upsertRiskRule(
        RiskRuleModel(
          id: 'risk_${template.code.toLowerCase()}_$accountId',
          accountId: accountId,
          name: template.name,
          riskPercentPerTrade: template.riskPerTrade,
          maxDailyLossAmount: template.maxDailyLoss,
          maxWeeklyLossAmount: template.maxWeeklyLoss,
          maxMonthlyLossAmount: template.maxMonthlyLoss,
          stopTradingRule: template.suitableFor,
          effectiveFrom: now,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  Future<void> _seedStrategyTemplates({required DateTime now}) async {
    final existingStrategies = await _strategyRepository.listActiveStrategies();
    final existingIds = existingStrategies.map((item) => item.id).toSet();

    for (final template in _strategyTemplates) {
      if (!existingIds.contains(template.id)) {
        await _strategyRepository.upsertStrategy(
          StrategyModel(
            id: template.id,
            name: template.name,
            description: '${template.style}. ${template.description}',
            status: 'active',
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      final versions = await _strategyRepository.listVersionsByStrategy(
        template.id,
      );
      if (versions.any((version) => version.versionNumber == 1)) continue;

      await _strategyRepository.upsertVersion(
        StrategyVersionModel(
          id: 'strv_${template.id}_v1',
          strategyId: template.id,
          versionNumber: 1,
          entryRules: template.description,
          exitRules: 'Exit by invalidation or target hit.',
          suitableMarketCondition: template.style,
          commonMistakes: 'Entering without confirmation.',
          effectiveFrom: now,
          createdAt: now,
        ),
      );
    }
  }
}

class _RiskTemplate {
  const _RiskTemplate({
    required this.code,
    required this.name,
    required this.riskPerTrade,
    required this.maxDailyLoss,
    required this.maxWeeklyLoss,
    required this.maxMonthlyLoss,
    required this.suitableFor,
  });

  final String code;
  final String name;
  final String riskPerTrade;
  final String maxDailyLoss;
  final String maxWeeklyLoss;
  final String maxMonthlyLoss;
  final String suitableFor;
}

class _StrategyTemplate {
  const _StrategyTemplate({
    required this.id,
    required this.name,
    required this.style,
    required this.description,
  });

  final String id;
  final String name;
  final String style;
  final String description;
}

const List<_RiskTemplate> _riskTemplates = [
  _RiskTemplate(
    code: 'CONSERVATIVE',
    name: 'Conservative Risk',
    riskPerTrade: '0.5',
    maxDailyLoss: '1.5',
    maxWeeklyLoss: '3',
    maxMonthlyLoss: '6',
    suitableFor: 'Nguoi moi, tai khoan lon',
  ),
  _RiskTemplate(
    code: 'STANDARD',
    name: 'Standard Risk',
    riskPerTrade: '1',
    maxDailyLoss: '3',
    maxWeeklyLoss: '6',
    maxMonthlyLoss: '10',
    suitableFor: 'Pho bien nhat',
  ),
  _RiskTemplate(
    code: 'AGGRESSIVE',
    name: 'Aggressive Risk',
    riskPerTrade: '2',
    maxDailyLoss: '5',
    maxWeeklyLoss: '10',
    maxMonthlyLoss: '15',
    suitableFor: 'Trader kinh nghiem',
  ),
  _RiskTemplate(
    code: 'PROP_STYLE',
    name: 'Prop Firm Style',
    riskPerTrade: '0.5-1',
    maxDailyLoss: '2',
    maxWeeklyLoss: '4',
    maxMonthlyLoss: '8',
    suitableFor: 'Quan tri nghiem ngat',
  ),
  _RiskTemplate(
    code: 'SMALL_ACCOUNT',
    name: 'Small Account Growth',
    riskPerTrade: '1.5',
    maxDailyLoss: '4',
    maxWeeklyLoss: '8',
    maxMonthlyLoss: '12',
    suitableFor: 'Tai khoan nho',
  ),
  _RiskTemplate(
    code: 'CAPITAL_PRESERVATION',
    name: 'Capital Preservation',
    riskPerTrade: '0.25',
    maxDailyLoss: '1',
    maxWeeklyLoss: '2',
    maxMonthlyLoss: '4',
    suitableFor: 'Uu tien giu von',
  ),
];

const List<_StrategyTemplate> _strategyTemplates = [
  _StrategyTemplate(
    id: 'strategy_breakout',
    name: 'Breakout',
    style: 'Trend-following',
    description: 'Buy when price breaks key resistance.',
  ),
  _StrategyTemplate(
    id: 'strategy_pullback',
    name: 'Pullback',
    style: 'Trend-following',
    description: 'Buy retracement within an uptrend.',
  ),
  _StrategyTemplate(
    id: 'strategy_mean_reversion',
    name: 'Mean Reversion',
    style: 'Counter-trend',
    description: 'Buy oversold moves expecting rebound.',
  ),
  _StrategyTemplate(
    id: 'strategy_momentum',
    name: 'Momentum',
    style: 'Trend-following',
    description: 'Trade symbols showing strong relative strength.',
  ),
  _StrategyTemplate(
    id: 'strategy_swing_trend',
    name: 'Swing Trend',
    style: 'Swing trading',
    description: 'Hold from a few days to weeks with trend context.',
  ),
  _StrategyTemplate(
    id: 'strategy_gap_trade',
    name: 'Gap Trading',
    style: 'Event-based',
    description: 'Trade after gap up or gap down sessions.',
  ),
  _StrategyTemplate(
    id: 'strategy_support_resistance',
    name: 'Support / Resistance',
    style: 'Price action',
    description: 'Buy support and sell resistance reactions.',
  ),
  _StrategyTemplate(
    id: 'strategy_breakdown_short',
    name: 'Breakdown Short',
    style: 'Short strategy',
    description: 'Short when support breaks with follow-through.',
  ),
  _StrategyTemplate(
    id: 'strategy_dividend_value',
    name: 'Dividend / Value',
    style: 'Investing',
    description: 'Focus on value or dividend opportunities.',
  ),
  _StrategyTemplate(
    id: 'strategy_news_catalyst',
    name: 'News Catalyst',
    style: 'Event-driven',
    description: 'Trade based on major news catalysts.',
  ),
];
