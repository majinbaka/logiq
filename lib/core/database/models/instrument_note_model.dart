import 'db_types.dart';

class InstrumentNoteModel {
  const InstrumentNoteModel({
    required this.id,
    required this.instrumentId,
    this.thesis,
    this.strengths,
    this.weaknesses,
    this.risks,
    this.bullCase,
    this.bearCase,
    this.status,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String instrumentId;
  final String? thesis;
  final String? strengths;
  final String? weaknesses;
  final String? risks;
  final String? bullCase;
  final String? bearCase;
  final String? status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  factory InstrumentNoteModel.fromMap(DbJson map) => InstrumentNoteModel(
    id: map['id'] as String,
    instrumentId: map['instrument_id'] as String,
    thesis: parseString(map['thesis']),
    strengths: parseString(map['strengths']),
    weaknesses: parseString(map['weaknesses']),
    risks: parseString(map['risks']),
    bullCase: parseString(map['bull_case']),
    bearCase: parseString(map['bear_case']),
    status: parseString(map['status']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
    deletedAt: parseDateTime(map['deleted_at']),
  );

  DbJson toMap() => {
    'id': id,
    'instrument_id': instrumentId,
    'thesis': thesis,
    'strengths': strengths,
    'weaknesses': weaknesses,
    'risks': risks,
    'bull_case': bullCase,
    'bear_case': bearCase,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
}
