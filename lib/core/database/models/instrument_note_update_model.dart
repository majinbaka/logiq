import 'db_types.dart';

class InstrumentNoteUpdateModel {
  const InstrumentNoteUpdateModel({
    required this.id,
    required this.instrumentNoteId,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String instrumentNoteId;
  final String content;
  final DateTime createdAt;

  factory InstrumentNoteUpdateModel.fromMap(DbJson map) =>
      InstrumentNoteUpdateModel(
        id: map['id'] as String,
        instrumentNoteId: map['instrument_note_id'] as String,
        content: map['content'] as String,
        createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
      );

  DbJson toMap() => {
    'id': id,
    'instrument_note_id': instrumentNoteId,
    'content': content,
    'created_at': createdAt.toIso8601String(),
  };
}
