import 'db_types.dart';

class EmotionLogModel {
  const EmotionLogModel({
    required this.id,
    this.tradeId,
    this.journalId,
    this.moment,
    required this.emotionType,
    this.intensity,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String? tradeId;
  final String? journalId;
  final String? moment;
  final String emotionType;
  final int? intensity;
  final String? note;
  final DateTime createdAt;

  factory EmotionLogModel.fromMap(DbJson map) => EmotionLogModel(
    id: map['id'] as String,
    tradeId: parseString(map['trade_id']),
    journalId: parseString(map['journal_id']),
    moment: parseString(map['moment']),
    emotionType: map['emotion_type'] as String,
    intensity: parseInt(map['intensity']),
    note: parseString(map['note']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
  );

  DbJson toMap() => {
    'id': id,
    'trade_id': tradeId,
    'journal_id': journalId,
    'moment': moment,
    'emotion_type': emotionType,
    'intensity': intensity,
    'note': note,
    'created_at': createdAt.toIso8601String(),
  };
}
