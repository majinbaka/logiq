import 'db_types.dart';

class AccountActivityLogModel {
  const AccountActivityLogModel({
    required this.id,
    required this.accountId,
    required this.actorId,
    required this.action,
    required this.beforeValue,
    required this.afterValue,
    required this.reason,
    required this.source,
    required this.correlationId,
    required this.createdAt,
  });

  final String id;
  final String accountId;
  final String actorId;
  final String action;
  final DbDecimal beforeValue;
  final DbDecimal afterValue;
  final String reason;
  final String source;
  final String correlationId;
  final DateTime createdAt;

  factory AccountActivityLogModel.fromMap(DbJson map) =>
      AccountActivityLogModel(
        id: map['id'] as String,
        accountId: map['account_id'] as String,
        actorId: parseString(map['actor_id']) ?? 'system',
        action: map['action'] as String,
        beforeValue: parseDecimal(map['before_value']) ?? '0',
        afterValue: parseDecimal(map['after_value']) ?? '0',
        reason: parseString(map['reason']) ?? '',
        source: parseString(map['source']) ?? 'local',
        correlationId: parseString(map['correlation_id']) ?? '',
        createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
      );

  DbJson toMap() => {
        'id': id,
        'account_id': accountId,
        'actor_id': actorId,
        'action': action,
        'before_value': beforeValue,
        'after_value': afterValue,
        'reason': reason,
        'source': source,
        'correlation_id': correlationId,
        'created_at': createdAt.toIso8601String(),
      };
}
