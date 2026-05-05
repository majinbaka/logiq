import 'package:hive/hive.dart';

import '../../core/database/models/instrument_note_model.dart';
import '../../core/database/models/instrument_note_update_model.dart';
import '../../core/database/models/trade_model.dart';
import '../../core/storage/storage_boxes.dart';
import '../../core/validation/validators.dart';
import '../contracts/instrument_note_repository.dart';
import 'local_repository_utils.dart';

class LocalInstrumentNoteRepository implements InstrumentNoteRepository {
  LocalInstrumentNoteRepository({
    Box<Map>? noteBox,
    Box<Map>? updateBox,
    Box<Map>? tradeBox,
  })
    : _noteBox = noteBox ?? Hive.box(StorageBoxes.instrumentNotes),
      _updateBox = updateBox ?? Hive.box(StorageBoxes.instrumentNoteUpdates),
      _tradeBox = tradeBox ?? Hive.box(StorageBoxes.trades);

  final Box<Map> _noteBox;
  final Box<Map> _updateBox;
  final Box<Map> _tradeBox;

  @override
  Future<void> upsertNote(InstrumentNoteModel note) =>
      _noteBox.put(note.id, note.toMap());

  @override
  Future<InstrumentNoteModel?> getByInstrumentId(String instrumentId) async {
    DataValidator.requireId(instrumentId, 'instrumentId');
    final notes = readActive(_noteBox, InstrumentNoteModel.fromMap).where(
      (note) => note.instrumentId == instrumentId,
    );
    if (notes.isEmpty) return null;
    return notes.reduce(
      (latest, current) => current.createdAt.isAfter(latest.createdAt)
          ? current
          : latest,
    );
  }

  @override
  Future<void> softDeleteNote(String noteId, DateTime deletedAt) async {
    final existing = _noteBox.get(noteId);
    if (existing == null) return;
    final note = InstrumentNoteModel.fromMap(toDbJson(existing));
    await _noteBox.put(
      noteId,
      InstrumentNoteModel(
        id: note.id,
        instrumentId: note.instrumentId,
        thesis: note.thesis,
        strengths: note.strengths,
        weaknesses: note.weaknesses,
        risks: note.risks,
        bullCase: note.bullCase,
        bearCase: note.bearCase,
        status: note.status,
        createdAt: note.createdAt,
        updatedAt: DateTime.now().toUtc(),
        deletedAt: deletedAt,
      ).toMap(),
    );
  }

  @override
  Future<void> upsertNoteUpdate(InstrumentNoteUpdateModel update) =>
      _updateBox.put(update.id, update.toMap());

  @override
  Future<List<InstrumentNoteUpdateModel>> listNoteUpdates(String noteId) async {
    DataValidator.requireId(noteId, 'noteId');
    final updates = _updateBox.values
        .map((value) => InstrumentNoteUpdateModel.fromMap(toDbJson(value)))
        .where((item) => item.instrumentNoteId == noteId)
        .toList(growable: false);
    updates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return updates;
  }

  @override
  Future<List<TradeModel>> listLinkedTrades(String instrumentId) async {
    DataValidator.requireId(instrumentId, 'instrumentId');
    return readActive(_tradeBox, TradeModel.fromMap)
        .where((trade) => trade.instrumentId == instrumentId)
        .toList(growable: false);
  }
}
