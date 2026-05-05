import 'package:hive/hive.dart';

import 'storage_boxes.dart';

class StorageInitializer {
  StorageInitializer._internal();

  static final StorageInitializer instance = StorageInitializer._internal();
  factory StorageInitializer() => StorageInitializer._internal();

  static const int schemaVersion = 1;
  static const String _schemaVersionKey = 'version';
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    for (final boxName in StorageBoxes.all) {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<Map>(boxName);
      }
    }

    final schemaBox = Hive.isBoxOpen(StorageBoxes.schema)
        ? Hive.box(StorageBoxes.schema)
        : await Hive.openBox(StorageBoxes.schema);
    final existingVersion = _tryParseSchemaVersion(
      schemaBox.get(_schemaVersionKey),
    );
    if (existingVersion > schemaVersion) {
      throw StateError(
        'Unsupported schema version: $existingVersion > $schemaVersion',
      );
    }
    if (existingVersion < schemaVersion) {
      await _migrateSchema(
        fromVersion: existingVersion,
        toVersion: schemaVersion,
      );
    }
    await schemaBox.put(_schemaVersionKey, schemaVersion);

    _initialized = true;
  }

  void resetForTest() {
    _initialized = false;
  }

  int _tryParseSchemaVersion(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Future<void> _migrateSchema({
    required int fromVersion,
    required int toVersion,
  }) async {
    // Placeholder migration pipeline for future schema upgrades.
    for (var version = fromVersion + 1; version <= toVersion; version++) {
      switch (version) {
        case 1:
          break;
      }
    }
  }
}
