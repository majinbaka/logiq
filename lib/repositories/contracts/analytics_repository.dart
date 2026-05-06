abstract class AnalyticsRepository {
  Future<String?> getLatestDailyPnl(String accountId);

  Future<void> clearAnalyticsFacts(String accountId);

  Future<void> rebuildAllAnalyticsFacts(String accountId);

  Future<void> rebuildAnalyticsFacts(
    String accountId,
    DateTime start,
    DateTime end,
  );

  Future<void> rebuildTradeFacts(String accountId, Iterable<String> tradeIds);
}
