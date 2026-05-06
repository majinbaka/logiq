import 'package:logiq/core/database/models/account_balance_model.dart';
import 'package:logiq/core/database/models/cash_ledger_model.dart';

class AccountBalanceSyncService {
  const AccountBalanceSyncService();

  AccountBalanceModel applyLedger({
    required AccountBalanceModel? current,
    required String accountId,
    required String currency,
    required CashLedgerModel ledger,
  }) {
    final base = current ??
        AccountBalanceModel(
          id: '${accountId}_$currency',
          accountId: accountId,
          currency: currency,
          currentCashBalance: '0',
          availableCash: '0',
          reservedCash: '0',
          buyingPower: '0',
          updatedAt: ledger.createdAt,
        );
    final status = ledger.status.trim().toLowerCase();
    if (status != 'completed') {
      return base;
    }

    final nextCurrent = _toDouble(ledger.balanceAfter);
    final nextReserved = _toDouble(base.reservedCash);
    final nextAvailable = nextCurrent - nextReserved;

    return AccountBalanceModel(
      id: base.id,
      accountId: base.accountId,
      currency: base.currency,
      currentCashBalance: _fmt(nextCurrent),
      availableCash: _fmt(nextAvailable),
      reservedCash: base.reservedCash,
      buyingPower: _fmt(nextAvailable),
      updatedAt: ledger.createdAt,
    );
  }

  double _toDouble(String? raw) => double.tryParse(raw ?? '') ?? 0;

  String _fmt(double value) {
    if (!value.isFinite) return '0';
    final normalized = value.abs() < 1e-12 ? 0.0 : value;
    return normalized.toStringAsFixed(8)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}
