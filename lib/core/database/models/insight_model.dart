import 'db_types.dart';

class InsightModel {
  const InsightModel({
    required this.id,
    required this.accountId,
    required this.insightType,
    required this.title,
    this.description,
    this.sourceMetric,
    this.sourceEntityType,
    this.sourceEntityId,
    this.recommendation,
    this.status,
    this.periodStart,
    this.periodEnd,
    required this.generatedAt,
    this.dismissedAt,
  });

  final String id;
  final String accountId;
  final String insightType;
  final String title;
  final String? description;
  final String? sourceMetric;
  final String? sourceEntityType;
  final String? sourceEntityId;
  final String? recommendation;
  final String? status;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime generatedAt;
  final DateTime? dismissedAt;

  factory InsightModel.fromMap(DbJson map) => InsightModel(
    id: map['id'] as String,
    accountId: map['account_id'] as String,
    insightType: map['insight_type'] as String,
    title: map['title'] as String,
    description: parseString(map['description']),
    sourceMetric: parseString(map['source_metric']),
    sourceEntityType: parseString(map['source_entity_type']),
    sourceEntityId: parseString(map['source_entity_id']),
    recommendation: parseString(map['recommendation']),
    status: parseString(map['status']),
    periodStart: parseDateTime(map['period_start']),
    periodEnd: parseDateTime(map['period_end']),
    generatedAt: parseRequiredDateTime(map['generated_at'], 'generated_at'),
    dismissedAt: parseDateTime(map['dismissed_at']),
  );

  DbJson toMap() => {
    'id': id,
    'account_id': accountId,
    'insight_type': insightType,
    'title': title,
    'description': description,
    'source_metric': sourceMetric,
    'source_entity_type': sourceEntityType,
    'source_entity_id': sourceEntityId,
    'recommendation': recommendation,
    'status': status,
    'period_start': periodStart?.toIso8601String(),
    'period_end': periodEnd?.toIso8601String(),
    'generated_at': generatedAt.toIso8601String(),
    'dismissed_at': dismissedAt?.toIso8601String(),
  };
}
