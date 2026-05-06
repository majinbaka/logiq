import 'db_types.dart';

class CashReservationModel {
  const CashReservationModel({
    required this.id,
    required this.accountId,
    required this.currency,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.reason,
    required this.createdAt,
    this.releasedAt,
  });

  final String id;
  final String accountId;
  final String currency;
  final String orderId;
  final DbDecimal amount;
  final String status;
  final String reason;
  final DateTime createdAt;
  final DateTime? releasedAt;

  factory CashReservationModel.fromMap(DbJson map) => CashReservationModel(
        id: map['id'] as String,
        accountId: map['account_id'] as String,
        currency: map['currency'] as String,
        orderId: map['order_id'] as String,
        amount: parseDecimal(map['amount']) ?? '0',
        status: parseString(map['status']) ?? 'active',
        reason: parseString(map['reason']) ?? 'order_reserve',
        createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
        releasedAt: parseDateTime(map['released_at']),
      );

  DbJson toMap() => {
        'id': id,
        'account_id': accountId,
        'currency': currency,
        'order_id': orderId,
        'amount': amount,
        'status': status,
        'reason': reason,
        'created_at': createdAt.toIso8601String(),
        'released_at': releasedAt?.toIso8601String(),
      };
}
