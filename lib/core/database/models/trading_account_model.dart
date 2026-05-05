import 'db_types.dart';

class TradingAccountModel {
  const TradingAccountModel({
    required this.id,
    required this.name,
    this.brokerName,
    this.accountType,
    required this.baseCurrency,
    this.status,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final String? brokerName;
  final String? accountType;
  final String baseCurrency;
  final String? status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  factory TradingAccountModel.fromMap(DbJson map) => TradingAccountModel(
    id: map['id'] as String,
    name: map['name'] as String,
    brokerName: parseString(map['broker_name']),
    accountType: parseString(map['account_type']),
    baseCurrency: map['base_currency'] as String,
    status: parseString(map['status']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
    deletedAt: parseDateTime(map['deleted_at']),
  );

  DbJson toMap() => {
    'id': id,
    'name': name,
    'broker_name': brokerName,
    'account_type': accountType,
    'base_currency': baseCurrency,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
}
