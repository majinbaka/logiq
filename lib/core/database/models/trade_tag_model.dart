import 'db_types.dart';

class TradeTagModel {
  const TradeTagModel({
    required this.id,
    required this.tradeId,
    required this.tagId,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String tradeId;
  final String tagId;
  final String? note;
  final DateTime createdAt;

  factory TradeTagModel.fromMap(DbJson map) => TradeTagModel(
    id: map['id'] as String,
    tradeId: map['trade_id'] as String,
    tagId: map['tag_id'] as String,
    note: parseString(map['note']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
  );

  DbJson toMap() => {
    'id': id,
    'trade_id': tradeId,
    'tag_id': tagId,
    'note': note,
    'created_at': createdAt.toIso8601String(),
  };
}
