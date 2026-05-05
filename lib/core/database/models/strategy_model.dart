import 'db_types.dart';

class StrategyModel {
  const StrategyModel({
    required this.id,
    required this.name,
    this.description,
    this.status,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  factory StrategyModel.fromMap(DbJson map) => StrategyModel(
    id: map['id'] as String,
    name: map['name'] as String,
    description: parseString(map['description']),
    status: parseString(map['status']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
    deletedAt: parseDateTime(map['deleted_at']),
  );

  DbJson toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
}
