import '../../core/database/models/instrument_note_model.dart';
import '../../core/database/models/instrument_note_update_model.dart';
import '../../core/database/models/trade_model.dart';

abstract class InstrumentNoteRepository {
  Future<void> upsertNote(InstrumentNoteModel note);
  Future<InstrumentNoteModel?> getByInstrumentId(String instrumentId);
  Future<void> softDeleteNote(String noteId, DateTime deletedAt);
  Future<void> upsertNoteUpdate(InstrumentNoteUpdateModel update);
  Future<List<InstrumentNoteUpdateModel>> listNoteUpdates(String noteId);
  Future<List<TradeModel>> listLinkedTrades(String instrumentId);
}
