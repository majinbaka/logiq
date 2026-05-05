import '../../core/database/models/emotion_log_model.dart';
import '../../core/database/models/tag_model.dart';
import '../../core/database/models/trade_tag_model.dart';

abstract class PsychologyRepository {
  Future<void> upsertEmotionLog(EmotionLogModel log);
  Future<void> deleteEmotionLog(String id);
  Future<List<EmotionLogModel>> listEmotionLogsByJournal(String journalId);
  Future<List<EmotionLogModel>> listEmotionLogsByTrade(String tradeId);
  Future<void> seedSystemBehaviorTags({DateTime? now});
  Future<List<TagModel>> listBehaviorTags();
  Future<void> attachTagToTrade(TradeTagModel tradeTag);
  Future<void> removeTagFromTrade(String tradeId, String tagId);
  Future<List<TradeTagModel>> listTradeTags(String tradeId);
}
