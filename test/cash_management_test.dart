import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/core/database/models/account_activity_log_model.dart';
import 'package:logiq/core/database/models/cash_ledger_model.dart';
import 'package:logiq/core/database/models/cash_movement_model.dart';
import 'package:logiq/core/database/models/cash_reservation_model.dart';
import 'package:logiq/core/fund/account_balance_sync_service.dart';
import 'package:logiq/core/fund/cash_request_validator.dart';
import 'package:logiq/core/storage/storage_boxes.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/repositories/local/local_portfolio_repository.dart';

void main() {
  group('cash validation', () {
    const validator = CashRequestValidator();

    test('accepts active positive deposit with ISO currency', () {
      validator.validateDeposit(
        accountStatus: 'active',
        amount: '10000',
        currency: 'USD',
        idempotencyKey: 'dep-1',
      );
    });

    test('rejects invalid deposits', () {
      expect(
        () => validator.validateDeposit(
          accountStatus: 'inactive',
          amount: '10000',
          currency: 'USD',
        ),
        throwsA(isA<CashValidationException>()),
      );
      expect(
        () => validator.validateDeposit(
          accountStatus: 'active',
          amount: '0',
          currency: 'USD',
        ),
        throwsA(isA<CashValidationException>()),
      );
      expect(
        () => validator.validateDeposit(
          accountStatus: 'active',
          amount: '100',
          currency: 'USDT',
        ),
        throwsA(isA<CashValidationException>()),
      );
    });

    test('rejects withdrawal above available cash', () {
      expect(
        () => validator.validateWithdrawal(
          accountStatus: 'active',
          amount: '10001',
          currency: 'USD',
          availableCash: '10000',
        ),
        throwsA(isA<CashValidationException>()),
      );
    });
  });

  group('cash ledger integration', () {
    late Directory dir;
    late LocalPortfolioRepository repository;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('cash_management_test_');
      Hive.init(dir.path);
      StorageInitializer.instance.resetForTest();
      await StorageInitializer.instance.initialize();
      repository = LocalPortfolioRepository();
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      await dir.delete(recursive: true);
    });

    test('pending cash movement does not update balance', () async {
      await repository.upsertCashMovement(
        CashMovementModel(
          id: 'cm_pending',
          accountId: 'acc_1',
          movementDate: DateTime.utc(2026, 5, 6),
          movementType: 'deposit',
          amount: '10000',
          currency: 'USD',
          status: 'pending',
          idempotencyKey: 'dep-10000',
          createdBy: 'user_1',
          createdAt: DateTime.utc(2026, 5, 6),
        ),
      );

      final balance = await repository.getAccountBalance(
        'acc_1',
        currency: 'USD',
      );
      expect(balance, isNotNull);
      expect(balance!.currentCashBalance, '0');
      expect(balance.availableCash, '0');
      expect(balance.buyingPower, '0');
    });

    test('broker confirmation completes deposit and updates balance', () async {
      await repository.upsertCashMovement(
        CashMovementModel(
          id: 'cm_initial',
          accountId: 'acc_1',
          movementDate: DateTime.utc(2026, 5, 6),
          movementType: 'deposit',
          amount: '10000',
          currency: 'USD',
          status: 'pending',
          idempotencyKey: 'dep-initial',
          createdBy: 'user_1',
          createdAt: DateTime.utc(2026, 5, 6),
        ),
      );

      await repository.completeCashMovement(
        movementId: 'cm_initial',
        brokerReference: 'broker-123',
        completedAt: DateTime.utc(2026, 5, 6, 1),
      );

      final balance = await repository.getAccountBalance(
        'acc_1',
        currency: 'USD',
      );
      expect(balance!.currentCashBalance, '10000');
      expect(balance.availableCash, '10000');
      expect(balance.reservedCash, '0');
      expect(balance.buyingPower, '10000');
      final logs = Hive.box<Map>(StorageBoxes.accountActivityLogs)
          .values
          .map(
            (raw) => AccountActivityLogModel.fromMap(
              Map<String, dynamic>.from(raw),
            ),
          )
          .toList();
      expect(
        logs.map((item) => item.action),
        contains('cash_movement_completed'),
      );
    });

    test(
      'order reserve, release, and fill update reserved and available cash',
      () async {
        await repository.upsertCashMovement(
          CashMovementModel(
            id: 'cm_seed',
            accountId: 'acc_1',
            movementDate: DateTime.utc(2026, 5, 6),
            movementType: 'deposit',
            amount: '10000',
            currency: 'USD',
            createdAt: DateTime.utc(2026, 5, 6),
          ),
        );

        await repository.reserveCashForOrder(
          accountId: 'acc_1',
          currency: 'USD',
          orderId: 'ord_1',
          amount: '3000',
          at: DateTime.utc(2026, 5, 6, 2),
        );
        var balance = await repository.getAccountBalance(
          'acc_1',
          currency: 'USD',
        );
        expect(balance!.availableCash, '7000');
        expect(balance.reservedCash, '3000');

        await repository.releaseReservedCashForOrder(
          accountId: 'acc_1',
          currency: 'USD',
          orderId: 'ord_1',
          amount: '3000',
          at: DateTime.utc(2026, 5, 6, 3),
        );
        balance = await repository.getAccountBalance(
          'acc_1',
          currency: 'USD',
        );
        expect(balance!.availableCash, '10000');
        expect(balance.reservedCash, '0');

        await repository.reserveCashForOrder(
          accountId: 'acc_1',
          currency: 'USD',
          orderId: 'ord_2',
          amount: '2500',
          at: DateTime.utc(2026, 5, 6, 4),
        );
        await repository.settleReservedCashOnFill(
          accountId: 'acc_1',
          currency: 'USD',
          orderId: 'ord_2',
          executionCost: '2400',
          reservedAmount: '2500',
          at: DateTime.utc(2026, 5, 6, 5),
        );
        balance = await repository.getAccountBalance(
          'acc_1',
          currency: 'USD',
        );
        expect(balance!.currentCashBalance, '7600');
        expect(balance.availableCash, '7600');
        expect(balance.reservedCash, '0');

        final reservation = CashReservationModel.fromMap(
          Map<String, dynamic>.from(
            Hive.box<Map>(StorageBoxes.cashReservations).get('ord_2')!,
          ),
        );
        expect(reservation.status, 'filled');
      },
    );
  });

  test('balance engine applies completed ledger only', () {
    const service = AccountBalanceSyncService();
    final pending = service.applyLedger(
      current: null,
      accountId: 'acc_1',
      currency: 'USD',
      ledger: CashLedgerModel(
        id: 'ledger_pending',
        accountId: 'acc_1',
        movementType: 'deposit',
        amount: '10000',
        balanceBefore: '0',
        balanceAfter: '10000',
        status: 'pending',
        createdAt: DateTime.utc(2026, 5, 6),
      ),
    );
    expect(pending.currentCashBalance, '0');

    final completed = service.applyLedger(
      current: pending,
      accountId: 'acc_1',
      currency: 'USD',
      ledger: CashLedgerModel(
        id: 'ledger_completed',
        accountId: 'acc_1',
        movementType: 'deposit',
        amount: '10000',
        balanceBefore: '0',
        balanceAfter: '10000',
        status: 'completed',
        createdAt: DateTime.utc(2026, 5, 6, 1),
      ),
    );
    expect(completed.currentCashBalance, '10000');
    expect(completed.availableCash, '10000');
    expect(completed.reservedCash, '0');
    expect(completed.buyingPower, '10000');
  });
}
