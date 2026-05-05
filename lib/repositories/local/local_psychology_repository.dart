import 'package:hive/hive.dart';

import '../../core/database/models/emotion_log_model.dart';
import '../../core/database/models/tag_model.dart';
import '../../core/database/models/trade_tag_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../../core/validation/validators.dart';
import '../contracts/psychology_repository.dart';
import 'local_repository_utils.dart';

class LocalPsychologyRepository implements PsychologyRepository {
  LocalPsychologyRepository({
    Box<Map>? emotionLogBox,
    Box<Map>? tagBox,
    Box<Map>? tradeTagBox,
  }) : _emotionLogBox = emotionLogBox ?? Hive.box(StorageBoxes.emotionLogs),
       _tagBox = tagBox ?? Hive.box(StorageBoxes.tags),
       _tradeTagBox = tradeTagBox ?? Hive.box(StorageBoxes.tradeTags);

  final Box<Map> _emotionLogBox;
  final Box<Map> _tagBox;
  final Box<Map> _tradeTagBox;

  static const _supportedEmotions = <String>{
    'confident',
    'fearful',
    'fomo',
    'hesitant',
    'calm',
    'frustrated',
  };

  static const _systemBehaviorTags = <String>[
    'Entered outside plan',
    'Held losing trade too long',
    'Took profit too early',
    'Moved stop loss',
    'Overtraded',
    'No clear setup',
    'Followed plan',
  ];

  @override
  Future<List<EmotionLogModel>> listEmotionLogsByJournal(
    String journalId,
  ) async {
    return _emotionLogBox.values
        .map((value) => EmotionLogModel.fromMap(toDbJson(value)))
        .where((item) => item.journalId == journalId)
        .toList(growable: false);
  }

  @override
  Future<List<EmotionLogModel>> listEmotionLogsByTrade(String tradeId) async {
    DataValidator.requireId(tradeId, 'tradeId');
    return _emotionLogBox.values
        .map((value) => EmotionLogModel.fromMap(toDbJson(value)))
        .where((item) => item.tradeId == tradeId)
        .toList(growable: false);
  }

  @override
  Future<void> seedSystemBehaviorTags({DateTime? now}) async {
    final createdAt = (now ?? DateTime.now()).toIso8601String();
    final existingNames = _tagBox.values
        .map((value) => TagModel.fromMap(toDbJson(value)))
        .where((tag) => tag.tagType == 'behavior')
        .map((tag) => tag.name.trim().toLowerCase())
        .toSet();

    for (final name in _systemBehaviorTags) {
      final key = name.toLowerCase();
      if (existingNames.contains(key)) continue;
      final id = 'tag_behavior_$key';
      await _tagBox.put(
        id,
        TagModel(
          id: id,
          tagType: 'behavior',
          name: name,
          isSystem: true,
          createdAt: DateTime.parse(createdAt),
        ).toMap(),
      );
      existingNames.add(key);
    }
  }

  @override
  Future<List<TagModel>> listBehaviorTags() async {
    return _tagBox.values
        .map((value) => TagModel.fromMap(toDbJson(value)))
        .where((tag) => tag.tagType == 'behavior')
        .toList(growable: false);
  }

  @override
  Future<void> attachTagToTrade(TradeTagModel tradeTag) async {
    final existing = _tradeTagBox.values
        .map((value) => TradeTagModel.fromMap(toDbJson(value)))
        .any(
          (item) => item.tradeId == tradeTag.tradeId && item.tagId == tradeTag.tagId,
        );
    if (existing) return;
    await _tradeTagBox.put(tradeTag.id, tradeTag.toMap());
  }

  @override
  Future<List<TradeTagModel>> listTradeTags(String tradeId) async {
    DataValidator.requireId(tradeId, 'tradeId');
    return _tradeTagBox.values
        .map((value) => TradeTagModel.fromMap(toDbJson(value)))
        .where((item) => item.tradeId == tradeId)
        .toList(growable: false);
  }

  @override
  Future<void> removeTagFromTrade(String tradeId, String tagId) async {
    DataValidator.requireId(tradeId, 'tradeId');
    DataValidator.requireId(tagId, 'tagId');
    final keysToDelete = <dynamic>[];
    for (final key in _tradeTagBox.keys) {
      final value = _tradeTagBox.get(key);
      if (value == null) continue;
      final tag = TradeTagModel.fromMap(toDbJson(value));
      if (tag.tradeId == tradeId && tag.tagId == tagId) {
        keysToDelete.add(key);
      }
    }
    if (keysToDelete.isNotEmpty) {
      await _tradeTagBox.deleteAll(keysToDelete);
    }
  }

  @override
  Future<void> upsertEmotionLog(EmotionLogModel log) async {
    if (log.tradeId == null && log.journalId == null) {
      throw ArgumentError('Emotion log must attach to tradeId or journalId');
    }
    DataValidator.requireScoreRange(log.intensity, 'intensity');
    if (!_supportedEmotions.contains(log.emotionType.toLowerCase())) {
      throw ArgumentError.value(log.emotionType, 'emotionType', 'is not supported');
    }
    await _emotionLogBox.put(log.id, log.toMap());
  }
}
