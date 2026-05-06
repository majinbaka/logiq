import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logiq/core/seed/account_master_data_seeder.dart';
import 'package:logiq/core/storage/storage_initializer.dart';
import 'package:logiq/repositories/local/local_risk_repository.dart';
import 'package:logiq/repositories/local/local_strategy_repository.dart';

void main() {
  late Directory dir;
  late LocalRiskRepository riskRepository;
  late LocalStrategyRepository strategyRepository;
  late AccountMasterDataSeeder seeder;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('account_master_seed_test_');
    Hive.init(dir.path);
    StorageInitializer.instance.resetForTest();
    await StorageInitializer.instance.initialize();

    riskRepository = LocalRiskRepository();
    strategyRepository = LocalStrategyRepository();
    seeder = AccountMasterDataSeeder(
      riskRepository: riskRepository,
      strategyRepository: strategyRepository,
    );
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('seeds risk templates for a new account and avoids duplicates', () async {
    const accountId = 'acc_seed_case';

    await seeder.seedForNewAccount(accountId);
    final firstSeed = await riskRepository.listRiskRulesByAccount(accountId);
    expect(firstSeed.length, 6);

    await seeder.seedForNewAccount(accountId);
    final secondSeed = await riskRepository.listRiskRulesByAccount(accountId);
    expect(secondSeed.length, 6);
  });

  test('ensures strategy templates exist with version 1', () async {
    await seeder.seedForNewAccount('acc_strategy_case');
    final strategies = await strategyRepository.listActiveStrategies();

    final seededStrategyIds = strategies
        .map((item) => item.id)
        .where((id) => id.startsWith('strategy_'))
        .toSet();
    expect(seededStrategyIds.length, 10);

    for (final strategyId in seededStrategyIds) {
      final versions = await strategyRepository.listVersionsByStrategy(strategyId);
      expect(versions.any((version) => version.versionNumber == 1), isTrue);
    }
  });
}
