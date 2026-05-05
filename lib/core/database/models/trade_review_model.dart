import 'db_types.dart';

class TradeReviewModel {
  const TradeReviewModel({
    required this.id,
    required this.tradeId,
    this.exitReason,
    this.followedPlan,
    this.mistakeSummary,
    this.lesson,
    this.disciplineScore,
    this.selfReview,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tradeId;
  final String? exitReason;
  final bool? followedPlan;
  final String? mistakeSummary;
  final String? lesson;
  final int? disciplineScore;
  final String? selfReview;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory TradeReviewModel.fromMap(DbJson map) => TradeReviewModel(
    id: map['id'] as String,
    tradeId: map['trade_id'] as String,
    exitReason: parseString(map['exit_reason']),
    followedPlan: parseBool(map['followed_plan']),
    mistakeSummary: parseString(map['mistake_summary']),
    lesson: parseString(map['lesson']),
    disciplineScore: parseInt(map['discipline_score']),
    selfReview: parseString(map['self_review']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
  );

  DbJson toMap() => {
    'id': id,
    'trade_id': tradeId,
    'exit_reason': exitReason,
    'followed_plan': followedPlan,
    'mistake_summary': mistakeSummary,
    'lesson': lesson,
    'discipline_score': disciplineScore,
    'self_review': selfReview,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
