import 'db_types.dart';

class PriceQuoteModel {
  const PriceQuoteModel({
    required this.id,
    required this.instrumentId,
    required this.quotedAt,
    required this.price,
    this.priceType,
    this.source,
    required this.createdAt,
  });

  final String id;
  final String instrumentId;
  final DateTime quotedAt;
  final DbDecimal price;
  final String? priceType;
  final String? source;
  final DateTime createdAt;

  factory PriceQuoteModel.fromMap(DbJson map) => PriceQuoteModel(
    id: map['id'] as String,
    instrumentId: map['instrument_id'] as String,
    quotedAt: parseRequiredDateTime(map['quoted_at'], 'quoted_at'),
    price: parseDecimal(map['price']) ?? '0',
    priceType: parseString(map['price_type']),
    source: parseString(map['source']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
  );

  DbJson toMap() => {
    'id': id,
    'instrument_id': instrumentId,
    'quoted_at': quotedAt.toIso8601String(),
    'price': price,
    'price_type': priceType,
    'source': source,
    'created_at': createdAt.toIso8601String(),
  };
}
