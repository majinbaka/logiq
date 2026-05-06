import 'db_types.dart';

class CashMovementModel {
  const CashMovementModel({
    required this.id,
    required this.accountId,
    required this.movementDate,
    required this.movementType,
    required this.amount,
    required this.currency,
    this.note,
    this.status = 'completed',
    this.idempotencyKey,
    this.brokerReference,
    this.createdBy,
    this.settledAt,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String accountId;
  final DateTime movementDate;
  final String movementType;
  final DbDecimal amount;
  final String currency;
  final String? note;
  final String status;
  final String? idempotencyKey;
  final String? brokerReference;
  final String? createdBy;
  final DateTime? settledAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory CashMovementModel.fromMap(DbJson map) => CashMovementModel(
    id: map['id'] as String,
    accountId: map['account_id'] as String,
    movementDate: parseRequiredDateTime(map['movement_date'], 'movement_date'),
    movementType: map['movement_type'] as String,
    amount: parseDecimal(map['amount']) ?? '0',
    currency: map['currency'] as String,
    note: parseString(map['note']),
    status: parseString(map['status']) ?? 'completed',
    idempotencyKey: parseString(map['idempotency_key']),
    brokerReference: parseString(map['broker_reference']),
    createdBy: parseString(map['created_by']),
    settledAt: parseDateTime(map['settled_at']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
  );

  DbJson toMap() => {
    'id': id,
    'account_id': accountId,
    'movement_date': movementDate.toIso8601String(),
    'movement_type': movementType,
    'amount': amount,
    'currency': currency,
    'note': note,
    'status': status,
    'idempotency_key': idempotencyKey,
    'broker_reference': brokerReference,
    'created_by': createdBy,
    'settled_at': settledAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
