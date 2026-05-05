import 'db_types.dart';

class InstrumentModel {
  const InstrumentModel({
    required this.id,
    required this.symbol,
    this.exchange,
    this.name,
    required this.assetClass,
    required this.currency,
    this.sector,
    this.industry,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String symbol;
  final String? exchange;
  final String? name;
  final String assetClass;
  final String currency;
  final String? sector;
  final String? industry;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  factory InstrumentModel.fromMap(DbJson map) => InstrumentModel(
    id: map['id'] as String,
    symbol: map['symbol'] as String,
    exchange: parseString(map['exchange']),
    name: parseString(map['name']),
    assetClass: map['asset_class'] as String,
    currency: map['currency'] as String,
    sector: parseString(map['sector']),
    industry: parseString(map['industry']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
    deletedAt: parseDateTime(map['deleted_at']),
  );

  DbJson toMap() => {
    'id': id,
    'symbol': symbol,
    'exchange': exchange,
    'name': name,
    'asset_class': assetClass,
    'currency': currency,
    'sector': sector,
    'industry': industry,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
}
