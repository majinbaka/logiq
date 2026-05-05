import 'db_types.dart';

class DailyJournalModel {
  const DailyJournalModel({
    required this.id,
    required this.accountId,
    required this.journalDate,
    this.marketView,
    this.tradingPlan,
    this.watchlistNote,
    this.completedActions,
    this.followedPlan,
    this.mistakes,
    this.wins,
    this.freeNote,
    this.disciplineScore,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String accountId;
  final DateTime journalDate;
  final String? marketView;
  final String? tradingPlan;
  final String? watchlistNote;
  final String? completedActions;
  final bool? followedPlan;
  final String? mistakes;
  final String? wins;
  final String? freeNote;
  final int? disciplineScore;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  factory DailyJournalModel.fromMap(DbJson map) => DailyJournalModel(
    id: map['id'] as String,
    accountId: map['account_id'] as String,
    journalDate: parseRequiredDateTime(map['journal_date'], 'journal_date'),
    marketView: parseString(map['market_view']),
    tradingPlan: parseString(map['trading_plan']),
    watchlistNote: parseString(map['watchlist_note']),
    completedActions: parseString(map['completed_actions']),
    followedPlan: parseBool(map['followed_plan']),
    mistakes: parseString(map['mistakes']),
    wins: parseString(map['wins']),
    freeNote: parseString(map['free_note']),
    disciplineScore: parseInt(map['discipline_score']),
    createdAt: parseRequiredDateTime(map['created_at'], 'created_at'),
    updatedAt: parseDateTime(map['updated_at']),
    deletedAt: parseDateTime(map['deleted_at']),
  );

  DbJson toMap() => {
    'id': id,
    'account_id': accountId,
    'journal_date': journalDate.toIso8601String(),
    'market_view': marketView,
    'trading_plan': tradingPlan,
    'watchlist_note': watchlistNote,
    'completed_actions': completedActions,
    'followed_plan': followedPlan,
    'mistakes': mistakes,
    'wins': wins,
    'free_note': freeNote,
    'discipline_score': disciplineScore,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
}
