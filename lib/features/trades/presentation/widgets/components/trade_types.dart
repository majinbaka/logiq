enum TradeStatusTab { draft, open, closed, canceled, all }

enum TradePnlState { profit, loss, neutral }

class TradeKpiItemData {
  const TradeKpiItemData({required this.label, required this.value});

  final String label;
  final String value;
}

class TradeCardData {
  const TradeCardData({
    required this.symbol,
    required this.name,
    required this.status,
    required this.direction,
    required this.openDate,
    required this.closeDate,
    required this.strategyLabel,
    required this.netPnl,
    required this.rMultiple,
    required this.pnlState,
    required this.riskStatus,
  });

  final String symbol;
  final String name;
  final String status;
  final String direction;
  final String openDate;
  final String closeDate;
  final String strategyLabel;
  final String netPnl;
  final String rMultiple;
  final TradePnlState pnlState;
  final String riskStatus;
}
